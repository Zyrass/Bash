#!/bin/bash

clear

# Déclaration des tableaux de pays et de drapeaux
pays=("France" "Espagne" "Italie" "Allemagne" "Royaume-Uni")
drapeaux=("🇫🇷" "🇪🇸" "🇮🇹" "🇩🇪" "🇬🇧")

# Randomisation des tableaux
pays=($(echo "${pays[@]}" | tr ' ' '\n' | shuf | tr '\n' ' '))
drapeaux=($(echo "${drapeaux[@]}" | tr ' ' '\n' | shuf | tr '\n' ' '))
correspondances=("0" "1" "2" "3" "4")

# Affichage des valeurs aléatoires sélectionnées
# "Pays aléatoire : $pays_random"
# "Drapeau aléatoire : $drapeau_random"

# Demande du nombre de questions
read -p "Combien de questions souhaitez-vous répondre? " nombre_questions
if [[ -z "$nombre_questions" ]]; then
    nombre_questions=$(random 1 5)
    echo "Nombre de questions aléatoire généré: $nombre_questions"
fi

# Initialisation du score
score=0

# Boucle sur le nombre de questions demandées
for ((i = 1; i <= nombre_questions; i++)); do
    # Sélection aléatoire d'une valeur de chaque tableau
    index=$(($RANDOM % ${#pays[@]}))
    pays_random=${pays[$index]}
    drapeau_random=${drapeaux[$index]}
    pays_selectionne=$pays_random
    drapeau_selectionne=$drapeau_random

    # Demande de réponse
    read -n1 -p "Le drapeau $drapeau_selectionne correspond-il à $pays_selectionne? (y/n) " reponse

    # Vérification de la réponse
    if [[ "$reponse" == "y" && "${pays[$index]}" == "$pays_selectionne" ]] || [[ "$reponse" == "n" && "${pays[$index]}" != "$pays_selectionne" ]]; then
        score=$((score + 1))
        echo -e "\033[32mBonne réponse! 🎉\033[0m"
    else
        echo -e "\033[31mMauvaise réponse! ❌\033[0m"
    fi
done

# Calcul et affichage du taux de réussite
taux_reussite=$(echo "scale=2; $score/$nombre_questions*100" | bc)
echo "Vous avez obtenu un score de $score sur $nombre_questions questions, soit un taux de réussite de $taux_reussite%."
