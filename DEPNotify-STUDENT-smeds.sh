#!/bin/zsh

## ╔═══════════════════════════════════════════════════════════════════╗
## ║  Student enrollment script. Includes parts of DEPNotify by Jamf  ║
## ║    Author: Keith Myers, i-Tech | keith.myers@i-techsupport.com    ║
## ╚═══════════════════════════════════════════════════════════════════╝
## 
## Written for: SMEDS | https://smeds.org
## CONTAINS PROPRIETARY INFORMATION. NOT FOR DISTRIBUTION.
##  
## Release Date: 4/4/2026
##
## Dependencies: DEPNotify | https://github.com/jamf/DEPNotify

# ══════════╣ GLOBAL VARIABLES ╠═══════════

ENROLLMENT_TYPE="STUDENT"
FV_ENABLED=false

START_DATE=$( TZ="America/New_York" date +"%Y-%m-%d %H:%M:%S" )
SECONDS=0

# Add permissions to run the unisntaller script.
UNINSTALLER="/usr/local/depnotify-with-installers/com.arekdreyer.DEPNotify-prestarter-uninstaller.zsh"
chown root:wheel "$UNINSTALLER"
chmod 777 "$UNINSTALLER"

TESTING_MODE=false # Set variable to true or false
FULLSCREEN=false # Set variable to true or false
BANNER_IMAGE_PATH="/usr/local/pics/Banner.png"
ORG_NAME="St. Mary's Episcopal Day School"
BANNER_TITLE="Welcome!  Configuring Student Computer...\n\n"
SUPPORT_CONTACT_DETAILS="Email techteam@smeds.org"
MAIN_TEXT='Congratulations on your new computer at '$ORG_NAME'! \n Please wait while we configure your new computer. This process could take 10-20 minutes to complete.  Please do not interrupt.  Please plug into a power outlet now. \n \n'
INITAL_START_STATUS="Initial Configuration Starting..."
INSTALL_COMPLETE_TEXT="Configuration Complete. The computer will now restart..."
COMPLETE_METHOD_DROPDOWN_ALERT=false # Set variable to true or false
FV_ALERT_TEXT="Please click REBOOT below, then log back on with your username and password.  Once you log back on, click ENABLE to begin the one-time process to encrypt the hard drive."
FV_COMPLETE_MAIN_TEXT='Please click REBOOT below, then log back on with your username and password.  Once you log back on, click ENABLE to begin the one-time process to encrypt the hard drive.'
FV_COMPLETE_BUTTON_TEXT="REBOOT"
COMPLETE_ALERT_TEXT="Initial setup and configuration is complete. The computer will now reboot."
COMPLETE_MAIN_TEXT='Initial setup and configuration is complete. The computer will now reboot.'
COMPLETE_BUTTON_TEXT="Initiating restart..."
PICS_FOLDER=/usr/local/pics/

# Alert settings. To be used if any of the policies require user attention.
ALERT_ENABLED=false
ALERT_TONE="/System/Library/Sounds/Purr.aiff"
ALERT_EVENT_TRIGGER="install-btenforce"

SHOW_CHECKLIST=true


INFO_PLIST_WRAPPER (){
DEP_NOTIFY_USER_INPUT_PLIST="/Users/$CURRENT_USER/Library/Preferences/menu.nomad.DEPNotifyUserInput.plist"
}

STATUS_TEXT_ALIGN="center"
HELP_BUBBLE_TITLE="Need Help?"
HELP_BUBBLE_BODY="This tool at $ORG_NAME is designed to help with new computer onboarding. If you have issues, please $SUPPORT_CONTACT_DETAILS"

# Main heading that will be displayed under the image
ERROR_BANNER_TITLE="The initial setup encountered a problem"

ERROR_MAIN_TEXT='We are sorry that you are experiencing this inconvenience with your new Mac. \n \n Please contact IT. \n \n'
ERROR_MAIN_TEXT="$ERROR_MAIN_TEXT $SUPPORT_CONTACT_DETAILS"
ERROR_STATUS="Setup Failed"

TRIGGER="event"

# ══════════╣ POLICY ARRAY ╠═══════════

POLICY_ARRAY=(
	" Assigning the computer           ,assign-computer,SMEDS1.png"
	" Configuring default interface    ,set-dark-mode,SMEDS1.png"
	" Installing swiftDialog           ,install-swiftdialog,SMEDS2.png"
	" Installing Bluetooth utility     ,install-blueutil,SMEDS3.png"
	" Setting the time zone            ,set-timezone,SMEDS4.png"
	" Installing Google Chrome         ,installChrome,SMEDS5.png"
	" Installing Jamf Protect          ,jamfprotect,SMEDS6.png"
	" Installing Dock Utility          ,dockutil,SMEDS7.png"
	" Configuring the dock             ,student-dock,SMEDS8.png"
	" Generating enrollment receipt    ,enrollment-receipt,SMEDS9.png"
	" Configuring the computer name    ,rename-username-stu,SMEDS10.png"
	" Initiating name reset            ,reset-name,SMEDS11.png"
	" Installing btenforce             ,install-btenforce,SMEDS12.png"
	" Installing Lightspeed Filter     ,install-lightspeed,fireworks800x200.png"
	" Preparing for the next login     ,uninstall-depnotify-installers,fireworks800x200.png"
)


  NO_SLEEP=true
  SELF_SERVICE_CUSTOM_BRANDING=false # Set variable to true or false
  SELF_SERVICE_APP_NAME="SMEDS Self Service.app"
  SELF_SERVICE_CUSTOM_WAIT=20


#########################################################################################
# EULA Variables to Modify
#########################################################################################
# EULA configuration
  EULA_ENABLED=false # Set variable to true or false

  # EULA status bar text
    EULA_STATUS="Waiting on completion of EULA acceptance"

  # EULA button text on the main screen
    EULA_BUTTON="Read and Agree to EULA"

  # EULA Screen Title
    EULA_MAIN_TITLE="Organization End User License Agreement"

  # EULA Subtitle
    EULA_SUBTITLE="Please agree to the following terms and conditions to start configuration of this Mac"

  # Path to the EULA file you would like the user to read and agree to. It is
  # best to package this up with Composer or another tool and deliver it to a
  # shared area like /Users/Shared/
    EULA_FILE_PATH="/Users/Shared/eula.txt"

#########################################################################################
# Registration Variables to Modify
#########################################################################################
# Registration window configuration
  REGISTRATION_ENABLED=false # Set variable to true or false

  # Registration window title
    REGISTRATION_TITLE="Register Mac at $ORG_NAME"

  # Registration status bar text
    REGISTRATION_STATUS="Waiting on completion of computer registration"

  # Registration window submit or finish button text
    REGISTRATION_BUTTON="Register Your Mac"

  # The text and pick list sections below will write the following lines out for
  # end users. Use the variables below to configure what the sentence says
  # Ex: Setting Computer Name to macBook0132
    REGISTRATION_BEGIN_WORD="Setting"
    REGISTRATION_MIDDLE_WORD="to"

  # Registration window can have up to two text fields. Leaving the text display
  # variable empty will hide the input box. Display text is to the side of the
  # input and placeholder text is the gray text inside the input box.
  # Registration window can have up to four dropdown / pick list inputs. Leaving
  # the pick display variable empty will hide the dropdown / pick list.

  # First Text Field
  #######################################################################################
    # Text Field Label
      REG_TEXT_LABEL_1="Computer Name"

    # Place Holder Text
      REG_TEXT_LABEL_1_PLACEHOLDER="macBook0123"

    # Optional flag for making the field an optional input for end user
      REG_TEXT_LABEL_1_OPTIONAL="false" # Set variable to true or false

    # Help Bubble for Input. If title left blank, this will not appear
      REG_TEXT_LABEL_1_HELP_TITLE="Computer Name Field"
      REG_TEXT_LABEL_1_HELP_TEXT="This field is sets the name of your new Mac to what is in the Computer Name box. This is important for inventory purposes."

    # Logic below was put in this section rather than in core code as folks may
    # want to change what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      REG_TEXT_LABEL_1_LOGIC (){
        REG_TEXT_LABEL_1_VALUE=$(/usr/bin/defaults read "$DEP_NOTIFY_USER_INPUT_PLIST" "$REG_TEXT_LABEL_1")
        if [ "$REG_TEXT_LABEL_1_OPTIONAL" = true ] && [ "$REG_TEXT_LABEL_1_VALUE" = "" ]; then
          echo "Status: $REG_TEXT_LABEL_1 was left empty. Skipping..." >> "$DEP_NOTIFY_LOG"
          echo "$(date "+%a %h %d %H:%M:%S"): $REG_TEXT_LABEL_1 was set to optional and was left empty. Skipping..." >> "$DEP_NOTIFY_DEBUG"
          sleep 5
        else
          echo "Status: $REGISTRATION_BEGIN_WORD $REG_TEXT_LABEL_1 $REGISTRATION_MIDDLE_WORD $REG_TEXT_LABEL_1_VALUE" >> "$DEP_NOTIFY_LOG"
          if [ "$TESTING_MODE" = true ]; then
            sleep 10
          else
            "$JAMF_BINARY" setComputerName -name "$REG_TEXT_LABEL_1_VALUE"
            sleep 5
          fi
        fi
      }

  # Second Text Field
  #######################################################################################
    # Text Field Label
      REG_TEXT_LABEL_2="Asset Tag"

    # Place Holder Text
      REG_TEXT_LABEL_2_PLACEHOLDER="81926392"

    # Optional flag for making the field an optional input for end user
      REG_TEXT_LABEL_2_OPTIONAL="true" # Set variable to true or false

    # Help Bubble for Input. If title left blank, this will not appear
      REG_TEXT_LABEL_2_HELP_TITLE="Asset Tag Field"
      REG_TEXT_LABEL_2_HELP_TEXT="This field is used to give an updated asset tag to our asset management system. If you do not know your asset tag number, please skip this field."

    # Logic below was put in this section rather than in core code as folks may
    # want to change what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      REG_TEXT_LABEL_2_LOGIC (){
        REG_TEXT_LABEL_2_VALUE=$(/usr/bin/defaults read "$DEP_NOTIFY_USER_INPUT_PLIST" "$REG_TEXT_LABEL_2")
        if [ "$REG_TEXT_LABEL_2_OPTIONAL" = true ] && [ "$REG_TEXT_LABEL_2_VALUE" = "" ]; then
          echo "Status: $REG_TEXT_LABEL_2 was left empty. Skipping..." >> "$DEP_NOTIFY_LOG"
          echo "$(date "+%a %h %d %H:%M:%S"): $REG_TEXT_LABEL_2 was set to optional and was left empty. Skipping..." >> "$DEP_NOTIFY_DEBUG"
          sleep 5
        else
          echo "Status: $REGISTRATION_BEGIN_WORD $REG_TEXT_LABEL_2 $REGISTRATION_MIDDLE_WORD $REG_TEXT_LABEL_2_VALUE" >> "$DEP_NOTIFY_LOG"
          if [ "$TESTING_MODE" = true ]; then
             sleep 10
          else
            "$JAMF_BINARY" recon -assetTag "$REG_TEXT_LABEL_2_VALUE"
          fi
        fi
      }

  # Popup 1
  #######################################################################################
    # Label for the popup
      REG_POPUP_LABEL_1="Building"

    # Array of options for the user to select
      REG_POPUP_LABEL_1_OPTIONS=(
        "Amsterdam"
        "Katowice"
        "Eau Claire"
        "Minneapolis"
      )

    # Help Bubble for Input. If title left blank, this will not appear
      REG_POPUP_LABEL_1_HELP_TITLE="Building Dropdown Field"
      REG_POPUP_LABEL_1_HELP_TEXT="Please choose the appropriate building for where you normally work. This is important for inventory purposes."

    # Logic below was put in this section rather than in core code as folks may
    # want to change what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      REG_POPUP_LABEL_1_LOGIC (){
        REG_POPUP_LABEL_1_VALUE=$(/usr/bin/defaults read "$DEP_NOTIFY_USER_INPUT_PLIST" "$REG_POPUP_LABEL_1")
        echo "Status: $REGISTRATION_BEGIN_WORD $REG_POPUP_LABEL_1 $REGISTRATION_MIDDLE_WORD $REG_POPUP_LABEL_1_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
           sleep 10
        else
          "$JAMF_BINARY" recon -building "$REG_POPUP_LABEL_1_VALUE"
        fi
      }

  # Popup 2
  #######################################################################################
    # Label for the popup
      REG_POPUP_LABEL_2="Department"

    # Array of options for the user to select
      REG_POPUP_LABEL_2_OPTIONS=(
        "Customer Onboarding"
        "Professional Services"
        "Sales Engineering"
      )

    # Help Bubble for Input. If title left blank, this will not appear
      REG_POPUP_LABEL_2_HELP_TITLE="Department Dropdown Field"
      REG_POPUP_LABEL_2_HELP_TEXT="Please choose the appropriate department for where you normally work. This is important for inventory purposes."

    # Logic below was put in this section rather than in core code as folks may
    # want to change what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      REG_POPUP_LABEL_2_LOGIC (){
        REG_POPUP_LABEL_2_VALUE=$(/usr/bin/defaults read "$DEP_NOTIFY_USER_INPUT_PLIST" "$REG_POPUP_LABEL_2")
        echo "Status: $REGISTRATION_BEGIN_WORD $REG_POPUP_LABEL_2 $REGISTRATION_MIDDLE_WORD $REG_POPUP_LABEL_2_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
           sleep 10
        else
          "$JAMF_BINARY" recon -department "$REG_POPUP_LABEL_2_VALUE"
        fi
      }

  # Popup 3 - Code is here but currently unused
  #######################################################################################
    # Label for the popup
      REG_POPUP_LABEL_3=""

    # Array of options for the user to select
      REG_POPUP_LABEL_3_OPTIONS=(
        "Option 1"
        "Option 2"
        "Option 3"
      )

    # Help Bubble for Input. If title left blank, this will not appear
      REG_POPUP_LABEL_3_HELP_TITLE="Dropdown 3 Field"
      REG_POPUP_LABEL_3_HELP_TEXT="This dropdown is currently not in use. All code is here ready for you to use. It can also be hidden by removing the contents of the REG_POPUP_LABEL_3 variable."

    # Logic below was put in this section rather than in core code as folks may
    # want to change what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      REG_POPUP_LABEL_3_LOGIC (){
        REG_POPUP_LABEL_3_VALUE=$(/usr/bin/defaults read "$DEP_NOTIFY_USER_INPUT_PLIST" "$REG_POPUP_LABEL_3")
        echo "Status: $REGISTRATION_BEGIN_WORD $REG_POPUP_LABEL_3 $REGISTRATION_MIDDLE_WORD $REG_POPUP_LABEL_3_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
          sleep 10
        else
          sleep 10
        fi
      }

  # Popup 4 - Code is here but currently unused
  #######################################################################################
    # Label for the popup
      REG_POPUP_LABEL_4=""

    # Array of options for the user to select
      REG_POPUP_LABEL_4_OPTIONS=(
        "Option 1"
        "Option 2"
        "Option 3"
      )

    # Help Bubble for Input. If title left blank, this will not appear
      REG_POPUP_LABEL_4_HELP_TITLE="Dropdown 4 Field"
      REG_POPUP_LABEL_4_HELP_TEXT="This dropdown is currently not in use. All code is here ready for you to use. It can also be hidden by removing the contents of the REG_POPUP_LABEL_4 variable."

    # Logic below was put in this section rather than in core code as folks may
    # want to change what the field does. This is a function that gets called
    # when needed later on. BE VERY CAREFUL IN CHANGING THE FUNCTION!
      REG_POPUP_LABEL_4_LOGIC (){
        REG_POPUP_LABEL_4_VALUE=$(/usr/bin/defaults read "$DEP_NOTIFY_USER_INPUT_PLIST" "$REG_POPUP_LABEL_4")
        echo "Status: $REGISTRATION_BEGIN_WORD $REG_POPUP_LABEL_4 $REGISTRATION_MIDDLE_WORD $REG_POPUP_LABEL_4_VALUE" >> "$DEP_NOTIFY_LOG"
        if [ "$TESTING_MODE" = true ]; then
          sleep 10
        else
          sleep 10
        fi
      }

#########################################################################################
#########################################################################################
# Core Script Logic - Don't Change Without Major Testing
#########################################################################################
#########################################################################################

# Variables for File Paths
  JAMF_BINARY="/usr/local/bin/jamf"
  FDE_SETUP_BINARY="/usr/bin/fdesetup"
  DEP_NOTIFY_APP="/Applications/Utilities/DEPNotify.app"
  DEP_NOTIFY_LOG="/var/tmp/depnotify.log"
  DEP_NOTIFY_DEBUG="/var/tmp/depnotifyDebug.log"
  DEP_NOTIFY_DONE="/var/tmp/com.depnotify.provisioning.done"

# Pulling from Policy parameters to allow true/false flags to be set. More info
# can be found on https://www.jamf.com/jamf-nation/articles/146/script-parameters
# These will override what is specified in the script above.
  # Testing Mode
    if [ "$4" != "" ]; then TESTING_MODE="$4"; fi
  # Fullscreen Mode
    if [ "$5" != "" ]; then FULLSCREEN="$5"; fi
  # No Sleep / Caffeinate Mode
    if [ "$6" != "" ]; then NO_SLEEP="$6"; fi
  # Self Service Custom Branding
    if [ "$7" != "" ]; then SELF_SERVICE_CUSTOM_BRANDING="$7"; fi
  # Complete method dropdown or main screen
    if [ "$8" != "" ]; then COMPLETE_METHOD_DROPDOWN_ALERT="$8"; fi
  # EULA Mode
    if [ "$9" != "" ]; then EULA_ENABLED="$9"; fi
  # Registration Mode
    if [ "${10}" != "" ]; then REGISTRATION_ENABLED="${10}"; fi

# Standard Testing Mode Enhancements
  if [ "$TESTING_MODE" = true ]; then
    # Removing old config file if present (Testing Mode Only)
      if [ -f "$DEP_NOTIFY_LOG" ]; then rm "$DEP_NOTIFY_LOG"; fi
      if [ -f "$DEP_NOTIFY_DONE" ]; then rm "$DEP_NOTIFY_DONE"; fi
      if [ -f "$DEP_NOTIFY_DEBUG" ]; then rm "$DEP_NOTIFY_DEBUG"; fi
    # Setting Quit Key set to command + control + x (Testing Mode Only)
      echo "Command: QuitKey: x" >> "$DEP_NOTIFY_LOG"
  fi

# Validating true/false flags
  if [ "$TESTING_MODE" != true ] && [ "$TESTING_MODE" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Testing configuration not set properly. Currently set to $TESTING_MODE. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$FULLSCREEN" != true ] && [ "$FULLSCREEN" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Fullscreen configuration not set properly. Currently set to $FULLSCREEN. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$NO_SLEEP" != true ] && [ "$NO_SLEEP" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Sleep configuration not set properly. Currently set to $NO_SLEEP. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$SELF_SERVICE_CUSTOM_BRANDING" != true ] && [ "$SELF_SERVICE_CUSTOM_BRANDING" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Self Service Custom Branding configuration not set properly. Currently set to $SELF_SERVICE_CUSTOM_BRANDING. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$COMPLETE_METHOD_DROPDOWN_ALERT" != true ] && [ "$COMPLETE_METHOD_DROPDOWN_ALERT" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Completion alert method not set properly. Currently set to $COMPLETE_METHOD_DROPDOWN_ALERT. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$EULA_ENABLED" != true ] && [ "$EULA_ENABLED" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): EULA configuration not set properly. Currently set to $EULA_ENABLED. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi
  if [ "$REGISTRATION_ENABLED" != true ] && [ "$REGISTRATION_ENABLED" != false ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Registration configuration not set properly. Currently set to $REGISTRATION_ENABLED. Please update to true or false." >> "$DEP_NOTIFY_DEBUG"
    exit 1
  fi

# Run DEP Notify will run after Apple Setup Assistant
  SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  until [ "$SETUP_ASSISTANT_PROCESS" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Setup Assistant Still Running. PID $SETUP_ASSISTANT_PROCESS." >> "$DEP_NOTIFY_DEBUG"
    sleep 1
    SETUP_ASSISTANT_PROCESS=$(pgrep -l "Setup Assistant")
  done

# Checking to see if the Finder is running now before continuing. This can help
# in scenarios where an end user is not configuring the device.
  FINDER_PROCESS=$(pgrep -l "Finder")
  until [ "$FINDER_PROCESS" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Finder process not found. Assuming device is at login screen." >> "$DEP_NOTIFY_DEBUG"
    sleep 1
    FINDER_PROCESS=$(pgrep -l "Finder")
  done

# After the Apple Setup completed. Now safe to grab the current user.
CURRENT_USER=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')
echo "$(date "+%a %h %d %H:%M:%S"): Current user set to $CURRENT_USER." >> "$DEP_NOTIFY_DEBUG"

# Stop DEPNotify if there was already a DEPNotify window running (from a PreStage package postinstall script).
 PREVIOUS_DEP_NOTIFY_PROCESS=$(pgrep -l "DEPNotify" | cut -d " " -f1)
  until [ "$PREVIOUS_DEP_NOTIFY_PROCESS" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Stopping the previously-opened instance of DEPNotify." >> "$DEP_NOTIFY_DEBUG"
    kill $PREVIOUS_DEP_NOTIFY_PROCESS
    PREVIOUS_DEP_NOTIFY_PROCESS=$(pgrep -l "DEPNotify" | cut -d " " -f1)
  done

 # Stop BigHonkingText if it's running (from a PreStage package postinstall script).
 BIG_HONKING_TEXT_PROCESS=$(pgrep -l "BigHonkingText" | cut -d " " -f1)
  until [ "$BIG_HONKING_TEXT_PROCESS" = "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Stopping the previously-opened instance of BigHonkingText." >> "$DEP_NOTIFY_DEBUG"
    kill $BIG_HONKING_TEXT_PROCESS
    BIG_HONKING_TEXT_PROCESS=$(pgrep -l "BigHonkingText" | cut -d " " -f1)
  done

# Adding Check and Warning if Testing Mode is off and BOM files exist
  if [[ ( -f "$DEP_NOTIFY_LOG" || -f "$DEP_NOTIFY_DONE" ) && "$TESTING_MODE" = false ]]; then
    echo "$(date "+%a %h %d %H:%M:%S"): TESTING_MODE set to false but config files were found in /var/tmp. Letting user know and exiting." >> "$DEP_NOTIFY_DEBUG"
    mv "$DEP_NOTIFY_LOG" "/var/tmp/depnotify_old.log"
    echo "Command: MainTitle: $ERROR_BANNER_TITLE" >> "$DEP_NOTIFY_LOG"
    echo "Command: MainText: $ERROR_MAIN_TEXT" >> "$DEP_NOTIFY_LOG"
    echo "Status: $ERROR_STATUS" >> "$DEP_NOTIFY_LOG"
    sudo -u "$CURRENT_USER" open -a "$DEP_NOTIFY_APP" --args -path "$DEP_NOTIFY_LOG"
    sleep 5
    exit 1
  fi

# If SELF_SERVICE_CUSTOM_BRANDING is set to true. Loading the updated icon
  if [ "$SELF_SERVICE_CUSTOM_BRANDING" = true ]; then
    open -a "/Applications/$SELF_SERVICE_APP_NAME" --hide

  # Loop waiting on the branding image to properly show in the users library
	SELF_SERVICE_COUNTER=0
	CUSTOM_BRANDING_PNG="/Users/${CURRENT_USER}/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"
	until [ -f "$CUSTOM_BRANDING_PNG" ]; do
		echo "$(date "+%a %h %d %H:%M:%S"): Waiting for branding image from Jamf Pro." >> "$DEP_NOTIFY_DEBUG"
		sleep 1
		(( SELF_SERVICE_COUNTER++ ))
		if [ $SELF_SERVICE_COUNTER -gt $SELF_SERVICE_CUSTOM_WAIT ];then
		   CUSTOM_BRANDING_PNG="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"
		   break
		fi
	done

  # Setting Banner Image for DEP Notify to Self Service Custom Branding
    BANNER_IMAGE_PATH="$CUSTOM_BRANDING_PNG"

  # Closing Self Service
    SELF_SERVICE_PID=$(pgrep -l "Self Service" | cut -d' ' -f1)
    echo "$(date "+%a %h %d %H:%M:%S"): Self Service custom branding icon has been loaded. Killing Self Service PID $SELF_SERVICE_PID." >> "$DEP_NOTIFY_DEBUG"
    kill "$SELF_SERVICE_PID"
  fi

# Setting custom image if specified
  if [ "$BANNER_IMAGE_PATH" != "" ]; then echo "Command: Image: $BANNER_IMAGE_PATH" >> "$DEP_NOTIFY_LOG"; fi

# Setting custom title if specified
  if [ "$BANNER_TITLE" != "" ]; then echo "Command: MainTitle: $BANNER_TITLE" >> "$DEP_NOTIFY_LOG"; fi

# Setting custom main text if specified
  if [ "$MAIN_TEXT" != "" ]; then echo "Command: MainText: $MAIN_TEXT" >> "$DEP_NOTIFY_LOG"; fi

# General Plist Configuration
  # Calling function to set the INFO_PLIST_PATH
    INFO_PLIST_WRAPPER

  # The plist information below
    DEP_NOTIFY_CONFIG_PLIST="/Users/$CURRENT_USER/Library/Preferences/menu.nomad.DEPNotify.plist"

  # If testing mode is on, this will remove some old configuration files
    if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_CONFIG_PLIST" ]; then rm "$DEP_NOTIFY_CONFIG_PLIST"; fi
    if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_USER_INPUT_PLIST" ]; then rm "$DEP_NOTIFY_USER_INPUT_PLIST"; fi

  # Setting default path to the plist which stores all the user completed info
    /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" pathToPlistFile "$DEP_NOTIFY_USER_INPUT_PLIST"

  # Setting status text alignment
    /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" statusTextAlignment "$STATUS_TEXT_ALIGN"

  # Setting help button
    if [ "$HELP_BUBBLE_TITLE" != "" ]; then
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" helpBubble -array-add "$HELP_BUBBLE_TITLE"
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" helpBubble -array-add "$HELP_BUBBLE_BODY"
    fi

# EULA Configuration
  if [ "$EULA_ENABLED" =  true ]; then
    DEP_NOTIFY_EULA_DONE="/var/tmp/com.depnotify.agreement.done"

    # If testing mode is on, this will remove EULA specific configuration files
      if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_EULA_DONE" ]; then rm "$DEP_NOTIFY_EULA_DONE"; fi

    # Writing title, subtitle, and EULA txt location to plist
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" EULAMainTitle "$EULA_MAIN_TITLE"
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" EULASubTitle "$EULA_SUBTITLE"
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" pathToEULA "$EULA_FILE_PATH"

    # Setting ownership of EULA file
      chown "$CURRENT_USER:staff" "$EULA_FILE_PATH"
      chmod 444 "$EULA_FILE_PATH"
  fi

# Registration Plist Configuration
  if [ "$REGISTRATION_ENABLED" = true ]; then
    DEP_NOTIFY_REGISTER_DONE="/var/tmp/com.depnotify.registration.done"

    # If testing mode is on, this will remove registration specific configuration files
      if [ "$TESTING_MODE" = true ] && [ -f "$DEP_NOTIFY_REGISTER_DONE" ]; then rm "$DEP_NOTIFY_REGISTER_DONE"; fi

    # Main Window Text Configuration
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" registrationMainTitle "$REGISTRATION_TITLE"
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" registrationButtonLabel "$REGISTRATION_BUTTON"
      /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" registrationPicturePath "$BANNER_IMAGE_PATH"

    # First Text Box Configuration
      if [ "$REG_TEXT_LABEL_1" != "" ]; then
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField1Label "$REG_TEXT_LABEL_1"
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField1Placeholder "$REG_TEXT_LABEL_1_PLACEHOLDER"
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField1IsOptional "$REG_TEXT_LABEL_1_OPTIONAL"
        # Code for showing the help box if configured
          if [ "$REG_TEXT_LABEL_1_HELP_TITLE" != "" ]; then
              /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField1Bubble -array-add "$REG_TEXT_LABEL_1_HELP_TITLE"
              /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField1Bubble -array-add "$REG_TEXT_LABEL_1_HELP_TEXT"
          fi
      fi

    # Second Text Box Configuration
      if [ "$REG_TEXT_LABEL_2" != "" ]; then
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField2Label "$REG_TEXT_LABEL_2"
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField2Placeholder "$REG_TEXT_LABEL_2_PLACEHOLDER"
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField2IsOptional "$REG_TEXT_LABEL_2_OPTIONAL"
        # Code for showing the help box if configured
          if [ "$REG_TEXT_LABEL_2_HELP_TITLE" != "" ]; then
              /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField2Bubble -array-add "$REG_TEXT_LABEL_2_HELP_TITLE"
              /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" textField2Bubble -array-add "$REG_TEXT_LABEL_2_HELP_TEXT"
          fi
      fi

    # Popup 1
      if [ "$REG_POPUP_LABEL_1" != "" ]; then
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton1Label "$REG_POPUP_LABEL_1"
        # Code for showing the help box if configured
          if [ "$REG_POPUP_LABEL_1_HELP_TITLE" != "" ]; then
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu1Bubble -array-add "$REG_POPUP_LABEL_1_HELP_TITLE"
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu1Bubble -array-add "$REG_POPUP_LABEL_1_HELP_TEXT"
          fi
        # Code for adding the items from the array above into the plist
          for REG_POPUP_LABEL_1_OPTION in "${REG_POPUP_LABEL_1_OPTIONS[@]}"; do
             /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton1Content -array-add "$REG_POPUP_LABEL_1_OPTION"
          done
      fi

    # Popup 2
      if [ "$REG_POPUP_LABEL_2" != "" ]; then
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton2Label "$REG_POPUP_LABEL_2"
        # Code for showing the help box if configured
          if [ "$REG_POPUP_LABEL_2_HELP_TITLE" != "" ]; then
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu2Bubble -array-add "$REG_POPUP_LABEL_2_HELP_TITLE"
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu2Bubble -array-add "$REG_POPUP_LABEL_2_HELP_TEXT"
          fi
        # Code for adding the items from the array above into the plist
          for REG_POPUP_LABEL_2_OPTION in "${REG_POPUP_LABEL_2_OPTIONS[@]}"; do
             /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton2Content -array-add "$REG_POPUP_LABEL_2_OPTION"
          done
      fi

    # Popup 3
      if [ "$REG_POPUP_LABEL_3" != "" ]; then
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton3Label "$REG_POPUP_LABEL_3"
        # Code for showing the help box if configured
          if [ "$REG_POPUP_LABEL_3_HELP_TITLE" != "" ]; then
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu3Bubble -array-add "$REG_POPUP_LABEL_3_HELP_TITLE"
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu3Bubble -array-add "$REG_POPUP_LABEL_3_HELP_TEXT"
          fi
        # Code for adding the items from the array above into the plist
          for REG_POPUP_LABEL_3_OPTION in "${REG_POPUP_LABEL_3_OPTIONS[@]}"; do
             /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton3Content -array-add "$REG_POPUP_LABEL_3_OPTION"
          done
      fi

    # Popup 4
      if [ "$REG_POPUP_LABEL_4" != "" ]; then
        /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton4Label "$REG_POPUP_LABEL_4"
        # Code for showing the help box if configured
          if [ "$REG_POPUP_LABEL_4_HELP_TITLE" != "" ]; then
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu4Bubble -array-add "$REG_POPUP_LABEL_4_HELP_TITLE"
            /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupMenu4Bubble -array-add "$REG_POPUP_LABEL_4_HELP_TEXT"
          fi
        # Code for adding the items from the array above into the plist
          for REG_POPUP_LABEL_4_OPTION in "${REG_POPUP_LABEL_4_OPTIONS[@]}"; do
             /usr/bin/defaults write "$DEP_NOTIFY_CONFIG_PLIST" popupButton4Content -array-add "$REG_POPUP_LABEL_4_OPTION"
          done
      fi
  fi

# Changing Ownership of the plist file
  chown "$CURRENT_USER":staff "$DEP_NOTIFY_CONFIG_PLIST"
  chmod 600 "$DEP_NOTIFY_CONFIG_PLIST"

# Opening the app after initial configuration
  if [ "$FULLSCREEN" = true ]; then
    sudo -u "$CURRENT_USER" open -a "$DEP_NOTIFY_APP" --args -path "$DEP_NOTIFY_LOG" -fullScreen
  elif [ "$FULLSCREEN" = false ]; then
    sudo -u "$CURRENT_USER" open -a "$DEP_NOTIFY_APP" --args -path "$DEP_NOTIFY_LOG"
  fi

# Grabbing the DEP Notify Process ID for use later
  DEP_NOTIFY_PROCESS=$(pgrep -l "DEPNotify" | cut -d " " -f1)
  until [ "$DEP_NOTIFY_PROCESS" != "" ]; do
    echo "$(date "+%a %h %d %H:%M:%S"): Waiting for DEPNotify to start to gather the process ID." >> "$DEP_NOTIFY_DEBUG"
    sleep 1
    DEP_NOTIFY_PROCESS=$(pgrep -l "DEPNotify" | cut -d " " -f1)
  done

# Using Caffeinate binary to keep the computer awake if enabled
  if [ "$NO_SLEEP" = true ]; then
    echo "$(date "+%a %h %d %H:%M:%S"): Caffeinating DEP Notify process. Process ID: $DEP_NOTIFY_PROCESS" >> "$DEP_NOTIFY_DEBUG"
    caffeinate -disu -w "$DEP_NOTIFY_PROCESS"&
  fi

# Adding an alert prompt to let admins know that the script is in testing mode
  if [ "$TESTING_MODE" = true ]; then
    echo "Command: Alert: DEP Notify is in TESTING_MODE. Script will not run Policies or other commands that make change to this computer."  >> "$DEP_NOTIFY_LOG"
  fi

# Adding nice text and a brief pause for prettiness
  echo "Status: $INITAL_START_STATUS" >> "$DEP_NOTIFY_LOG"
  sleep 5

# Setting the status bar
  # Counter is for making the determinate look nice. Starts at one and adds
  # more based on EULA, register, or other options.
    ADDITIONAL_OPTIONS_COUNTER=1
    if [ "$EULA_ENABLED" = true ]; then ((ADDITIONAL_OPTIONS_COUNTER++)); fi
    if [ "$REGISTRATION_ENABLED" = true ]; then ((ADDITIONAL_OPTIONS_COUNTER++))
      if [ "$REG_TEXT_LABEL_1" != "" ]; then ((ADDITIONAL_OPTIONS_COUNTER++)); fi
      if [ "$REG_TEXT_LABEL_2" != "" ]; then ((ADDITIONAL_OPTIONS_COUNTER++)); fi
      if [ "$REG_POPUP_LABEL_1" != "" ]; then ((ADDITIONAL_OPTIONS_COUNTER++)); fi
      if [ "$REG_POPUP_LABEL_2" != "" ]; then ((ADDITIONAL_OPTIONS_COUNTER++)); fi
      if [ "$REG_POPUP_LABEL_3" != "" ]; then ((ADDITIONAL_OPTIONS_COUNTER++)); fi
      if [ "$REG_POPUP_LABEL_4" != "" ]; then ((ADDITIONAL_OPTIONS_COUNTER++)); fi
    fi

	CHECK_COUNT=9
	((ADDITIONAL_OPTIONS_COUNTER+=CHECK_COUNT))

  # Checking policy array and adding the count from the additional options above.
    ARRAY_LENGTH="$((${#POLICY_ARRAY[@]}+ADDITIONAL_OPTIONS_COUNTER))"
    echo "Command: Determinate: $ARRAY_LENGTH" >> "$DEP_NOTIFY_LOG"

# EULA Window Display Logic
  if [ "$EULA_ENABLED" = true ]; then
    echo "Status: $EULA_STATUS" >> "$DEP_NOTIFY_LOG"
    echo "Command: ContinueButtonEULA: $EULA_BUTTON" >> "$DEP_NOTIFY_LOG"
    while [ ! -f "$DEP_NOTIFY_EULA_DONE" ]; do
      echo "$(date "+%a %h %d %H:%M:%S"): Waiting for user to accept EULA." >> "$DEP_NOTIFY_DEBUG"
      sleep 1
    done
  fi

# Registration Window Display Logic
  if [ "$REGISTRATION_ENABLED" = true ]; then
    echo "Status: $REGISTRATION_STATUS" >> "$DEP_NOTIFY_LOG"
    echo "Command: ContinueButtonRegister: $REGISTRATION_BUTTON" >> "$DEP_NOTIFY_LOG"
    while [ ! -f "$DEP_NOTIFY_REGISTER_DONE" ]; do
      echo "$(date "+%a %h %d %H:%M:%S"): Waiting for user to complete registration." >> "$DEP_NOTIFY_DEBUG"
      sleep 1
    done
    # Running Logic For Each Registration Box
      if [ "$REG_TEXT_LABEL_1" != "" ]; then REG_TEXT_LABEL_1_LOGIC; fi
      if [ "$REG_TEXT_LABEL_2" != "" ]; then REG_TEXT_LABEL_2_LOGIC; fi
      if [ "$REG_POPUP_LABEL_1" != "" ]; then REG_POPUP_LABEL_1_LOGIC; fi
      if [ "$REG_POPUP_LABEL_2" != "" ]; then REG_POPUP_LABEL_2_LOGIC; fi
      if [ "$REG_POPUP_LABEL_3" != "" ]; then REG_POPUP_LABEL_3_LOGIC; fi
      if [ "$REG_POPUP_LABEL_4" != "" ]; then REG_POPUP_LABEL_4_LOGIC; fi
  fi

########################
## Entrollment Report ##
########################
LOCAL_HOST=$( hostname )
COMPUTER_NAME_PREFIX="STU-Mac-"
SERIAL_NUMBER=$( ioreg -l | awk -F'"' '/IOPlatformSerialNumber/{print $4}' )

task_file="/Users/${CURRENT_USER}/.post-enrollment.txt"
first=${CURRENT_USER%%.*}
last=${CURRENT_USER##*.}

titlecase="${(C)first}.${(C)last}"
NEW_COMPUTER_NAME="${COMPUTER_NAME_PREFIX}${titlecase}-${SERIAL_NUMBER}"

now=$( date +%FT%T )


## Add manual tasks to the top of the file.
echo -e "Enrollment Type: "$ENROLLMENT_TYPE"  |  Date: ${now}\n" >> "$task_file"
echo -e "                       ╔════════════════════════╗ " >> "$task_file"
echo -e "═══════════════════════╣ M A N U A L  T A S K S ╠════════════════════════" >> "$task_file"
echo -e "                       ╚════════════════════════╝ \n" >> "$task_file"



echo -e "[ ] Log onto Chrome and create the student's profile" >> "$task_file"
#echo -e "[ ] Log onto Mail as the student." >> "$task_file"
#echo -e "[ ] Log onto the student's Managed Apple Account." >> "$task_file"
#echo -e "[ ] Complete the Entra ID SSO enrollment (see notification ↗)." >> "$task_file"
#echo -e "[ ] Approve Screen Recording for Securly Classroom." >> "$task_file"
echo -e "[ ] Check content filtering by attempting to view a web page on the blocked list." >> "$task_file"
echo -e "[ ] Resolve any failed policies (any with a red X below)." >> "$task_file"

echo -e "\n➤ Need to re-run one of the policies? Use: sudo jamf policy -event <event_trigger>" >> "$task_file"
echo -e "➤ Example: sudo jamf policy -event set-timezone" >> "$task_file"
#echo -e "➤ If the secureToken dialog ran, the default hadmin password was set (for 1 hour)" >> "$task_file"

echo -e "\n ⬆︎ PLEASE COMPLETE THE ABOVE MANUAL TASKS.⬆︎ \n" >> "$task_file"

echo -e "                       ╔════════════════════════╗ " >> "$task_file"
echo -e "═══════════════════════╣  AUTOMATED ENROLLMENT  ╠════════════════════════" >> "$task_file"
echo -e "                       ╚════════════════════════╝ \n" >> "$task_file"

for POLICY in "${POLICY_ARRAY[@]}"; do
    
	status_update=$(echo "$POLICY" | cut -d ',' -f2)
	desc="${POLICY%%,*}"
	trigger_file="${POLICY#*,}"
	trigger="${trigger_file%%,*}"

	if [[ "$ALERT_ENABLED" == true ]]; then

		if [[ "$status_update" == "$ALERT_EVENT_TRIGGER" ]]; then
			# Play the alert tone to get the user's attention.
			afplay "$ALERT_TONE" -v 10
		fi
	fi

	echo "[✅]${desc} | ${trigger}" >> "$task_file"
	echo "Command: MainTextImage: "$PICS_FOLDER"/$(echo "$POLICY" | cut -d ',' -f3)" >> "$DEP_NOTIFY_LOG"
	echo "Command: MainText: ${POLICY_ARRAY_TEXT} >> $DEP_NOTIFY_LOG"
	echo "Status: $(echo "$POLICY" | cut -d ',' -f1)" >> "$DEP_NOTIFY_LOG"


	if [ "$TESTING_MODE" = true ]; then
		sleep 3
	elif [ "$TESTING_MODE" = false ]; then
		"$JAMF_BINARY" policy -event "$(echo "$POLICY" | cut -d ',' -f2)"
	fi
done

echo "Policy iteration complete."

chrome="/Applications/Google Chrome.app"
token_status=$( dscl . -read /Users/hadmin AuthenticationAuthority | grep -o SecureToken )
timezone=$( date +"%Z %z" )

echo "Status: Checking the enrollment..." >> "$DEP_NOTIFY_LOG"
echo -e "\n\n" >> "$task_file"
echo -e "                       ╔════════════════════════╗ " >> "$task_file"
echo -e "═══════════════════════╣   ENROLLMENT CHECKS    ╠════════════════════════" >> "$task_file"
echo -e "                       ╚════════════════════════╝ \n" >> "$task_file"


# 1. Check that Chrome is installed and run the policy if it is not.
if [[ ! -e "$chrome" ]]; then
	"$JAMF_BINARY" policy -event installChrome
	echo "Status: Could not detect Google Chrome. Reran the policy." >> "$DEP_NOTIFY_LOG"
  if [[ ! -e "$chrome" ]]; then
    echo -e "[❌] Install Google Chrome because it is missing after two tries. ⚠️ MUST BE RESOLVED PRIOR TO DISTRIBUTION" >> "$task_file"
  else
    echo -e "[✅] Google Chrome is installed (second try)." >> "$task_file"
  fi
else
	echo "Status: ✅ Google Chrome is installed." >> "$DEP_NOTIFY_LOG"
	echo -e "[✅] Google Chrome is installed." >> "$task_file"
fi

# 2. Check that the timezone is set to EDT/EST and run the policy if it is not.
if [[ "$timezone" == "EDT -0400" || "$timezone" == "EST -0500" ]]; then
	echo "Status: ✅ Timezone is set to EDT/EST" >> "$DEP_NOTIFY_LOG"
	echo -e "[✅] Timezone is set to EDT/EST" >> "$task_file"
else
	"$JAMF_BINARY" policy -event set-timezone
	if [[ "$timezone" == "EDT -0400" || "$timezone" == "EST -0500" ]]; then
		echo "Status: ✅ Corrected the timezone." >> "$DEP_NOTIFY_LOG"
		echo -e "[✅] Timezone is correct. Set to ${timezone}." >> "$task_file"
	else
		echo "Status: ❌ Could not correct the timezone." >> "$DEP_NOTIFY_LOG"
		echo -e "[❌] Could not correct the timezone." >> "$task_file"
	fi
fi

# 3. Check that swiftDialog is installed and run the policy if it is not.
dialog=$( which dialog )
if [[ -z "$dialog" ]]; then
	"$JAMF_BINARY" policy -event install-dialog
	dialog=$( which dialog )
	if [[ -z "$dialog" ]]; then
		echo "Status: ❌ swiftDialog is missing." >> "$DEP_NOTIFY_LOG"
		echo -e "[❌] swift Dialog is missing. Rerun policy." >> "$task_file"
	else
		echo "Status: ✅ swiftDialog is installed (second try)." >> "$DEP_NOTIFY_LOG"
		echo -e "[✅] swiftDialog is installed (second try)." >> "$task_file"
	fi
else
	echo "Status: ✅ swiftDialog is installed." >> "$DEP_NOTIFY_LOG"
	echo -e "[✅] swiftDialog is installed." >> "$task_file"
fi

# 4. Check that dockutil is installed and run the policy if it is not.
dockutilbin=$( which dockutil )
if [[ -z "$dockutilbin" ]]; then
	"$JAMF_BINARY" policy -event dockutil
	dockutilbin=$( which dockutil )
	if [[ -z "$dockutilbin" ]]; then
		echo "Status: ❌ Cannot find dockutil" >> "$DEP_NOTIFY_LOG"
		echo -e "[❌] Dockutil is missing. Second attempt failed. Please troubleshoot." >> "$task_file"
	else
		"$JAMF_BINARY" policy -event dockutil
		echo "Status: ✅ Reran the student dock script." >> "$DEP_NOTIFY_LOG"
		echo -e "[✅] Dockutil is installed (second try)." >> "$task_file"
	fi
else
	echo "Status: ✅ Dockutil is installed." >> "$DEP_NOTIFY_LOG"
	echo -e "[✅] Dockutil is installed." >> "$task_file"
fi

# 5. Check that FileVault is enabled and run the policy if it is not.
if [[ "$FV_ENABLED" = true ]]; then
	fvstatus=$( fdesetup status )
	if [[ "$fvstatus" == "FileVault is On." ]]; then
		echo "Status: ✅ FileVault is enabled." >> "$DEP_NOTIFY_LOG"
		echo -e "[✅] FileVault is enabled." >> "$task_file"
	else
		echo "Status: ❌ FileVault is NOT enabled. ⚠️" >> "$DEP_NOTIFY_LOG"
		echo -e "[❌] FileVault is NOT enabled. ⚠️" >> "$task_file"
	fi
fi

# 6. Check that the computer name is correct and run the policy if it is not.
host_name=$( scutil --get ComputerName )
setopt NO_CASE_MATCH
if [[ "$host_name" == "$NEW_COMPUTER_NAME" ]]; then
	echo "Status: ✅ The computer is named correctly. (${host_name})" >> "$DEP_NOTIFY_LOG"
	echo -e "[✅] The computer is named correctly (${host_name})." >> "$task_file"
else
	"$JAMF_BINARY" policy -event rename-username-stu
	sleep 2
	host_name=$( scutil --get ComputerName )
	if [[ "$host_name" != "$NEW_COMPUTER_NAME" ]]; then
		echo "Status: ❌ Unable to correct the host name. Current: ${host_name}" >> "$DEP_NOTIFY_LOG"
		echo -e "[❌] The computer name is incorrect. Second attempt failed.(${host_name})" >> "$task_file"
	else
		echo "Status: ✅ Corrected the computer name. Now: ${host_name}" >> "$DEP_NOTIFY_LOG"
		echo -e "[✅] The computer is named correctly (${host_name})." >> "$task_file"
	fi
fi
unsetopt NO_CASE_MATCH

# 7. Check that the SecureToken for hadmin is present and run the policy if it is not.
token_status=$( dscl . -read /Users/hadmin AuthenticationAuthority | grep -o SecureToken )
if [[ -z $token_status ]]; then
	echo -e "[⚠️] SecureToken is missing. Log on as hadmin via GUI, then log back on as ${CURRENT_USER}.\n" >> "$task_file"
	echo "Status: ⚠️ Unable to obtain a SecureToken for hadmin." >> "$DEP_NOTIFY_LOG"
else
	echo "Status: ✅ Secure Token has been assigned to hadmin." >> "$DEP_NOTIFY_LOG"
	echo -e "[✅] Secure Token has been assigned to hadmin.\n" >> "$task_file"
fi

echo "Status: Generating checklist. Restarting the computer in 5 seconds..." >> "$DEP_NOTIFY_LOG"
sleep 5

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

# Remove the "Click ALLOW if prompted" line from the task file.
sed -i '' 's/Click ALLOW if prompted ⬆︎//g' "$task_file"

# Set ownership on the task file.
chown "$CURRENT_USER":staff "$task_file"

sleep 1

# Create the checklist script and agent.
echo "Creating the checklist script and agent."
open_checklist="/Users/${CURRENT_USER}/.open_checklist.sh"
launch_agents="/Users/${CURRENT_USER}/Library/LaunchAgents"

if [[ ! -d "$launch_agents" ]]; then
	mkdir -p "$launch_agents"
	chown "${CURRENT_USER}:staff" "$launch_agents"
	echo "Created ${launch_agents} and made it owned by ${CURRENT_USER}."
fi

sleep 1

# Create the agent and script to show the checklist.
if [[ "$SHOW_CHECKLIST" = true ]]; then

	checklist_agent="${launch_agents}/com.itech.checklist.plist"
cat << EOF > "$open_checklist"
#!/bin/zsh

open -a TextEdit "${task_file}"

# Use AppleScript to send TextEdit into full screen.
osascript <<EOOSASCRIPT
tell application "TextEdit"
    activate
end tell
tell application "System Events"
    keystroke "f" using {control down, command down}
end tell
EOOSASCRIPT

# Delete the LaunchAgent and this script so the checklist only ever displays once.
rm "${checklist_agent}"
rm "\$0"
EOF

	if [[ -f "$open_checklist" ]]; then
		chmod +x "$open_checklist"
		chown "${CURRENT_USER}:staff" "$open_checklist"
		echo "Created ${open_checklist} and made it executable."
	else
		echo "Failed to create ${open_checklist}."
	fi

cat << EOF > "$checklist_agent"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.loginonce</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/${CURRENT_USER}/.open_checklist.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>LaunchOnlyOnce</key>
    <true/>
</dict>
</plist>
EOF

	if [[ -f "$checklist_agent" ]]; then
		chown "${CURRENT_USER}:staff" "$checklist_agent"
		chmod 644 "$checklist_agent"
		echo "Created user LaunchAgent."
	else
		echo "Failed to create user LaunchAgent."
	fi
fi

# Kill the Microsoft AutoUpdate BS notice.
# ms_update=$( ps -ef | grep -i "Microsoft" | grep -v grep | awk '{ print $2 }' )

# if [[ -n "$ms_update" ]]; then
#   for proc in "${ms_update[@]}"; do
#     kill "$proc"
#     echo "Killed Microsoft AutoUpdate ${proc}."
#   done
# else
#   echo "Couldn't find MS process to kill."
# fi

# 8. Nice completion text
echo "Status: $INSTALL_COMPLETE_TEXT" >> "$DEP_NOTIFY_LOG"

# ═════════════════════════════════════════════
# FileVault & Script Completion Logic 

if [[ "$FV_ENABLED" = true ]]; then
# Check to see if FileVault Deferred enablement is active
  FV_DEFERRED_STATUS=$($FDE_SETUP_BINARY status | grep "Deferred" | cut -d ' ' -f6)

  # Logic to log user out if FileVault is detected. Otherwise, app will close.
  if [ "$FV_DEFERRED_STATUS" = "active" ] && [ "$TESTING_MODE" = true ]; then
    if [ "$COMPLETE_METHOD_DROPDOWN_ALERT" = true ]; then
		echo "Command: Quit: This is typically where your FV_LOGOUT_TEXT would be displayed. However, TESTING_MODE is set to true and FileVault deferred status is on." >> "$DEP_NOTIFY_LOG"
    else
      echo "Command: MainText: TESTING_MODE is set to true and FileVault deferred status is on. Button effect is quit instead of logout. \n \n $FV_COMPLETE_MAIN_TEXT" >> "$DEP_NOTIFY_LOG"
      echo "Command: ContinueButton: Test $FV_COMPLETE_BUTTON_TEXT" >> "$DEP_NOTIFY_LOG"
    fi
  elif [ "$FV_DEFERRED_STATUS" = "active" ] && [ "$TESTING_MODE" = false ]; then
    if [ "$COMPLETE_METHOD_DROPDOWN_ALERT" = true ]; then
      echo "Command: RestartNow: $FV_ALERT_TEXT" >> "$DEP_NOTIFY_LOG"
    else
      echo "Command: MainText: $FV_COMPLETE_MAIN_TEXT" >> "$DEP_NOTIFY_LOG"
      echo "Command: RestartNow: $FV_COMPLETE_BUTTON_TEXT" >> "$DEP_NOTIFY_LOG"
      fi
    else
      if [ "$COMPLETE_METHOD_DROPDOWN_ALERT" = true ]; then
        echo "Command: Quit: $COMPLETE_ALERT_TEXT" >> "$DEP_NOTIFY_LOG"
      else
        echo "Command: MainText: $COMPLETE_MAIN_TEXT" >> "$DEP_NOTIFY_LOG"
        #echo "Command: ContinueButton: $COMPLETE_BUTTON_TEXT" >> "$DEP_NOTIFY_LOG"
        echo "Command: Quit" >> "$DEP_NOTIFY_LOG"
      fi
    fi
else
  if [ "$COMPLETE_METHOD_DROPDOWN_ALERT" = true ]; then
    echo "Command: Quit: $COMPLETE_ALERT_TEXT" >> "$DEP_NOTIFY_LOG"
  else
    # Complete Logic
    echo "Command: MainText: $COMPLETE_MAIN_TEXT" >> "$DEP_NOTIFY_LOG"
    echo "Command: Quit: $COMPLETE_BUTTON_TEXT" >> "$DEP_NOTIFY_LOG"
  fi
fi

END_DATE=$( date +"%Y-%m-%d %H:%M:%S" )
echo "Enrollment script terminated at: ${END_DATE}."
echo "Restarting..."

# Prevent the DEP agent from running again.
launchctl bootout system/com.arekdreyer.DEPNotify-prestarter

shutdown -r now

exit 0
