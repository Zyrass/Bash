#!/usr/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo
    echo "Ce programme n'est pas démarrer en root"
    echo "Fin du programme"
    echo
    exit
fi

CHOIX=$1

fnc_create_user() {
    clear

    echo
    echo "---- Création d'un utilisateur ----"
    echo

    # Vérifier si des paramètres existes ou non
    if [[ $# -eq 2 ]]; then
        USERNAME=$1
        PASSWORD=$2
    else
        echo
        read -rp "Veuillez saisir le nom du nouvel utilisateur : " USERNAME
        read -sp "Veuillez saisir un mot de passe (Mode silentieux) : " PASSWORD
        echo
    fi

    # Affichage des informations saisies
    echo
    echo Ok, voici les identifiants que tu souhaiterais obtenir pour ce nouvel utilisateur :
    echo
    echo "Nom d'utilisateur souhaité : " ${USERNAME}
    echo "Son mot de passe provisoire : " ${PASSWORD}
    echo
    echo Vérification si l\'utilisateur "${USERNAME}" existe ou pas...
    echo

    if id "$USERNAME" >/dev/null 2>&1; then
        echo "❌ - Cet utilisateur existe déjà. Fin du programme."
        exit
    else
        # Si l'utilisateur n'existe pas alors on va le créer
        echo "❌ - Cet utilisateur n'existe pas. Création du user."
        echo
        # Création du user avec la définition du shell bash par défaut.
        useradd -m "$USERNAME" -s /bin/bash
        echo "$USERNAME:$PASSWORD" | chpasswd
        # passwd -e "$USERNAME";
        echo "✅ - L'utilisateur a été créer avec succès"
    fi
}

fnc_delete_user() {
    if [[ $# -eq 1 ]]; then
        USERNAME=$1
    else
        echo
        read -rp "Veuillez saisir le nom de l'utilisateur que vous voulez supprimer : " USERNAME
        echo
    fi

    if id "$USERNAME" >/dev/null 2>&1; then
        echo "✅ - Cet utilisateur existe bien, exécution de la suppression de $USERNAME et de son répertoire personnel"
        deluser --remove-home $USERNAME
        exit
    else
        echo "❌ - Cet utilisateur n'existe pas. Fin du programme."
        exit
    fi
}

if [[ "$CHOIX" = "up" ]]; then
    fnc_create_user
elif [[ "$CHOIX" = "down" ]]; then
    fnc_delete_user
else
    echo "Désolé mais le choix ne correspond pas à 'up' ou 'down'"
    exit
fi
