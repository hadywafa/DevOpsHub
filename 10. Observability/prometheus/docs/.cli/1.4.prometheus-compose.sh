#!/bin/bash
# ============================================
# Prometheus Installation via Docker Compose
# ============================================

set -e

PROM_DIR="$PWD/prometheus_compose"
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

echo "🧩 Creating docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v2.53.0
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    restart: unless-stopped

volumes:
  prometheus_data:
EOF

echo "🚀 Launching Prometheus with Docker Compose..."
docker compose up -d

echo "✅ Prometheus (persistent) started successfully!"
echo "🌐 Access it at: http://localhost:9090"