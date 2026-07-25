#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

topic="${1:-orders}"

docker compose exec -T kafka-1 \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka-1:19092 \
  --describe \
  --topic "$topic"
