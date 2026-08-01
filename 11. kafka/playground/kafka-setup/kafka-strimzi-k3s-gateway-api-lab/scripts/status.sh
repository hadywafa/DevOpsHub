#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
NAMESPACE="${NAMESPACE:-kafka-lab}"

if [[ -f .lab.env ]]; then
  # shellcheck disable=SC1091
  source .lab.env
fi

echo "== Platform controllers =="
kubectl get pods -n metallb-system 2>/dev/null || true
kubectl get pods -n envoy-gateway-system 2>/dev/null || true

echo
echo "== Gateway API =="
kubectl get gatewayclass,gateway,httproute -A 2>/dev/null || true

echo
echo "== Gateway LoadBalancer Service =="
kubectl get svc -n envoy-gateway-system \
  -l gateway.envoyproxy.io/owning-gateway-name=kafka-gateway 2>/dev/null || true

echo
echo "== Kafka =="
kubectl get kafka,kafkanodepool,kafkatopic -n "$NAMESPACE" 2>/dev/null || true

echo
echo "== Workloads =="
kubectl get pods -n "$NAMESPACE" -o wide 2>/dev/null || true

echo
echo "== Storage =="
kubectl get pvc -n "$NAMESPACE" 2>/dev/null || true

if [[ -n "${BASE_DOMAIN:-}" ]]; then
  echo
  cat <<EOF_ENDPOINTS
Endpoints:
  Kafbat UI:       http://ui.${BASE_DOMAIN}
  Schema Registry: http://registry.${BASE_DOMAIN}
  REST Proxy:      http://rest.${BASE_DOMAIN}
EOF_ENDPOINTS
fi
