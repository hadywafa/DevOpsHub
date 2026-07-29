#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

topic="${1:-orders}"

echo "Producing to '$topic'. Each line is one record; press Ctrl-C to stop."
docker compose exec kafka-1 \
  /opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server kafka-1:19092,kafka-2:19092,kafka-3:19092 \
  --topic "$topic" \
  --producer-property acks=all
