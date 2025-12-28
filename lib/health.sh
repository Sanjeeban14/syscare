#!/usr/bin/env bash

# ===============================
# syscare - system health checks
# ===============================

source "$(dirname "$0")/lib/utils.sh"

# ---------- CPU -----------
check_cpu() {
	require_command uptime

	local load
	load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)
	
	info "CPU Load (1 min): $load"
}

# --------- Memory ---------
check_memory() {
	require_command free

	local used total percent 
	read -r _ total used _ < <(free -m | awk '/Mem:/ {print $2, $3}') #total and used are two variables here assigned their respective values in megabytes (-m)
	
	percent=$(( used * 100 / total ))

	if (( percent > 80 )); then
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
}
