#!/bin/bash

# Vérifie si un argument a été donné en paramètre
if [[ -z $1 ]]; then
    # Si non, demande à l'utilisateur de saisir un nombre
    read -p "Entrez un nombre : " n
else
    # Si oui, utilise le premier paramètre comme nombre à factoriser
    declare -i n=$1
fi

# Initialise la variable fact à 1
fact=1

# Boucle for pour calculer la factorielle de n
for ((i = 1; i <= n; i++)); do
    # Multiplie fact par i à chaque itération
    fact=$((fact * i))
done

# Affiche le résultat
echo "La factorielle de $n est : $fact"
