#!/bin/bash
# ============================================
# Prometheus Installation via Docker
# ============================================

set -e

PROM_DIR="$PWD/prometheus_docker"
mkdir -p ${PROM_DIR}
cd ${PROM_DIR}

echo "🧾 Creating prometheus.yml configuration..."
cat <<EOF > prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOF

echo "🐳 Pulling and running Prometheus container..."
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

echo "✅ Prometheus container is running!"
echo "🌐 Access it at: http://localhost:9090"