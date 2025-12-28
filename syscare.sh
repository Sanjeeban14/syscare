#!/usr/bin/env bash

#load common utilities
source "$(dirname "$0")/lib/utils.sh"
source "$(dirname "$0")/lib/health.sh"
source "$(dirname "$0")/lib/cleanup.sh"
source "$(dirname "$0")/lib/backup.sh"

case "${1:-}" in
	check)
		run_health_checks
		;;
	cleanup)
		run_cleanup
		;;
	backup)
		run_backup
		;;
	*)
		echo "Usage: $0 {check|cleanup}"
		;;
esac
