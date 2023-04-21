#!/bin/bash

# check si le programme est démarrer avec les droits utilisateurs
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo
    echo "Ce programme n'est pas démarrer en root"
    echo "Fin du programme"
    echo
    exit 1
fi

# Constante paramètre
GET_MODE=$1

# Fonction pour afficher l'aide
mode_help() {
    echo
    echo "⛑ Utilisation : script.sh [MODE|OPTION] [...PARAMETRES]"

    echo
    echo "📌 Obtenir de l'aide :"
    echo

    echo " 📖 -h            - Option courte pour afficher l'aide."
    echo " 📖 --help        - Option longue pour afficher l'aide."
    echo

    echo "📌 Les modes valides sont :"
    echo
    echo " 📖 add_user      - Ajouter un nouvel utilisateur. PARAMETRES : USERNAME PASSWORD"
    echo " 📖 delete_user   - Supprimer un utilisateur. PARAMETRES : USERNAME"
    echo " 📖 install       - Installer un nouveau serveur."
    echo " 📖 nginx_host    - Configurer un nouveau serveur hôte nginx."
    echo " 📖 disk_space    - Afficher l'espace disque disponible."
    echo " 📖 cronjob_setup - Configurer une tâche cron."
    echo
}

mode_add_user() {
    echo
    echo "⚪ MODE : AJOUT D'UN NOUVEL UTILISATEUR"
    echo

    local username=$1
    local password=$2

    # Vérifier si le paramètre USERNAME ($1) et le mot de passe ($2) sont fournis
    [[ -z "$username" || -z "$password" ]] && {
        echo "❌ - Veuillez fournir un nom d'utilisateur et un mot de passe."
        echo "Fin du programme."
        exit 1
    }

    # Vérification de la longueur du mot de passe
    while ((${#password} < 8)); do
        read -rsp $'\nLe mot de passe doit contenir au moins 8 caractères.\nVeuillez re-saisir un mot de passe temporaire : ' GET_NEW_PASSWORD
        echo
    done

    # Affichage des informations saisies
    echo
    echo "Ok, voici les informations que vous souhaitez obtenir pour cet utilisateur :"
    echo
    echo "- NOM D'UTILISATEUR : $username"
    echo "- MOT DE PASSE (temporaire) : $password"
    echo
    echo "Vérification si l'utilisateur $username existe déjà ou non..."

    # Vérification si l'utilisateur existe déjà
    if id "$username" >/dev/null 2>&1; then
        echo
        echo -e "❌ - L'utilisateur \"$username\" existe déjà. Fin du programme."
        exit 1
    else
        echo "✅ - Cet utilisateur n'existe pas. Création en cours pour $username..."

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
        message="\n# Alain GUILLON ( $mydate ) - Prochaine mise à jour dans 30min\n💬\tAlexis, tu es la variable la plus constante dans mon équation de réussite en programmation.\n💬\t Je te remercie de ta patience, de ton expertise et de ta passion pour l'enseignement.\n💬\t Bonne chance pour tes futurs projets !\n\n## ESPACE DISQUE PAS ASSEZ FAIBLE ( $espace% disponible )\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺\n྅ \t\t📢 \tMon espace disque est si plein qu'il est en train de développer sa propre personnalité.\n྅ \t\t📢 \tJ'ai l'impression que bientôt il va prendre le contrôle de mon ordinateur et me forcer à coder pour lui.\n྅ \t\t📢 \tSi cela arrive... Veuillez prévenir ma femme qu'elle me verra moins souvent 👀 ou pas...\n྅ \t\t📢 \n྅ \t\t📢 \tMais, je sais que ce sera sa vengeance pour toutes les fois où je l'ai maltraité en stockant des fichiers inutiles !\n྅ \t\t📢 \tRestons positif, je suis un développeur un peu fou sur les bords\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺"

        echo "$message"

    fi

    # Envoie le message sur Discord via le webhook
    curl -H "Content-Type: application/json" -d "{ \"content\": \"$message\" }" https://discord.com/api/webhooks/1098570523002277899/InkvgtZDAReTRLy-wrHJtigOgYhkDXZ7y4-S_vElPzKgDMOpFxMyjDkWgIE0lnRx8stI
}

mode_cronjob_setup() {
    echo
    echo "⚪ MODE : CREATION D'UNE TACHE CRON POUR AFFICHER L'ESPACE DISQUE"
    echo

    # Donner l'autorisation de lecture et d'exécution du script pour tous les utilisateurs
    # chmod +x /home/zyrass/www/it-akademy/cours/Bash/alexis/setup-server.sh

    # Ajouter la tâche cron pour l'utilisateur zyrass

    crontab -l >mycron
    echo "*/30 * * * * /home/zyrass/www/it-akademy/cours/Bash/alexis/setup-server.sh disk_space" >>mycron
    crontab mycron
    rm mycron
    # service cron restart
    echo "Tâche cron ajoutée avec succès pour l'utilisateur zyrass !"
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
    get_help
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
