#!/usr/bin/env bash

# ===============================
# syscare - system health checks
# ===============================

source "$(dirname "$0")/lib/utils.sh"

HEALTH_CPU_STATUS="ok"
HEALTH_MEM_STATUS="ok"
HEALTH_DISK_STATUS="ok"


# ---------- CPU -----------
check_cpu() {
	read -r LOAD_1 LOAD_5 LOAD_15 _ < /proc/loadavg
	CPU_CORES=$(nproc)

	info "CPU Load (1m/5m/15m): $LOAD_1 $LOAD_5 $LOAD_15"

	if (( $(echo "$LOAD_1 > $CPU_CORES" | bc -l) )); then
		HEALTH_CPU_STATUS="high"
		warn "High CPU load: load ($LOAD_1) > cores ($CPU_CORES)"
	fi 
}


# --------- Memory ---------
check_memory() {

	local used mem_total mem_available percent 
	mem_total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
	mem_available=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
	
	used=$(( $mem_total - $mem_available ))
	percent=$(( used * 100 / mem_total ))

	if (( percent > 80 )); then
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
		local percent=${usage%\%}

		if (( percent > 85 ));then
			HEALTH_DISK_STATUS="high"
			warn "Disk usage high on $mount: ${usage}"
		else
			info "Disk usage on $mount: ${usage}"
		fi
	done
}

# --------- Run ----------
run_health_checks() {
	info "Running system health checks..."

	check_cpu
	check_memory
	check_disk


	cat <<EOF
	{
	  "cpu": "$HEALTH_CPU_STATUS",
	  "memory": "$HEALTH_MEM_STATUS",
	  "disk": "$HEALTH_DISK_STATUS"
	}
EOF

}
