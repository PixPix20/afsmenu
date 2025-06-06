#!/bin/bash
#variables
version="1.2"
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
  printf "\033[31m %s %s \033[0m\n" "$s" "$connection_stop"
  sleep 3
  exit 1
}
function warning {
  printf "\033[33m [%s] %s \033[0m\n" "$warning_general" "$1"
  sleep 3
}
function success {
  printf "\033[32m%s\033[0m\n" "$1"
  sleep 2
}
function info {
  printf "%s\n" "$1"
  sleep 2
}
function debug {
  printf "%s\n" "$1"
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
  printf "%s\n" "          _                   _              _ "
  printf "%s\n" "         / /\                /\ \           / /\ "
  printf "%s\n" "        / /  \              /  \ \         / /  \ "
  printf "%s\n" "       / / /\ \            / /\ \ \       / / /\ \__ "
  printf "%s\n" "      / / /\ \ \          / / /\ \_\     / / /\ \___\ "
  printf "%s\n" "     / / /  \ \ \        / /_/_ \/_/     \ \ \ \/___/ "
  printf "%s\n" "    / / /___/ /\ \      / /____/\         \ \ \ "
  printf "%s\n" "   / / /_____/ /\ \    / /\____\/     _    \ \ \ "
  printf "%s\n" "  / /_________/\ \ \  / / /          /_/\__/ / / "
  printf "%s\n" " / / /_       __\ \_\/ / /           \ \/___/ / "
  printf "%s\n" " \_\___\     /____/_/\/_/             \_____/\/ "
  printf "%s\n" "Version : $version"
#########################################################################

  if ! ping -c 1 -W 3 "$host" > /dev/null; then
      error "$connection_check_failed"
  fi

  debug "$dependency_check_start"
  for cmd in kinit sshfs whiptail; do
      if ! command -v "$cmd" &> /dev/null; then
          error "$dependency_check_missing $cmd"
      fi
  done
  success "$dependency_check_success"

  for ((attempt=1; attempt<=2; attempt++)); do 
    if [ -f "$afs_configuration_file_location" ]; then
        source "$afs_configuration_file_location"
        if [ -z "$id_epita" ]; then
            reconfiguration
            break
        fi
    else
        reconfiguration
        break
    fi
  done

  ticket_generation "$id_epita"
  file_generation 
  sshfs_connection "$id_epita"
}

function reconfiguration {
  warning "$config_check_failed"
  read choice
  if [ $choice == 'y' ]; then
      if [ ! -d "$afs_configuration_location" ]; then
          debug "$config_create_dir"
          mkdir "$afs_configuration_location"
      fi
      id_epita=$(whiptail --inputbox "$config_prompt_username" 10 60 3>&1 1>&2 2>&3)
      if [ $? -ne 0 ]; then
          error "$config_invalid"
      fi
      echo "id_epita=$id_epita" >> "$afs_configuration_file_location"
  else
      error "$config_invalid"
  fi
}

function ticket_generation {
  id_epita=$1

  if [[ -z "$id_epita" ]]; then
      error $kerberos_ticket_generate_retry
  fi

  for ((attempt=1; attempt<=3; attempt++)); do
      printf "%s\n" "$kerberos_ticket_generate_for $id_epita@$cri_host_kerberos ($kerberos_ticket_generate_attempt$attempt/3)..."
      
      if kinit -f "$id_epita@$cri_host_kerberos"; then
          success "$kerberos_ticket_generate_success"
          return 0
      else
          warning "$kerberos_ticket_generate_retry"
      fi
  done

  error "$kerberos_ticket_generate_failed"
}

function check_afs_connected {
  if mount | grep -q "$afs_location"; then
      return 0
  else
      return 1
  fi
}

function afs_dismount {
  info "$afs_unmount_start"
  if fusermount -u "$afs_location"; then
      success "$afs_unmount_success"
  else
      error "$afs_unmount_failed"
  fi
}

function sshfs_connection {
  id_epita=$1
  first_letter=$(echo "$id_epita" | head -c 1)
  second_letter=$(echo "$id_epita" | head -c 2)
  if check_afs_connected; then
      if whiptail --yesno "$afs_already_connected_prompt" --yes-button "$answer_yes" --no-button "$answer_no" 10 60 3>&1 1>&2 2>&3 ; then
        afs_dismount
      else
        success "$afs_already_connected_no_action"
        exit 0
      fi  
  fi

  for ((attempt=1; attempt<=2; attempt++)); do
      info "$sshfs_connect_attempt $id_epita@$ssh_host... "
      if sshfs -o reconnect "$id_epita@$ssh_host:$url/$first_letter/$second_letter/$id_epita/u/" "$afs_location"; then
          success "$sshfs_connect_success"
          break
      else
          warning "$sshfs_connect_retry"
      fi
      if [ $attempt -eq 2 ]; then
          error "$sshfs_connect_failed"
      fi
  done
}

function file_generation {
  if [ ! -d "$afs_location" ]; then
    debug "$afs_dir_create"
    mkdir -p "$afs_location"    
  fi
  info "$afs_dir_tip"
}

function prestart {
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
    error "Le fichier de configuration est manquant ! Tu peux le créer et le configurer avec le script | The configuration file is missing! You can create it and you can configure it with the script"
  fi
  start
}

prestart
success "$afs_connect_success"
sleep 5
