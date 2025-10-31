#!/bin/bash
# ======================================================
# Node Exporter - Docker Compose (host network)
# ======================================================
set -euo pipefail

DIR="${DIR:-$PWD/node-exporter-compose}"
IMAGE="${IMAGE:-prom/node-exporter:latest}"

mkdir -p "${DIR}"
cd "${DIR}"

echo "🧩 Creating docker-compose.yml ..."
cat > docker-compose.yml <<EOF
version: "3.8"

services:
  node-exporter:
    image: ${IMAGE}
    container_name: node-exporter
    restart: unless-stopped
    network_mode: host
    pid: host
    volumes:
      - "/:/host:ro,rslave"
    command:
      - '--path.rootfs=/host'
EOF

echo "🚀 Starting Node Exporter via docker compose..."
if command -v docker compose >/dev/null 2>&1; then
  docker compose up -d
else
  docker-compose up -d
fi

echo "✅ Node Exporter is running."
echo "🌐 Metrics: http://localhost:9100/metrics"
echo "📁 Compose dir: ${DIR}"