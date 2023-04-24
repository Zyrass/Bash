#!/bin/bash

# Nettoie l'affichage du terminal
clear

# Vérifie si le nombre d'arguments est valide
if [ $# -lt 1 ]; then
    # Si le nombre d'arguments est insuffisant, affiche un message d'aide et quitte le programme avec un code d'erreur
    echo -e "\n Comment utiliser ce programme: $0 [nombre d'entiers à saisir]\n"
    exit 1
fi

# Initialise un tableau vide avec l'option -a de la commande declare, et définit une variable pour le nombre d'entiers à saisir
declare -a tableau
declare -i compteur=$1

echo -e "\n"

# Saisit les entiers et les stocke dans le tableau
for ((i = 0; i < $compteur; i++)); do
    # Demande à l'utilisateur de saisir un entier et le stocke dans le tableau à l'index i
    read -p " Entrez l'entier numéro $((i + 1)): " entier
    tableau[$i]=$entier
done

# Trie les entiers dans l'ordre croissant avec une boucle imbriquée
for ((i = 0; i < $compteur - 1; i++)); do
    for ((j = i + 1; j < $compteur; j++)); do
        # Compare chaque élément du tableau avec l'élément suivant et les échange si nécessaire pour les ordonner dans l'ordre croissant
        if ((${tableau[i]} > ${tableau[j]})); then
            temp=${tableau[i]}
            tableau[$i]=${tableau[j]}
            tableau[$j]=$temp
        fi
    done
done

echo -e "\n"

# Affiche le contenu du tableau trié
echo -e " Le contenu du tableau trié est le suivant :\n"
for entier in "${tableau[@]}"; do
    echo -n " $entier |"
done

echo -e "\n"

# Quitte le programme avec un code de succès
exit 0
