#!/bin/bash
# ============================================
# Prometheus Installation via Systemd Service
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

echo "👤 Creating prometheus user and directories..."
sudo useradd --no-create-home --shell /bin/false prometheus || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

echo "⚙️ Copying binaries..."
sudo cp ${PROM_DIR}/prometheus ${PROM_DIR}/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

echo "📁 Copying configuration and console assets..."
sudo cp -r ${PROM_DIR}/consoles ${PROM_DIR}/console_libraries /etc/prometheus/
sudo cp ${PROM_DIR}/prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus

echo "🧾 Creating systemd service file..."
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd and starting Prometheus..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "✅ Prometheus is running as a service!"
sudo systemctl status prometheus --no-pager
echo "🌐 Access it at: http://localhost:9090"