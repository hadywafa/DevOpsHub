#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
NAMESPACE="${NAMESPACE:-kafka-lab}"

echo "== Kafka resource =="
kubectl get kafka lab-kafka -n "$NAMESPACE" -o wide

echo
echo "== Kafka node pool =="
kubectl get kafkanodepool -n "$NAMESPACE"

echo
echo "== Topics =="
kubectl get kafkatopic -n "$NAMESPACE"

echo
echo "== Pods =="
kubectl get pods -n "$NAMESPACE" -o wide

echo
echo "== Services =="
kubectl get svc -n "$NAMESPACE"

echo
echo "== PersistentVolumeClaims =="
kubectl get pvc -n "$NAMESPACE"

echo
echo "== External Kafka bootstrap =="
kubectl get kafka lab-kafka -n "$NAMESPACE" \
  -o=jsonpath='{.status.listeners[?(@.name=="external")].bootstrapServers}{"\n"}'
