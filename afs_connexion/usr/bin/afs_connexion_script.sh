#!/bin/bash

#Vérification de la connexion
if ! ping -c 1 -W 3 "google.com" > /dev/null; then
    handle_error "Impossible de se connecter à Internet. Vérifiez la connexion réseau."
    exit 1
fi

# Chargement des données de configuration
for ((attempt=1; attempt<=2; attempt++)); do
  
    if [ -f /etc/afs_configuration.conf ]; then
        source /etc/afs_configuration.conf
        break
    else
        
        echo "
Le fichier de configuration est manquant. 
Attention cette action demande un accès administrateur.

Voulez vous reconfigurer l'AFS ? (y/n)
"
        read reconfigure
        if [ "$reconfigure" == 'y' ]; then
            echo "Entrez votre nom d'utilisateur (prenom.nom) de votre compte EPITA : "
            read USERNAME
            echo "USERNAME=$USERNAME" | sudo tee /etc/afs_configuration.conf
            
        else
            echo "Impossible de continuer sans fichier de configuration."
            exit 1
        fi
    fi
done
# Variables de configuration

# Transformation pour extraire les lettres
first_letter=$(echo "$USERNAME" | head -c 1)
second_letter=$(echo "$USERNAME" | head -c 2)

#USER=""
DOMAIN="CRI.EPITA.FR"
SSH_SERVER="ssh.cri.epita.fr"
#REMOTE_PATH="/afs/cri.epita.fr/user/$premiere_lettre/$deuxieme_lettre/$USERNAME/u/"
#LOCAL_MOUNT_POINT="./afs_mount"
#AFS_PARTITION="afs/"

#création du dossier de l'afs dans le repertoire de l'user
AFS_PATH="$HOME"
if [ ! -d "$AFS_PATH/afs" ]; then
    mkdir -p $AFS_PATH/"afs"    
fi

# Fonction pour gérer les erreurs et arrêter le script en cas d'échec
function handle_error {
    echo "Erreur rencontrée : $1. Arrêt du script."
    exit 1
}

# Vérification des dépendances requises (kinit, sshfs)
echo "Vérification des dépendances..."
for cmd in kinit sshfs umount; do
    if ! command -v "$cmd" &> /dev/null; then
        handle_error "La commande '$cmd' n'est pas installée ou introuvable."
    fi
done
echo "Toutes les dépendances sont présentes."

# Génération du ticket Kerberos
for ((attempt=1; attempt<=3; attempt++)); do
    echo "Génération du ticket Kerberos pour $USERNAME@$DOMAIN (Tentative $attempt/3)..."
    if kinit -f "$USERNAME@$DOMAIN"; then
        echo "Ticket généré avec succès."
        sleep 2
        break  # Sortie de la boucle si kinit réussit
    else
        echo "Échec de la génération du ticket Kerberos. Veuillez réessayer."
        slepp 2
    fi
    if [ $attempt -eq 3 ]; then
        handle_error "Échec de l'authentification Kerberos après 3 tentatives."
    fi
    
done
#sleep 5
for ((attempt=1; attempt<=2; attempt++)); do
    echo "Tentative de connection à l'AFS $USERNAME@$SSH_SERVER (Tentative $attempt/3)..."
    
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
        handle_error "Échec de la connexion SSHFS après 3 tentatives."
    fi
done

echo "Vous pouvez ajouter ce dossier dans vos signets mais pensez à vous reconnecter !"

# Vérification de l'état du réseau
#echo "Vérification de la connexion réseau..."
#if ! ping -c 1 -W 3 "$REMOTE_SERVER" > /dev/null; then
#    handle_error "Impossible de joindre le serveur $REMOTE_SERVER. Vérifiez la connexion réseau."
#fi
#echo "Connexion réseau active."

# Démontage des partitions AFS si elles sont montées
#echo "Vérification des partitions AFS montées..."
#if mount | grep "$AFS_PARTITION" > /dev/null; then
#    echo "Démontage des partitions AFS..."
#    if ! umount "$AFS_PARTITION"; then
#        handle_error "Échec du démontage des partitions AFS"
#    fi
#    echo "Partitions AFS démontées avec succès."
#else
#    echo "Aucune partition AFS n'est actuellement montée."
#fi
#sleep 2

# Reconnexion à l'AFS avec SSHFS
#echo "Connexion à l'AFS via SSHFS..."

# Vérification de l'existence du point de montage local
#if [ ! -d "$LOCAL_MOUNT_POINT" ]; then
#    echo "Création du point de montage local $LOCAL_MOUNT_POINT..."
#    if ! mkdir -p "$LOCAL_MOUNT_POINT"; then
#        handle_error "Impossible de créer le point de montage local"
#    fi
#fi

# Vérification des droits sur le point de montage local
#if [ ! -w "$LOCAL_MOUNT_POINT" ]; then
#    handle_error "Le répertoire $LOCAL_MOUNT_POINT n'est pas accessible en écriture."
#fi

# Montage via SSHFS avec reconnexion automatique
#if mountpoint -q "$LOCAL_MOUNT_POINT"; then
#    echo "Le point de montage $LOCAL_MOUNT_POINT est déjà monté. Démontage préalable..."
#    if ! fusermount -u "$LOCAL_MOUNT_POINT"; then
#        handle_error "Échec du démontage préalable du point de montage."
#    fi
#fi

#echo "Montage de l'AFS..."
#if ! sshfs -o reconnect "$USER@$REMOTE_SERVER:$REMOTE_PATH" "$LOCAL_MOUNT_POINT"; then
#    handle_error "Échec de la connexion à l'AFS via SSHFS"
#fi
echo "Connecté avec succès à l'AFS"
sleep 5