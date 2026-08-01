#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="${NAMESPACE:-kafka-lab}"
SR_LOCAL_PORT="${SR_LOCAL_PORT:-18081}"
REST_LOCAL_PORT="${REST_LOCAL_PORT:-18082}"

command -v curl >/dev/null 2>&1 || {
  echo "ERROR: curl is required." >&2
  exit 1
}

pids=()
cleanup() {
  curl -sS -X DELETE \
    -H 'Content-Type: application/vnd.kafka.v2+json' \
    "http://127.0.0.1:${REST_LOCAL_PORT}/consumers/lab-avro-group/instances/lab-avro-consumer" \
    >/dev/null 2>&1 || true

  for pid in "${pids[@]:-}"; do
    kill "$pid" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT INT TERM

kubectl port-forward -n "$NAMESPACE" svc/schema-registry \
  "$SR_LOCAL_PORT:8081" >/tmp/kafka-lab-test-sr.log 2>&1 &
pids+=("$!")

kubectl port-forward -n "$NAMESPACE" svc/kafka-rest-proxy \
  "$REST_LOCAL_PORT:8082" >/tmp/kafka-lab-test-rest.log 2>&1 &
pids+=("$!")

for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${SR_LOCAL_PORT}/subjects" >/dev/null 2>&1 \
     && curl -fsS "http://127.0.0.1:${REST_LOCAL_PORT}/brokers" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

curl -fsS "http://127.0.0.1:${SR_LOCAL_PORT}/subjects" >/dev/null
curl -fsS "http://127.0.0.1:${REST_LOCAL_PORT}/brokers" >/dev/null

echo "1. Producing one Avro record through REST Proxy..."
curl -fsS -X POST \
  -H 'Content-Type: application/vnd.kafka.avro.v2+json' \
  -H 'Accept: application/vnd.kafka.v2+json' \
  --data-binary @- \
  "http://127.0.0.1:${REST_LOCAL_PORT}/topics/lab-events" <<'JSON'
{
  "value_schema": "{\"type\":\"record\",\"name\":\"LabEvent\",\"namespace\":\"lab\",\"fields\":[{\"name\":\"id\",\"type\":\"long\"},{\"name\":\"message\",\"type\":\"string\"}]}",
  "records": [
    {
      "value": {
        "id": 1,
        "message": "hello from REST Proxy"
      }
    }
  ]
}
JSON

echo
echo
echo "2. Schema Registry subjects:"
curl -fsS "http://127.0.0.1:${SR_LOCAL_PORT}/subjects"
echo

echo
echo "3. Creating an Avro REST consumer..."
curl -fsS -X POST \
  -H 'Content-Type: application/vnd.kafka.avro.v2+json' \
  -H 'Accept: application/vnd.kafka.avro.v2+json' \
  --data '{"name":"lab-avro-consumer","format":"avro","auto.offset.reset":"earliest","auto.commit.enable":"false"}' \
  "http://127.0.0.1:${REST_LOCAL_PORT}/consumers/lab-avro-group"
echo

echo
echo "4. Subscribing the consumer to lab-events..."
curl -fsS -o /dev/null -X POST \
  -H 'Content-Type: application/vnd.kafka.v2+json' \
  --data '{"topics":["lab-events"]}' \
  "http://127.0.0.1:${REST_LOCAL_PORT}/consumers/lab-avro-group/instances/lab-avro-consumer/subscription"

echo "Subscription created."

echo
echo "5. Consuming records through REST Proxy..."
records='[]'
for _ in $(seq 1 10); do
  records="$(curl -fsS \
    -H 'Accept: application/vnd.kafka.avro.v2+json' \
    "http://127.0.0.1:${REST_LOCAL_PORT}/consumers/lab-avro-group/instances/lab-avro-consumer/records?timeout=3000&max_bytes=300000")"
  if [[ "$records" != "[]" ]]; then
    break
  fi
  sleep 1
done

printf '%s\n' "$records"

echo
echo "End-to-end test completed successfully."
