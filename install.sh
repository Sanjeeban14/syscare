#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

INSTALL_DIR="/usr/local/lib/syscare"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="/etc/syscare"
LOG_DIR="/var/log/syscare"
DATA_DIR="/var/lib/syscare"

TARGET_USER="${SUDO_USER:-$USER}"

echo "Creating directories..."

sudo mkdir -p "$INSTALL_DIR"
sudo mkdir -p "$CONFIG_DIR"

sudo mkdir -p "$LOG_DIR"

sudo mkdir -p "$DATA_DIR/backups"
sudo mkdir -p "$DATA_DIR/reports"
sudo mkdir -p "$DATA_DIR/reports/pending"

echo "Creating log file..."

sudo touch "$LOG_DIR/syscare.log"

echo "Setting ownership..."

sudo chown "$TARGET_USER:$TARGET_USER" "$LOG_DIR/syscare.log"
sudo chown -R "$TARGET_USER:$TARGET_USER" "$DATA_DIR"

echo "Copying core files..."

sudo rm -rf "$INSTALL_DIR/lib"

sudo cp -r "$SRC_DIR/lib" "$INSTALL_DIR/"
sudo cp "$SRC_DIR/syscare.sh" "$INSTALL_DIR/"

echo "Copying config..."

sudo cp "$SRC_DIR/config/syscare.conf" "$CONFIG_DIR/"

echo "Installing syscare binary..."

sudo install -m 755 "$SRC_DIR/bin/syscare" "$BIN_DIR/syscare"

if [[ -d "$SRC_DIR/systemd" ]]; then

    echo "Installing systemd units..."

    sudo cp \
        "$SRC_DIR/systemd/"*.service \
        "$SRC_DIR/systemd/"*.timer \
        /etc/systemd/system/

    sudo systemctl daemon-reload

    echo "Systemd units installed."
    echo "Enable with:"
    echo "  sudo systemctl enable --now syscare.timer"
fi

echo
echo "Installation complete."
echo
echo "Logs:"
echo "  $LOG_DIR/syscare.log"
echo
echo "Backups:"
echo "  $DATA_DIR/backups"
echo
echo "Reports:"
echo "  $DATA_DIR/reports"