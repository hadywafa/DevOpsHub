#!/bin/bash
# ======================================================
# Node Exporter - Direct (foreground/background) runner
# ======================================================
set -euo pipefail

# Override via env: VERSION=1.7.0 ./node-exporter-direct.sh
VERSION="${VERSION:-1.8.1}"

# Detect arch -> prom release uses linux-amd64 / linux-arm64
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)  REL_ARCH="linux-amd64" ;;
  aarch64) REL_ARCH="linux-arm64" ;;
  arm64)   REL_ARCH="linux-arm64" ;;
  *) echo "Unsupported arch: ${ARCH}"; exit 1 ;;
esac

PKG="node_exporter-${VERSION}.${REL_ARCH}"
TAR="${PKG}.tar.gz"
URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${TAR}"

echo "📦 Downloading Node Exporter ${VERSION} (${REL_ARCH})..."
if [[ ! -f "${TAR}" ]]; then
  wget -q "${URL}" -O "${TAR}"
else
  echo "ℹ️ Tarball already exists: ${TAR}"
fi

echo "📂 Extracting..."
rm -rf "./${PKG}"
tar -xzf "${TAR}"

echo "▶️ Starting Node Exporter..."
cd "${PKG}"

# Foreground:
# ./node_exporter

# Background (default):
nohup ./node_exporter > node_exporter.log 2>&1 &
PID=$!

echo "✅ Node Exporter started (PID ${PID})"
echo "🌐 Metrics: http://localhost:9100/metrics"
echo "📝 Log: $(pwd)/node_exporter.log"