#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
NAMESPACE="${NAMESPACE:-kafka-lab}"
PURGE_DATA=false

if [[ "${1:-}" == "--purge-data" ]]; then
  PURGE_DATA=true
fi

kubectl delete -n "$NAMESPACE" -f manifests/60-kafka-client.yaml --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/50-kafbat-ui.yaml --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/40-rest-proxy.yaml --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/30-schema-registry.yaml --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/20-topics.yaml --ignore-not-found || true
kubectl delete -n "$NAMESPACE" -f manifests/10-kafka.yaml --ignore-not-found || true

helm uninstall strimzi-cluster-operator -n "$NAMESPACE" >/dev/null 2>&1 || true

if [[ "$PURGE_DATA" == true ]]; then
  kubectl delete pvc -n "$NAMESPACE" --all --ignore-not-found
  kubectl delete namespace "$NAMESPACE" --ignore-not-found
  echo "Kafka lab, PVCs and namespace were removed."
else
  echo "Kafka lab was removed, but PVCs and namespace were retained."
  echo "To remove all data: ./uninstall.sh --purge-data"
fi
