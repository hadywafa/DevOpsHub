#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ ! -f secrets/kafka-1.keystore.p12 ]]; then
  ./generate-certs.sh
fi

if [[ ! -f .env ]]; then
  CLUSTER_ID="$(docker run --rm apache/kafka:4.3.1 /opt/kafka/bin/kafka-storage.sh random-uuid)"
  cat > .env <<EOF_ENV
KAFKA_CLUSTER_ID=$CLUSTER_ID
KAFKA_SSL_PASSWORD=${KAFKA_SSL_PASSWORD:-changeit}
EOF_ENV
fi

docker compose config --quiet
docker compose up -d

echo
printf 'Kafka TLS bootstrap servers: localhost:29093,localhost:39093,localhost:49093\n'
printf 'Kafbat UI:                  http://localhost:8080\n'
printf 'Check status:               docker compose ps\n'
