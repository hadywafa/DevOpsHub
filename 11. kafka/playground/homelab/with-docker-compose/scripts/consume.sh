#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

topic="${1:-orders}"
group="${2:-orders-demo-group}"

docker compose exec kafka-2 \
  /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka-1:19092,kafka-2:19092,kafka-3:19092 \
  --topic "$topic" \
  --group "$group" \
  --from-beginning \
  --property print.partition=true \
  --property print.offset=true \
  --property print.key=true \
  --property key.separator=' | '
