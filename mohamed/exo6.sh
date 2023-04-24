#!/bin/bash

clear

# Vérifie si un répertoire est fourni en paramètre
if [ -z "$1" ]; then
    echo -e "\n Comment utiliser ce script: $0 <directory> \n"
    exit 1
fi

# Vérifie si le paramètre est un répertoire existant
if [ ! -d "$1" ]; then
    echo -e "\n Erreur: $1 n'est pas un répertoire. \n"
    exit 1
fi

# Affiche le répertoire à compter
echo -e "\n Décompte des fichiers et des sous-répertoires dans le répertoire: $1\n"

# Compte le nombre de fichiers standards
# -maxdepth 1 : limite la recherche au répertoire donné en paramètre, sans chercher dans les sous-répertoires
# -type f : cherche des fichiers
# wc -l : compte le nombre de lignes retournées (correspondant au nombre de fichiers)
files=$(find "$1" -maxdepth 1 -type f | wc -l)

# Compte le nombre de sous-répertoires
# -maxdepth 1 : limite la recherche au répertoire donné en paramètre, sans chercher dans les sous-répertoires
# -type d : cherche des répertoires
# wc -l : compte le nombre de lignes retournées (correspondant au nombre de répertoires)
directories=$(find "$1" -maxdepth 1 -type d | wc -l)

# Check le nombre de fichiers existant
if [ $files -eq 0 ]; then
    echo " Ce répertoire ne contient pas de fichiers à proprement parlé. Oui, sur linux tout est fichier donc ici je précise bien qu'il n'y en a pas."
else
    # Affiche le nombre de fichiers
    # Affiche le nombre de fichiers (en soustrayant 1 car la commande find compte également le répertoire donné en paramètre)
    echo " Nombre de fichiers : $((files - 1))"
fi

# Check le nombre de sous-dossiers existant
if [ $directories -eq 0 ]; then
    echo -e " Ce répertoire ne contient pas de fichiers à proprement parlé.\n"
    echo -e " Oui, sur linux tout est fichier donc ici je précise bien qu'il n'y en a pas."
else
    # Affiche le nombre de sous-répertoires (en soustrayant 1 car la commande find compte également le répertoire donné en paramètre)
    echo -e " Nombre de sous-dossiers: $((directories - 1))\n"
fi
