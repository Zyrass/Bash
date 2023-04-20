#!/bin/bash

# check si le programme est démarrer avec les droits utilisateurs
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo
    echo "Ce programme n'est pas démarrer en root"
    echo "Fin du programme"
    echo
    exit 1
fi

# Configuration des paramètres passé au programme
MODE=$1
SET_USERNAME=$2
SET_USERNAME_PASSWORD=$3

setNewUser() {
    clear
    echo
    echo "⚪ MODE : AJOUT D'UN NOUVEL UTILISATEUR"
    echo

    # Vérifier si le paramètre USERNAME ($1) est fourni ainsi que le mot de passe ($2)
    if [[ -z "$1" || -z "$2" ]]; then
        echo "❌ - Veuillez fournir un nom d'utilisateur et un mot de passe. Fin du programme."
        echo
        exit 1
    fi

    GET_CREATE_NEW_USERNAME=$1
    GET_CREATE_NEW_PASSWORD_FOR_NEW_USERNAME=$2

    # Vérification de la longueur du mot de passe
    while [[ ${#GET_CREATE_NEW_PASSWORD_FOR_NEW_USERNAME} -lt 8 ]]; do
        echo
        echo "Le mot de passe doit contenir au moins 8 caractères"
        read -sp "Veuillez re-saisir un mot de passe temporaire : " GET_CREATE_NEW_PASSWORD_FOR_NEW_USERNAME
        echo
    done

    # Affichage des informations saisies
    echo
    echo "Ok, voici les informations que vous souhaitez obtenir pour cet utilisateur :"
    echo
    echo "- NOM D'UTILISATEUR : " ${GET_CREATE_NEW_USERNAME}
    echo "- MOT DE PASSE (temporaire) : " ${GET_CREATE_NEW_PASSWORD_FOR_NEW_USERNAME}
    echo
    echo "Vérification si l'utilisateur ${GET_CREATE_NEW_USERNAME} existe déjà ou non..."

    if id "$GET_CREATE_NEW_USERNAME" >/dev/null 2>&1; then
        echo
        echo -e "❌ - L'utilisateur \"$GET_CREATE_NEW_USERNAME\" existe déjà. Fin du programme."
        exit 1
    else
        echo "✅ - Cet utilisateur n'existe pas. Création en cours pour $GET_CREATE_NEW_USERNAME..."

        # Création de l'utilisateur avec le shell bash par défaut.
        useradd -m "$GET_CREATE_NEW_USERNAME" -s /bin/bash

        # Création d'un mot de passe temporaire
        echo -e "$GET_CREATE_NEW_PASSWORD_FOR_NEW_USERNAME\n$GET_CREATE_NEW_PASSWORD_FOR_NEW_USERNAME" | passwd "$GET_CREATE_NEW_USERNAME"

        if [[ "$?" == 1 ]]; then
            echo
            echo -e "❌ - Le mot de passe saisie n'est pas bon kévin..."
            exit 1
        elif [[ "$?" == 0 ]]; then

            # Demande de changement de mot de passe au premier démarrage
            chage -d 0 "$GET_CREATE_NEW_USERNAME"

            echo "✅ - ${GET_CREATE_NEW_USERNAME} a été créer avec succès."
            echo "✅ - Le mot de passe temporaire à bien été créer."
            echo "✅ - Le mot de passe doit être changé au premier démarrage."
            echo
            exit 1
        fi

    fi
}

setDeleteUser() {
    clear
    echo
    echo "⚪ MODE : SUPPRESSION D'UN UTILISATEUR"
    echo

    # Vérifier si le paramètre USERNAME ($1) est fourni
    if [[ -z "$1" ]]; then
        echo "❌ - Veuillez fournir un nom d'utilisateur à supprimer. Fin du programme."
        echo
        exit 1
    fi

    # Paramètre de la fonction
    GET_USERNAME=$1

    #
    if id "$GET_USERNAME" >/dev/null 2>&1; then
        echo "✅ - $GET_USERNAME existe bien, suppression en cours..."

        # Vérifier si le groupe de l'utilisateur est vide et le supprimer s'il est vide
        USER_GROUP=$(id -gn $GET_USERNAME)
        if [[ $(getent group $USER_GROUP) == "$USER_GROUP:*" ]]; then
            echo "Le groupe $USER_GROUP est vide, il sera supprimé avec l'utilisateur."
            groupdel $USER_GROUP
        fi

        deluser --remove-home $GET_USERNAME
        exit 1
    else
        echo "❌ - Désolé, l'utilisateur \"$GET_USERNAME\" n'existe pas. Fin du programme."
        echo
        exit 1
    fi
}

setInstallNewServer() {
    # Efface l'écran et affiche le titre de la fonction
    clear
    echo
    echo "⚪ MODE : CONFIGURATION D'UN NOUVEAU SERVEUR"
    echo

    # Mettre à jour le système et les paquets SNAP en une seule commande pour éviter une deuxième vérification de la liste des paquets
    echo "👉 ETAPE 1 : Mise à jour du système et des paquets SNAP"
    echo

    apt-get update && apt-get upgrade -y && snap refresh && apt-get autoremove -y

    # Installer tous les paquets nécessaires en une seule commande pour éviter d'exécuter plusieurs commandes distinctes
    echo
    echo "👉 ETAPE 2 : Installation de différents paquets avec APT"
    echo
    apt install nginx php8.2-fpm php8.2-common composer git curl -y

    echo
    echo "🎉 - Configuration du nouveau serveur terminée avec succès. 🎊"
    echo

    exit
}

setNginxHost() {
    clear
    echo
    echo "༻ °°°°°°°°°°° ༒ °°°°°°°°°°° ༒ °°°°°°°°°°° ༺"
    echo "༔ ༔"
    echo "༔ ⛏ CREATION NGINX MODE ⛏ ༔"
    echo "༔ ༔"
    echo "༻ °°°°°°°°°°° ༒ °°°°°°°°°°° ༒ °°°°°°°°°°° ༺"
    echo

    # Récupération des informations de l'utiilisateur
    read -p "Entrez le nom d'hôte désiré : " HOSTNAME

    # Configuration de l'hôte dans Nginx
    echo "Configuration de l'hôte dans Nginx..."

    cat >/etc/nginx/sites-available/$HOSTNAME <<EOF

server {
    listen 80;
    listen [::];
    server_name ${HOSTNAME};
    root /var/www/${HOSTNAME}/html;
    index index.html index.php;

    location / {
        try_files \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }
}
EOF

    # Activation du nouvel hôte
    ln -s /etc/nginx/sites-available/$HOSTNAME /etc/nginx/sites-enabled/

    read -p "Voulez-vous créer un fichier index.html pour cet hôte ? (y/n) " CREATE_INDEX

    # Création du dossier pour le nouvel hôte
    mkdir -p /var/www/$HOSTNAME/html

    if [ "$CREATE_INDEX" == "y" ] || [ "$CREATE_INDEX" == "Y" ]; then
        echo -e "<html><body><h1>Bienvenue sur $HOSTNAME</h1><pre><?php print_r($_SERVER); ?></pre></body></html>" >/var/www/$HOSTNAME/html/index.html
    fi

    systemctl reload nginx

    # Changer le propriétaire des fichiers pour PHP-FPM
    chown -R www-data:www-data /var/www/$HOSTNAME/html

    # Remplacer index.html par index.php
    sed -i 's/index.html/index.php/g' /etc/nginx/sites-available/$HOSTNAME

    if [ "$?" -eq 1 ]; then
        rm -rf /etc/nginx/sites-available/$HOSTNAME.conf
        rm -rf /etc/nginx/sites-enabled/$HOSTNAME
        echo
        echo "✅ - Le nom d'hôte existait déjà, il a été supprimé"
        # echo $?
        exit

    else
        echo
        echo "Redémarrage de Nginx..."
        systemctl restart nginx
        echo
        echo "🎉 Le nouvel hôte a été ajouté avec succès ! 🎊"
        echo
        echo "Check du status du service"
        echo
        # Redémarrer PHP-FPM et Nginx
        systemctl restart php8.1-fpm
        systemctl restart nginx
        systemctl status nginx
        echo
    fi

}

getDiskSpace() {
    clear
    echo
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔"
    echo "༔          🃏  ESPACE DISQUE MODE 🃏           ༔"
    echo "༔                                               ༔"
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo

    SPACE_DISK=$(df -h / | grep / | cut -d " " -f 21 | cut -d "%" -f 1)

    # echo "Actuellement sur ce système d'expoitation, il y a $SPACE_DISK% d'espace disque utilisé";
    # echo
    echo $SPACE_DISK
    echo

    # Prénom de l'utilisateur
    prenom="Alain"

    # Seuil d'espace disque libre (en pourcentage)
    seuil=5

    # Récupère l'espace disque disponible en pourcentage
    espace=$(df -h | grep /dev/sda1 | awk '{print $5}' | cut -d'%' -f1)

    # Vérifie si l'espace disque disponible est inférieur au seuil
    if [ $espace -lt $seuil ]; then
        # Construit le message à envoyer sur Discord
        message="Attention $prenom, l'espace disque est faible (${espace}% libre)."

        # Envoie le message sur Discord via le webhook
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" https://discord.com/api/webhooks/XXX/YYY
    fi

}

setCronjobSetup() {
    chmod +x /home/zyrass/www/setup-server.sh

    # Ajouter la tâche cron
    (
        crontab -l -u zyrass
        echo "*/15 * * * * ~/www/setup-server.sh disk"
    ) | crontab -
    echo $?
    echo "Tâche cron ajoutée avec succès !"
}

if [[ "$MODE" = "add_user" || "$MODE" = "ADD_USER" ]]; then
    setNewUser $SET_USERNAME $SET_USERNAME_PASSWORD
elif [[ "$MODE" = "delete_user" || "$MODE" = "DELETE_USER" ]]; then
    setDeleteUser $SET_USERNAME
elif [[ "$MODE" = "install" || "$MODE" = "INSTALL" ]]; then
    setInstallNewServer
elif [[ "$MODE" = "nginx_host" || "$MODE" = "NGINX_HOST" ]]; then
    setNginxHost
elif [[ "$MODE" = "disk_space" || "$MODE" = "DISK_SPACE" ]]; then
    getDiskSpace
elif [[ "$MODE" = "cronjob_setup" || "$MODE" = "CRONJOB_SETUP" ]]; then
    setCronjobSetup
else
    echo "Désolé mais seul six (6) MODE sont possible:"
    echo -e "\tadd_user"
    echo -e "\tdelete_user"
    echo -e "\tinstall"
    echo -e "\tnginx_host"
    echo -e "\tdisk_space"
    echo -e "\tcronjob_setup"
    exit 1
fi
