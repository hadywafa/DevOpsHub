#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

NAMESPACE="${NAMESPACE:-kafka-lab}"
KAFKA_NAME="${KAFKA_NAME:-lab-kafka}"
STRIMZI_RELEASE="${STRIMZI_RELEASE:-strimzi-cluster-operator}"
PURGE_DATA=false
ASSUME_YES=false
REMOVE_PLATFORM=false

usage() {
  cat <<'EOF_USAGE'
Usage:
  ./uninstall.sh
      Stop Kafka and remove lab HTTP workloads/routes while preserving Kafka
      custom resources, cluster identity, schemas, messages, offsets and PVCs.

  ./uninstall.sh --purge-data
      Permanently delete the kafka-lab namespace and all Kafka data.

  ./uninstall.sh --purge-data --remove-platform
      Also uninstall Envoy Gateway and MetalLB after deleting the lab.
EOF_USAGE
}

for arg in "$@"; do
  case "$arg" in
    --purge-data) PURGE_DATA=true ;;
    --remove-platform) REMOVE_PLATFORM=true ;;
    -y|--yes) ASSUME_YES=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

command -v kubectl >/dev/null 2>&1 || {
  echo "ERROR: kubectl is required." >&2
  exit 1
}
command -v helm >/dev/null 2>&1 || {
  echo "ERROR: helm is required." >&2
  exit 1
}

if [[ "$PURGE_DATA" == true ]]; then
  if [[ "$ASSUME_YES" != true ]]; then
    echo "WARNING: This permanently deletes Kafka messages, schemas, offsets, secrets and PVCs."
    read -r -p "Type PURGE-${KAFKA_NAME} to continue: " confirmation
    [[ "$confirmation" == "PURGE-${KAFKA_NAME}" ]] || {
      echo "Cancelled."
      exit 0
    }
  fi

  if helm status "$STRIMZI_RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
    helm uninstall "$STRIMZI_RELEASE" -n "$NAMESPACE"
  fi

  kubectl delete namespace "$NAMESPACE" \
    --ignore-not-found --wait=true --timeout=10m

  ./scripts/remove-hosts.sh 2>/dev/null || true
  rm -f .lab.env .generated/*.yaml

  if [[ "$REMOVE_PLATFORM" == true ]]; then
    kubectl delete gatewayclass envoy --ignore-not-found || true
    kubectl delete ipaddresspool kafka-gateway-pool \
      -n metallb-system --ignore-not-found || true
    kubectl delete l2advertisement kafka-gateway-l2 \
      -n metallb-system --ignore-not-found || true

    helm uninstall envoy-gateway -n envoy-gateway-system 2>/dev/null || true
    helm uninstall metallb -n metallb-system 2>/dev/null || true
  fi

  echo "Kafka lab and all Kafka data were permanently removed."
  [[ "$REMOVE_PLATFORM" == true ]] && \
    echo "Envoy Gateway and MetalLB were also removed."
  exit 0
fi

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "Namespace '$NAMESPACE' does not exist. Nothing to stop."
  exit 0
fi

cluster_id="$(
  kubectl get kafka "$KAFKA_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.status.clusterId}' 2>/dev/null || true
)"

echo "Removing Gateway API routes and stateless services..."
if [[ -f .generated/70-gateway-api.yaml ]]; then
  kubectl delete -f .generated/70-gateway-api.yaml \
    --ignore-not-found 2>/dev/null || true
else
  kubectl delete httproute --all -n "$NAMESPACE" --ignore-not-found || true
  kubectl delete gateway kafka-gateway -n "$NAMESPACE" --ignore-not-found || true
  kubectl delete envoyproxy kafka-gateway-proxy -n "$NAMESPACE" --ignore-not-found || true
fi

kubectl delete -n "$NAMESPACE" -f manifests/50-kafbat-ui.yaml \
  --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/40-rest-proxy.yaml \
  --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/30-schema-registry.yaml \
  --ignore-not-found || true

./scripts/remove-hosts.sh 2>/dev/null || true

echo "Stopping the Strimzi operator..."
if helm status "$STRIMZI_RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  helm uninstall "$STRIMZI_RELEASE" -n "$NAMESPACE"
fi

# The Kafka and KafkaNodePool resources stay in Kubernetes. Their status,
# cluster ID, generated secrets, topics and PVCs therefore remain associated
# with the same KRaft cluster identity.
echo "Stopping Kafka runtime pods while preserving identity and disks..."
kubectl delete deployment -n "$NAMESPACE" \
  -l "strimzi.io/cluster=${KAFKA_NAME}" \
  --ignore-not-found || true
kubectl delete pod -n "$NAMESPACE" \
  -l "strimzi.io/cluster=${KAFKA_NAME}" \
  --ignore-not-found --wait=true || true

echo
[[ -n "$cluster_id" ]] && echo "Preserved Kafka cluster ID: $cluster_id"
kubectl get kafka,kafkanodepool,pvc -n "$NAMESPACE" 2>/dev/null || true

echo
cat <<EOF_STOPPED
Kafka workloads are stopped. Data and cluster identity are preserved.

Resume the same cluster:
  ./install.sh

Delete all Kafka data:
  ./uninstall.sh --purge-data

Envoy Gateway and MetalLB remain installed as cluster networking platform components.
EOF_STOPPED
