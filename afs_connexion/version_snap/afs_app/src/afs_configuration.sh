#!/bin/bash

# Demande à l'utilisateur d'entrer son nom d'utilisateur
USERNAME=$(whiptail --inputbox "Veuillez entrer votre nom d'utilisateur (prenom.nom) de votre compte EPITA :" 10 60 3>&1 1>&2 2>&3)
if [ $? -ne 0 ]; then
    echo "Installation annulée."
    exit 1
fi

# Enregistrement des données dans un fichier de configuration
CONFIG_DIR="$HOME/.afs"
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir "$CONFIG_DIR"
fi
echo "USERNAME=$USERNAME" > "$CONFIG_DIR/afs_configuration.conf"

echo "Configuration SSH..."
SSH_CONFIG="$HOME/.ssh/config"
# Vérifie si le fichier de configuration existe, sinon le crée
if [ ! -f "$SSH_CONFIG" ]; then
    touch "$SSH_CONFIG"
fi

# Vérifie si l'entrée d'hôte est déjà présente dans le fichier SSH
if ! grep -Fxq "Host git.cri.epita.fr" "$SSH_CONFIG"; then
    echo "Configuration du SSH : $SSH_CONFIG."
    # Ajoute l'entrée au fichier de configuration
    cat <<EOL >> "$SSH_CONFIG"
Host git.cri.epita.fr
  GSSAPIAuthentication yes

Host ssh.cri.epita.fr
  GSSAPIAuthentication yes
  GSSAPIDelegateCredentials yes
EOL
    echo "La configuration a été rajoutée."
else
    echo "Le SSH est déjà configuré sur : $SSH_CONFIG. Aucune action requise."
fi

echo "SSH configuré."
