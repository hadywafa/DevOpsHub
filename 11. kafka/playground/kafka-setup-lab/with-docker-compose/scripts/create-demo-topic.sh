#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

topic="${1:-orders}"
partitions="${2:-6}"

docker compose exec -T kafka-1 \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka-1:19092 \
  --create \
  --if-not-exists \
  --topic "$topic" \
  --partitions "$partitions" \
  --replication-factor 3 \
  --config min.insync.replicas=2

docker compose exec -T kafka-1 \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka-1:19092 \
  --describe \
  --topic "$topic"
