#!/usr/bin/env bash
set -euo pipefail

echo "Uninstalling syscare backend..."

# systemd
if systemctl list-unit-files | grep -q syscare-backend.service; then
    sudo systemctl disable --now syscare-backend.service || true
fi

sudo rm -f /etc/systemd/system/syscare-backend.service
sudo systemctl daemon-reload

# backend files
sudo rm -rf /usr/local/lib/syscare-backend

# data & logs
sudo rm -rf /var/lib/syscare-backend
sudo rm -rf /var/log/syscare-backend

echo "Syscare backend uninstalled successfully."
