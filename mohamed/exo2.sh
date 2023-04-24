#!/bin/bash

# EXO 2
while true; do
    # Demander à l'utilisateur de saisir une note
    read -p "Saisissez une note entre 0 et 20 ou 'q' pour quitter : " note_saisie

    # Quitter le programme si l'utilisateur saisit 'q'
    if [[ "$note_saisie" == 'q' || "$note_saisie" == 'Q' || "$note_saisie" -lt 0 ]]; then
        exit 0
    fi

    # Vérifier si la note est valide (entre 0 et 20)
    if [[ "$note_saisie" -gt 20 ]]; then
        echo "La note ne peut-être supérieur à 20. Veuillez saisir une note entre 0 et 20 ou 'q' pour quitter."
        continue
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

    # Ajouter la note à la somme et incrémenter le compteur
    somme=$((somme + note_saisie))
    compteur=$((compteur + 1))

    # Calculer la moyenne
    moyenne=$((somme / compteur))

    # Afficher la moyenne
    echo "Moyenne : $moyenne"
done
