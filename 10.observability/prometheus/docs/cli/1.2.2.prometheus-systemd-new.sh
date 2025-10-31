#!/bin/bash
# ============================================
# Prometheus Installation via Systemd Service
# - Auto-detects consoles availability (2.x vs 3.x+)
# ============================================

set -euo pipefail

PROM_VERSION="${PROM_VERSION:-2.53.0}"   # override with: PROM_VERSION=3.7.0 ./prometheus-systemd.sh
PROM_DIR="prometheus-${PROM_VERSION}.linux-amd64"
PROM_TAR="${PROM_DIR}.tar.gz"
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/${PROM_TAR}"

echo "📦 Downloading Prometheus v${PROM_VERSION}..."
wget -q "${DOWNLOAD_URL}" -O "${PROM_TAR}"

echo "📂 Extracting package..."
rm -rf "${PROM_DIR}"
tar xvf "${PROM_TAR}"

echo "👤 Creating prometheus user and directories..."
if ! id -u prometheus >/dev/null 2>&1; then
  sudo useradd --no-create-home --shell /bin/false prometheus
fi
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

echo "⚙️ Copying binaries..."
sudo cp "${PROM_DIR}/prometheus" "${PROM_DIR}/promtool" /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
sudo chmod 0755 /usr/local/bin/prometheus /usr/local/bin/promtool

# Detect whether consoles exist in this release (present in Prometheus 2.x, removed in 3.x+)
CONSOLES_PRESENT=false
if [[ -d "${PROM_DIR}/consoles" && -d "${PROM_DIR}/console_libraries" ]]; then
  CONSOLES_PRESENT=true
fi

echo "📁 Copying configuration (and console assets if present)..."
sudo cp "${PROM_DIR}/prometheus.yml" /etc/prometheus/
if $CONSOLES_PRESENT; then
  sudo cp -r "${PROM_DIR}/consoles" "${PROM_DIR}/console_libraries" /etc/prometheus/
fi
sudo chown -R prometheus:prometheus /etc/prometheus

# Build ExecStart line conditionally (omit web.console.* when consoles are embedded in Prometheus 3.x+)
EXECSTART="/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/"

if $CONSOLES_PRESENT; then
  EXECSTART="${EXECSTART} \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries"
fi

echo "🧾 Creating systemd service file..."
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=${EXECSTART}
Restart=on-failure
RestartSec=5s

# Security hardening (safe defaults)
NoNewPrivileges=true
ProtectSystem=full
ProtectHome=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
LockPersonality=true

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd and starting Prometheus..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "✅ Prometheus is running as a service!"
sudo systemctl status prometheus --no-pager || true
echo "🌐 Access it at: http://localhost:9090"
