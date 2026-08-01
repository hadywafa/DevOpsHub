#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

NAMESPACE="${NAMESPACE:-kafka-lab}"
STRIMZI_VERSION="${STRIMZI_VERSION:-1.1.0}"
TIMEOUT="${TIMEOUT:-15m}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || fail "kubectl is required."
command -v helm >/dev/null 2>&1 || fail "Helm 3 is required."

kubectl cluster-info >/dev/null 2>&1 || fail "kubectl cannot reach the Kubernetes cluster."
helm version >/dev/null 2>&1 || fail "Helm is not working."

if ! kubectl get storageclass -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -q .; then
  fail "The cluster has no StorageClass. Kafka persistent volumes cannot be provisioned."
fi

DEFAULT_STORAGE_CLASS="$({
  kubectl get storageclass \
    -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}'
  kubectl get storageclass \
    -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.beta\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}'
} | awk 'NF && !seen[$0]++ {print; exit}')"

if [[ -z "$DEFAULT_STORAGE_CLASS" ]]; then
  fail "No default StorageClass was found. Mark one as default or set storageClass in manifests/10-kafka.yaml."
fi

echo "Namespace:             $NAMESPACE"
echo "Strimzi version:       $STRIMZI_VERSION"
echo "Default StorageClass:  $DEFAULT_STORAGE_CLASS"
echo

echo "Installing Strimzi Cluster Operator..."
helm upgrade --install strimzi-cluster-operator \
  oci://quay.io/strimzi-helm/strimzi-kafka-operator \
  --version "$STRIMZI_VERSION" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set watchAnyNamespace=false \
  --wait \
  --timeout "$TIMEOUT"

echo
echo "Deploying the three-node KRaft Kafka cluster..."
kubectl apply -n "$NAMESPACE" -f manifests/10-kafka.yaml

kubectl wait -n "$NAMESPACE" \
  kafka/lab-kafka \
  --for=condition=Ready \
  --timeout="$TIMEOUT"

echo
echo "Creating lab topics..."
kubectl apply -n "$NAMESPACE" -f manifests/20-topics.yaml

kubectl wait -n "$NAMESPACE" \
  kafkatopic/lab-events \
  --for=condition=Ready \
  --timeout=5m

kubectl wait -n "$NAMESPACE" \
  kafkatopic/orders \
  --for=condition=Ready \
  --timeout=5m

echo
echo "Deploying Schema Registry..."
kubectl apply -n "$NAMESPACE" -f manifests/30-schema-registry.yaml
kubectl rollout status -n "$NAMESPACE" deployment/schema-registry --timeout="$TIMEOUT"

echo
echo "Deploying Confluent REST Proxy..."
kubectl apply -n "$NAMESPACE" -f manifests/40-rest-proxy.yaml
kubectl rollout status -n "$NAMESPACE" deployment/kafka-rest-proxy --timeout="$TIMEOUT"

echo
echo "Deploying Kafbat UI and Kafka client pod..."
kubectl apply -n "$NAMESPACE" -f manifests/50-kafbat-ui.yaml
kubectl apply -n "$NAMESPACE" -f manifests/60-kafka-client.yaml
kubectl rollout status -n "$NAMESPACE" deployment/kafbat-ui --timeout="$TIMEOUT"
kubectl rollout status -n "$NAMESPACE" deployment/kafka-client --timeout=5m

echo
kubectl get pods -n "$NAMESPACE" -o wide

echo
cat <<MSG
Kafka lab is ready.

Internal Kafka bootstrap:
  lab-kafka-kafka-bootstrap.${NAMESPACE}.svc.cluster.local:9092

HTTP services inside Kubernetes:
  Schema Registry: http://schema-registry.${NAMESPACE}.svc.cluster.local:8081
  REST Proxy:      http://kafka-rest-proxy.${NAMESPACE}.svc.cluster.local:8082
  Kafbat UI:       http://kafbat-ui.${NAMESPACE}.svc.cluster.local:8080

Host access for HTTP services:
  ./scripts/port-forward.sh

Run the end-to-end Avro test:
  ./scripts/test.sh

Open a Kafka CLI shell:
  ./scripts/kafka-shell.sh

Inspect the external NodePort bootstrap address:
  kubectl get kafka lab-kafka -n ${NAMESPACE} \
    -o=jsonpath='{.status.listeners[?(@.name=="external")].bootstrapServers}{"\n"}'
MSG
