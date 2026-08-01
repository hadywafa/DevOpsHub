#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

[[ -f .lab.env ]] || {
  echo "ERROR: .lab.env does not exist. Run ./install.sh once or copy config.env.example." >&2
  exit 1
}

# shellcheck disable=SC1091
source .lab.env

: "${LOAD_BALANCER_IP:?LOAD_BALANCER_IP is required}"
: "${BASE_DOMAIN:?BASE_DOMAIN is required}"

BEGIN_MARKER="# BEGIN kafka-strimzi-gateway-api-lab"
END_MARKER="# END kafka-strimzi-gateway-api-lab"
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
  $0 == begin {skip=1; next}
  $0 == end {skip=0; next}
  !skip {print}
' /etc/hosts > "$TMP_FILE"

cat >> "$TMP_FILE" <<EOF_HOSTS
$BEGIN_MARKER
$LOAD_BALANCER_IP ui.$BASE_DOMAIN registry.$BASE_DOMAIN rest.$BASE_DOMAIN
$END_MARKER
EOF_HOSTS

sudo cp "$TMP_FILE" /etc/hosts

echo "Updated /etc/hosts:"
echo "  $LOAD_BALANCER_IP ui.$BASE_DOMAIN registry.$BASE_DOMAIN rest.$BASE_DOMAIN"
