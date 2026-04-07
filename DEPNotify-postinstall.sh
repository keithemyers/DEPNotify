#!/bin/zsh

## Postinstall script for DEPNotify bootstrap process.
## Installs Company Portal and sets up DEPNotify to run after enrollment.

set -E

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

# =====[ Global Variables ]=====
user_type="student" # Options: student, staff

# mspkg="/Library/Shared/CompanyPortal-Installer.pkg"
# msapp="/Applications/Company Portal.app"
# msurl="https://go.microsoft.com/fwlink/?linkid=853070"
DEPNotifyInstallerName=DEPNotify.pkg
DEPNotifyAppPath="/Applications/Utilities/DEPNotify.app"
TempUtilitiesPath=/usr/local/depnotify-with-installers
InstallerBaseString=com.arekdreyer.DEPNotify-prestarter
InstallerScriptName=${InstallerBaseString}-installer.zsh
InstallerScriptPath=${TempUtilitiesPath}/${InstallerScriptName}
DEPNotifyPackagePath="${TempUtilitiesPath}/${DEPNotifyInstallerName}"
UnInstallerScriptName=${InstallerBaseString}-uninstaller.zsh
UnInstallerScriptPath=${TempUtilitiesPath}/${UnInstallerScriptName}
LaunchDaemonName=${InstallerBaseString}.plist
LaunchDaemonPath="/Library/LaunchDaemons"/${LaunchDaemonName}
DEPNOTIFYSTARTER_TRIGGER="start-depnotify-${user_type}"


# =====[ Functions ]=====

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

install_package() {
	package="$1"
	label="$2"

	if [[ ! -f "$package" ]]; then
		log "❌ Package ${package} not found. Cannot install ${label}."
		return 1
	fi

	log "Installing ${label}..."

	install_output=$( installer -dumplog -pkg "$package" -target / 2>&1 )
	local install_exit_code=$?
	
	# Log all output.
	if [[ -n "$install_output" ]]; then
		log "-------[ Installer Output ]-------"
		echo "$install_output" | while IFS= read -r line; do
			log " INSTALLER: ${line}"
		done
		
		log "---------------------------------------"
	else
		log "No output from installer."
	fi

	if [[ $install_exit_code -eq 0 ]]; then
		log "✅ ${label} installer completed successfully (exit code: ${install_exit_code})"
		return 0
	else
		log "❌ ${label} installer failed with exit code: ${install_exit_code}"
		return 1
	fi
}

download_file() {
	url="$1"
	destination="$2"
	
	log "Downloading from ${url} to ${destination}..."
	
	if curl_output=$( curl -Ls -w "HTTP_CODE:%{http_code} | TOTAL_TIME:%{time_total} | SIZE_DOWNLOAD:%{size_download}" -o "$destination" "$url" 2>&1 ); then
		log "✅ Curl completed successfully."
	else
		log "❌ Curl encountered an error."
		return 1
	fi

	# Log all output.
	if [[ -n "$curl_output" ]]; then
		log "$curl_output"
	else
		log "No output from curl."
	fi

	if [[ -f "$destination" ]]; then
		local file_size
		file_size=$( stat -f%z "$destination" 2>/dev/null || echo 0 )

		# Validate file size (threshold: 75MB)
		if [[ "$file_size" -lt 78643200 ]]; then
			log "❌ Downloaded file size is suspiciously small (${file_size} bytes). Possible download error."
			return 1
		fi

		log "✅ Downloaded to ${destination} (${file_size} bytes)."
		return 0
	else
		log "❌ File not found after download."
		return 1
	fi

}

trap 'handle_error $LINENO' ERR

log "======[ Starting enrollment installation process for ${user_type} ]======"

# Handled separately.
# ======[ Install Company Portal ]=====

# if [[ ! -f "$mspkg" ]]; then
# 	log "${mspkg} not found. Attempting download..."
# 	download_file "$msurl" "$mspkg"
# 	sleep 1
# else
# 	install_package "$mspkg" "Microsoft Company Portal"
# 	sleep 1
	
# 	# Verify installation.
# 	if [[ -d "$msapp" ]]; then
# 		log "${msapp} has been installed and confirmed."
# 	else
# 		log "${msapp} installation failed or not found."
# 	fi
# fi

# ======[ Install DEPNotify ]=====

# Create temporary utilities directory.
if [[ ! -d "$TempUtilitiesPath" ]]; then
	log "Creating temporary utilities directory at ${TempUtilitiesPath}."
	mkdir -p "$TempUtilitiesPath"
else
	log "Temporary utilities directory already exists at ${TempUtilitiesPath}."
fi

# Install DEPNotify package.
log "Installing DEPNotify to ${TempUtilitiesPath}."
install_package "$DEPNotifyPackagePath" "DEPNotify"

# Verify DEPNotify installation.
if [[ -d "$DEPNotifyAppPath" ]]; then
	log "✅ DEPNotify installed successfully at ${DEPNotifyAppPath}."
else
	log "❌ DEPNotify installation failed or not found at ${DEPNotifyAppPath}."
fi

# ======[ Installer Script ]=====

log "Creating ${InstallerScriptPath}."
(
cat <<ENDOFINSTALLERSCRIPT
#!/bin/zsh
until [ -f /var/log/jamf.log ]
do
	echo "Waiting for jamf log to appear"
	sleep 1
done
until ( /usr/bin/grep -q enrollmentComplete /var/log/jamf.log )
do
	echo "Waiting for jamf enrollment to be complete."
	sleep 1
done
/usr/local/jamf/bin/jamf policy -event ${DEPNOTIFYSTARTER_TRIGGER}
exit 0

ENDOFINSTALLERSCRIPT
) > "${InstallerScriptPath}"

log "Setting permissions for ${InstallerScriptPath}."
chmod 755 "${InstallerScriptPath}"
chown root:wheel "${InstallerScriptPath}"


# ======[ LaunchDaemon ]=====

log "Creating ${LaunchDaemonPath}."
(
cat <<ENDOFLAUNCHDAEMON
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${InstallerBaseString}</string>
	<key>RunAtLoad</key>
	<true/>
	<key>UserName</key>
	<string>root</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/zsh</string>
		<string>${InstallerScriptPath}</string>
	</array>
	<key>StandardErrorPath</key>
	<string>/var/tmp/${InstallerScriptName}.err</string>
	<key>StandardOutPath</key>
	<string>/var/tmp/${InstallerScriptName}.out</string>
</dict>
</plist>

ENDOFLAUNCHDAEMON
)  > "${LaunchDaemonPath}"

log "Setting permissions for ${LaunchDaemonPath}."
chmod 644 "${LaunchDaemonPath}"
chown root:wheel "${LaunchDaemonPath}"

log "Loading ${LaunchDaemonName}."

# Load the LaunchDaemon.
launchctl bootstrap system "$LaunchDaemonPath"
status_bootstrap=$?

# Wait a moment to ensure the LaunchDaemon has time to load.
sleep 3

# Verify LaunchDaemon is loaded.
launchctl print system/"${InstallerBaseString}" >/dev/null 2>&1
status_print=$?

if [[ $status_bootstrap -eq 0 && $status_print -eq 0 ]]; then
    log "✅ Successfully loaded ${LaunchDaemonName}."
else
    log "❌ Failed to load ${LaunchDaemonName}."
fi


# ======[ Uninstaller Script ]=====

log "Creating ${UnInstallerScriptPath}."
(
cat <<ENDOFUNINSTALLERSCRIPT
#!/bin/zsh
# This is meant to be called by a Jamf Pro policy via trigger
# Near the end of your POLICY_ARRAY in your DEPNotify.sh script

rm ${TempUtilitiesPath}/${DEPNotifyInstallerName}
rm ${InstallerScriptPath}

#Note that if you unload the LaunchDaemon this will immediately kill the depNotify.sh script
#Just remove the underlying plist file, and the LaunchDaemon will not run after next reboot/login.

rm ${LaunchDaemonPath}
rm ${UnInstallerScriptPath}
rmdir ${TempUtilitiesPath}

exit 0
exit 1

ENDOFUNINSTALLERSCRIPT
) > "${UnInstallerScriptPath}"

log "Setting permissions for ${UnInstallerScriptPath}."
chmod 644 "${UnInstallerScriptPath}"
chown root:wheel "${UnInstallerScriptPath}"

log "======[ Installation process complete ]======"
