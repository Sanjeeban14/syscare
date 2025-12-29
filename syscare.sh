#!/usr/bin/env bash

#load common utilities
source "$(dirname "$0")/lib/utils.sh"
source "$(dirname "$0")/lib/health.sh"
source "$(dirname "$0")/lib/cleanup.sh"
source "$(dirname "$0")/lib/backup.sh"

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


