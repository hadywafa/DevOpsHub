#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

NAMESPACE="${NAMESPACE:-kafka-lab}"
KAFKA_NAME="${KAFKA_NAME:-lab-kafka}"
STRIMZI_RELEASE="${STRIMZI_RELEASE:-strimzi-cluster-operator}"
STRIMZI_VERSION="${STRIMZI_VERSION:-1.1.0}"
TIMEOUT="${TIMEOUT:-20m}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || fail "kubectl is required."
command -v helm >/dev/null 2>&1 || fail "Helm 3 is required."
command -v curl >/dev/null 2>&1 || fail "curl is required."

kubectl cluster-info >/dev/null 2>&1 || fail "kubectl cannot reach Kubernetes."
helm version >/dev/null 2>&1 || fail "Helm is not working."

kubectl get ingressclass traefik >/dev/null 2>&1 || {
  fail "Traefik IngressClass was not found. K3s must be running with its default Traefik ingress controller."
}

DEFAULT_STORAGE_CLASS="$(
  kubectl get storageclass \
    -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}' |
    awk 'NF {print; exit}'
)"

[[ -n "$DEFAULT_STORAGE_CLASS" ]] || fail "No default StorageClass was found."

kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f - >/dev/null

kafka_exists=false
existing_cluster_id=""
if kubectl get crd kafkas.kafka.strimzi.io >/dev/null 2>&1 \
   && kubectl get kafka "$KAFKA_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
  kafka_exists=true
  existing_cluster_id="$(
    kubectl get kafka "$KAFKA_NAME" -n "$NAMESPACE" \
      -o jsonpath='{.status.clusterId}' 2>/dev/null || true
  )"
fi

existing_pvcs="$(
  kubectl get pvc -n "$NAMESPACE" \
    -l "strimzi.io/cluster=${KAFKA_NAME}" \
    -o name 2>/dev/null || true
)"

if [[ -n "$existing_pvcs" && "$kafka_exists" != true ]]; then
  cat >&2 <<EOF
ERROR: Kafka PVCs exist but Kafka/$KAFKA_NAME does not.
Refusing to create a new KRaft identity on disks from another cluster.

Use one of these recovery paths:
  1. Restore the original Kafka and KafkaNodePool resources, or
  2. ./uninstall.sh --purge-data
EOF
  exit 1
fi

NODE_IP="${NODE_IP:-$(
  kubectl get nodes \
    -o jsonpath='{range .items[*]}{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}{end}' |
    awk 'NF {print; exit}'
)}"
[[ -n "$NODE_IP" ]] || fail "Could not detect the Multipass/K3s node IP."

BASE_DOMAIN="${BASE_DOMAIN:-kafka.${NODE_IP}.nip.io}"

printf '%-24s %s\n' "Namespace:" "$NAMESPACE"
printf '%-24s %s\n' "Mode:" "$([[ "$kafka_exists" == true ]] && echo resume || echo fresh)"
printf '%-24s %s\n' "K3s node IP:" "$NODE_IP"
printf '%-24s %s\n' "Base domain:" "$BASE_DOMAIN"
printf '%-24s %s\n' "StorageClass:" "$DEFAULT_STORAGE_CLASS"
printf '%-24s %s\n' "Strimzi:" "$STRIMZI_VERSION"

echo
echo "Installing or reconciling Strimzi..."
helm upgrade --install "$STRIMZI_RELEASE" \
  oci://quay.io/strimzi-helm/strimzi-kafka-operator \
  --version "$STRIMZI_VERSION" \
  --namespace "$NAMESPACE" \
  --set watchAnyNamespace=false \
  --wait \
  --timeout "$TIMEOUT"

echo
echo "Creating or reconciling Kafka..."
kubectl apply -n "$NAMESPACE" -f manifests/10-kafka.yaml
kubectl wait -n "$NAMESPACE" kafka/"$KAFKA_NAME" \
  --for=condition=Ready --timeout="$TIMEOUT"

current_cluster_id="$(
  kubectl get kafka "$KAFKA_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.status.clusterId}'
)"

if [[ -n "$existing_cluster_id" && "$existing_cluster_id" != "$current_cluster_id" ]]; then
  fail "Kafka cluster ID changed from $existing_cluster_id to $current_cluster_id."
fi

echo "Kafka cluster ID: $current_cluster_id"

echo
echo "Creating or reconciling topics..."
kubectl apply -n "$NAMESPACE" -f manifests/20-topics.yaml
kubectl wait -n "$NAMESPACE" kafkatopic/lab-events \
  --for=condition=Ready --timeout=5m
kubectl wait -n "$NAMESPACE" kafkatopic/orders \
  --for=condition=Ready --timeout=5m

echo
echo "Deploying Schema Registry..."
kubectl apply -n "$NAMESPACE" -f manifests/30-schema-registry.yaml
kubectl rollout status -n "$NAMESPACE" deployment/schema-registry --timeout="$TIMEOUT"

echo
echo "Deploying REST Proxy..."
kubectl apply -n "$NAMESPACE" -f manifests/40-rest-proxy.yaml
kubectl rollout status -n "$NAMESPACE" deployment/kafka-rest-proxy --timeout="$TIMEOUT"

echo
echo "Deploying Kafbat UI..."
kubectl apply -n "$NAMESPACE" -f manifests/50-kafbat-ui.yaml
kubectl rollout status -n "$NAMESPACE" deployment/kafbat-ui --timeout="$TIMEOUT"

echo
echo "Rendering and applying the Traefik ingress..."
NODE_IP="$NODE_IP" BASE_DOMAIN="$BASE_DOMAIN" \
  ./scripts/render-ingress.sh >/dev/null
kubectl apply -n "$NAMESPACE" -f .generated/60-ingress.yaml

for _ in $(seq 1 60); do
  if curl -fsS "http://registry.${BASE_DOMAIN}/subjects" >/dev/null 2>&1 \
     && curl -fsS "http://rest.${BASE_DOMAIN}/brokers" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo
kubectl get pods,ingress -n "$NAMESPACE"

echo
cat <<EOF
Kafka lab is ready.

HTTP endpoints through the K3s Traefik ingress gateway:
  Kafbat UI:       http://ui.${BASE_DOMAIN}
  Schema Registry: http://registry.${BASE_DOMAIN}
  REST Proxy:      http://rest.${BASE_DOMAIN}

Kafka is intentionally internal-only:
  lab-kafka-kafka-bootstrap.${NAMESPACE}.svc.cluster.local:9092

Open an ephemeral Kafka CLI pod:
  ./scripts/kafka-shell.sh

Run the Avro end-to-end test through ingress:
  ./scripts/test.sh

Stop and preserve all Kafka data:
  ./uninstall.sh

Delete the lab and all data:
  ./uninstall.sh --purge-data
EOF
