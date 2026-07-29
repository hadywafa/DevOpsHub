#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

CONFIG=/etc/kafka/secrets/client-docker.properties
BS=kafka-1:19093
TOPIC=ssl-demo

run() {
  docker compose exec kafka-1 "$@"
}

run /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server "$BS" \
  --command-config "$CONFIG" \
  --create --if-not-exists \
  --topic "$TOPIC" \
  --partitions 3 \
  --replication-factor 3

printf 'encrypted-message-1\nencrypted-message-2\n' |
  docker compose exec -T kafka-1 \
    /opt/kafka/bin/kafka-console-producer.sh \
    --bootstrap-server "$BS" \
    --command-config "$CONFIG" \
    --topic "$TOPIC"

run /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server "$BS" \
  --command-config "$CONFIG" \
  --topic "$TOPIC" \
  --from-beginning \
  --max-messages 2 \
  --timeout-ms 10000
