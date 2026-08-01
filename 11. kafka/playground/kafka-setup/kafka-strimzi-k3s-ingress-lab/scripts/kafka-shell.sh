#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="${NAMESPACE:-kafka-lab}"
IMAGE="${KAFKA_CLIENT_IMAGE:-quay.io/strimzi/kafka:1.1.0-kafka-4.3.0}"
NAME="kafka-cli-$(date +%s)"

cat <<'MSG'
Opening an ephemeral Kafka CLI pod.

Bootstrap server:
  lab-kafka-kafka-bootstrap:9092

Examples:
  bin/kafka-topics.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --list
  bin/kafka-console-producer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic orders
  bin/kafka-console-consumer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic orders --from-beginning

Exit the shell to delete the pod automatically.
MSG

kubectl run "$NAME" \
  -n "$NAMESPACE" \
  --rm -it \
  --restart=Never \
  --image="$IMAGE" \
  --command -- /bin/bash
