#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]];
then
    echo;
    echo "Ce programme n'est pas démarrer en root";
    echo "Fin du programme";
    echo;
    exit 1;
fi

CHOIX=$1;

fnc_create_user() {
    clear
    echo
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔              ✅ CREATE MODE ✅                ༔";
    echo "༔                                               ༔";
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo

    # Vérifier si des paramètres existes ou non
    if [[ $# -eq 2 ]];
    then
        NEW_USERNAME=$1;
        PASSWORD=$2;
    else
        echo
        read -rp "Veuillez saisir le nom du nouvel utilisateur : " NEW_USERNAME;
        read -sp "Veuillez saisir un mot de passe temporaire (Mode silentieux) : " PASSWORD;
        echo
    fi

    # Vérification de la longueur du mot de passe
    while [[ ${#PASSWORD} -lt 8 ]];
    do
        echo "Le mot de passe doit contenir au moins 8 caractères";
        read -sp "Veuillez saisir un mot de passe temporaire (Mode silencieux) : " PASSWORD;
        echo
    done

    # Affichage des informations saisies
    echo
    echo Ok, voici les identifiants que tu souhaiterais obtenir pour ce nouvel utilisateur :
    echo
    echo "Nom d'utilisateur souhaité : " ${NEW_USERNAME}
    echo "Son mot de passe provisoire est hashé : " ${PASSWORD} #| sha256sum
    echo
    echo "Vérification si l\'utilisateur ${NEW_USERNAME} existe ou pas...";
    echo

    if id "$NEW_USERNAME" > /dev/null 2>&1; then
        echo "❌ - Cet utilisateur existe déjà. Fin du programme.";
        exit;
    else
        # Si l'utilisateur n'existe pas alors on va le créer
        echo "❌ - Cet utilisateur n'existe pas. Création du user."; 
        echo
        # Création du user avec la définition du shell bash par défaut.
        useradd -m "$NEW_USERNAME" -s /bin/bash;

        # Création d'un mot de passe temporaire
        echo -e "$PASSWORD\n$PASSWORD" | passwd "$NEW_USERNAME";

        # Demande de changement de mot de passe au premier démarrage
        chage -d 0 "$NEW_USERNAME";

        # echo "$USERNAME:$PASSWORD" | chpasswd;
        # passwd -e "$NEW_USERNAME";
        echo "✅ - L'utilisateur a été créer avec succès - Mot de passe temporaire qui devra être changé au premier démarrage est actuellement : $PASSWORD";
    fi 
}

fnc_delete_user() {
    clear
    echo
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔                ❌ DELETE MODE ❌              ༔";
    echo "༔                                               ༔";
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"

    if [[ $# -eq 1 ]];
    then
        NEW_USERNAME=$1;
    else
        echo
        read -rp "Veuillez saisir le nom de l'utilisateur que vous voulez supprimer : " NEW_USERNAME;
        echo
    fi

    if id "$NEW_USERNAME" > /dev/null 2>&1; then
        echo "✅ - Cet utilisateur existe bien, exécution de la suppression de $NEW_USERNAME et de son répertoire personnel"; 
        deluser --remove-home $NEW_USERNAME;
        exit;
    else
        echo "❌ - Cet utilisateur n'existe pas. Fin du programme.";
        exit;
    fi 
}

fnc_maintenance() {
    clear
    echo
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔             ⛑  MAINTENANCE MODE ⛑             ༔";
    echo "༔                                               ༔";
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo
    echo
    echo
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔            ⭐ MISE A JOUR SYSTEM ⭐           ༔";
    echo "༔                                               ༔";
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo

    apt-get update && apt-get full-upgrade -y && apt-get autoremove;

    echo
    echo "🎉 - Mise à jour du système terminé avec succès. 🎊";
    echo

    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔     ⭐ MISE A JOUR DES PAQUETS SNAP ⭐        ༔";
    echo "༔                                               ༔";
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"

    snap refresh

    echo
    echo "🎉 - Mise à jour des paquets snap terminé avec succès 🎊";
    echo

    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔    ⭐ INSTALLATION DE DIFFERENTS PAQUETS ⭐   ༔";
    echo "༔                                               ༔";
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo

    apt  install curl git composer php8.1-common php8.1-fpm nginx -y

    echo
    echo "🎉 - Installation des paquets terminé avec succès 🎊";
    echo

    exit;
}

fnc_nginx_host() {
    clear
    echo
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔          ⛏  CREATION NGINX MODE ⛏           ༔";
    echo "༔                                               ༔";
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo

    # Récupération des informations de l'utiilisateur
    read -p "Entrez le nom d'hôte désiré : " HOSTNAME;

    # Configuration de l'hôte dans Nginx
    echo "Configuration de l'hôte dans Nginx...";

    cat > /etc/nginx/sites-available/$HOSTNAME <<EOF

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

    if [ "$CREATE_INDEX" == "y" ] || [ "$CREATE_INDEX" == "Y" ];
    then
        echo -e "<html><body><h1>Bienvenue sur $HOSTNAME</h1><pre><?php print_r($_SERVER); ?></pre></body></html>" > /var/www/$HOSTNAME/html/index.html;
    fi

    systemctl reload nginx

    # Changer le propriétaire des fichiers pour PHP-FPM
    chown -R www-data:www-data /var/www/$HOSTNAME/html

    # Remplacer index.html par index.php
    sed -i 's/index.html/index.php/g' /etc/nginx/sites-available/$HOSTNAME

    if [ "$?" -eq 1 ];
    then
        rm -rf /etc/nginx/sites-available/$HOSTNAME.conf;
        rm -rf /etc/nginx/sites-enabled/$HOSTNAME;
        echo
        echo "✅ - Le nom d'hôte existait déjà, il a été supprimé";
        # echo $?
        exit

    else
        echo 
        echo "Redémarrage de Nginx..."
        systemctl restart nginx
        echo
        echo "🎉 Le nouvel hôte a été ajouté avec succès ! 🎊";
        echo
        echo "Check du status du service";
        echo
        # Redémarrer PHP-FPM et Nginx
        systemctl restart php8.1-fpm
        systemctl restart nginx
        systemctl status nginx;
        echo
    fi
    
}

fnc_disk_space() {
    clear
    echo
    echo "༻  °°°°°°°°°°° ༒  °°°°°°°°°°°  ༒  °°°°°°°°°°° ༺"
    echo "༔                                               ༔";
    echo "༔          🃏  ESPACE DISQUE MODE 🃏           ༔";
    echo "༔                                               ༔";
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

fnc_cronjob_setup() {
    chmod +x /home/zyrass/www/setup-server.sh

    # Ajouter la tâche cron
    (crontab -l -u zyrass; echo "*/15 * * * * ~/www/setup-server.sh disk") | crontab -
    echo $?
    echo "Tâche cron ajoutée avec succès !"
}

if [[ "$CHOIX" = "create" || "$CHOIX" = "CREATE" ]];
then
    fnc_create_user;
elif [[ "$CHOIX" = "delete" || "$CHOIX" = "DELETE" ]];
then
    fnc_delete_user;
elif [[ "$CHOIX" = "maintenance" || "$CHOIX" = "MAINTENANCE" ]];
then
    fnc_maintenance;
elif [[ "$CHOIX" = "nginx" || "$CHOIX" = "NGINX" ]];
then
    fnc_nginx_host;
elif [[ "$CHOIX" = "disk" || "$CHOIX" = "DISK" ]];
then
    fnc_disk_space;
elif [[ "$CHOIX" = "cronjob_setup" || "$CHOIX" = "CRONJOB_SETUP" ]];
then
    fnc_cronjob_setup;
else
    echo "Désolé mais seul six (6) choix sont possible: <create> ; <delete> ; <maintenance> ; <nginx> ; <disk> ; <cronjob_setup>";
    exit;
fi

