#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"

command -v docker >/dev/null 2>&1 || {
  echo "ERROR: docker is not installed or not in PATH." >&2
  exit 1
}

docker compose version >/dev/null 2>&1 || {
  echo "ERROR: Docker Compose v2 is required (docker compose)." >&2
  exit 1
}

if [[ ! -f .env ]]; then
  echo "Generating a unique Kafka KRaft cluster ID..."
  cluster_id="$(docker run --rm apache/kafka:4.3.1 \
    /opt/kafka/bin/kafka-storage.sh random-uuid | tail -n 1 | tr -d '\r')"

  if [[ -z "$cluster_id" ]]; then
    echo "ERROR: Failed to generate the Kafka cluster ID." >&2
    exit 1
  fi

  cat > .env <<EOF
KAFKA_CLUSTER_ID=$cluster_id
KAFKA_BIND_ADDRESS=127.0.0.1
KAFKA_EXTERNAL_HOST=localhost
KAFKA_UI_BIND_ADDRESS=127.0.0.1
KAFKA_UI_PORT=8080
EOF

  echo "Created .env with cluster ID: $cluster_id"
fi

docker compose config --quiet
docker compose pull
docker compose up -d

echo
echo "Kafka bootstrap servers: localhost:29092,localhost:39092,localhost:49092"
echo "Kafbat UI:              http://localhost:8080"
echo
echo "Run ./scripts/status.sh to verify the cluster."
