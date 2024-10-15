#!/bin/bash

# Fonction pour gérer les erreurs et arrêter le script en cas d'échec
function handle_error {
    echo "Erreur rencontrée : $1. Arrêt de la connexion !"
    sleep 3
    exit 1
}

function start {
    # Vérification de la connexion internet
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
    CONFIG_FILE="$HOME/.afs/afs_configuration.conf"  # Chemin modifié pour être dans le répertoire personnel
    for ((attempt=1; attempt<=2; attempt++)); do 
        if [ -f "$CONFIG_FILE" ]; then
            source "$HOME/.afs/afs_configuration.conf"       

            # Vérification de la validité de la variable USERNAME
            if [[ ! "$USERNAME" =~ ^[a-zA-Zàâçéèêëîïôûñ]{1}[a-zA-Zàâçéèêëîïôûñ-]*\.[a-zA-Zàâçéèêëîïôûñ]{1}[a-zA-Zàâçéèêëîïôûñ-]*$ ]]; then
                handle_error "Le fichier de configuration est invalide. USERNAME doit être au format 'prenom.nom', avec des prénoms ou noms composés autorisés."
            fi
        else 
            reconfiguration "$CONFIG_FILE"
        fi
    done

    # Appel des fonctions
    ticket_generation "$USERNAME"
    file_generation 
    afs_connection "$USERNAME"
}

# Fonction pour régénérer la configuration
function reconfiguration {
    echo "
        Le fichier de configuration est manquant et/ou est incomplet !
        Voulez-vous reconfigurer l'AFS ? (y/n)
    "
    read choice
    if [ "$choice" == 'y' ]; then
        # Si le dossier de configuration n'existe pas, on le crée
        if [ ! -d "$HOME/.afs/" ]; then
            mkdir "$HOME/.afs/"
        fi
        
        USERNAME=$(whiptail --inputbox "Veuillez entrer votre nom d'utilisateur (prenom.nom) de votre compte EPITA :" 10 60 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ]; then
            handle_error "Impossible de continuer sans un fichier de configuration valide !"
        fi
        echo "USERNAME=$USERNAME" > "$CONFIG_FILE"
    else
        handle_error "Impossible de continuer sans un fichier de configuration valide !"
    fi
}

# Fonction pour générer le ticket pour pouvoir se connecter à l'AFS
function ticket_generation {
    DOMAIN="CRI.EPITA.FR"
    USERNAME=$1
    
    # Génération du ticket Kerberos
    for ((attempt=1; attempt<=3; attempt++)); do
        echo "Génération du ticket Kerberos pour $USERNAME@$DOMAIN (Tentative n°$attempt/3)..."
        if kinit -f "$USERNAME@$DOMAIN"; then
            sleep 2
            echo "Ticket généré avec succès."
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
            echo "Connexion SSHFS réussie. Votre AFS se trouve dans votre dossier personnel."
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
    # Création du dossier de l'AFS dans le répertoire personnel
    AFS_PATH="$HOME/afs"
    if [ ! -d "$AFS_PATH" ]; then
        mkdir -p "$AFS_PATH"    
    fi
    echo "Petit tip : Vous pouvez ajouter ce dossier dans vos signets, mais pensez à vous reconnecter !"
}

# Démarrer le script
start
echo "Connecté avec succès à l'AFS"
sleep 5
