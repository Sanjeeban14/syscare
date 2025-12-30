#!/usr/bin/env bash

# ===============================
# syscare - entrypoint
# ===============================

# Detect project root (dev vs installed)
if [[ -d "$(dirname "$0")/lib" ]]; then
	# Repo / dev mode
	SYSCARE_ROOT="$(cd "$(dirname "$0")" && pwd)"
else
	# Installed mode
	SYSCARE_ROOT="/usr/local/lib/syscare"
fi

export SYSCARE_ROOT

# Load common utilities and modules
source "$SYSCARE_ROOT/lib/utils.sh"
source "$SYSCARE_ROOT/lib/health.sh"
source "$SYSCARE_ROOT/lib/cleanup.sh"
source "$SYSCARE_ROOT/lib/backup.sh"
 

trap 'warn "Syscare received SIGTERM; exiting cleanly"; exit 0' SIGTERM

emit_full_report() {
	local timestamp
	timestamp="$(date --iso-8601=seconds)"

	cat <<EOF
	{
		"timestamp": "$timestamp",
		"health": $(get_health_json),
		"cleanup": $(get_cleanup_json),
		"backup": $(get_backup_json)
	}
EOF
}

START_TIME_NS=$(date +%s%N)
case "${1:-}" in
	check)
		with_module "health" run_health_checks "${@:2}"
		;;
	cleanup)
		with_module "cleanup" run_cleanup "${@:2}"
		;;
	backup)
		with_module "backup" run_backup "${@:2}"
		;;
	all)
		info "Running all system modules..."
		with_module "health" run_health_checks "${@:2}"
		with_module "cleanup" run_cleanup "${@:2}"
		with_module "backup" run_backup "${@:2}"
		info "All tasks completed"
		emit_full_report
		;;
	*)
		echo "Usage: $0 {check|cleanup|backup|all}" >&2
		;;
esac
END_TIME_NS=$(date +%s%N)
DURATION=$(( ($END_TIME_NS - $START_TIME_NS) / 1000000 ))

info "Health checks completed in ${DURATION} ms"


