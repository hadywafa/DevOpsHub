#!/usr/bin/env bash
set -Eeuo pipefail

BEGIN_MARKER="# BEGIN kafka-strimzi-gateway-api-lab"
END_MARKER="# END kafka-strimzi-gateway-api-lab"
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
  $0 == begin {skip=1; next}
  $0 == end {skip=0; next}
  !skip {print}
' /etc/hosts > "$TMP_FILE"

sudo cp "$TMP_FILE" /etc/hosts

echo "Removed Kafka lab entries from /etc/hosts."
