#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_SRC="$SRC_DIR/syscare-backend"
REQUIRED_NODE_MAJOR=18

BACKEND_INSTALL_DIR="/usr/local/lib/syscare-backend"
DATA_DIR="/var/lib/syscare-backend"
LOG_DIR="/var/lib/syscare-backend"

SYSTEMD_DIR="/etc/systemd/system"
SERVICE_FILE="syscare-backend.service"

echo "Installing syscare backend..."

# -------- Helpers --------
has_node() {
	command -v node >/dev/null 2>&1
}

node_major_version() {
	node -v | sed 's/v//' | cut -d. -f1
}

install_node() {
	echo "Installing Node.js $REQUIRED_NODE_MAJOR..."
	curl -fsSL https://deb.nodesource.com/setup_$REQUIRED_NODE_MAJOR.x | sudo -E bash -
	sudo apt-get install -y nodejs
}

# -------- Node check --------
if ! has_node; then
	echo "Node.js is not installed."
	read -rp "Install Node.js $REQUIRED_NODE_MAJOR now? [y/N]: " ans
	[[ "$ans" =~ ^[Yy]$ ]] || {
		echo "Node.js required. Aborting."
		exit 1
	}
	install_node
else
	NODE_MAJOR="$(node_major_version)"
	if (( NODE_MAJOR < REQUIRED_NODE_MAJOR )); then
		echo "Node.js version $NODE_MAJOR detected (>= $REQUIRED_NODE_MAJOR required)."
		read -rp "Upgrade Node.js to $REQUIRED_NODE_MAJOR? [y/N]: " ans
		[[ "$ans" =~ ^[Yy]$ ]] || {
			echo "Node.js >= $REQUIRED_NODE_MAJOR required. Aborting."
			exit 1
		}
		install_node
	fi
fi

echo "Node.js OK: $(node -v)"
echo "npm OK: $(npm -v)"
# -----Installing backend-----
echo "Creating backend directories..."
sudo mkdir -p "$BACKEND_INSTALL_DIR" "$DATA_DIR" "$LOG_DIR"

echo "Copying backend source..."
sudo cp -r "$BACKEND_SRC/"* "$BACKEND_INSTALL_DIR/"

echo "Installing backend dependencies..."
sudo npm install --prefix "$BACKEND_INSTALL_DIR" --production

#Permissions
sudo chown -R root:root "$BACKEND_INSTALL_DIR" "$DATA_DIR" "$LOG_DIR"

#systemd
if [[ -f "$SRC_DIR/systemd/$SERVICE_FILE" ]]; then
	echo "Installing systemd service..."
	sudo cp "$SRC_DIR/systemd/$SERVICE_FILE" "$SYSTEMD_DIR"
	sudo systemctl daemon-reload

	echo
	echo "Backend service installed."
	echo "Enable and start with:"
	echo "  sudo systemctl enable --now syscare-backend.service"
else
	echo "WARNING: systemd service file not found: $SERVICE_FILE"
fi

echo
echo "Syscare backend installation complete."