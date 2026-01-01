#!/usr/bin/env bash

# ============================
# syscare - cleanup module
# ============================

# Defaults
DAYS_OLD=${CLEANUP_DAYS:-7}
DELETED_COUNT=0
DRY_RUN=${DRY_RUN:-true}

# ----------- File Cleanup ------------
cleanup_directory() {
	local dir="$1"
	if [[ ! -d "$dir" ]]; then
		warn "Directory not found: $dir"
		return
	fi
	
	info "Scanning $dir for files older than $DAYS_OLD days"

	while read -r file; do
		if [[ "$DRY_RUN" == true ]]; then
			warn "[DRY_RUN] Would delete: $file" 
		else
			warn "Deleting: $file"
			rm -f "$file"
			DELETED_COUNT=$(( DELETED_COUNT + 1 ))
		fi
	done < <(find "$dir" -type f -mtime +"$DAYS_OLD")
}

get_cleanup_json() {
	cat <<EOF
	{
		"status": "ok",
		"deleted_files": $DELETED_COUNT,
		"dry_run": $DRY_RUN,
		"days": $DAYS_OLD
	}
EOF
}


# --------- Run Cleanup --------
run_cleanup() {
	# parse CLI overrides passed to the run function
	for arg in "$@"; do
		case $arg in
			--apply) DRY_RUN=false ;;
			--days=*) DAYS_OLD="${arg#*=}" ;;
		esac
	done

	info "Starting cleanup process"
	info "Dry-run mode: $DRY_RUN"

	cleanup_directory "$(dirname "$LOG_FILE")"
	
	if [[ "$SYSCARE_MODE" == "dev" ]]; then
		cleanup_directory "$SYSCARE_CODE_ROOT/reports"
	fi

	info "Cleanup completed"
}
