#!/usr/bin/env bash

run_temp_cleanup() {

    local apply=false
    local purge=false

    for arg in "$@"; do
        case "$arg" in
            --apply)
                apply=true
                ;;
            --purge)
                purge=true
                ;;
        esac
    done

    info "Scanning temporary locations..."

    local locations=(
        "/tmp"
        "$HOME/.cache"
        "$HOME/.local/share/Trash/files"
    )

    local total_bytes=0

    for dir in "${locations[@]}"; do

        info "Checking: $dir"

        if [[ ! -d "$dir" ]]; then
            warn "Directory not found: $dir"
            continue
        fi

        local files=0
        local size=0

        files=$(find "$dir" -type f 2>/dev/null | wc -l || echo 0)

        size=$(du -sb "$dir" 2>/dev/null | awk '{print $1}' || echo 0)

        [[ "$size" =~ ^[0-9]+$ ]] || size=0

        total_bytes=$((total_bytes + size))

        info "Directory: $dir"
        info "Files: $files"
        info "Size: $(numfmt --to=iec "$size")"

    done

    info "Total reclaimable space: $(numfmt --to=iec "$total_bytes")"

    # DRY RUN
    if [[ "$apply" == false && "$purge" == false ]]; then
        TEMP_CLEANUP_MODE="dry-run"
        TEMP_RECLAIMABLE_BYTES="$total_bytes"
        info "Dry-run mode"
        info "Run with --apply to clean cache/trash"
        info "Run with --purge for aggressive cleanup"
        return 0
    fi

    # SAFE CLEANUP
    if [[ "$apply" == true ]]; then
        TEMP_CLEANUP_MODE="apply"
        TEMP_RECLAIMABLE_BYTES="$total_bytes"
        info "Starting safe cleanup..."

        find "$HOME/.cache" \
            -type f \
            -delete 2>/dev/null || true

        find "$HOME/.local/share/Trash/files" \
            -type f \
            -delete 2>/dev/null || true

        info "Safe cleanup completed"

        emit_temp_cleanup_report "apply" "$total_bytes"

        return 0
    fi

    # AGGRESSIVE CLEANUP
    if [[ "$purge" == true ]]; then
        TEMP_CLEANUP_MODE="purge"
        TEMP_RECLAIMABLE_BYTES="$total_bytes"
        info "Starting aggressive cleanup..."

        find "$HOME/.cache" \
            -type f \
            -delete 2>/dev/null || true

        find "$HOME/.local/share/Trash/files" \
            -type f \
            -delete 2>/dev/null || true

        find /tmp \
            -type f \
            -delete 2>/dev/null || true

        info "Aggressive cleanup completed"

        emit_temp_cleanup_report "purge" "$total_bytes"

        return 0
    fi
}

get_temp_cleanup_json() {

    cat <<EOF
{
    "mode": "${TEMP_CLEANUP_MODE}",
    "estimated_reclaimed_bytes": ${TEMP_RECLAIMABLE_BYTES}
}
EOF

}