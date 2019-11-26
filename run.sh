#!/bin/bash

CMD=Rscript

#Vérification de la presence de la commande 'Rscript'
RSCRIPT="$(which $CMD)"

if [ "$RSCRIPT" = "" ]; then
    echo -e "\e[31mLa commande '$CMD' n'est pas installé...\e[0m"
    sudo apt-get install r-base
    if [ "$?" != "0" ]; then
        exit 1
    fi
fi

#Lancement du script
echo -e "\e[32mLancement du script...\e[0m\n\n"
Rscript Scripts/check_VSoil.R $1 $2
