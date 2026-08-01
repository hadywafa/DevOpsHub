#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

NAMESPACE="${NAMESPACE:-kafka-lab}"
KAFKA_NAME="${KAFKA_NAME:-lab-kafka}"
STRIMZI_RELEASE="${STRIMZI_RELEASE:-strimzi-cluster-operator}"
STRIMZI_VERSION="${STRIMZI_VERSION:-1.1.0}"
ENVOY_GATEWAY_RELEASE="${ENVOY_GATEWAY_RELEASE:-envoy-gateway}"
ENVOY_GATEWAY_VERSION="${ENVOY_GATEWAY_VERSION:-v1.8.3}"
METALLB_RELEASE="${METALLB_RELEASE:-metallb}"
METALLB_CHART_VERSION="${METALLB_CHART_VERSION:-0.16.1}"
TIMEOUT="${TIMEOUT:-20m}"
CONFIGURE_HOSTS="${CONFIGURE_HOSTS:-true}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

for command_name in kubectl helm curl awk sed grep; do
  command -v "$command_name" >/dev/null 2>&1 || \
    fail "$command_name is required."
done

kubectl cluster-info >/dev/null 2>&1 || fail "kubectl cannot reach Kubernetes."
helm version >/dev/null 2>&1 || fail "Helm is not working."

KUBERNETES_MINOR="$(
  kubectl version -o json |
    sed -n 's/.*"minor"[[:space:]]*:[[:space:]]*"\([0-9][0-9]*\).*/\1/p' |
    tail -n 1
)"
[[ -n "$KUBERNETES_MINOR" ]] || fail "Could not detect the Kubernetes server version."
(( KUBERNETES_MINOR >= 32 )) ||   fail "Envoy Gateway $ENVOY_GATEWAY_VERSION requires Kubernetes 1.32 or newer. Upgrade K3s first."

# Clean ownership boundary: K3s packaged Traefik and ServiceLB must not coexist
# with this lab's Envoy Gateway and MetalLB north-south stack.
if kubectl get deployment traefik -n kube-system >/dev/null 2>&1; then
  fail "K3s Traefik is still installed. Run ./prepare-k3s.sh first."
fi

if kubectl get daemonset -n kube-system -o name 2>/dev/null | grep -q '/svclb-'; then
  fail "K3s ServiceLB is still active. Run ./prepare-k3s.sh first."
fi

DEFAULT_STORAGE_CLASS="$(
  kubectl get storageclass \
    -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}' |
    awk 'NF {print; exit}'
)"
[[ -n "$DEFAULT_STORAGE_CLASS" ]] || fail "No default StorageClass was found."

NODE_IP="${NODE_IP:-$(
  kubectl get nodes \
    -o jsonpath='{range .items[*]}{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}{end}' |
    awk 'NF {print; exit}'
)}"
[[ -n "$NODE_IP" ]] || fail "Could not detect the K3s node InternalIP."

if [[ -f .lab.env ]]; then
  # shellcheck disable=SC1091
  source .lab.env
fi

NAMESPACE="${NAMESPACE:-kafka-lab}"
KAFKA_NAME="${KAFKA_NAME:-lab-kafka}"
BASE_DOMAIN="${BASE_DOMAIN:-kafka.test}"

if [[ -z "${LOAD_BALANCER_IP:-}" ]]; then
  if [[ "$NODE_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    prefix="${NODE_IP%.*}"
    LOAD_BALANCER_IP="${prefix}.240"
    [[ "$LOAD_BALANCER_IP" != "$NODE_IP" ]] || LOAD_BALANCER_IP="${prefix}.241"
  else
    fail "Set LOAD_BALANCER_IP in .lab.env; automatic selection supports IPv4 only."
  fi
fi

cat > .lab.env <<EOF_ENV
NAMESPACE=$NAMESPACE
KAFKA_NAME=$KAFKA_NAME
NODE_IP=$NODE_IP
LOAD_BALANCER_IP=$LOAD_BALANCER_IP
BASE_DOMAIN=$BASE_DOMAIN
STRIMZI_VERSION=$STRIMZI_VERSION
ENVOY_GATEWAY_VERSION=$ENVOY_GATEWAY_VERSION
METALLB_CHART_VERSION=$METALLB_CHART_VERSION
CONFIGURE_HOSTS=$CONFIGURE_HOSTS
EOF_ENV

export NAMESPACE LOAD_BALANCER_IP BASE_DOMAIN
./scripts/render.sh

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
  cat >&2 <<EOF_ERROR
ERROR: Kafka PVCs exist but Kafka/$KAFKA_NAME does not.
Refusing to create a new KRaft identity on disks from another cluster.

Restore the original Kafka resources or run:
  ./uninstall.sh --purge-data
EOF_ERROR
  exit 1
fi

printf '%-26s %s\n' "Namespace:" "$NAMESPACE"
printf '%-26s %s\n' "Mode:" "$([[ "$kafka_exists" == true ]] && echo resume || echo fresh)"
printf '%-26s %s\n' "K3s node IP:" "$NODE_IP"
printf '%-26s %s\n' "Gateway VIP:" "$LOAD_BALANCER_IP"
printf '%-26s %s\n' "Base domain:" "$BASE_DOMAIN"
printf '%-26s %s\n' "StorageClass:" "$DEFAULT_STORAGE_CLASS"
printf '%-26s %s\n' "Envoy Gateway:" "$ENVOY_GATEWAY_VERSION"
printf '%-26s %s\n' "MetalLB chart:" "$METALLB_CHART_VERSION"
printf '%-26s %s\n' "Strimzi:" "$STRIMZI_VERSION"

echo
echo "Installing MetalLB..."
helm repo add metallb https://metallb.github.io/metallb >/dev/null 2>&1 || true
helm repo update metallb >/dev/null
helm upgrade --install "$METALLB_RELEASE" metallb/metallb \
  --version "$METALLB_CHART_VERSION" \
  --namespace metallb-system \
  --create-namespace \
  --wait \
  --timeout "$TIMEOUT"

kubectl rollout status deployment/metallb-controller \
  -n metallb-system --timeout="$TIMEOUT"
kubectl rollout status daemonset/metallb-speaker \
  -n metallb-system --timeout="$TIMEOUT"
kubectl apply -f .generated/60-metallb-pool.yaml

echo
echo "Installing Envoy Gateway and Gateway API CRDs..."
helm upgrade --install "$ENVOY_GATEWAY_RELEASE" \
  oci://docker.io/envoyproxy/gateway-helm \
  --version "$ENVOY_GATEWAY_VERSION" \
  --namespace envoy-gateway-system \
  --create-namespace \
  --set deployment.replicas=1 \
  --wait \
  --timeout "$TIMEOUT"

kubectl rollout status deployment/envoy-gateway \
  -n envoy-gateway-system --timeout="$TIMEOUT"

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
echo "Creating or resuming Kafka..."
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
kubectl rollout status -n "$NAMESPACE" deployment/schema-registry \
  --timeout="$TIMEOUT"

echo
echo "Deploying REST Proxy..."
kubectl apply -n "$NAMESPACE" -f manifests/40-rest-proxy.yaml
kubectl rollout status -n "$NAMESPACE" deployment/kafka-rest-proxy \
  --timeout="$TIMEOUT"

echo
echo "Deploying Kafbat UI..."
kubectl apply -n "$NAMESPACE" -f manifests/50-kafbat-ui.yaml
kubectl rollout status -n "$NAMESPACE" deployment/kafbat-ui \
  --timeout="$TIMEOUT"

echo
echo "Applying GatewayClass, Gateway, EnvoyProxy and HTTPRoutes..."
kubectl apply -f .generated/70-gateway-api.yaml
kubectl wait gatewayclass/envoy \
  --for=condition=Accepted --timeout=5m
kubectl wait gateway/kafka-gateway -n "$NAMESPACE" \
  --for=condition=Programmed --timeout=5m

actual_gateway_ip="$(
  kubectl get gateway kafka-gateway -n "$NAMESPACE" \
    -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true
)"

[[ "$actual_gateway_ip" == "$LOAD_BALANCER_IP" ]] || {
  kubectl get gateway kafka-gateway -n "$NAMESPACE" -o yaml >&2 || true
  fail "Gateway address is '$actual_gateway_ip', expected '$LOAD_BALANCER_IP'."
}

if [[ "$CONFIGURE_HOSTS" == "true" ]]; then
  echo
  echo "Configuring local DNS entries in /etc/hosts..."
  ./scripts/configure-hosts.sh
fi

echo
echo "Waiting for HTTP endpoints..."
for _ in $(seq 1 90); do
  if curl -fsS "http://registry.${BASE_DOMAIN}/subjects" >/dev/null 2>&1 \
     && curl -fsS "http://rest.${BASE_DOMAIN}/brokers" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

curl -fsS "http://registry.${BASE_DOMAIN}/subjects" >/dev/null || \
  fail "Schema Registry is not reachable through Gateway API."
curl -fsS "http://rest.${BASE_DOMAIN}/brokers" >/dev/null || \
  fail "REST Proxy is not reachable through Gateway API."

echo
./scripts/status.sh

echo
cat <<EOF_READY
Kafka lab is ready.

Gateway API endpoints through Envoy Gateway and the MetalLB VIP:
  Kafbat UI:       http://ui.${BASE_DOMAIN}
  Schema Registry: http://registry.${BASE_DOMAIN}
  REST Proxy:      http://rest.${BASE_DOMAIN}

Gateway VIP:
  ${LOAD_BALANCER_IP}

Kafka remains internal-only:
  lab-kafka-kafka-bootstrap.${NAMESPACE}.svc.cluster.local:9092

Open an ephemeral Kafka CLI pod:
  ./scripts/kafka-shell.sh

Run the Avro end-to-end test:
  ./scripts/test.sh

Stop workloads and preserve Kafka data and cluster identity:
  ./uninstall.sh

Delete the namespace and all Kafka data:
  ./uninstall.sh --purge-data
EOF_READY
