#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
NAMESPACE="${NAMESPACE:-kafka-lab}"

kubectl run kafka-cli \
  -n "$NAMESPACE" \
  --rm -it \
  --restart=Never \
  --image=apache/kafka:4.3.1 \
  --command -- bash
