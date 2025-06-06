#!/bin/bash
# Fichier de messages pour le script principal
# Convention : <groupe>_<sujet>_<action>[_<statut>]

# Warnings
warning_general="Attention !"

# Connexion
connection_stop="Arrêt de la connexion !"
connection_check_failed="Impossible de se connecter à l'intranet.
  1. Vérifiez que vous êtes connecté à internet.
  2. Si vous êtes connecté, cela vient peut-être d'EPITA.
  3. Consultez le blog du cri pour en savoir plus."

# Dépendances
dependency_check_start="Vérification des dépendances..."
dependency_check_missing="La commande n'est pas installée ou introuvable : "
dependency_check_success="Toutes les dépendances sont présentes."

# Configuration
config_check_failed="Le fichier de configuration est manquant et/ou est incomplet !
Voulez-vous reconfigurer l'AFS ? (y/n)"
config_create_dir="Création du dossier .afs"
config_prompt_username="Veuillez entrer votre nom d'utilisateur (prenom.nom) de votre compte EPITA :"
config_invalid="Impossible de continuer sans un fichier de configuration valide !"

# Kerberos
kerberos_ticket_generate_for="Génération du ticket Kerberos pour"
kerberos_ticket_generate_attempt="Tentative n°"
kerberos_ticket_generate_retry="Échec de la génération du ticket Kerberos. Veuillez réessayer."
kerberos_ticket_generate_success="Ticket généré avec succès."
kerberos_ticket_generate_failed="Échec de l'authentification Kerberos après 3 tentatives."

# AFS
afs_mount_already="Le disque AFS est déjà monté."
afs_unmount_start="Démontage du disque AFS en cours..."
afs_unmount_success="Disque AFS démonté avec succès."
afs_unmount_failed="Échec du démontage du disque AFS."
afs_already_connected_prompt="Vous êtes déjà connecté à l'AFS. Voulez-vous vous reconnecter ?"
afs_already_connected_no_action="Vous êtes déjà connecté à l'AFS, pas besoin de vous reconnecter."

# Réponses
answer_yes="OUI"
answer_no="NON"

# SSHFS
sshfs_connect_attempt="Tentative de connexion à l'AFS sur"
sshfs_connect_success="Connexion SSHFS réussie. Votre AFS se trouve dans votre dossier personnel."
sshfs_connect_retry="Échec de la connexion SSHFS. Nouvelle tentative dans 3 secondes."
sshfs_connect_failed="Échec de la connexion SSHFS après 2 tentatives."

# Dossiers
afs_dir_create="Création du dossier de l'AFS."
afs_dir_tip="Petit tip : Vous pouvez ajouter ce dossier dans vos signets, mais pensez à vous reconnecter !"
afs_connect_success="Connecté avec succès à l'AFS."
