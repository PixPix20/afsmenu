#!/bin/bash

# Fonction pour gérer les erreurs et arrêter le script en cas d'échec
function handle_error {
    echo "Erreur rencontrée : $1. Arrêt du script."
    sleep 3
    exit 1
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
  if ! ping -c 1 -W 3 "google.com" > /dev/null; then
      handle_error "Impossible de se connecter à Internet. Vérifiez la connexion réseau."
  fi
  
  # Vérification des dépendances requises (kinit, sshfs)
  echo "Vérification des dépendances..."
  for cmd in kinit sshfs; do
      if ! command -v "$cmd" &> /dev/null; then
          handle_error "La commande '$cmd' n'est pas installée ou introuvable."
      fi
  done
  echo "Toutes les dépendances sont présentes."

  # Chargement des données de configuration
  for ((attempt=1; attempt<=2; attempt++)); do 
      if [ -f /etc/afs_configuration.conf ]; then
          source /etc/afs_configuration.conf       
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
  echo "
       Le fichier de configuration est manquant et/ou est incomplet ! 
       Attention cette action demande un accès administrateur.
       
       Voulez-vous reconfigurer l'AFS ? (y/n)
       "
  read reconfigure
  if [ "$reconfigure" == 'y' ]; then
      echo "Entrez votre nom d'utilisateur (prenom.nom) de votre compte EPITA : "
      read USERNAME
      echo "USERNAME=$USERNAME" | sudo tee /etc/afs_configuration.conf
  else
      handle_error "Impossible de continuer sans un fichier de configuration valide."
  fi
}

# Fonction pour générer le ticket pour pouvoir se connecter à l'AFS
function ticket_generation {
  DOMAIN="CRI.EPITA.FR"
  USERNAME=$1
  
  # Génération du ticket Kerberos
  for ((attempt=1; attempt<=3; attempt++)); do
      echo "Génération du ticket Kerberos pour $USERNAME@$DOMAIN (Tentative $attempt/3)..."
      if kinit -f "$USERNAME@$DOMAIN"; then
          echo "Ticket généré avec succès."
          sleep 2
          break  # Sortie de la boucle si kinit réussit
      else
          echo "Échec de la génération du ticket Kerberos. Veuillez réessayer."
          sleep 2
      fi
      if [ $attempt -eq 3 ]; then
          handle_error "Échec de l'authentification Kerberos après 3 tentatives."
      fi
  done
}

function afs_connection {
  SSH_SERVER="ssh.cri.epita.fr"
  USERNAME=$1
  # Transformation pour extraire les lettres
  first_letter=$(echo "$USERNAME" | head -c 1)
  second_letter=$(echo "$USERNAME" | head -c 2)
  
  for ((attempt=1; attempt<=2; attempt++)); do
      echo "Tentative de connexion à l'AFS $USERNAME@$SSH_SERVER (Tentative $attempt/2)..."
      
      # Correctement formater la commande sshfs
      if sshfs -o reconnect "$USERNAME@$SSH_SERVER:/afs/cri.epita.fr/user/$first_letter/$second_letter/$USERNAME/u/" "$HOME/afs"; then
          echo "Connexion SSHFS réussie.
          Votre AFS se trouve dans votre dossier personnel."
          sleep 2
          break  # Sortie de la boucle si SSHFS réussit
      else
          echo "Échec de la connexion SSHFS. Nouvelle tentative dans 3 secondes."
          sleep 3
      fi
      if [ $attempt -eq 2 ]; then
          handle_error "Échec de la connexion SSHFS après 2 tentatives."
      fi
  done
}

function file_generation {
  # Création du dossier de l'AFS dans le répertoire de l'utilisateur
  AFS_PATH="$HOME"
  if [ ! -d "$AFS_PATH/afs" ]; then
      mkdir -p "$AFS_PATH/afs"    
  fi
  echo "Petit tip : Vous pouvez ajouter ce dossier dans vos signets, mais pensez à vous reconnecter !"
}

# Démarrer le script
start
echo "Connecté avec succès à l'AFS"
sleep 5
