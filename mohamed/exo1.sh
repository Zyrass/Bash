#!/bin/bash

# EXO 1

# Demander à l'utilisateur de saisir une note
read -p "Veuillez saisir une note entre 0 et 20 : " note_saisie

# Vérifier si la note est valide (entre 0 et 20)
if [[ "$note_saisie" -lt 0 || "$note_saisie" -gt 20 ]]; then
    echo "La note n'est pas correcte, veuillez saisir une note entre 0 et 20."
    exit 1
fi

# Afficher un message en fonction de la note
if [[ "$note_saisie" -ge 16 ]]; then
    echo "Très bien !"
elif [[ "$note_saisie" -ge 14 ]]; then
    echo "Bien."
elif [[ "$note_saisie" -ge 12 ]]; then
    echo "Assez bien."
elif [[ "$note_saisie" -ge 10 ]]; then
    echo "Moyen."
else
    echo "Insuffisant."
fi
