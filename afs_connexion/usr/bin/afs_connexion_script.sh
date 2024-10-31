#!/bin/bash

# Fonction pour gérer les erreurs et arrêter le script en cas d'échec
function error {
  echo -e "\033[31m $1. Arrêt de la connexion ! \041[0m" #affiche le texte en rouge
  sleep 3
  exit 1
}
function warning {
  echo -e "\033[33m $1 \033[40m" #affiche le texte en orange
  sleep 3
}
function success {
  echo -e "\033[32m $1 \033[0m " #affiche le texte en vert
  sleep 2
}
function info {
  echo  -e "$1"
  sleep 2
}
function debug {
  echo -e " $1 " #à venir... mais bon c'est pricipalement pour les devs
}

function start {
  # La phase de lancement se déroule en 3 étapes :
  # 1. Vérification de la connexion internet (sans internet c'est dur d'avoir son AFS)
  # 2. Vérification des dépendances
  # 3. Import de la configuration
  
  # La phase de connexion se déroule en 3 étapes
  # 1. On génère le ticket Kerberos
  # 2. On regarde si le dossier de l'AFS existe, sinon on le crée dans le dossier personnel
  # 3. On se connecte à l'AFS via le dossier de l'AFS dans le dossier personnel (/home/user/afs)
  
  # Vérification de la connexion
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
#########################################################################
  
  if ! ping -c 1 -W 3 "cri.epita.fr/" > /dev/null; then
      error "Impossible de se connecter à l'intranet. 
      1. Vérifiez que vous êtes connecté à internet.
      2. Si vous êtes connecté, cela vient peut-être d'EPITA. 
      3. Consultez le blog du cri pour en savoir plus."
  fi
  
  # Vérification des dépendances requises (kinit, sshfs)
  info "Vérification des dépendances..."
  for cmd in kinit sshfs; do
      if ! command -v "$cmd" &> /dev/null; then
          error "La commande '$cmd' n'est pas installée ou introuvable."
      fi
  done
  success "Toutes les dépendances sont présentes."

  # Chargement des données de configuration
  for ((attempt=1; attempt<=2; attempt++)); do 
      if [ -f "$HOME/.afs/configuration.conf" ]; then
          source "$HOME/.afs/configuration.conf"       
      elif [ "$USERNAME" == "" ]; then
          reconfiguration
          break
      else 
          reconfiguration
      fi
  done

  # Appel des fonctions
  ticket_generation "$USERNAME"
  file_generation 
  afs_connection "$USERNAME"
}

# Fonction pour regénérer la configuration
function reconfiguration {
  
  warning "
       Le fichier de configuration est manquant et/ou est incomplet !
       Voulez-vous reconfigurer l'AFS ? (y/n)
       "
  read choice
  if [ $choice == 'y' ]; then
    
      # Si le dossier de configuration a été supprimé on le regénère.
        if [ ! -d "$HOME/.afs/" ]; then
          debug "Création du dossier .afs"
          mkdir "$HOME/.afs/"
        fi
        
      #echo "Entrez votre nom d'utilisateur (prenom.nom) de votre compte EPITA : "
      USERNAME=$(whiptail --inputbox "Veuillez entrer votre nom d'utilisateur (prenom.nom) de votre compte EPITA :" 10 60 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ]; then
                error "Impossible de continuer sans un fichier de configuration valide !"
        fi
      echo "USERNAME=$USERNAME" >> "$HOME/.afs/configuration.conf"
  else
      error "Impossible de continuer sans un fichier de configuration valide !"
  fi
}

# Fonction pour générer le ticket pour pouvoir se connecter à l'AFS
function ticket_generation {
  DOMAIN="CRI.EPITA.FR"
  USERNAME=$1
  
  # Génération du ticket Kerberos
  for ((attempt=1; attempt<=3; attempt++)); do
      echo "Génération du ticket Kerberos pour $USERNAME@$DOMAIN (Tentative n°$attempt/3)..."
      if (kinit -f "$USERNAME@$DOMAIN"); then
          success "Ticket généré avec succès."
          break  # Sortie de la boucle si kinit réussit
      else
          warning "Échec de la génération du ticket Kerberos. Veuillez réessayer."
      fi
      if [ $attempt -eq 3 ]; then
          error "Échec de l'authentification Kerberos après 3 tentatives."
      fi
  done
}

# Fonction pour vérifier si le disque 'afs' est monté
function check_afs_connected {
  if mount | grep -q "$HOME/afs"; then
      warning "Le disque AFS est déjà monté."
      return 0
  else
      return 1
  fi
}

function afs_dismount {
  # Vérification si le disque est monté
    info "Démontage du disque AFS en cours..."
    # Démonter le disque
    if fusermount -u "$HOME/afs"; then
        success "Disque AFS démonté avec succès."
    else
        error "Échec du démontage du disque AFS."
    fi
}

function afs_connection {
  SSH_SERVER="ssh.cri.epita.fr"
  USERNAME=$1
  # Transformation pour extraire les lettres
  first_letter=$(echo "$USERNAME" | head -c 1)
  second_letter=$(echo "$USERNAME" | head -c 2)
  
  # Vérification si le disque est monté avant de se connecter
  if check_afs_connected; then
      if whiptail --yesno "Vous êtes déja connecté à l'AFS. 
      Voulez vous vous déconnecter de l'AFS puis se reconnecter ?" --yes-button "OUI" --no-button "NON" 10 60 3>&1 1>&2 2>&3 ; then
        afs_dismount
      
      else
        success "Vous êtes déja connecté à l'AFS, pas besoin de vous reconnecter."
        exit 0
        
      fi  
  fi

  for ((attempt=1; attempt<=2; attempt++)); do
      info "Tentative de connexion à l'AFS $USERNAME@$SSH_SERVER (Tentative $attempt/2)..."
      
      # Correctement formater la commande sshfs
      if sshfs -o reconnect "$USERNAME@$SSH_SERVER:/afs/cri.epita.fr/user/$first_letter/$second_letter/$USERNAME/u/" "$HOME/afs"; then
          success " Connexion SSHFS réussie.
          Votre AFS se trouve dans votre dossier personnel."
          break  # Sortie de la boucle si SSHFS réussit
      else
          warning "Échec de la connexion SSHFS. Nouvelle tentative dans 3 secondes."
      fi
      if [ $attempt -eq 2 ]; then
          error "Échec de la connexion SSHFS après 2 tentatives."
      fi
  done
}

function file_generation {
  # Création du dossier de l'AFS dans le répertoire de l'utilisateur
  if [ ! -d "$HOME/afs" ]; then
    debug "Création du dossier de l'afs."
      mkdir -p "$HOME/afs"    
  fi
  info "Petit tip : Vous pouvez ajouter ce dossier dans vos signets, mais pensez à vous reconnecter !"
}

# Démarrer le script
start
success "Connecté avec succès à l'AFS"
sleep 5
