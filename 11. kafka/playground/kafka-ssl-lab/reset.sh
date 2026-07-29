#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
read -r -p "Type DELETE to remove Kafka data, certificates, and .env: " answer
[[ "$answer" == "DELETE" ]] || { echo "Cancelled"; exit 1; }
docker compose down -v --remove-orphans || true
rm -rf secrets pki/ca .env
mkdir -p secrets pki/ca
echo "Reset complete"
