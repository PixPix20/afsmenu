**VERSION : 1.0**  

---

**FR :**  

Ce paquet DEBIAN (.deb) automatise la connexion à votre AFS depuis votre ordinateur personnel.  
Il est utilisable **uniquement** sur les systèmes d'exploitation basés sur un noyau DEBIAN (Ubuntu, Debian, Lubuntu, etc.).  

Pour savoir comment le script se connecte à votre AFS, je vous invite à consulter l'article [```migration realm kerberos```](https://blog.cri.epita.fr/post/2020-10-30-migration-realm-kerberos/) blog du CRI : 

Voici les commandes pour le transformer/installer si vous téléchargez les fichiers depuis GitHub :  

- **Transformation du dossier en fichier .deb:**  
  ```bash
  dpkg-deb --build afs_connexion/
  ```
  - **Installation**
  ```bash
  sudo apt install ./afs_connexion.deb
  ```
  Assurez-vous que vous vous trouvez dans le dossier contenant l'archive, ou fournissez le chemin complet vers celle-ci.

- **Pour les utilisateurs de DEBIAN :**  
  Assurez-vous que votre compte figure dans la liste des sudoers. Sinon, vous devrez placer manuellement les fichiers dans leurs répertoires respectifs. (Leur emplacement est indiqué dans l'arborescence de l'archive dans le dossier ```usr```)

---

**EN :**  

Here is a DEBIAN package (.deb) designed to automate AFS login from your personal computer.  
It is only compatible with operating systems based on a DEBIAN kernel (Ubuntu, Debian, Lubuntu, etc.).  

To learn how the script connects to your AFS, I invite you to read the article [```migration realm kerberos```](https://blog.cri.epita.fr/post/2020-10-30-migration-realm-kerberos/) on the CRI blog:

Here are the commands to package/install the files if you download them from GitHub:  

- **Convert the folder into a .deb package:**  
  ```bash
  dpkg-deb --build <folder_name>
  ```
  - **Installation**
  ```bash
  sudo apt install ./<folder_name>.deb
  ```
  Make sure you are in the folder where the archive is located, or provide the full path to it.

- **For DEBIAN users:**  
  Make sure your account is listed in the sudoers file. Otherwise, you will need to manually place the files in their respective directories. (Their location is provided through the archive's directory structure in the ```usr``` folder)
