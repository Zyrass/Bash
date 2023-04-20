#!/bin/bash

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
        NEW_USERNAME=$1
        PASSWORD=$2
    else
        echo
        read -rp "Veuillez saisir le nom du nouvel utilisateur : " NEW_USERNAME
        read -sp "Veuillez saisir un mot de passe temporaire (Mode silentieux) : " PASSWORD
        echo
    fi

    # Vérification de la longueur du mot de passe
    while [[ ${#PASSWORD} -lt 8 ]]; do
        echo "Le mot de passe doit contenir au moins 8 caractères"
        read -sp "Veuillez saisir un mot de passe temporaire (Mode silencieux) : " PASSWORD
        echo
    done

    # Affichage des informations saisies
    echo
    echo Ok, voici les identifiants que tu souhaiterais obtenir pour ce nouvel utilisateur :
    echo
    echo "Nom d'utilisateur souhaité : " ${NEW_USERNAME}
    echo "Son mot de passe provisoire est hashé : " ${PASSWORD} #| sha256sum
    echo
    echo "Vérification si l\'utilisateur ${NEW_USERNAME} existe ou pas..."
    echo

    if id "$NEW_USERNAME" >/dev/null 2>&1; then
        echo "❌ - Cet utilisateur existe déjà. Fin du programme."
        exit
    else
        # Si l'utilisateur n'existe pas alors on va le créer
        echo "❌ - Cet utilisateur n'existe pas. Création du user."
        echo
        # Création du user avec la définition du shell bash par défaut.
        useradd -m "$NEW_USERNAME" -s /bin/bash

        # Création d'un mot de passe temporaire
        echo -e "$PASSWORD\n$PASSWORD" | passwd "$NEW_USERNAME"

        # Demande de changement de mot de passe au premier démarrage
        chage -d 0 "$NEW_USERNAME"

        # echo "$USERNAME:$PASSWORD" | chpasswd;
        # passwd -e "$NEW_USERNAME";
        echo "✅ - L'utilisateur a été créer avec succès - Mot de passe temporaire qui devra être changé au premier démarrage est actuellement : $PASSWORD"
    fi
}

fnc_delete_user() {
    if [[ $# -eq 1 ]]; then
        NEW_USERNAME=$1
    else
        echo
        read -rp "Veuillez saisir le nom de l'utilisateur que vous voulez supprimer : " NEW_USERNAME
        echo
    fi

    if id "$NEW_USERNAME" >/dev/null 2>&1; then
        echo "✅ - Cet utilisateur existe bien, exécution de la suppression de $NEW_USERNAME et de son répertoire personnel"
        deluser --remove-home $NEW_USERNAME
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
