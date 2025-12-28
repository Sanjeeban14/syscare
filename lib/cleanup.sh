#!/usr/bin/env bash

# ============================
# syscare - cleanup module
# ============================

source "$(dirname "$0")/lib/utils.sh"

#Defaults
DAYS_OLD=7
DRY_RUN=true

for arg in "$@"; do
	case $arg in
		--apply) DRY_RUN=false ;;
		--days=*) DAYS_OLD="${ARG#*=}" ;;
	esac
done

# ----------- File Cleanup ------------
cleanup_directory() {
	local dir="$1"
	if [[ ! -d "$dir" ]]; then
		warn "Directory not found: $dir"
		return
	fi
	
	info "Scanning $dir for files older than $DAYS_OLD days"

	find "$dir" -type f -mtime +"$DAYS_OLD" | while read -r file; do
		if [[ "$DRY_RUN" == true ]]; then
			warn "[DRY_RUN] Would delete: $file" 
		else
			info "Deleting: $file"
			rm -f "$file"
		fi
	done
}

# --------- Run Cleanup --------
run_cleanup() {
	info "Starting cleanup process"
	info "Dry-run mode: $DRY_RUN"

	cleanup_directory "$PROJECT_ROOT/logs"
	cleanup_directory "$PROJECT_ROOT/reports"

	info "Cleanup completed"
}
