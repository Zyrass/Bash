#!/bin/bash

# Vérification du nombre de paramètres
if [ $# -ne 3 ]; then
    echo -e "\n Comment l'utiliser: $0 <nombre1> <opérateur> <nombre2>"
    exit 1
fi

# Récupération des paramètres
declare -i num1=$1
op=$2
declare -i num2=$3

# Vérification de l'opérateur
case $op in
+) result=$(($num1 + $num2)) ;;
-) result=$(($num1 - $num2)) ;;
x) result=$(($num1 * $num2)) ;;
/) result=$(($num1 / $num2)) ;;
*)
    echo "Opérateur non supporté sur ce programme"
    exit 1
    ;;
esac

# Affichage du résultat
echo "$num1 $op $num2 = $result"
