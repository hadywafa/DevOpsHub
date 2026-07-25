#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

echo "=== Containers ==="
docker compose ps

echo
echo "=== KRaft quorum ==="
docker compose exec -T kafka-1 \
  /opt/kafka/bin/kafka-metadata-quorum.sh \
  --bootstrap-server kafka-1:19092 \
  describe --status

echo
echo "=== Brokers ==="
docker compose exec -T kafka-1 \
  /opt/kafka/bin/kafka-broker-api-versions.sh \
  --bootstrap-server kafka-1:19092 | grep -E '^kafka-[123]:' || true

echo
echo "=== Topics ==="
docker compose exec -T kafka-1 \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka-1:19092 \
  --list
