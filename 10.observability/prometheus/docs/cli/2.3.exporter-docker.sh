#!/bin/bash
# ======================================================
# Node Exporter - Docker (host metrics) one-liner
# ======================================================
set -euo pipefail

NAME="${NAME:-node-exporter}"
IMAGE="${IMAGE:-prom/node-exporter:latest}"

echo "🐳 Running ${NAME} from ${IMAGE} ..."
# Remove existing container if present
if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "ℹ️ Removing existing container ${NAME}..."
  docker rm -f "${NAME}" >/dev/null 2>&1 || true
fi

docker run -d \
  --name "${NAME}" \
  --restart unless-stopped \
  --pid="host" \
  -p 9100:9100 \
  -v "/:/host:ro,rslave" \
  "${IMAGE}" \
  --path.rootfs=/host

echo "✅ Container started."
echo "🌐 Metrics: http://localhost:9100/metrics"
echo "🗒️ Logs: docker logs -f ${NAME}"