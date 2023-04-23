#!/bin/bash

# Effacement du contenu du terminal
clear

# Vérification si le programme est bien démarrer en super administrateur auquel cas,
# celui-ci affiche un message avec une petite notice de comment faire.
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e "\n❌ \033[31m- Désolé, mais ce programme doit être démarrer en super administrateur...\n\033[0m"
    echo -e "\033[1m📌 - Mais... Comment faire ?\033[0m\n"

    echo -e "\033[4mSIGNATURE:\033[0m\t \033[92msudo \033[91msetup-server.sh [MODE] [OPTIONS]?\033[0m"
    echo -e "\033[4mAIDE (courte):\033[0m\t \033[92msudo \033[91msetup-server.sh \033[92m-h\033[0m"
    echo -e "\033[4mAIDE (longue):\033[0m\t \033[92msudo \033[91msetup-server.sh \033[92m--help\n\033[0m"

    echo -e "Fin du programme.\n"
    exit
fi

# Définition des constantes utililisée(s) dans ce programme.
GET_MODE=$1

# Bonus à voir lors de la génération d'un user avec mot de passe valide.
# Cette fonction c'est pour éviter d'avoir un message comme quoi le mot de passe n'est pas bon avec passwd
# Elle fonctionne mais n'est pas du tout appliqué dans l'algorithme demandé.
generate_password() {
    # Définit la longueur du mot de passe, par défaut 16 caractères
    # en utilisant le premier argument passé à la fonction, ou 16 si aucun argument n'est fourni.
    local length=${1:-16}

    # Définit les caractères autorisés dans le mot de passe.
    # La chaîne de caractères inclut des lettres minuscules, des lettres majuscules, des chiffres, ainsi que les caractères spéciaux "!*$#@".
    local chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!*$#@'

    # Utilise /dev/urandom pour générer une chaîne de caractères aléatoires.
    # La commande tr -dc supprime les caractères non désirés qui ne figurent pas dans la liste de caractères spécifiée dans $chars.
    # Enfin, la commande head -c lit les $length premiers caractères de la chaîne résultante.
    local password=$(tr -dc $chars </dev/urandom | head -c $length)

    # Renvoie le mot de passe généré.
    echo "$password"
}

# ================================================================================================================
#                      CONFIGURATION DES FONCTIONS A VENIR ET UTILISABLE COMME 1ER ARGUMENT
# ================================================================================================================
#   NOMS DES FONCTIONS      ||  DES PARAMETRES ?            ||  DESCRIPTION COURTE
# ================================================================================================================
#                           ||                              ||  Permet de créer un nouvel utilisateur
#   add_user                ||  OUI (2) username password   ||  le mot de passe est temporaire et sera
#                           ||                              ||  à changer obligatoire à la 1ère connexion.
# ================================================================================================================
#                           ||                              ||  Permet de supprimer un utilisateur ainsi
#   delete_user             ||  OUI (1) username            ||  que tout son espace de travail sera
#                           ||                              ||  immédiatement supprimé.
# ================================================================================================================
#   install                 ||  NON                         ||  Permet d'installer une nouvelle configuration
#                           ||                              ||  serveur en une seule commande.
# ================================================================================================================
#   nginx_host              ||  OUI (1) domain_name         ||  Permet de configurer un serveur nginx
#                           ||                              ||  avec l'ajout d'un nouveau nom de domaine.
# ================================================================================================================
#   disk_space              ||  OUI (1) path                ||  Permet d'afficher instantanément l'espace
#                           ||                              ||  restant sur une machine quelconque.
# ================================================================================================================
#                           ||                              ||  Permet de configurer une tâche cron
#   cronjob_setup           ||  NON                         ||  afin d'afficher l'espace disque sur un
#                           ||                              ||  serveur discord.
# ===============================================================================================================
#   -h                      ||  NON                         ||  Permet d'afficher l'aide du programme.
# ================================================================================================================
#   --help                  ||  NON                         ||  Permet d'afficher l'aide du programme.
# ================================================================================================================

# Fonction pour le mode : -h
# Fonction pour le mode : --help
mode_help() {
    echo -e "\n ✅ - \033[1mMODE LANCE AVEC SUCCES: \033[96m-h || --help\033[0m\n"

    echo -e " 📌 \033[1mSIGNATURE DU PROGRAMME :\033[0m\n"
    echo -e "\t\033[91msudo setup-server.sh [MODE] [OPTIONS]?\033[0m\n"

    echo -e " 📌 \033[1mPOUR OBTENIR DE L'AIDE - (\033[30m\033[3m C'est celle que tu vois à l'écran même \033[0m) :\033[0m\n"
    echo -e " 📖 \033[92m-h\033[0m            - Option courte pour afficher l'aide."
    echo -e " 📖 \033[92m--help\033[0m        - Option longue pour afficher l'aide.\n"

    echo -e " 📌 \033[1mLes modes disponible sont :\033[0m\n"
    echo -e " 📖 \033[92madd_user\033[0m      - Ajouter un nouvel utilisateur. \033[1m2 PARAMETRES OBLIGATOIRE\033[0m : \033[96mUSERNAME PASSWORD\033[0m"
    echo -e " 📖 \033[92mdelete_user\033[0m   - Supprimer un utilisateur. \033[1m1 PARAMETRE OBLIGATOIRE\033[0m : \033[96mUSERNAME\033[0m"
    echo -e " 📖 \033[92minstall\033[0m       - Installer un nouveau serveur."
    echo -e " 📖 \033[92mnginx_host\033[0m    - Configurer un nouveau serveur hôte nginx. \033[1m1 PARAMETRE OBLIGATOIRE\033[0m : \033[96mNOM_DU_DOMAINE\033[0m"
    echo -e " 📖 \033[92mdisk_space\033[0m    - Afficher l'espace disque disponible. \033[1m1 PARAMETRE OBLIGATOIRE\033[0m : \033[96mPATH\033[0m"
    echo -e " 📖 \033[92mcronjob_setup\033[0m - Configurer une tâche cron.\n"

    echo -e "\t\033[93mVeuillez relancer ce script avec le mode désiré et les paramètres si nécessaires.\033[0m"
    echo -e "\t\033[93mMerci à bientôt Alain.\033[0m\n"
}

# Fonction pour le mode : add_user param1 param2
mode_add_user() {
    # Définition des variable locale à la fonction.
    # Il s'agit des arguments passé qui seront exploité uniquement dans cette fonction.
    local username=$1
    local password=$2

    # Vérifier si le paramètre USERNAME ($1) et le mot de passe ($2) sont fournis
    [[ -z "$username" && -z "$password" ]] && {
        echo -e "\n\033[1m\n ❌ - ECHEC DU DEMARRAGE DU MODE:\033[0m \033[94madd_user\033[0m\n"
        echo -e "\033[93m 💬 - Veuillez fournir un nom d'utilisateur et un mot de passe avec aux moins 8 caractères pour continuer.\033[0m"
        echo -e "\033[93m 💬 - Fin du programme.\033[0m\n"
        exit 1
    }

    # Si un seul paramètre alors prévenir qu'il manque un mot de passe
    [[ -z "$password" ]] && {
        echo -e "\n\033[1m\n ❌ - ECHEC DU DEMARRAGE DU MODE:\033[0m \033[94madd_user\033[0m\n"
        echo -e " 💬 - \033[93m\033[1m$username\033[0m \033[93mdoit obligatoirement avoir un mot de passe avec aux moins 8 caractères.\033[0m"
        echo -e " 💬 - \033[93m\033[1m$USER\033[0m\033[93m, veuillez relancer le script avec un paramètre en plus qui sera le mot de passe temporaire. Merci.\033[0m"
        echo -e " 💬 - \033[93mFin du programme.\033[0m\n"
        exit 1
    }

    # Vérification de la longueur du mot de passe
    while ((${#password} < 8)); do
        echo -e "\n\033[1m\n ❌ - ECHEC DU DEMARRAGE DU MODE:\033[0m \033[94madd_user\033[0m\n"
        echo -e ' \033[95mLe mot de passe doit contenir au moins 8 caractères.\033[0m'
        read -rsp $'\n Veuillez de nouveau saisir un mot de passe temporaire pour continuer : ' GET_NEW_PASSWORD
    done

    echo -e "\033[1m\n ✅ MODE DEMARRER AVEC SUCCES:\033[0m \033[94madd_user\n\033[0m"

    # Récapitulatif des informations saisies en paramètres
    echo -e " 💬 - Voici les informations que vous souhaitez obtenir pour l'utilisateur \"\033[1;32m$username\033[0m\" :\n"

    echo -e " ✅ \033[1m- NOM D'UTILISATEUR : \033[1;32m$username\033[0m"
    echo -e " ✅ \033[1m- MOT DE PASSE PASSE EN 2EME ARGUMENTS DE LA FONCTION (temporaire) : \033[1;32m$password\033[0m"

    random_password=$(generate_password 16)
    echo -e " ❌ \033[1m\033[1;31m- MOT DE PASSE NON UTILISE MAIS QUI POURRAIS ETRE PRATIQUE DANS LA CREATION D'UN COMPTE (temporaire) : \033[1;33m$random_password\033[0m"

    echo -e "\n 💬 - Avant de créer cet utilisateur ($username), je dois m'assurer si il existe ou non...\n"

    # Vérification de l'existance de l'utilisateur
    if id "$username" >/dev/null 2>&1; then
        echo -e "\n ❌ \033[1m\033[1;31m- L'utilisateur \"$username\" existe déjà.\033[0m\n"
        echo -e " 💬 \033[1;33m- Aucune création n'a été réalisé. Ceci marque donc la fin du programme.\033[0m\n"
        exit 1
    else
        echo -e " ✅ - $username, n'existe pas. Création en cours... ( Veuillez patientez 1s )\n"

        # Fait patienté 1s
        sleep 1

        # Création de l'utilisateur avec le shell bash par défaut.
        useradd -m "$username" -s /bin/bash

        # Création d'un mot de passe temporaire
        echo -e "$password\n$password" | passwd "$username" 2>toto.txt

        # Effacement du fichier créé en sortie. (La fonction pour générer un mot de passe serait vachement utile à ce moment.)
        # Le contenu du fichier étant celui-ci :
        #
        # Nouveau mot de passe : MOT DE PASSE INCORRECT :
        # Le mot de passe ne passe pas la vérification dans le dictionnaire - basé sur un mot du dictionnaire
        # Retapez le nouveau mot de passe : passwd : mot de passe mis à jour avec succès
        rm toto.txt

        # Force le changement de mot de passe au premier démarrage
        chage -d 0 "$username"

        echo -e " 🎉 \033[1m\033[1;32m- $username a été créé avec succès.\033[0m 🎊"
        echo -e " 🎉 \033[1m\033[1;32m- Le mot de passe temporaire a été créé avec succès. Pour rappel il s'agit de : \033[1m\033[1;33m$password\033[0m 🎊"
        echo -e " 🎉 \033[1m\033[1;32m- Un nouveau mot de passe sera demandé à la première connexion de $username.\033[0m 🎊\n"

        exit
    fi
}

# Fonction pour le mode : delete_user param1
mode_delete_user() {
    # Définition de la variable locale de la fonction.
    # Il s'agit de l'arguments passé qui sera exploité uniquement dans cette fonction.
    local username=$1

    # Vérifier si le paramètre USERNAME ($1) est fourni
    if [[ -z "$username" ]]; then
        echo -e "\n\033[1m\n ❌ - ECHEC DU DEMARRAGE DU MODE:\033[0m \033[94mdelete_user\033[0m\n"
        echo -e " 💬 \033[1;33m- Désolé mais vous devez fournir un nom d'utilisateur à supprimer.\033[0m"
        echo -e " 💬 \033[1;33m- Fin du programme.\033[0m\n"
        exit
    fi

    echo -e "\033[1m\n ✅ MODE DEMARRER AVEC SUCCES:\033[0m \033[94mdelete_user\n\033[0m"
    echo -e " 💬 \033[1m- Vérification de l'existance de l'utilisateur ( Patientez 1s ) : \033[1;32m$username\033[0m...\n"

    # Ajoute une pause d'une seconde
    sleep 1

    # Vérifier si l'utilisateur existe
    if id "$username" >/dev/null 2>&1; then
        echo -e " ✅ \033[1;32m- $username a bien été trouvé, suppression en cours...\033[0m\n"
        sleep 1

        # Vérifier si le groupe de l'utilisateur est vide et le supprimer s'il est vide
        USER_GROUP=$(id -gn ${username})
        if getent group "$USER_GROUP" | grep -q "$USER_GROUP:.*"; then
            echo -e " 💬 Le groupe $USER_GROUP est vide, il sera supprimé avec l'utilisateur.\n"
            groupdel "$USER_GROUP"
        fi

        # Supprimer l'utilisateur
        deluser --remove-home "$username"

        echo -e "\n 🎉 \033[1;32m- Suppression de l'utilisateur $username terminée avec succès.\033[0m 🎊"
        echo
    else
        echo -e " ❌ \033[1;31m- Désolé, l'utilisateur \"\033[1m$username\"\033[0m\033[1;31m n'existe pas. Fin du programme.\n\033[0m"
        exit
    fi
}

# Fonction pour le mode : install
mode_install() {
    echo -e "\033[1m\n ✅ MODE DEMARRER AVEC SUCCES:\033[0m \033[94minstall\n\033[0m"

    # Vérifier si le repository ppa:ondrej/php existe déjà
    echo -e " 💬 \033[1m\033[1;35mETAPE 1:\033[0m \033[1;33mAjout du repository pour obtenir php 8.2 (ppa:ondrej/php)\033[0m\n"

    # Le "-q" de la commande grep signifie "quiet", c'est-à-dire que grep ne doit pas afficher les résultats de la recherche à l'écran.
    # "ondrej/php" est la chaîne de caractères que je recherche.
    # "/etc/apt/sources.list" est le fichier dans lequel je cherche la chaîne de caractères précédente.
    # "/etc/apt/sources.list.d/*" est un chemin qui spécifie tous les fichiers situés dans le répertoire /etc/apt/sources.list.d/
    if ! grep -q "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
        echo -e " ✅ \033[1m\033[1;32mInstallation du repository pour obtenir php 8.2 (ppa:ondrej/php)\033[0m\n"
        add-apt-repository ppa:ondrej/php -y
    else
        echo -e " ❌ \033[1m\033[1;31mLe repository pour obtenir php 8.2 (ppa:ondrej/php) à déjà été ajouté\033[0m\n"
    fi

    # Ajoute une pause d'une seconde
    sleep 1

    # Mettre à jour le système et les paquets SNAP en une seule commande pour éviter une deuxième vérification de la liste des paquets
    echo -e " 💬 \033[1m\033[1;35mETAPE 2:\033[0m \033[1;33mMise à jour du système et des paquets SNAP\033[0m\n"
    apt-get update && apt-get upgrade -y && snap refresh && apt-get autoremove -y

    # Ajoute une pause d'une seconde
    sleep 1

    # Installer tous les paquets nécessaires en une seule commande pour éviter d'exécuter plusieurs commandes distinctes
    echo -e "\n 💬 \033[1m\033[1;35mETAPE 3:\033[0m \033[1;33mInstallation de différents paquets avec APT\033[0m\n"
    echo -e " ➕ \033[1m\033[1;36mcurl\033[0m"
    echo -e " ➕ \033[1m\033[1;36msoftware-properties-common\033[0m"
    echo -e " ➕ \033[1m\033[1;36mphp8.2-common\033[0m"
    echo -e " ➕ \033[1m\033[1;36mphp8.2-fpm\033[0m"
    echo -e " ➕ \033[1m\033[1;36mnginx\033[0m"
    echo -e " ➕ \033[1m\033[1;36mcomposer\033[0m"
    echo -e " ➕ \033[1m\033[1;36mgit\033[0m\n"
    apt install software-properties-common nginx php8.2-fpm php8.2-common composer git curl -y

    # Ajoute une pause d'une seconde
    sleep 1

    # Vérifier si l'installation est réussie
    if [ $? -eq 0 ]; then
        echo -e "\n 🎉 \033[1m\033[1;32m- Configuration du nouveau serveur terminée avec succès.\033[0m 🎊\n"
    else
        echo -e "\n ❌ \033[1m\033[1;31m- Erreur lors de l'installation des paquets requis.\033[0m\n"
    fi
    exit
}

# Fonction pour le mode : nginx_host
mode_nginx_host() {
    # Définition de la variable locale de la fonction.
    # Il s'agit de l'arguments passé qui sera exploité uniquement dans cette fonction.
    local domain_name=$1

    # Si un seul paramètre alors prévenir qu'il manque un mot de passe
    [[ -z "$domaine_name" ]] && {
        echo -e "\n\033[1m\n ❌ - ECHEC DU DEMARRAGE DU MODE:\033[0m \033[94mnginx_host\033[0m\n"
        echo -e " 💬 - \033[93mLe nom de domaine est obligatoire.\033[0m"
        echo -e " 💬 - \033[93m\033[1m$USER\033[0m\033[93m, veuillez relancer le script avec un paramètre en plus qui sera le nom de domaine souhaité. Merci.\033[0m"
        echo -e " 💬 - \033[93mFin du programme.\033[0m\n"
        exit 1
    }

    echo -e "\033[1m\n ✅ MODE DEMARRER AVEC SUCCES:\033[0m \033[94mnginx_host\n\033[0m"

    # Création d'un répertoire de sauvegarde pour le dossier par défaut du dossier site-enabled
    echo -e " ⚪ \033[1;36mCréation d'un répertoire pour sauvegarder le fichier \"default\" situé dans /etc/nginx/site-enabled\033[0m"
    mkdir -p "/etc/nginx/back"
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Création du répertoire réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- création impossible, le répertoire existe déjà.\033[0m"
    fi

    # Dépalcement du fichier "default" dans le répertoire "back" fraîchement créer
    echo -e "\n ⚪ \033[1;36mDéplacement du fichier \"default\" situé dans /etc/nginx/site-enabled vers /etc/nginx/back\033[0m\n"
    mv "/etc/nginx/site-enabled/default" "/etc/nginx/back/default"
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Déplacement du fichier default réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Déplacement du fichier default impossible, celui-ci existe déjà.\033[0m"
    fi

    # Configuration de l'hôte dans Nginx
    # Dépalcement du fichier "default" dans le répertoire "back" fraîchement créer
    echo -e "\n ⚪ \033[1;36mConfiguration de l'hôte dans Nginx\033[0m\n"
    cat >"/etc/nginx/sites-available/${domain_name}" <<EOF
server {
	listen 80;
	listen [::]:80;

    server_name ${domain_name};
	root /var/www/${domain_name};
	index index.php index.html;

	location / {
        
	}

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
EOF

    # Test de la syntax du fichier de configuration
    nginx -t
    if [ $? -ne 0 ]; then
        # Dépalcement du fichier "default" dans le répertoire "back" fraîchement créer
        echo -e " ❌ \033[1m\033[1;31m- La configuration du nom de domaine a échoué\033[0m\n" >&2

        # Suppression des fichiers si une erreur à été trouvé ainsi on peut directement relancer un test avec le même nom de domaine
        rm -r "/etc/nginx/sites-available/${domain_name}.conf"
        rm -r "/etc/nginx/sites-enabled/${domain_name}"
        rm -r "/var/www/${domain_name}"
        exit 1
    fi

    # Modification du fichier hosts
    echo -e "\n ⚪ \033[1;36mAjout du nom d'hôte dans le fichier hosts situé dans /etc/hosts.\033[0m"
    echo "127.0.0.1 ${domain_name}" >>/etc/hosts
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Inscription du nom de domaine (${domaine_name}) dans le fichier hosts réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Inscription du nom de domaine (${domaine_name}) dans le fichier hosts impossible.\033[0m"
    fi

    # Activation du nouvel hôte
    echo -e "\n ⚪ \033[1;36mCréation d'un lien symbolique du nom de domaine ${domain_name} vers le dossier /etc/nginx/sites-enabled\033[0m\n"
    ln -s "/etc/nginx/sites-available/${domain_name}" "/etc/nginx/sites-enabled"
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Activation du lien symbolique réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Activation du lien symbolique impossible, celui-ci existe déjà.\033[0m"
    fi

    # Création du dossier pour le nouvel hôte
    echo -e "\n ⚪ \033[1;36mCréation du répertoire ${domain_name} dans /var/www/\033[0m"
    mkdir -p "/var/www/${domain_name}"
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Création du répertoire ${domain_name} dans /var/www/ réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Création du répertoire ${domain_name} dans /var/www/ impossible, celui-ci existe déjà.\033[0m"
    fi

    # Création de la page index.php qui sera utilisé pour ce nom de domaine.
    echo -e "\n ⚪ \033[1;36mCréation du fichier index.php qui se trouvera dans le répertoire /var/www/${domain_name}/\033[0m"
    echo "<!DOCTYPE html>
            <html lang=\"fr\">
            <head>
                <meta charset=\"UTF-8\">
                <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
                <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
                <title>${domain_name}</title>
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }
                    body {
                        min-height: 100vh;
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                        align-items: center;
                        background-color: #333;
                    }
                    h1 {
                        color: #f1f1f1;
                    }
                    h2 {
                        color: plum;
                        margin: 20px 0;
                    }
                    div {
                        width: 80vw;
                        background-color: #111;
                    }
                    pre {
                        padding: 1%;
                        color: lime;
                    }
                </style>
            </head>
            <body>
                <h1>NGINX te propose ton nouveau nom de domaine : ${domain_name}</h1>
                <h2>Affichage de la configuration serveur</h2>
                <div>
                    <pre>
                        <?php print_r(\$_SERVER); ?>
                    </pre>
                </div>
            </body>
            </html>" >/var/www/${domain_name}/index.php
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Création de la page index.php dans /var/www/ réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Création de la page index.php dans /var/www/ impossible, celui-ci existe déjà.\033[0m"
    fi

    # Changer le propriétaire des fichiers pour PHP-FPM
    echo -e "\n ⚪ \033[1;36mChangement du propriétaire pour le répertoire /var/www/${domain_name} afin que PHP-FPM puisse l'utiliser sans problème.\033[0m"
    chown -R www-data:www-data "/var/www/${domain_name}"
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Changement de propriétaire pour le répertoire /var/www réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Changement de propriétaire pour le répertoire /var/www impossible.\033[0m"
    fi

    echo -e "\n ⚪ \033[1;36mredémarrage de Nginx (systemctl et services).\033[0m"
    systemctl restart nginx
    service nginx reload
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Redémarrage de NGINX réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Redémarrage de NGINX impossible\033[0m"
    fi

    echo -e "\n ⚪ \033[1;36mredémarrage de php8.2-fpm (services).\033[0m"
    service php8.2-fpm restart
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Redémarrage de PHP8.2-FPM réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Redémarrage de PHP8.2-FPM impossible\033[0m"
    fi

    echo -e "\n ⚪ \033[1;36mVérification de l'état du nom de domaine.\033[0m"
    nslookup "${domain_name}"
    if [ $? -eq 0 ]; then
        echo -e " ✅ \033[1m\033[1;32m- Vérification de l'état du nom de domaine réussi avec succès\033[0m"
    else
        echo -e " ❌ \033[1m\033[1;31m- Vérification de l'état du nom de domaine impossible\033[0m\n"
    fi

    echo -e "\n 🎉 \033[1;33mCongratulation le nom d'hôte est fonctionnel :P\033[0m"
    echo -e " 🎉 \033[1;33m- Le nouvel hôte (${domain_name}) a été ajouté avec succès il est accessible à cette adresse :\033[0m \033[1m\033[1;35mhttp://${domain_name}\033[0m \033[1;33m!\033[0m 🎊"

    echo -e "\n 👀 \033[4m\033[1;30mAffichage des services histoire de confirmer le bon fonctionnement\033[0m\n"
    service php8.2-fpm status
    service nginx status
    if [ $? -eq 0 ]; then
        echo -e " 🎉 \033[1m\033[1;32m- Affichage des services NGINX et PHP8.2-FPM réussi avec succès\033[0m 🎊"
    else
        echo -e " ❌ \033[1m\033[1;31m- Affichage des services NGINX et PHP8.2-FPM impossible\033[0m"
    fi
    exit
}

# Fonction pour le mode : disk_space
mode_disk_space() {
    echo -e "\033[1m\n ✅ MODE DEMARRER AVEC SUCCES:\033[0m \033[94mdisk_space\n\033[0m"

    # Définition du chemin par défaut si celui-ci n'est pas défini ou n'existe pas
    local space_path_default=${1:-"/"}

    if ! test -d "$space_path_default"; then
        echo -e "\033[93m ❌ - Le dossier $space_path_default n'existe pas.\033[0m"
        space_path_default="/"
        echo -e "\033[93m 💬 - Le chemin par défaut à été définit sur $space_path_default vous pouvez changer celui-ci en spécifiant un chemin valide en paramètre de la fonction.\033[0m\n"
    fi

    # Définition des variables
    local mydate=$(date +"%A %d %B %Y à %T")
    local mySystem=$(lsb_release -d | cut -f2)
    local space_disk=$(df -h "$space_path_default" | awk 'NR==2{print $(NF-4)}')
    local space_free=$(df -h "$space_path_default" | awk 'NR==2{print $(NF-2)}')
    local space_used=$(df -h "$space_path_default" | awk 'NR==2{print $(NF-3)}')
    local space_percent=$(df -h "$space_path_default" | awk 'NR==2{print $(NF-1)}' | cut -d "%" -f 1)
    local limit=5 # Seuil d'espace disque libre (en pourcentage)

    # Vérifie si l'espace disque utilisé est supérieur à la limite imposé (5)
    if [[ "${space_percent}" -gt "${limit}" ]]; then

        # Construit le message à envoyer sur Discord
        # Construction du message Discord
        local message="### Espace disque utilisé :  $space_percent%\n\n💬 \t**Alain**, sur ton PC portable qui est sous **$mySystem**,\n💬 \ttu as un espace disque qui commence à se réduire. Fais attention !\n\n- Path analysé: **$space_path_default**\n- Espace Disque: **$space_disk**\n- Epace disponible: **$space_free**\n- Espace utilisé: **$space_used** soit **$space_percent%** 👀\n\n\`\`\`diff\n+ Ce message a été envoyé via un script Bash écrit par Alain GUILLON.\n- Il a été programmé pour être envoyé toutes les heures à partir d'une tâche cron.\n\`\`\`\n📢 - Nous sommes le **$mydate**, le prochain rappel sera dans **1 heure**\n\n"

        echo -e "${space_percent}\n"

        # Envoie le message sur Discord via le webhook
        # curl -H "Content-Type: application/json" -d "{ \"content\": \"$message\" }" https://discord.com/api/webhooks/1098570523002277899/InkvgtZDAReTRLy-wrHJtigOgYhkDXZ7y4-S_vElPzKgDMOpFxMyjDkWgIE0lnRx8stI

        curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$message\"}" https://discord.com/api/webhooks/1099275717839171594/Njj9b6_dgIwNpekavRsh5L4p_24VSkO4HFrTDbRF9MHkh2XFU3lpPq1-xRBLbJDTBRd8
    fi

}

mode_cronjob_setup() {
    echo
    echo "⚪ MODE : CREATION D'UNE TACHE CRON POUR AFFICHER L'ESPACE DISQUE"
    echo

    # Sauvegarde de la tâche cron existante dans un fichier temporaire
    crontab -l >mycron

    # Ajout de la nouvelle tâche cron à la fin du fichier temporaire
    # La tâche est exécutée à la minute 0 de chaque heure
    # Le script "setup-server.sh" est exécuté avec l'argument "disk_space"
    echo "0 * * * * /home/zyrass/www/it-akademy/cours/Bash/alexis/setup-server.sh disk_space" >>mycron

    # Importation de la nouvelle tâche cron depuis le fichier temporaire
    crontab mycron

    # Suppression du fichier temporaire
    rm mycron

    echo "Tâche cron ajoutée avec succès pour l'utilisateur $USER !"
}

case $GET_MODE in
add_user | ADD_USER)
    mode_add_user "$2" "$3"
    ;;
delete_user | DELETE_USER)
    mode_delete_user "$2"
    ;;
-h | --help | -H | --HELP)
    mode_help
    ;;
install | INSTALL)
    mode_install
    ;;
nginx_host | NGINX_HOST)
    mode_nginx_host "$2"
    ;;
disk_space | DISK_SPACE)
    mode_disk_space "$2"
    ;;
cronjob_setup | CRONJOB_SETUP)
    mode_cronjob_setup
    ;;
*)
    echo -e "\n\033[1m\n ❌ - ECHEC DU DEMARRAGE DU SCRIPT\033[0m\n"

    echo -e " 📌 \033[1mLes modes disponible sont :\033[0m\n"
    echo -e " 📖 \033[92madd_user\033[0m      - Ajouter un nouvel utilisateur. \033[1m2 PARAMETRES OBLIGATOIRE\033[0m : \033[96mUSERNAME PASSWORD\033[0m"
    echo -e " 📖 \033[92mdelete_user\033[0m   - Supprimer un utilisateur. \033[1m1 PARAMETRE OBLIGATOIRE\033[0m : \033[96mUSERNAME\033[0m"
    echo -e " 📖 \033[92minstall\033[0m       - Installer un nouveau serveur."
    echo -e " 📖 \033[92mnginx_host\033[0m    - Configurer un nouveau serveur hôte nginx. \033[1m1 PARAMETRE OBLIGATOIRE\033[0m : \033[96mNOM_DU_DOMAINE\033[0m"
    echo -e " 📖 \033[92mdisk_space\033[0m    - Afficher l'espace disque disponible."
    echo -e " 📖 \033[92mcronjob_setup\033[0m - Configurer une tâche cron.\n"

    echo -e "\t\033[93mVeuillez relancer ce script avec le mode désiré et les paramètres si nécessaires.\033[0m"
    echo -e "\t\033[93mMerci à bientôt Alain.\033[0m\n"
    exit 1
    ;;
esac
