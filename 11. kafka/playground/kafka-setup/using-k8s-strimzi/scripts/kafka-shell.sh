#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="${NAMESPACE:-kafka-lab}"
POD="$(kubectl get pod -n "$NAMESPACE" -l app.kubernetes.io/name=kafka-client -o jsonpath='{.items[0].metadata.name}')"

if [[ -z "$POD" ]]; then
  echo "ERROR: kafka-client pod was not found." >&2
  exit 1
fi

cat <<'MSG'
Kafka bootstrap inside this shell:
  lab-kafka-kafka-bootstrap:9092

Useful commands:
  bin/kafka-topics.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --list
  bin/kafka-console-producer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic orders
  bin/kafka-console-consumer.sh --bootstrap-server lab-kafka-kafka-bootstrap:9092 --topic orders --from-beginning
MSG

kubectl exec -n "$NAMESPACE" -it "$POD" -- /bin/bash
