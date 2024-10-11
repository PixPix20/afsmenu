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

echo "Entrez votre prénom : "
read prenom

# Transformation pour extraire les lettres
premiere_lettre=$(echo "$prenom" | head -c 1)
deuxieme_lettre=$(echo "$prenom" | head -c 2)

afs_path="/afs/cri.epita.fr/user/$premiere_lettre/$deuxieme_lettre/$prenom/u/"

echo "Le chemin AFS est : $afs_path"

# Ici, tu peux continuer avec le reste de ton script
