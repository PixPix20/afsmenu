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
 

