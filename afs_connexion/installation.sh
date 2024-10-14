#!/bin/bash

echo "Configuration SSH..."
SSH_CONFIG="$HOME/.ssh/config"
# Vérifie si le fichier de configuration existe, sinon le crée
if [ ! -f "$SSH_CONFIG" ]; then
    touch "$SSH_CONFIG"
fi
HOST_ENTRY
    "Host git.cri.epita.fr
      GSSAPIAuthentication yes
    
    Host ssh.cri.epita.fr
      GSSAPIAuthentication yes
      GSSAPIDelegateCredentials yes
      "

if grep -Fxq "Host" "$SSH_CONFIG"; then
    echo "Le SSH et déja configuré sur : $SSH_CONFIG. Aucune action requise."
else
    echo "Configuration du SSH : $SSH_CONFIG."
    # Ajoute l'entrée au fichier de configuration
    echo "$HOST_ENTRY" >> "$SSH_CONFIG"
    echo "La configuration a été rajoutée."
fi
echo "SSH configuré."

echo "Entrez votre identifiant EPITA(prenom.nom) : "
read username

# Transformation pour extraire les lettres du nom d'utilisateur
#Exemple prenom.nom -> first_char=p, second_char=pr
#Cette étape est obligatoire pour se connecter à son AFS 

first_char=$(echo "$username" | head -c 1)
second_char=$(echo "$username" | head -c 2)

afs_path="/afs/cri.epita.fr/user/$first_char/$second_char/$username/u/"

echo "Le chemin de votre AFS est : $afs_path"
