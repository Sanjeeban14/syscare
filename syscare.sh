#!/usr/bin/env bash

#load common utilities
source "$(dirname "$0")/lib/utils.sh"
source "$(dirname "$0")/lib/health.sh"

case "${1:-}" in
	check)
		run_health_checks
		;;
	*)
		echo "Usage: $0 check"
		;;
esac
