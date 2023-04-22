#!/bin/bash

# Vérification si le programme est bien démarrer en super administrateur auquel cas, celui-ci affiche un message avec une petite notice de comment faire.
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    clear
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

# ================================================================================================================
#                                   CONFIGURATION DES FONCTIONS A VENIR
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
#   disk_space              ||  NON                         ||  Permet d'afficher instantanément l'espace
#                           ||                              ||  restant sur une machine quelconque.
# ================================================================================================================
#   cronjob_setup           ||  NON                         ||  Permet de configurer une tâche cron
#                           ||                              ||  afin d'afficher l'espace disque sur un
#                           ||                              ||  serveur discord.
# ===============================================================================================================
#   -h                      ||  NON                         ||  Permet d'afficher l'aide du programme.
# ================================================================================================================
#   --help                  ||  NON                         ||  Permet d'afficher l'aide du programme.
# ================================================================================================================

# Fonction pour le mode : -h
# Fonction pour le mode : --help
mode_help() {
    clear
    echo -e "\n\033[1mMODE : AIDE SUR L'UTILISATION DU PROGRAMME\033[0m\n"

    echo -e "📌 \033[1mSIGNATURE DU PROGRAMME :\033[0m\n"
    echo -e "\t\033[91msudo setup-server.sh [MODE] [OPTIONS]?\033[0m\n"

    echo -e "📌 \033[1mPOUR OBTENIR DE L'AIDE - (\033[30m\033[3m C'est celle que tu vois à l'écran même \033[0m) :\033[0m\n"
    echo -e " 📖 \033[92m-h\033[0m            - Option courte pour afficher l'aide."
    echo -e " 📖 \033[92m--help\033[0m        - Option longue pour afficher l'aide.\n"

    echo -e "📌 \033[1mLes modes disponible sont :\033[0m\n"
    echo -e " 📖 \033[92madd_user\033[0m      - Ajouter un nouvel utilisateur. \033[1m2 PARAMETRES OBLIGATOIRE\033[0m : \033[96mUSERNAME PASSWORD\033[0m"
    echo -e " 📖 \033[92mdelete_user\033[0m   - Supprimer un utilisateur. \033[1m1 PARAMETRE OBLIGATOIRE\033[0m : \033[96mUSERNAME\033[0m"
    echo -e " 📖 \033[92minstall\033[0m       - Installer un nouveau serveur."
    echo -e " 📖 \033[92mnginx_host\033[0m    - Configurer un nouveau serveur hôte nginx. \033[1m1 PARAMETRE OBLIGATOIRE\033[0m : \033[96mNOM_DU_DOMAINE\033[0m"
    echo -e " 📖 \033[92mdisk_space\033[0m    - Afficher l'espace disque disponible."
    echo -e " 📖 \033[92mcronjob_setup\033[0m - Configurer une tâche cron.\n"

    echo -e "\t\033[93mVeuillez relancer ce script avec le mode désiré et les paramètres si nécessaires.\033[0m"
    echo -e "\t\033[93mMerci à bientôt Alain.\033[0m\n"
}

# Fonction pour le mode : add_user param1 param2
mode_add_user() {
    clear

    # Définition des variable locale à la fonction.
    # Il s'agit des paramètres qui sont retourné.
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
        echo -rp '\033[95mLe mot de passe doit contenir au moins 8 caractères.\033[0m\n'
        read -rsp $'\nVeuillez de nouveau saisir un mot de passe temporaire : ' GET_NEW_PASSWORD
        echo
    done

    echo "\033[1m\n✅ MODE DEMARRER AVEC SUCCES:\033[0m \033[93madd_user\n\033[0m"

    # Récapitulatif des informations saisies en paramètres
    echo "\nOk, voici les informations que vous souhaitez obtenir pour cet utilisateu:\n"

    echo "- NOM D'UTILISATEUR : $username"
    echo "- MOT DE PASSE (temporaire) : $password"

    echo "\nAvant de créer cet utilisateur ($username), je dois m'assurer si il existe ou non...\n"

    # Vérification de l'existance de l'utilisateur
    if id "$username" >/dev/null 2>&1; then
        echo -e "\n❌ - L'utilisateur \"$username\" existe déjà.\nAucune création n'a été réalisé. Ceci marque donc la fin du programme.\n"
        exit 1
    else
        echo "✅ - $username, n'existe pas. Création en cours..."

        # Création de l'utilisateur avec le shell bash par défaut.
        useradd -m "$username" -s /bin/bash

        # Création d'un mot de passe temporaire
        echo -e "$password\n$password" | passwd "$username"

        # Vérification du mot de passe
        if [[ "$?" == 1 ]]; then
            echo
            echo -e "❌ - Le mot de passe saisi n'est pas valide.\nFin du programme."
            exit 1
        else
            # Demande de changement de mot de passe au premier démarrage
            chage -d 0 "$username"

            echo "✅ - $username a été créé avec succès."
            echo "✅ - Le mot de passe temporaire a été créé avec succès."
            echo "✅ - Le mot de passe doit être changé au premier démarrage."
            echo
            exit 1
        fi
    fi
}

mode_delete_user() {
    echo
    echo "⚪ MODE : SUPPRESSION D'UN UTILISATEUR"
    echo

    # Paramètre de la fonction
    local username=$1

    # Vérifier si le paramètre USERNAME ($1) est fourni
    if [[ -z "$username" ]]; then
        echo -e "❌ - Veuillez fournir un nom d'utilisateur à supprimer.\nFin du programme."
        echo
        exit 1
    fi

    # Vérifier si l'utilisateur existe
    if id "$username" >/dev/null 2>&1; then
        echo "✅ - $username existe bien, suppression en cours..."

        # Vérifier si le groupe de l'utilisateur est vide et le supprimer s'il est vide
        USER_GROUP=$(id -gn username)
        if getent group "$USER_GROUP" | grep -q "$USER_GROUP:.*"; then
            echo "Le groupe $USER_GROUP est vide, il sera supprimé avec l'utilisateur."
            groupdel "$USER_GROUP"
        fi

        # Supprimer l'utilisateur
        deluser --remove-home "$username"

        echo "🎉 - Suppression de l'utilisateur $username terminée avec succès. 🎊"
        echo
    else
        echo "❌ - Désolé, l'utilisateur \"$username\" n'existe pas. Fin du programme."
        echo
        exit 1
    fi
}

mode_install() {
    echo
    echo "⚪ MODE : CONFIGURATION D'UN NOUVEAU SERVEUR"
    echo

    echo "👉 ETAPE 1 : Ajout du repository pour php (ppa:ondrej/php)"
    add-apt-repository ppa:ondrej/php -y

    # Mettre à jour le système et les paquets SNAP en une seule commande pour éviter une deuxième vérification de la liste des paquets
    echo "👉 ETAPE 2 : Mise à jour du système et des paquets SNAP"
    echo

    apt-get update && apt-get upgrade -y && snap refresh && apt-get autoremove -y

    # Installer tous les paquets nécessaires en une seule commande pour éviter d'exécuter plusieurs commandes distinctes
    echo
    echo "👉 ETAPE 3 : Installation de différents paquets avec APT"
    echo

    apt install software-properties-common nginx php8.2-fpm php8.2-common composer git curl -y

    echo
    echo "🎉 - Configuration du nouveau serveur terminée avec succès. 🎊"
    echo

    exit
}

mode_disk_space() {
    echo
    echo "⚪ MODE : AFFICHAGE DE L'ESPACE DISQUE"
    echo

    # Seuil d'espace disque libre (en pourcentage)
    seuil=5

    # Récupère l'espace disque disponible en pourcentage
    espace=$(df -h / | cut -d " " -f 22 | cut -d "%" -f 1 | tail -n1)

    if [[ "$espace" -gt "$seuil" ]]; then

        # Vérifie si l'espace disque disponible est inférieur au seuil
        # Construit le message à envoyer sur Discord
        # message="\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺\n\n྅   📢 - Alain:\tL'espace disque dispose actuellement de $espace% d'espace libre.\n྅   📢 - Alain:\tMon espace disque est si plein qu'il est en train de développer sa propre personnalité.\n྅   📢 - Alain:\tJ'ai l'impression que bientôt il va prendre le contrôle de mon ordinateur et me forcer à coder pour lui.\n྅   📢 - Alain:\tSi cela arrive, je sais que ce sera sa vengeance pour toutes les fois où je l'ai maltraité en stockant des fichiers inutiles !.\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺\n"

        mydate=$(
            date +"%A %d %B %Y - %T"
        )
        message="\n# Alain GUILLON ( $mydate ) - Prochaine mise à jour dans 1 heure\n💬\tAlexis, tu es la variable la plus constante dans mon équation de réussite en programmation.\n💬\t Je te remercie de ta patience, de ton expertise et de ta passion pour l'enseignement.\n💬\t Bonne chance pour tes futurs projets !\n\n## ESPACE DISQUE PAS ASSEZ FAIBLE ( $espace% disponible )\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺\n྅ \t\t📢 \tMon espace disque est si plein qu'il est en train de développer sa propre personnalité.\n྅ \t\t📢 \tJ'ai l'impression que bientôt il va prendre le contrôle de mon ordinateur et me forcer à coder pour lui.\n྅ \t\t📢 \tSi cela arrive... Veuillez prévenir ma femme qu'elle me verra moins souvent 👀 ou pas...\n྅ \t\t📢 \n྅ \t\t📢 \tMais, je sais que ce sera sa vengeance pour toutes les fois où je l'ai maltraité en stockant des fichiers inutiles !\n྅ \t\t📢 \tRestons positif, je suis un développeur un peu fou sur les bords\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺"

        echo "$message"

    fi

    # Envoie le message sur Discord via le webhook
    # curl -H "Content-Type: application/json" -d "{ \"content\": \"$message\" }" https://discord.com/api/webhooks/1098570523002277899/InkvgtZDAReTRLy-wrHJtigOgYhkDXZ7y4-S_vElPzKgDMOpFxMyjDkWgIE0lnRx8stI

    curl -H "Content-Type: application/json" -d "{ \"content\": \"$message\" }" https://discord.com/api/webhooks/1099275717839171594/Njj9b6_dgIwNpekavRsh5L4p_24VSkO4HFrTDbRF9MHkh2XFU3lpPq1-xRBLbJDTBRd8
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

mode_nginx_host2() {
    # Vérification des paramètres fournis
    if [ $# -ne 1 ]; then
        echo "Usage: $0 -add-domain nom_de_domaine.com" >&2
        exit 1
    fi

    # Récupération de l'argument
    domain_name="$1"

    echo "Configuration du domaine $1"

    # Création de l'arborescence du dossier du site web et et du fichier html
    mkdir /var/www/$domain_name
    echo "<!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="UTF-8">
                <meta http-equiv="X-UA-Compatible" content="IE=edge">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>$domain_name</title>
                <style>
                    html, body {
                        width: 100%;
                        height: 100%;
                        margin: 0;
                        padding: 0;
                    }
                    body {
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                        align-items: center;
                        background-color: rgb(226, 233, 241);
                    }
                    h1 {
                        color: rgb(0, 65, 126);
                    }
                    h2 {
                        color: rgb(255, 72, 0);
                    }
                </style>
            </head>
            <body>
                <h1>Bienvenue sur ton nouveau domaine</h1>
                <h2>$domain_name</h2>
                <div>
                    <pre>
                        <?php print_r(\$_SERVER); ?>
                    </pre>
                </div>
            </body>
            </html>" >/var/www/$domain_name/index.php

    # Création du fichier de configuration du nouveau nom de domaine
    echo "server {
        listen 80;
        server_name $domain_name www.$domain_name;
        root /var/www/$domain_name;
        index index.php index.html index.htm;

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        }
    }" >/etc/nginx/sites-available/$domain_name

    # Test de la syntax du fichier de configuration
    nginx -t
    if [ $? -ne 0 ]; then
        echo "La configuration du nom de domaine a échoué" >&2
        exit 1
    fi
    # Création du lien symbolique dans sites-enabled
    ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/

    # Redémarrage du server nginx
    systemctl restart nginx
    if [ $? -ne 0 ]; then
        echo "Le redémarrage du server nginx a échoué" >&2
        exit 1
    fi

    # Configuration du pare-feu pour autoriser le HTTP et HTTPS
    ufw allow 'Nginx Full'
    if [ $? -ne 0 ]; then
        echo "La configuration du pare-feu a échoué" >&2
        exit 1
    fi

    # Ajout de la correspondance du nom de domaine avec l'ip localhost
    sed -i "1i127.0.0.1    $domain_name" /etc/hosts
    if [ $? -ne 0 ]; then
        echo "La configuration du fichier hosts a échoué" >&2
        exit 1
    fi

    echo "Le domaine est en ligne http://$domain_name"
}

mode_nginx_host() {

    echo
    echo "MODE : CONFIGURATION D'UN SERVEUR NGINX"
    echo

    # Récupération des informations du nom de domaine saisie en paramètre
    local domain=$1

    mv "/etc/nginx/site-enabled/default" "/etc/nginx/site-enabled/default.back"

    # Configuration de l'hôte dans Nginx
    cat >"/etc/nginx/sites-available/${domain}" <<EOF
server {
	listen 80;
	listen [::]:80;

    server_name ${domain};
	root /var/www/${domain};
	index index.php index.html;

	location / {
        
	}

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
EOF

    echo "127.0.0.1 ${domain}" >>/etc/hosts
    # sed -i "1i127.0.0.1    $domain" /etc/hosts

    # Activation du nouvel hôte
    ln -s "/etc/nginx/sites-available/${domain}" "/etc/nginx/sites-enabled"

    # Création du dossier pour le nouvel hôte
    mkdir -p "/var/www/${domain}"

    echo "<!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="UTF-8">
                <meta http-equiv="X-UA-Compatible" content="IE=edge">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>$domain</title>
                <style>
                    html, body {
                        width: 100%;
                        height: 100%;
                        margin: 0;
                        padding: 0;
                    }
                    body {
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                        align-items: center;
                        background-color: rgb(226, 233, 241);
                    }
                    h1 {
                        color: rgb(0, 65, 126);
                    }
                    h2 {
                        color: rgb(255, 72, 0);
                    }
                </style>
            </head>
            <body>
                <h1>Bienvenue sur ton nouveau domaine</h1>
                <h2>$domain</h2>
                <div>
                    <pre>
                        <?php print_r(\$_SERVER); ?>
                    </pre>
                </div>
            </body>
            </html>" >/var/www/$domain/index.php

    # Changer le propriétaire des fichiers pour PHP-FPM
    chown -R www-data:www-data "/var/www/${domain}"

    # Remplacer index.html par index.php
    # sed -i 's/index.html/index.php/g' /etc/nginx/sites-available/"$domain"

    if [ "$?" -eq 1 ]; then
        rm -rf "/etc/nginx/sites-available/${domain}.conf"
        rm -rf "/etc/nginx/sites-enabled/${domain}"
        echo
        echo "✅ - Le nom d'hôte existait déjà, il a été supprimé"
        exit
    else
        echo
        echo "Redémarrage de Nginx..."
        service nginx reload
        echo
        echo "🎉 Le nouvel hôte (${domain}) a été ajouté avec succès ! 🎊"
        echo
        echo "Check du status du service"
        echo
        nslookup "$domain"
        echo

        # Test de la syntax du fichier de configuration
        nginx -t

        echo "Le domaine est en ligne http://$domain"

        # Redémarrer PHP-FPM et Nginx
        service php8.2-fpm restart
        service nginx reload
        systemctl restart nginx
        service php8.2-fpm status
        service nginx status
        echo
    fi
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
    mode_disk_space
    ;;
cronjob_setup | CRONJOB_SETUP)
    mode_cronjob_setup
    ;;
*)
    echo "Désolé mais seuls six (7) modes sont possibles:"
    echo -e "\t-h ou --help"
    echo -e "\tadd_user"
    echo -e "\tdelete_user"
    echo -e "\tinstall"
    echo -e "\tnginx_host"
    echo -e "\tdisk_space"
    echo -e "\tcronjob_setup"
    exit 1
    ;;
esac
