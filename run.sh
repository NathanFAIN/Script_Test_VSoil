#!/bin/bash

#Vérification de la presence de la commande 'Rscript'
RSCRIPT="$(which Rscript)"

if [ "$RSCRIPT" = "" ]; then
    echo "La commande Rscript n'est pas installé..."
    sudo apt-get install r-base
fi

#Lancement du script
Rscript Script.R $1 $2
