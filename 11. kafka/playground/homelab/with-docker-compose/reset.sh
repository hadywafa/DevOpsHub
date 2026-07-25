#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")"

cat <<'EOF'
WARNING: This deletes all Kafka topics, records, offsets and KRaft metadata
stored in the three Docker volumes.
EOF

read -r -p "Type DELETE to continue: " answer
[[ "$answer" == "DELETE" ]] || {
  echo "Cancelled."
  exit 0
}

docker compose down --volumes --remove-orphans
rm -f .env

echo "Cluster data and .env removed. Run ./start.sh for a fresh cluster."
