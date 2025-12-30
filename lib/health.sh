#!/usr/bin/env bash

# ===============================
# syscare - system health checks
# ===============================

# source "$(dirname "$0")/lib/utils.sh"

HEALTH_CPU_STATUS="ok"
HEALTH_MEM_STATUS="ok"
HEALTH_DISK_STATUS="ok"
percent=0
LOAD_1=0
LOAD_5=0
LOAD_15=0

# Defaults (can be overridden via config or CLI)
CPU_THRESHOLD=${CPU_THRESHOLD:-1.0}
MEMORY_THRESHOLD=${MEMORY_THRESHOLD:-80}
DISK_THRESHOLD=${DISK_THRESHOLD:-85}

# ---------- CPU -----------
check_cpu() {
	read -r LOAD_1 LOAD_5 LOAD_15 _ < /proc/loadavg
	CPU_CORES=$(nproc)
	CPU_LIMIT=$(echo "$CPU_CORES * $CPU_THRESHOLD" | bc -l)

	info "CPU Load (1m/5m/15m): $LOAD_1 $LOAD_5 $LOAD_15"

	if (( $(echo "$LOAD_1 > $CPU_LIMIT" | bc -l) )); then
		HEALTH_CPU_STATUS="high"
		warn "High CPU load: load ($LOAD_1) > cores ($CPU_LIMIT)"
	fi 
}


# --------- Memory ---------
check_memory() {

	local used mem_total mem_available
	mem_total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
	mem_available=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
	
	used=$(( $mem_total - $mem_available ))
	percent=$(( used * 100 / mem_total ))

	if (( $percent > MEMORY_THRESHOLD )); then
		HEALTH_MEM_STATUS="high"
		warn "Memory usage high: ${percent}%"
	else 
		info "Memory usage: ${percent}%"
	fi
}

# -------- Disk ---------
check_disk() {
	require_command df
	
	df -h --output=source,pcent,target | tail -n +2 | while read -r fs usage mount; do
		local percent_disk=${usage%\%}

		if (( $percent_disk > DISK_THRESHOLD ));then
			HEALTH_DISK_STATUS="high"
			warn "Disk usage high on $mount: ${usage}"
		else
			info "Disk usage on $mount: ${usage}"
		fi
	done
}

get_health_json() {
	cat <<EOF
{
  	"cpu": {
		"status": "$HEALTH_CPU_STATUS",
    	"load_1m": "$LOAD_1",
    	"threshold": "$CPU_THRESHOLD"
  	},
  	"memory": {
    	"status": "$HEALTH_MEM_STATUS",
		"usage_percent": "$percent",
		"threshold": "$MEMORY_THRESHOLD"
	},
	"disk": {
		"status": "$HEALTH_DISK_STATUS",
		"threshold": "$DISK_THRESHOLD"
	}
}
EOF
}

# --------- Run ----------
run_health_checks() {
	# parse CLI overrides passed to the run function
	for arg in "$@"; do
		case $arg in
			--cpu-threshold=*) CPU_THRESHOLD="${arg#*=}" ;;
			--memory-threshold=*) MEMORY_THRESHOLD="${arg#*=}" ;;
			--disk-threshold=*) DISK_THRESHOLD="${arg#*=}" ;;
		esac
	done

	info "Running system health checks..."

	check_cpu
	check_memory
	check_disk
	# get_health_json
}