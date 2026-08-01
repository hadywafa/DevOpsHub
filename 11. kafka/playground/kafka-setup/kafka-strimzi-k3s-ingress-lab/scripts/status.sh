#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
NAMESPACE="${NAMESPACE:-kafka-lab}"

if [[ -f .lab.env ]]; then
  # shellcheck disable=SC1091
  source .lab.env
fi

echo "== Kafka =="
kubectl get kafka,kafkanodepool,kafkatopic -n "$NAMESPACE"

echo
echo "== Workloads =="
kubectl get pods -n "$NAMESPACE" -o wide

echo
echo "== Services and ingress =="
kubectl get svc,ingress -n "$NAMESPACE"

echo
echo "== Storage =="
kubectl get pvc -n "$NAMESPACE"

echo
if [[ -n "${BASE_DOMAIN:-}" ]]; then
  cat <<EOF
Endpoints:
  Kafbat UI:       http://ui.${BASE_DOMAIN}
  Schema Registry: http://registry.${BASE_DOMAIN}
  REST Proxy:      http://rest.${BASE_DOMAIN}
EOF
fi
