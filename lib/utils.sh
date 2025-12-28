#!/usr/bin/env bash

# ===============================
# syscare - common utilities
# ===============================

# Exit immediately on error, unset variable, or failure pipe
set -euo pipefail

# Project root directory (absolute path)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default log file 
LOG_FILE="$PROJECT_ROOT/logs/syscare.log"

# ---------- Colors ----------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# --------- Logging ----------
log(){
	local level="$1"
	local message="$2"
	local timestamp

	timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

	mkdir -p "$(dirname "$LOG_FILE")"
	echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}
info(){
	echo -e "${BLUE}[INFO]${RESET} $1"
	log "INFO" "$1"
}
warn(){
	echo -e "${YELLOW}[WARN]${RESET} $1"
	log "WARN" "$1"
}
error(){
	echo -e "${RED}[ERROR]${RESET} $1"
	log "ERROR" "$1"
}

# --------- Safety ---------
require_command() {
	command -v "$1" >/dev/null 2>&1 || {
		error "Require command '$1' not found"
		exit 1
	}
}
