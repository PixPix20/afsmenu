#!/bin/bash
#variables
version="1.4"
host="epita.fr"
cri_host_kerberos="CRI.EPITA.FR"
cri_host="cri.$host"
ssh_host="ssh.$cri_host"
url="/afs/$cri_host/user"
afs_configuration_location="$HOME/.afs"
afs_configuration_file_location="$afs_configuration_location/configuration.conf"
afs_location="$HOME/afs"
language_file_location="/usr/share/afs/lang"

# Function to handle errors and stop the script in case of failure
function error {
  echo -e "\033[31m $1 $msg_error \033[0m" # Display text in red
  sleep 3
  exit 1
}
function warning {
  echo -e "\033[33m [$msg_warning] $1 \033[0m" # Display text in orange
  sleep 3
}
function success {
  echo -e "\033[32m $1 \033[0m " # Display text in green
  sleep 2
}
function info {
  echo  -e "$1"
  sleep 2
}
function debug {
  echo -e " $1 " # This is coming soon... mainly for devs
}

function start {
  # The startup phase consists of 3 steps:
  # 1. Check internet connection and servers (hard to get AFS without internet)
  # 2. Check software dependencies
  # 3. Import the user configuration
  
  # The connection phase consists of 3 steps
  # 1. Generate the EPITA Kerberos ticket
  # 2. Check if the AFS folder exists; if not, create it in the home directory
  # 3. Connect to AFS via the AFS folder in the home directory (/home/user/afs)
  
######################################################################### 
  echo "          _                   _              _ ";
  echo "         / /\                /\ \           / /\ ";
  echo "        / /  \              /  \ \         / /  \ ";
  echo "       / / /\ \            / /\ \ \       / / /\ \__ ";
  echo "      / / /\ \ \          / / /\ \_\     / / /\ \___\ ";
  echo "     / / /  \ \ \        / /_/_ \/_/     \ \ \ \/___/ ";
  echo "    / / /___/ /\ \      / /____/\         \ \ \ ";
  echo "   / / /_____/ /\ \    / /\____\/     _    \ \ \ ";
  echo "  / /_________/\ \ \  / / /          /_/\__/ / / ";
  echo " / / /_       __\ \_\/ / /           \ \/___/ / ";
  echo " \_\___\     /____/_/\/_/             \_____\/ ";
  echo ""
  echo "Version : $version"
#########################################################################

  # Checking connection
  if ! ping -c 1 -W 3 "$host" > /dev/null; then
      error "$msg_no_connection"
  fi
  
  # Checking required dependencies (kinit, sshfs)
  debug "$msg_checking_dependencies"
  for cmd in kinit sshfs whiptail; do
      if ! command -v "$cmd" &> /dev/null; then
          error "$msg_dependency_check_failed_part_one $cmd $msg_dependency_check_failed_part_two"
      fi
  done
  success "$msg_dependency_checking_success"

  # Loading configuration data
  for ((attempt=1; attempt<=2; attempt++)); do 
      if [ -f "$afs_configuration_file_location" ]; then
          source "$afs_configuration_file_location"       
      elif [ "$id_epita" == "" ]; then
          reconfiguration
          break
      else 
          reconfiguration
      fi
  done

  # Calling functions
  ticket_generation "$id_epita"
  file_generation 
  afs_connection "$id_epita"
}

# Function to regenerate configuration
function reconfiguration {
  
  warning "$msg_missing_config"
  read choice
  if [ $choice == 'y' ]; then
    
      # If the configuration folder has been deleted, regenerate it.
        if [ ! -d "$afs_configuration_location" ]; then
          debug "$msg_file_creation"
          mkdir "$afs_configuration_location"
        fi
        
      #echo "Enter your EPITA username (firstname.lastname) : "
      id_epita=$(whiptail --inputbox "$msg_enter_username" 10 60 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ]; then
                error "$msg_invalid_config"
        fi
      echo "USERNAME=$id_epita" >> "$afs_configuration_file_location"
  else
      error "$msg_invalid_config"
  fi
}

# Function to generate the ticket for connecting to AFS
function ticket_generation {
  id_epita=$1
  
  # Generate Kerberos ticket
  for ((attempt=1; attempt<=3; attempt++)); do
      echo "$msg_kerberos_generation $id_epita@$cri_host_kerberos $msg_attempt$attempt/3)..."
      if (kinit -f "$id_epita@$cri_host_kerberos"); then
          success "$msg_ticket_success"
          break  # Exit the loop if kinit succeeds
      else
          warning "$msg_kerberos_failure"
      fi
      if [ $attempt -eq 3 ]; then
          error "$msg_kerberos_auth_failure"
      fi
  done
}

# Function to check if the 'afs' disk is mounted
function check_afs_connected {
  if mount | grep -q "$afs_location"; then
      #warning "$msg_afs_mounted"
      return 0
  else
      return 1
  fi
}

function afs_dismount {
  # Check if disk is mounted
    info "$msg_afs_unmounting"
    # Unmount disk
    if fusermount -u "$afs_location"; then
        success "$msg_afs_unmounted"
    else
        error "$msg_afs_unmount_failure"
    fi
}

function afs_connection {
  id_epita=$1
  # Transformation to extract letters
  first_letter=$(echo "$id_epita" | head -c 1)
  second_letter=$(echo "$id_epita" | head -c 2)
  
  # Check if disk is mounted before connecting
  if check_afs_connected; then
      if whiptail --yesno "$msg_afs_already_connected" --yes-button "$msg_yes" --no-button "$msg_no" 10 60 3>&1 1>&2 2>&3 ; then
        afs_dismount
      else
        success "$msg_afs_already_connected_no_need"
        exit 0
      fi  
  fi

  for ((attempt=1; attempt<=2; attempt++)); do
      info "$msg_afs_connection_attempt $id_epita@$ssh_host $msg_attempt$attempt/2)... "
      # Properly format the sshfs command
      if sshfs -o reconnect "$id_epita@$ssh_host:$url/$first_letter/$second_letter/$id_epita/u/" "$afs_location"; then
          success "$msg_sshfs_success"
          break  # Exit loop if SSHFS succeeds
      else
          warning "$msg_sshfs_failure"
      fi
      if [ $attempt -eq 2 ]; then
          error "$msg_sshfs_failure_final"
      fi
  done
}

function file_generation {
  # Create the AFS folder in the user's directory
  if [ ! -d "$afs_location" ]; then
    debug "$msg_afs_creation"
      mkdir -p "$afs_location"    
  fi
  info "$msg_afs_tip"
}
#function cloning_afs {
#  if check_afs_connected; then
#    sftp -r "$id_epita@$ssh_host"
  
#  fi
#}
  
function prestart {
  # Initialize the program before launch
  if [ -f "$afs_configuration_file_location" ]; then
    source "$afs_configuration_file_location"
    
    if [ -d "$language_file_location" ]; then
      
      if [ -f "$language_file_location/lang_$language.sh" ]; then
        source "$language_file_location/lang_$language.sh"
        
      elif [ -f "$language_file_location/lang_en.sh" ]; then
        source "$language_file_location/lang_en.sh"
      
      else
        error "Impossible de charger les langues, fichier manquant. | Unable to load languages, file missing."
      fi
      
    else
      error "Impossible de charger les langues, le dossier des langues est manquant. | Unable to load languages, language folder missing."
    fi
    
  else
      error "Le fichier de configuration est manquant ! | The configuration file is missing !"
  fi
  
  start
}



# Start the script
prestart
success "$msg_afs_connected_success"
sleep 5
