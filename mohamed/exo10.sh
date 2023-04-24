#!/bin/bash

# Efface l'écran de la console
clear

# Vérifie s'il y a au moins un argument passé en paramètre
if [[ $# -eq 0 ]]; then
    echo -e "\n Un paramètre est obligatoire\n" # Affiche un message d'erreur si aucun argument n'est passé
    exit 1                                      # Termine le script avec un code d'erreur
fi

# Convertit le premier argument en lettres minuscules
CHOICE=$(echo "$1" | tr [:upper:] [:lower:])

# Définit des variables pour chaque pays, représentées par des emojis drapeaux
FRANCE=$(echo -e "\U0001F1EB\U0001F1F7")
ITALIE=$(echo -e "\U0001F1EE\U0001F1F9")
JAPON=$(echo -e "\U0001F1EF\U0001F1F5")
ETATS_UNIS=$(echo -e "\U0001F1FA\U0001F1F8")
ALLEMAGNE=$(echo -e "\U0001F1E9\U0001F1EA")
BRESIL=$(echo -e "\U0001F1E7\U0001F1F7")
MEXIQUE=$(echo -e "\U0001F1F2\U0001F1FD")
RUSSIE=$(echo -e "\U0001F1F7\U0001F1FA")
CHINE=$(echo -e "\U0001F1E8\U0001F1F3")
ARGENTINE=$(echo -e "\U0001F1E6\U0001F1F7")
PORTUGAL=$(echo -e "\U0001F1F5\U0001F1F9")
NORVEGE=$(echo -e "\U0001F1F3\U0001F1F4")
DANEMARK=$(echo -e "\U0001F1E9\U0001F1F0")
SUISSE=$(echo -e "\U0001F1E8\U0001F1ED")

echo

# Utilise une instruction switch-case pour afficher le drapeau du pays correspondant à l'argument passé en paramètre
case $CHOICE in
france)
    echo " FRANCE : $FRANCE" # Affiche le drapeau de la France
    ;;
italie)
    echo " ITALIE  : $ITALIE" # Affiche le drapeau de l'Italie
    ;;
japon)
    echo " JAPON : $JAPON" # Affiche le drapeau du Japon
    ;;
usa)
    echo " ETATS_UNIS : $ETATS_UNIS" # Affiche le drapeau des Etats-Unis
    ;;
allemagne)
    echo " ALLEMAGNE : $ALLEMAGNE" # Affiche le drapeau de l'Allemagne
    ;;
bresil)
    echo " BRESIL : $BRESIL" # Affiche le drapeau du Brésil
    ;;
mexique)
    echo " MEXIQUE : $MEXIQUE" # Affiche le drapeau du Mexique
    ;;
russie)
    echo " RUSSIE : $RUSSIE" # Affiche le drapeau de la Russie
    ;;
chine)
    echo " CHINE : $CHINE" # Affiche le drapeau de la Chine
    ;;
argentine)
    echo " ARGENTINE : $ARGENTINE" # Affiche le drapeau de l'Argentine
    ;;
portugal)
    echo " PORTUGAL : $PORTUGAL" # Affiche le drapeau du Portugal
    ;;
norvege)
    echo " NORVEGE : $NORVEGE" # Affiche le drapeau de la Norvège
    ;;
danemark)
    echo " DANEMARK : $DANEMARK" # Affiche le drapeau du Danemark
    ;;
suisse)
    echo " SUISSE : $SUISSE" # Affiche le drapeau de la Suisse
    ;;
*)                                                                                                                                                     # Si le choix de l'utilisateur ne correspond à aucun cas dans la liste de pays
    echo " Le pays choisi n'est pas dans la liste."                                                                                                    # Afficher un message d'erreur indiquant que le pays choisi n'est pas dans la liste
    echo " Les pays disponibles sont : france italie japon coree usa allemagne bresil mexique russie chine argentine portugal norvege danemark suisse" # Afficher la liste de pays disponibles
    ;;
esac

echo # Afficher une ligne vide à la fin de l'exécution du script pour une meilleure lisibilité
