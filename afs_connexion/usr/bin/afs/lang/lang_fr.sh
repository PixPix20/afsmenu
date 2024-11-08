#!/bin/bash
#statut
msg_error="Arrêt de la connexion !"
msg_warning="Attention ! "
msg_no_connection="Impossible de se connecter à l'intranet. 
  1. Vérifiez que vous êtes connecté à internet.
  2. Si vous êtes connecté, cela vient peut-être d'EPITA. 
  3. Consultez le blog du cri pour en savoir plus."
msg_checking_dependencies="Vérification des dépendances..."
msg_dependency_check_failed_part_one="La commande"
msg_dependency_check_failed_part_two="n'est pas installée ou introuvable."
msg_dependency_checking_success="Toutes les dépendances sont présentes."
msg_missing_config=" Le fichier de configuration est manquant et/ou est incomplet !
Voulez-vous reconfigurer l'AFS ? (y/n)"
msg_file_creation="Création du dossier .afs"
msg_enter_username="Veuillez entrer votre nom d'utilisateur (prenom.nom) de votre compte EPITA :"
msg_invalid_config="Impossible de continuer sans un fichier de configuration valide !"
msg_kerberos_generation="Génération du ticket Kerberos pour"
msg_attempt="(Tentative n°"
msg_ticket_success="Ticket généré avec succès."
msg_kerberos_failure="Échec de la génération du ticket Kerberos. Veuillez réessayer."
msg_kerberos_auth_failure="Échec de l'authentification Kerberos après 3 tentatives."
msg_afs_mounted="Le disque AFS est déjà monté."
msg_afs_unmounting="Démontage du disque AFS en cours..."
msg_afs_unmounted="Disque AFS démonté avec succès."
msg_afs_unmount_failure="Échec du démontage du disque AFS."
msg_afs_already_connected="Vous êtes déjà connecté à l'AFS. Voulez-vous vous reconnecter ?"
msg_afs_already_connected_no_need="Vous êtes déjà connecté à l'AFS, pas besoin de vous reconnecter."
msg_yes="OUI"
msg_no="NON"
msg_afs_connection_attempt="Tentative de connexion à l'AFS sur "
msg_sshfs_success="Connexion SSHFS réussie. Votre AFS se trouve dans votre dossier personnel."
msg_sshfs_failure="Échec de la connexion SSHFS. Nouvelle tentative dans 3 secondes."
msg_sshfs_failure_final="Échec de la connexion SSHFS après 2 tentatives."
msg_afs_creation="Création du dossier de l'afs."
msg_afs_tip="Petit tip : Vous pouvez ajouter ce dossier dans vos signets, mais pensez à vous reconnecter !"
msg_afs_connected_success="Connecté avec succès à l'AFS."