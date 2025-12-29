#!/usr/bin/env bash
# set -x
# ===============================
# syscare - common utilities
# ===============================

# Exit immediately on error, unset variable, or failure pipe
set -euo pipefail

# Project root directory (absolute path)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default log file 
LOG_FILE="$PROJECT_ROOT/logs/syscare.log"


with_module() {
	
		# subshell = isolated scope
		local MODULE_NAME="$1"
		shift
			"$@"
	
}


# ---------- Colors ----------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# --------- Logging ----------
log_json(){
	local level="$1"
	local module="$2"
	local message="$3"
	local timestamp

	# timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
	timestamp="$(date --iso-8601=seconds)"
	mkdir -p "$(dirname "$LOG_FILE")"
#	echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
	echo "{\"timestamp\":\"$timestamp\",\"module\":\"$module\",\"level\":\"$level\",\"message\":\"$message\"}" >> "$LOG_FILE"

}


info(){
	local module="${MODULE_NAME:-general}"
	echo -e "${BLUE}[INFO]${RESET} $1" >&2
	log_json "INFO" "$module" "$1"
}
warn(){
	local module="${MODULE_NAME:-general}"
	echo -e "${YELLOW}[WARN]${RESET} $1" >&2
	log_json "WARN" "$module" "$1"
}
error(){
	local module="${MODULE_NAME:-general}"
	echo -e "${RED}[ERROR]${RESET} $1" >&2
	log_json "ERROR" "$module" "$1"
}

# --------- Safety ---------
require_command() {
	command -v "$1" >/dev/null 2>&1 || {
		error "Require command '$1' not found"
		exit 1
	}
}

# Default config file (local for testing)
CONFIG_FILE="$PROJECT_ROOT/config/syscare.conf"

if [[ -f "$CONFIG_FILE" ]]; then
	source "$CONFIG_FILE"
  	with_module "general" info "Loaded config from $CONFIG_FILE"
else
	with_module "general" warn "Config file not found: $CONFIG_FILE, using defaults"
fi