#!/bin/bash

# check si le programme est démarrer avec les droits utilisateurs
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo
    echo "Ce programme n'est pas démarrer en root"
    echo "Fin du programme"
    echo
    exit 1
fi

# Fonction pour afficher l'aide
get_help() {
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

# Constante paramètre
GET_MODE=$1

setNewUser() {
    clear
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

setDeleteUser() {
    clear
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

setInstallNewServer() {
    # Efface l'écran et affiche le titre de la fonction
    clear
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
    echo "MODE : Gestion de l'espace disque"
    echo

    # Seuil d'espace disque libre (en pourcentage)
    seuil=5

    # Récupère l'espace disque disponible en pourcentage
    espace=$(df -h / | cut -d " " -f 22 | cut -d "%" -f 1 | tail -n1)

    if [[ "$espace" -gt "$seuil" ]]; then

        # Vérifie si l'espace disque disponible est inférieur au seuil
        # Construit le message à envoyer sur Discord
        # message="\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺\n\n྅   📢 - Alain:\tL'espace disque dispose actuellement de $espace% d'espace libre.\n྅   📢 - Alain:\tMon espace disque est si plein qu'il est en train de développer sa propre personnalité.\n྅   📢 - Alain:\tJ'ai l'impression que bientôt il va prendre le contrôle de mon ordinateur et me forcer à coder pour lui.\n྅   📢 - Alain:\tSi cela arrive, je sais que ce sera sa vengeance pour toutes les fois où je l'ai maltraité en stockant des fichiers inutiles !.\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺\n"

        message="\n# Alain GUILLON\n\n> Alexis, tu es la variable la plus constante dans mon équation de réussite en programmation.\n> Je te remercie de ta patience, de ton expertise et de ta passion pour l'enseignement.\n> Bonne chance pour tes futurs projets !\n\n## ESPACE DISQUE PAS ASSEZ FAIBLE ( $espace% disponible )\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺\n྅ \t\t📢 \tMon espace disque est si plein qu'il est en train de développer sa propre personnalité.\n྅ \t\t📢 \tJ'ai l'impression que bientôt il va prendre le contrôle de mon ordinateur et me forcer à coder pour lui.\n྅ \t\t📢 \tSi cela arrive... Veuillez prévenir ma femme qu'elle me verra moins souvent 👀 ou pas...\n྅ \t\t📢 \n྅ \t\t📢 \tMais, je sais que ce sera sa vengeance pour toutes les fois où je l'ai maltraité en stockant des fichiers inutiles !\n྅ \t\t📢 \tRestons positif, je suis un développeur un peu fou sur les bords\n\n༻ °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° ༺"

        echo "$message"

    fi

    # Envoie le message sur Discord via le webhook
    curl -H "Content-Type: application/json" -d "{ \"content\": \"$message\" }" https://discord.com/api/webhooks/1098570523002277899/InkvgtZDAReTRLy-wrHJtigOgYhkDXZ7y4-S_vElPzKgDMOpFxMyjDkWgIE0lnRx8stI
}

setCronjobSetup() {
    chmod +x /home/zyrass/www/setup-server.sh

    # Ajouter la tâche cron
    (
        crontab -l -u "$USER"
        echo "*/15 * * * * ~/www/setup-server.sh disk"
    ) | crontab -
    echo $?
    echo "Tâche cron ajoutée avec succès !"
}

case $GET_MODE in
add_user | ADD_USER)
    setNewUser "$2" "$3"
    ;;
delete_user | DELETE_USER)
    setDeleteUser "$2"
    ;;
-h | --help)
    get_help
    ;;
install | INSTALL)
    setInstallNewServer
    ;;
nginx_host | NGINX_HOST)
    setNginxHost
    ;;
disk_space | DISK_SPACE)
    getDiskSpace
    ;;
cronjob_setup | CRONJOB_SETUP)
    setCronjobSetup
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
