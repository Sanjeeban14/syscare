#!/usr/bin/env bash
# set -x
# ===============================
# syscare - common utilities
# ===============================

# Exit immediately on error, unset variable, or failure pipe
set -euo pipefail

OUTPUT_JSON="$SYSCARE_ROOT/out.json"

#---------------------------------
# Path resolution (dev vs installed)
#----------------------------------

UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSCARE_CODE_ROOT="$(cd "$UTILS_DIR/.." && pwd)"

if [[ "$SYSCARE_CODE_ROOT" == "/usr/local/lib/syscare" ]]; then
	SYSCARE_MODE="installed"
else
	SYSCARE_MODE="dev"
fi

# Paths by mode

if [[ "$SYSCARE_MODE" == "installed" ]]; then
	CONFIG_FILE="/etc/syscare/syscare.conf"
	LOG_FILE="/var/log/syscare/syscare.log"
	DATA_DIR="/var/lib/syscare"
	PENDING_DIR="$DATA_DIR/reports/pending"
else
	CONFIG_FILE="$SYSCARE_CODE_ROOT/config/syscare.conf"
	LOG_FILE="$SYSCARE_CODE_ROOT/logs/syscare/log"
	DATA_DIR="$SYSCARE_CODE_ROOT/backups"
	PENDING_DIR="$SYSCARE_CODE_ROOT/reports/pending"
fi


with_module() {	
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

# -------- Config Loading ---------

if [[ -f "$CONFIG_FILE" ]]; then
	source "$CONFIG_FILE"
  	with_module "general" info "Loaded config from $CONFIG_FILE"
else
	with_module "general" warn "Config file not found: $CONFIG_FILE, using defaults"
fi


# --------- Writing JSON files ---------
emit_full_report() {
	local timestamp
	timestamp="$(date --iso-8601=seconds)"

	cat > "$OUTPUT_JSON" <<EOF 
	{
		"timestamp": "$timestamp",
		"health": $(get_health_json),
		"cleanup": $(get_cleanup_json),
		"backup": $(get_backup_json)
	}
EOF
}
emit_health_report() {
	local timestamp
	timestamp="$(date --iso-8601=seconds)"

	cat > "$OUTPUT_JSON" <<EOF 
	{
		"timestamp": "$timestamp",
		"health": $(get_health_json)
	}
EOF
}
emit_cleanup_report() {
	local timestamp
	timestamp="$(date --iso-8601=seconds)"

	cat > "$OUTPUT_JSON" <<EOF 
	{
		"timestamp": "$timestamp",
		"cleanup": $(get_cleanup_json)
	}
EOF
}
emit_backup_report() {
	local timestamp
	timestamp="$(date --iso-8601=seconds)"

	cat > "$OUTPUT_JSON" <<EOF 
	{
		"timestamp": "$timestamp",
		"backup": $(get_backup_json)
	}
EOF
}

# ----- Retry Queue -----
queue_report() {
	local json_file="$1"
	local ts="$(date +%s)"
	cp "$json_file" "$PENDING_DIR/report-$ts.json"
	warn "Report queued for retry"
}

# ------ Backend Reporting ------

post_json() {
	local file="$1"

	curl -s -X POST "$BACKEND_URL" \
		-H "Content-Type: application/json" \
		-d @"$file"
}

flush_pending_reports() {
	[[ ! -d "$PENDING_DIR" ]] && return 0

	for file in "$PENDING_DIR"/*.json; do
		[[ -e "$file" ]] || return 0

		curl -sf "$BACKEND_HEALTH_URL" >/dev/null || return 0

		if post_json "$file"; then
			rm -f "$file"
			info "Sent queued report: $(basename "$file")"
		else
			return 0
		fi
	done
}

send_report() {
	local json_file="$1"

	[[ "${BACKEND_ENABLED:-false}" != "true" ]] && return 0 # backend inactive

	[[ ! -f "${json_file}" ]] && return 0 # no json

	mkdir -p "$PENDING_DIR"

	flush_pending_reports

	#health check for fast fail
	if ! curl -sf "$BACKEND_HEALTH_URL" >/dev/null; then
		queue_report "$json_file"
		warn "Backend unavailable, will try to report next time"
		return 0
	fi

	# sending report
	if ! post_json "$json_file"; then
		queue_report "$json_file"
	fi
}