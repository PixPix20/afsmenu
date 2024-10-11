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

if grep -Fxq "Host nom_du_serveur" "$SSH_CONFIG"; then
    echo "L'entrée 'Host nom_du_serveur' existe déjà dans $SSH_CONFIG. Aucune action requise."
else
    echo "Ajout de l'entrée dans $SSH_CONFIG."
    # Ajoute l'entrée au fichier de configuration
    echo "$HOST_ENTRY" >> "$SSH_CONFIG"
    echo "L'entrée a été ajoutée avec succès."
fi
echo "SSH configuré."

echo "Entrez votre nom d'utilisateur (prenom.nom) : "
read user

# Transformation pour extraire les lettres du nom d'utilisateur
#Exemple prenom.nom -> first_char=p, second_char=pr
#Cette étape est obligatoire pour se connecter à son AFS 

first_char=$(echo "$user" | head -c 1)
second_char=$(echo "$user" | head -c 2)

afs_path="/afs/cri.epita.fr/user/$first_char/$second_char/$user/u/"

echo "Le chemin AFS est : $afs_path"
