VERSION : 1.1
Ceci est un paquet DEBIAN (.deb) pour automatiser la connexion à son AFS depuis son ordinateur personnel.
Il n'est utilisable **que** sur les OS (système d'exploitation) aillant un noyau DEBIAN (ubuntu, debian, lubuntu, etc).
Pour savoir un peu plus comment le script marche, je vous invite à lire le blog du CRI : _https://blog.cri.epita.fr/post/2020-10-30-migration-realm-kerberos/_
Voici les commandes pour le transformer/installer si vous téléchargez les fichiers depuis le Github.
-Transformation en fichier .deb : **dpkg-deb --build <nom_du_dossier>**
-Installation : **sudo apt install ./<nom_du_dossier>.deb** (faite bien attention que vous soyez dans le même dossier que l'archive.deb)
