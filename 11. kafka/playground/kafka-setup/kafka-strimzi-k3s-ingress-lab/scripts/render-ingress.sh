#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

NODE_IP="${NODE_IP:-}"
BASE_DOMAIN="${BASE_DOMAIN:-}"
OUTPUT="${OUTPUT:-.generated/60-ingress.yaml}"

if [[ -z "$NODE_IP" ]]; then
  NODE_IP="$(
    kubectl get nodes \
      -o jsonpath='{range .items[*]}{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}{end}' |
      awk 'NF {print; exit}'
  )"
fi

[[ -n "$NODE_IP" ]] || {
  echo "ERROR: Could not detect the K3s node InternalIP." >&2
  exit 1
}

if [[ -z "$BASE_DOMAIN" ]]; then
  BASE_DOMAIN="kafka.${NODE_IP}.nip.io"
fi

mkdir -p "$(dirname "$OUTPUT")"
sed "s/__BASE_DOMAIN__/${BASE_DOMAIN//\//\\/}/g" \
  manifests/60-ingress.yaml.tpl > "$OUTPUT"

cat > .lab.env <<EOF
NODE_IP=$NODE_IP
BASE_DOMAIN=$BASE_DOMAIN
EOF

printf '%s\n' "$OUTPUT"
