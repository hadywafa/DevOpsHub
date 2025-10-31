#!/bin/bash
# ============================================
# Prometheus Direct Binary Installation Script
# ============================================

set -e

PROM_VERSION="2.53.0"
PROM_DIR="prometheus-${PROM_VERSION}.linux-amd64"
PROM_TAR="${PROM_DIR}.tar.gz"
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/${PROM_TAR}"

echo "📦 Downloading Prometheus v${PROM_VERSION}..."
wget -q ${DOWNLOAD_URL} -O ${PROM_TAR}

echo "📂 Extracting package..."
tar xvf ${PROM_TAR}

echo "🚀 Starting Prometheus directly..."
cd ${PROM_DIR}
nohup ./prometheus > prometheus.log 2>&1 &

echo "✅ Prometheus started successfully!"
echo "🌐 Access it at: http://localhost:9090"
echo "💡 Log file: $(pwd)/prometheus.log"