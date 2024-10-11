#!/bin/bash

# Chargement des données de configuration
if [ -f /etc/monscript.conf ]; then
    source /etc/monscript.conf
else
    echo "Le fichier de configuration est manquant. Veuillez réinstaller le script."
    exit 1
fi
# Variables de configuration

# Transformation pour extraire les lettres
premiere_lettre=$(echo "$prenom" | head -c 1)
deuxieme_lettre=$(echo "$prenom" | head -c 2)

#USER=""
DOMAIN="CRI.EPITA.FR"
REMOTE_SERVER="ssh.cri.epita.fr"
REMOTE_PATH="/afs/cri.epita.fr/user/$premiere_lettre/$deuxieme_lettre/$prenom/u/"
#LOCAL_MOUNT_POINT="./afs_mount"
#AFS_PARTITION="afs/"
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

#création du dossier de l'afs dans le repertoire de l'user



# Génération du ticket Kerberos
for ((attempt=1; attempt<=3; attempt++)); do
    echo "Génération du ticket Kerberos pour $USER@$DOMAIN (Tentative $attempt/3)..."
    if kinit -f "$USER@$DOMAIN"; then
        echo "Ticket généré avec succès."
        sleep 2
        break  # Sortie de la boucle si kinit réussit
    else
        echo "Échec de la génération du ticket Kerberos. Veuillez réessayer."
    fi
    if [ $attempt -eq 3 ]; then
        handle_error "Échec de l'authentification Kerberos après 3 tentatives."
    fi
    
done

for ((attempt=1; attempt<=3; attempt++)); do
    echo "Génération du ticket Kerberos pour $USER@$DOMAIN (Tentative $attempt/3)..."
    
    # Correctement formater la commande sshfs
    if sshfs -o reconnect "$USER@$DOMAIN:/afs/cri.epita.fr/user/$premiere_lettre/$deuxieme_lettre/$USER/u/" "$HOME/afs"; then
        echo "Connexion SSHFS réussie."
        sleep 2
        break  # Sortie de la boucle si sshfs réussit
    else
        echo "Échec de la connexion SSHFS. Tentative $attempt échouée."
    fi
    
    if [ $attempt -eq 3 ]; then
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
echo "Connecté avec succès à l'AFS à l'emplacement $LOCAL_MOUNT_POINT."
sleep 5

