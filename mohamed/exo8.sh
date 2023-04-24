#!/bin/bash

# Effacer le fichier FichierNote.txt s'il existe déjà
rm -rf "./FichierNote.txt"

# Vérifier si le fichier de notes existe, sinon le créer et y ajouter des données
if [ ! -f "FichierNote.txt" ]; then
    echo -e "\n Le fichier de notes n'existe pas. Création du fichier...\n"
    touch FichierNote.txt

    echo "Adam Troijours 17" >>FichierNote.txt
    echo "Alain Térieur 8" >>FichierNote.txt
    echo "Yves Vapabien 3" >>FichierNote.txt
    echo "Aude Javel 15" >>FichierNote.txt
    echo "Habib Oché 19" >>FichierNote.txt
    echo "Jacques Ouzi 8" >>FichierNote.txt
    echo "Anas Hatim 13" >>FichierNote.txt
    echo "Alain Delon 0" >>FichierNote.txt
    echo "Alain Guillon 20" >>FichierNote.txt
    echo "Malo Gusto 5" >>FichierNote.txt
    echo "Dimitri Paillette 0" >>FichierNote.txt
    echo "Tarek Taguine 19" >>FichierNote.txt
    echo "Alex Boulom 18" >>FichierNote.txt
fi

# Lire chaque ligne du fichier FichierNote.txt et extraire le nom, prénom et note
while read line; do
    nom=$(echo $line | cut -d " " -f1)    # Extraire la première colonne (nom) en utilisant un espace comme délimiteur (-d " ")
    prenom=$(echo $line | cut -d " " -f2) # Extraire la deuxième colonne (prénom) en utilisant un espace comme délimiteur (-d " ")
    note=$(echo $line | cut -d " " -f3)   # Extraire la troisième colonne (note) en utilisant un espace comme délimiteur (-d " ")

    # Vérifier si la note est supérieure ou égale à 10
    if [ $note -ge 10 ]; then
        # Afficher le nom, prénom et la note, avec un emoji selon la note (18 -> 🥉, 19 -> 🥈, 20 -> 🥇)
        if [ $note -eq 18 ]; then
            echo " $nom $prenom : $note 🥉"
        elif [ $note -eq 19 ]; then
            echo " $nom $prenom : $note 🥈"
        elif [ $note -eq 20 ]; then
            echo " $nom $prenom : $note 🥇"
        else
            echo " $nom $prenom : $note "
        fi
    fi
done <FichierNote.txt

echo # Afficher une ligne vide pour la lisibilité
