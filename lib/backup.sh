#!/usr/bin/env bash

# ===============================
# syscare - backup module
# ===============================

source "$(dirname "$0")/lib/utils.sh"

BACKUP_SOURCE="$PROJECT_ROOT"
BACKUP_DIR="$PROJECT_ROOT/backups"
RETENTION_COUNT=${RETENTION_COUNT:-5}
archive=""

for arg in "$@"; do
    case $arg in
        --retain=*) RETENTION_COUNT="${arg#*=}" ;;
    esac
done

# ------ Create backup -------
run_backup() {
	require_command tar

	mkdir -p "$BACKUP_DIR"

	local timestamp
	timestamp="$(date --iso-8601=seconds)"
	archive="$BACKUP_DIR/backup-$timestamp.tar.gz"

	info "Starting backup of $BACKUP_SOURCE"
	info "Creating archive" $(basename "$archive")

	tar --exclude="$(basename "$BACKUP_DIR")" \
	-czf "$archive" -C "$(dirname "$BACKUP_SOURCE")" "$(basename "$BACKUP_SOURCE")" #-czvf for listing files during backup 

	info "Backup completed successfully"
	rotate_backups
}

get_backup_json() {
	cat<<EOF
	{
		"status": "ok",
		"archive": "$(basename "$archive")",
		"retention_count": "$RETENTION_COUNT"
	}
EOF
}


# ------- Rotation --------
rotate_backups() {
	info "Applying backup rotation (keep last $RETENTION_COUNT)"
	ls -1t "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | tail -n +"$((RETENTION_COUNT + 1))" | while read -r old_backup; do
		warn "Removing old backup: $(basename "$old_backup")"
		rm -r "$old_backup"
	done
	# get_backup_json
}