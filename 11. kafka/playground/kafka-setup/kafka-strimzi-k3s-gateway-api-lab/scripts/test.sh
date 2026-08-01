#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

command -v curl >/dev/null 2>&1 || {
  echo "ERROR: curl is required." >&2
  exit 1
}

[[ -f .lab.env ]] || {
  echo "ERROR: .lab.env not found. Run ./install.sh first." >&2
  exit 1
}

# shellcheck disable=SC1091
source .lab.env

SR_URL="http://registry.${BASE_DOMAIN}"
REST_URL="http://rest.${BASE_DOMAIN}"
GROUP="lab-avro-group-$(date +%s)"
INSTANCE="lab-avro-consumer"

cleanup() {
  curl -fsS -X DELETE \
    -H 'Content-Type: application/vnd.kafka.v2+json' \
    "$REST_URL/consumers/$GROUP/instances/$INSTANCE" \
    >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

curl -fsS "$SR_URL/subjects" >/dev/null
curl -fsS "$REST_URL/brokers" >/dev/null

echo "1. Producing one Avro record through Gateway API and REST Proxy..."
curl -fsS -X POST \
  -H 'Content-Type: application/vnd.kafka.avro.v2+json' \
  -H 'Accept: application/vnd.kafka.v2+json' \
  --data-binary @- \
  "$REST_URL/topics/lab-events" <<'JSON'
{
  "value_schema": "{\"type\":\"record\",\"name\":\"LabEvent\",\"namespace\":\"lab\",\"fields\":[{\"name\":\"id\",\"type\":\"long\"},{\"name\":\"message\",\"type\":\"string\"}]}",
  "records": [
    {
      "value": {
        "id": 1,
        "message": "hello through Gateway API and Envoy Gateway"
      }
    }
  ]
}
JSON

echo
echo
echo "2. Schema Registry subjects:"
curl -fsS "$SR_URL/subjects"
echo

echo
echo "3. Creating an Avro REST consumer..."
curl -fsS -X POST \
  -H 'Content-Type: application/vnd.kafka.avro.v2+json' \
  -H 'Accept: application/vnd.kafka.avro.v2+json' \
  --data "{\"name\":\"$INSTANCE\",\"format\":\"avro\",\"auto.offset.reset\":\"earliest\",\"auto.commit.enable\":\"false\"}" \
  "$REST_URL/consumers/$GROUP"
echo

echo
echo "4. Subscribing to lab-events..."
curl -fsS -o /dev/null -X POST \
  -H 'Content-Type: application/vnd.kafka.v2+json' \
  --data '{"topics":["lab-events"]}' \
  "$REST_URL/consumers/$GROUP/instances/$INSTANCE/subscription"

echo "5. Consuming records..."
records='[]'
for _ in $(seq 1 10); do
  records="$(curl -fsS \
    -H 'Accept: application/vnd.kafka.avro.v2+json' \
    "$REST_URL/consumers/$GROUP/instances/$INSTANCE/records?timeout=3000&max_bytes=300000")"
  [[ "$records" != "[]" ]] && break
  sleep 1
done

printf '%s\n' "$records"
echo
echo "End-to-end test completed successfully."
