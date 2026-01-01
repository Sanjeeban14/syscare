#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

INSTALL_DIR="/usr/local/lib/syscare"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="/etc/syscare"
LOG_DIR="/var/log/syscare"
DATA_DIR="/var/lib/syscare"

echo "Creating directories..."
sudo mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$LOG_DIR" "$DATA_DIR"

echo "Copying core files..."
sudo cp -r "$SRC_DIR/lib" "$INSTALL_DIR/"
sudo cp "$SRC_DIR/syscare.sh" "$INSTALL_DIR/"

echo "Copying config..."
sudo cp "$SRC_DIR/config/syscare.conf" "$CONFIG_DIR/"

echo "Installing syscare binary..."
sudo install -m 755 "$SRC_DIR/bin/syscare" "$BIN_DIR/syscare"

echo "Creating data directories..."
sudo mkdir -p "$DATA_DIR/reports/pending"

if [[ -d "$SRC_DIR/systemd" ]]; then
    echo "Installing systemd units..."
    sudo cp "$SRC_DIR/systemd/"*.service "$SRC_DIR/systemd/"*.timer /etc/systemd/system
    sudo systemctl daemon-reload

    echo "Systemd units installed."
    echo "Enable with:"
    echo " sudo systemctl enable --now syscare.timer"
fi