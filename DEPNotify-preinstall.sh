#!/bin/zsh
## preinstall

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

# Logging function with timestamp.
log() {
	local log_file="/var/log/dep_bootstrap.log"
	local timestamp msg

	if [[ ! -d "$(dirname "$log_file")" ]]; then
		mkdir -p "$(dirname "$log_file")"
	fi

	if [[ ! -f "$log_file" ]]; then
		touch "$log_file"
	fi

	timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
	msg="[$timestamp] $1"
	echo "$msg" | tee -a "$log_file"
}

handle_error() {
	local exit_code=$?
	local line_no="$1"
	local func_name="${FUNCNAME[1]}"
	local command="${BASH_COMMAND}"
	
	log "ERROR: Command failed with exit code ${exit_code}"
	log "ERROR: Failed command: ${command}"
	log "ERROR: Function: ${func_name}"
	log "ERROR: Line number: ${line_no}"
	log "ERROR: Call stack: ${FUNCNAME[*]}"
	
	# Additional context - show recent commands if available
	if command -v fc &> /dev/null; then
		log "ERROR: Recent command history:"
		fc -l -10 2>/dev/null || true
	fi
}

trap 'handle_error $LINENO' ERR

log "Preinstall script started. Starting Rosetta install…"

if /usr/sbin/softwareupdate --install-rosetta --agree-to-license; then
    log "Installed Rosetta successfully."
    exit 0
else
    log "Rosetta reported a non-zero exit code"
    exit 1
fi

