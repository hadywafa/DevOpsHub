#!/bin/bash
# ======================================================
# Node Exporter - systemd service installation
# ======================================================
set -euo pipefail

VERSION="${VERSION:-1.8.1}"

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)  REL_ARCH="linux-amd64" ;;
  aarch64) REL_ARCH="linux-arm64" ;;
  arm64)   REL_ARCH="linux-arm64" ;;
  *) echo "Unsupported arch: ${ARCH}"; exit 1 ;;
resac

PKG="node_exporter-${VERSION}.${REL_ARCH}"
TAR="${PKG}.tar.gz"
URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${TAR}"

WORKDIR="$(pwd)"

echo "📦 Downloading Node Exporter ${VERSION} (${REL_ARCH})..."
if [[ ! -f "${TAR}" ]]; then
  wget -q "${URL}" -O "${TAR}"
else
  echo "ℹ️ Tarball already exists: ${TAR}"
fi

echo "📂 Extracting..."
rm -rf "./${PKG}"
tar -xzf "${TAR}"

echo "👤 Creating service user (node_exporter)..."
if ! id -u node_exporter >/dev/null 2>&1; then
  sudo useradd --no-create-home --shell /bin/false node_exporter
else
  echo "ℹ️ User node_exporter already exists."
fi

echo "⚙️ Installing binary to /usr/local/bin..."
sudo cp "${PKG}/node_exporter" /usr/local/bin/node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo chmod 0755 /usr/local/bin/node_exporter

SERVICE_FILE="/etc/systemd/system/node_exporter.service"
echo "🧾 Writing systemd unit: ${SERVICE_FILE}"
sudo tee "${SERVICE_FILE}" >/dev/null <<'EOF'
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100

# Hardening
NoNewPrivileges=true
ProtectSystem=full
ProtectHome=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
LockPersonality=true

Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading & starting service..."
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

echo "✅ Node Exporter service is up."
sudo systemctl --no-pager status node_exporter || true
echo "🌐 Metrics: http://<this-host>:9100/metrics"