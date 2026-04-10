#!/bin/zsh

ENROLLMENT_TYPE="STUDENT"
JAMF_PROTECT_TENANT="smeds.protect"
FV_ENABLED=false
BTENFORCE=false
START_DATE=$( TZ="America/New_York" date +"%Y-%m-%d %H:%M:%S" )
SECONDS=0
JAMF_BINARY="/usr/local/bin/jamf"
WARN_SEC_TOKEN=false

log_file="/var/log/dep-lab-smeds.log"
task_file="/var/log/dep-lab-smeds-task.txt"

Start-Log () {
	local script_name="$1"

	if [[ -z $script_name ]]; then
		echo "Error: Script name required." >&2
		return 1
	fi
	
	local dt=$( date +"%Y-%m-%d %H:%M:%S" )
	
	if [[ ! -d $log_file ]]; then
		touch "$log_file" 
	fi
	
	echo -e "════════[ ${dt}: Starting ${script_name} ]════════" | tee -a "$log_file"
	
	if [[ ! -f "$log_file" ]]; then
		echo "⚠️  WARNING: The log file could not be found."
	fi
}

## Add the date and time stamp to the log file.
Append-Log () {
	local message="$1"
	local dt=$( date +"%Y-%m-%d %H:%M:%S" )
	echo "${dt} -- ${message}" | tee -a "$log_file"
}

Start-Log "DEP-LAB-smeds.sh"


POLICY_ARRAY=(

	" Configuring default interface    ,set-dark-mode"
	" Installing swiftDialog           ,install-dialog"
	" Installing Bluetooth utility     ,install-blueutil"
	" Setting the time zone            ,set-timezone"
	" Installing Google Chrome         ,installChrome"
	" Installing Jamf Protect          ,jamfprotect"
	" Installing Dock Utility          ,dockutil"
	" Generating enrollment receipt    ,enrollment-receipt"
	" Configuring the computer name    ,rename-shared-computer"
	" Installing btenforce             ,install-btenforce"
	" Installing Lightspeed Filter     ,install-lightspeed"
)

for POLICY in "${POLICY_ARRAY[@]}"; do
    
	desc="${POLICY%%,*}"
	trigger="${POLICY#*,}"

	if "$JAMF_BINARY" policy -event "$trigger"; then
		Append-Log "[✅] $desc | $trigger"
	else
		Append-Log "[❌] $desc | $trigger"
	fi
done

echo "Policy iteration complete."

chrome="/Applications/Google Chrome.app"
token_status=$( dscl . -read /Users/hadmin AuthenticationAuthority | grep -o SecureToken )
timezone=$( date +"%Z %z" )

echo -e "\n\n" >> "$task_file"
echo -e "                       ╔════════════════════════╗ " >> "$task_file"
echo -e "═══════════════════════╣   ENROLLMENT CHECKS    ╠════════════════════════" >> "$task_file"
echo -e "                       ╚════════════════════════╝ \n" >> "$task_file"


# 1. Check that Chrome is installed and run the policy if it is not.
if [[ ! -e "$chrome" ]]; then
	"$JAMF_BINARY" policy -event installChrome
  if [[ ! -e "$chrome" ]]; then
    echo -e "[❌] Install Google Chrome because it is missing after two tries. ⚠️ MUST BE RESOLVED PRIOR TO DISTRIBUTION" >> "$task_file"
  else
    echo -e "[✅] Google Chrome is installed (second try)." >> "$task_file"
  fi
else
	echo -e "[✅] Google Chrome is installed." >> "$task_file"
fi

# 2. Check that the timezone is set to EDT/EST and run the policy if it is not.
if [[ "$timezone" == "EDT -0400" || "$timezone" == "EST -0500" ]]; then
	echo -e "[✅] Timezone is set to EDT/EST." >> "$task_file"
else
	"$JAMF_BINARY" policy -event set-timezone
	if [[ "$timezone" == "EDT -0400" || "$timezone" == "EST -0500" ]]; then
		echo -e "[✅] Timezone is correct. Set to ${timezone}." >> "$task_file"
	else
		echo -e "[❌] Could not correct the timezone." >> "$task_file"
	fi
fi

# 3. Check that swiftDialog is installed and run the policy if it is not.
dialog=$( which dialog )
if [[ -z "$dialog" ]]; then
	"$JAMF_BINARY" policy -event install-dialog
	dialog=$( which dialog )
	if [[ -z "$dialog" ]]; then
		echo -e "[❌] swift Dialog is missing. Rerun policy." >> "$task_file"
	else
		echo -e "[✅] swiftDialog is installed (second try)." >> "$task_file"
	fi
else
	echo -e "[✅] swiftDialog is installed." >> "$task_file"
fi

# 4. Check that dockutil is installed and run the policy if it is not.
dockutilbin=$( which dockutil )
if [[ -z "$dockutilbin" ]]; then
	"$JAMF_BINARY" policy -event dockutil
	dockutilbin=$( which dockutil )
	if [[ -z "$dockutilbin" ]]; then
		echo -e "[❌] Dockutil is missing. Second attempt failed. Please troubleshoot." >> "$task_file"
	else
		"$JAMF_BINARY" policy -event dockutil
		echo -e "[✅] Dockutil is installed (second try)." >> "$task_file"
	fi
else
	echo -e "[✅] Dockutil is installed." >> "$task_file"
fi

# 5. Check that FileVault is enabled and run the policy if it is not.
if [[ "$FV_ENABLED" = true ]]; then
	fvstatus=$( fdesetup status )
	if [[ "$fvstatus" == "FileVault is On." ]]; then
		echo -e "[✅] FileVault is enabled." >> "$task_file"
	else
		echo -e "[❌] FileVault is NOT enabled. ⚠️" >> "$task_file"
	fi
fi

if [[ "$WARN_SEC_TOKEN" = true ]]; then
  # 7. Check that the SecureToken for hadmin is present and run the policy if it is not.
  token_status=$( dscl . -read /Users/hadmin AuthenticationAuthority | grep -o SecureToken )
  if [[ -z $token_status ]]; then
    echo -e "[⚠️] SecureToken is missing. Please contact the IT Helpdesk.\n" >> "$task_file"
  else
    echo -e "[✅] Secure Token has been assigned to hadmin.\n" >> "$task_file"
  fi
fi

lightspd_status=$( systemextensionsctl list | grep "lightspeed" | awk '{ print $9, $10 }' )
if [[ "$lightspd_status" == "[activated enabled]" ]]; then
  echo -e "[✅] Lightspeed filter is enabled." >> "$task_file"
else
  "$JAMF_BINARY" policy -event install-lightspeed
  sleep 2
  lightspd_status=$( systemextensionsctl list | grep "lightspeed" | awk '{ print $9, $10 }' )
  if [[ "$lightspd_status" == "[activated enabled]" ]]; then
    echo -e "[✅] Lightspeed filter is enabled." >> "$task_file"
  else
    echo -e "[❌] Lightspeed filter is NOT enabled after second try." >> "$task_file"
  fi
fi

jprotect="/usr/local/bin/protectctl"
jprotect_status=$( "$jprotect" info --plain | grep -i Tenant | awk '{ print $2 }' 2> /dev/null )
if [[ "$jprotect_status" == "$JAMF_PROTECT_TENANT" ]]; then
  echo -e "[✅] Jamf Protect is enabled." >> "$task_file"
else
  "$JAMF_BINARY" policy -event install-jprotect
  sleep 2
  jprotect_status=$( "$jprotect" info --plain | grep -i Tenant | awk '{ print $2 }' )
  if [[ "$jprotect_status" == "$JAMF_PROTECT_TENANT" ]]; then
    echo -e "[✅] Jamf Protect is enabled after second try." >> "$task_file"
  else
    echo -e "[❌] Jamf Protect is NOT enabled after second try." >> "$task_file"
  fi
fi

if [[ "$BTENFORCE" = true ]]; then
  btenforce_status=$( launchctl list | grep itech | awk '{ print $3 }' )
  if [[ "$btenforce_status" == "com.itech.btenforce" ]]; then
    echo -e "[✅] Student Bluetooth enforcement is installed." >> "$task_file"
  else
    "$JAMF_BINARY" policy -event install-btenforce
    sleep 2
    btenforce_status=$( launchctl list | grep itech | awk '{ print $3 }' )
    if [[ "$btenforce_status" == "com.itech.btenforce" ]]; then
      echo -e "[✅] Student Bluetooth enforcement is installed after second try." >> "$task_file"
    else
      echo -e "[❌] Student Bluetooth enforcement is NOT installed after second try." >> "$task_file"
    fi
  fi
fi

receipt_path="/usr/local/.receipt"
receipt="${receipt_path}/receipt.txt"
if [[ -f "$receipt" ]]; then
    read rdate _ < "$receipt"
    echo -e "[✅] Enrollment receipt found: ${rdate}" >> "$task_file"
else
  "$JAMF_BINARY" policy -event enrollment-receipt
  sleep 2
  if [[ -f "$receipt" ]]; then
    read rdate _ < "$receipt"
    echo -e "[✅] Enrollment receipt found: ${rdate}" >> "$task_file"
  else
    echo -e "[❌] Enrollment receipt not found" >> "$task_file"
  fi
fi

echo -e "\n\n" >> "$task_file"

# Calculate the time difference in mins and seconds.
END_DATE=$( date +"%Y-%m-%d %H:%M:%S" )

# Convert START_DATE to EDT/EST.
echo -e "➤ Process began:  ${START_DATE}" >> "$task_file"
echo -e "➤ Completed:      ${END_DATE}" >> "$task_file"

# Calculate the time difference in mins and seconds.
minutes=$((SECONDS / 60))
seconds=$((SECONDS % 60))

echo -e "➤ Execution time: ${minutes}m ${seconds}s" >> "$task_file"
echo -e "➤ Local path for this file: ${task_file}" >> "$task_file"

echo -e "\n\n" >> "$task_file"
echo -e "═════════════════════════════════════════════════════════════════════════"  >> "$task_file"

echo "Script completed"

"$JAMF_BINARY" policy -event "reboot"
exit 0