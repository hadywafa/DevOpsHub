#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="${NAMESPACE:-kafka-lab}"
SCHEMA_REGISTRY_PORT="${SCHEMA_REGISTRY_PORT:-8081}"
REST_PROXY_PORT="${REST_PROXY_PORT:-8082}"
KAFBAT_UI_PORT="${KAFBAT_UI_PORT:-8080}"

pids=()
cleanup() {
  for pid in "${pids[@]:-}"; do
    kill "$pid" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT INT TERM

kubectl port-forward -n "$NAMESPACE" svc/schema-registry \
  "$SCHEMA_REGISTRY_PORT:8081" >/tmp/kafka-lab-schema-registry-port-forward.log 2>&1 &
pids+=("$!")

kubectl port-forward -n "$NAMESPACE" svc/kafka-rest-proxy \
  "$REST_PROXY_PORT:8082" >/tmp/kafka-lab-rest-proxy-port-forward.log 2>&1 &
pids+=("$!")

kubectl port-forward -n "$NAMESPACE" svc/kafbat-ui \
  "$KAFBAT_UI_PORT:8080" >/tmp/kafka-lab-kafbat-ui-port-forward.log 2>&1 &
pids+=("$!")

sleep 2

for pid in "${pids[@]}"; do
  kill -0 "$pid" >/dev/null 2>&1 || {
    echo "ERROR: A port-forward process failed." >&2
    cat /tmp/kafka-lab-*-port-forward.log >&2 || true
    exit 1
  }
done

cat <<MSG
Port forwarding is active:
  Schema Registry: http://127.0.0.1:${SCHEMA_REGISTRY_PORT}
  REST Proxy:      http://127.0.0.1:${REST_PROXY_PORT}
  Kafbat UI:       http://127.0.0.1:${KAFBAT_UI_PORT}

Press Ctrl+C to stop.
MSG

wait
