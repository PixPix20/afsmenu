#!/bin/bash
# Message file for main script
# Convention: <group>_<subject>_<action>[_<status>]

# Warnings
warning_general="Warning!"

# Connection
connection_stop="Connection stopped!"
connection_check_failed="Unable to connect to the intranet.
  1. Check that you are connected to the internet.
  2. If you are connected, the issue may be with EPITA.
  3. Check the CRI blog for more information."

# Dependencies
dependency_check_start="Checking dependencies..."
dependency_check_missing="The command %s is not installed or not found."
dependency_check_success="All dependencies are present."

# Configuration
config_check_failed="The configuration file is missing and/or incomplete!
Would you like to reconfigure AFS? (y/n)"
config_create_dir="Creating .afs folder"
config_prompt_username="Please enter your EPITA account username (firstname.lastname):"
config_invalid="Cannot proceed without a valid configuration file!"

# Kerberos
kerberos_ticket_generate_for="Generating Kerberos ticket for"
kerberos_ticket_generate_attempt="(Attempt #%d)"
kerberos_ticket_generate_retry="Kerberos ticket generation failed. Please try again."
kerberos_ticket_generate_success="Ticket successfully generated."
kerberos_ticket_generate_failed="Kerberos authentication failed after 3 attempts."

# AFS
afs_mount_already="The AFS drive is already mounted."
afs_unmount_start="Unmounting the AFS drive..."
afs_unmount_success="AFS drive successfully unmounted."
afs_unmount_failed="Failed to unmount the AFS drive."
afs_already_connected_prompt="You are already connected to AFS. Would you like to reconnect?"
afs_already_connected_no_action="You are already connected to AFS; no need to reconnect."

# Answers
answer_yes="YES"
answer_no="NO"

# SSHFS
sshfs_connect_attempt="Attempting to connect to AFS on %s"
sshfs_connect_success="SSHFS connection successful. Your AFS is in your home directory."
sshfs_connect_retry="SSHFS connection failed. Retrying in 3 seconds."
sshfs_connect_failed="SSHFS connection failed after 2 attempts."

# Directories
afs_dir_create="Creating the AFS folder."
afs_dir_tip="Tip: You can add this folder to your bookmarks, but remember to reconnect!"
afs_connect_success="Successfully connected to AFS."
