#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

NAMESPACE="${NAMESPACE:-kafka-lab}"
KAFKA_NAME="${KAFKA_NAME:-lab-kafka}"
STRIMZI_RELEASE="${STRIMZI_RELEASE:-strimzi-cluster-operator}"
PURGE_DATA=false
ASSUME_YES=false

usage() {
  cat <<'EOF'
Usage:
  ./uninstall.sh                  Stop workloads and preserve Kafka identity/data
  ./uninstall.sh --purge-data     Permanently delete the namespace and all data
  ./uninstall.sh --purge-data -y  Purge without interactive confirmation
EOF
}

for arg in "$@"; do
  case "$arg" in
    --purge-data) PURGE_DATA=true ;;
    -y|--yes) ASSUME_YES=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is required." >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "ERROR: helm is required." >&2; exit 1; }

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "Namespace '$NAMESPACE' does not exist. Nothing to remove."
  exit 0
fi

if [[ "$PURGE_DATA" == true ]]; then
  if [[ "$ASSUME_YES" != true ]]; then
    echo "WARNING: This permanently deletes Kafka messages, schemas, offsets, secrets and PVCs."
    read -r -p "Type PURGE-${KAFKA_NAME} to continue: " confirmation
    [[ "$confirmation" == "PURGE-${KAFKA_NAME}" ]] || { echo "Cancelled."; exit 0; }
  fi

  if helm status "$STRIMZI_RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
    helm uninstall "$STRIMZI_RELEASE" -n "$NAMESPACE"
  fi

  kubectl delete namespace "$NAMESPACE" --wait=true --timeout=10m
  rm -f .lab.env .generated/60-ingress.yaml

  echo "Kafka lab and all data were permanently removed."
  exit 0
fi

cluster_id="$(
  kubectl get kafka "$KAFKA_NAME" -n "$NAMESPACE" \
    -o jsonpath='{.status.clusterId}' 2>/dev/null || true
)"

echo "Removing ingress and stateless services..."
kubectl delete -n "$NAMESPACE" -f .generated/60-ingress.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -n "$NAMESPACE" -f manifests/50-kafbat-ui.yaml --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/40-rest-proxy.yaml --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/30-schema-registry.yaml --ignore-not-found || true

echo "Stopping the Strimzi operator..."
if helm status "$STRIMZI_RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  helm uninstall "$STRIMZI_RELEASE" -n "$NAMESPACE"
fi

# With the operator stopped, deleting the generated pods and deployments frees
# local CPU/RAM without deleting the Kafka CR, cluster ID, secrets, topics or PVCs.
echo "Stopping Kafka runtime pods while preserving cluster identity and disks..."
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
cat <<EOF
Kafka workloads are stopped and data is preserved.

Resume the same cluster:
  ./install.sh

Delete everything:
  ./uninstall.sh --purge-data
EOF
