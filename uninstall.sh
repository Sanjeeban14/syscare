#!/usr/bin/env bash
set -euo pipefail

echo "Uninstalling syscare agent..."

# systemd
if systemctl list-unit-files | grep -q syscare.timer; then
    sudo systemctl disable --now syscare.timer || true
fi

if systemctl list-unit-files | grep -q syscare.service; then
    sudo systemctl disable --now syscare.service || true
fi

sudo rm -f /etc/systemd/system/syscare.service
sudo rm -f /etc/systemd/system/syscare.timer
sudo systemctl daemon-reload

# binaries & libs
sudo rm -f /usr/local/bin/syscare
sudo rm -rf /usr/local/lib/syscare

# config
sudo rm -rf /etc/syscare

# data & logs (explicit delete)
sudo rm -rf /var/log/syscare
sudo rm -rf /var/lib/syscare

echo "Syscare agent uninstalled successfully."
