#!/usr/bin/env bash

# ===============================
# syscare - backup module
# ===============================

archive=""

# Backup pths based on mode
if [[ "$SYSCARE_MODE" == "dev" ]]; then
	BACKUP_SOURCE="$SYSCARE_CODE_ROOT"
	BACKUP_DIR="$SYSCARE_CODE_ROOT/backups"
else
	BACKUP_SOURCE="/etc/syscare"
	BACKUP_DIR="$DATA_DIR/backups"
fi

# ------ Create backup -------
run_backup() {
	RETENTION_COUNT=${RETENTION_COUNT:-5}

	for arg in "$@"; do
		case $arg in
			--retain=*) RETENTION_COUNT="${arg#*=}" ;;
		esac
	done

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
		rm -f "$old_backup"
	done
}