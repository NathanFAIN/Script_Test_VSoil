#!/bin/bash

SCRIPT=Rscript
DIR=Scripts
SRC=generate_pdf.Rmd
NAME=check_VSoil.pdf
CMD='rmarkdown::render("'$DIR"/"$SRC'",output_file="'$NAME'")'

#Vérification de la presence de la commande 'Rscript'
IS_SCRIPT="$(which $SCRIPT)"

if [ "$IS_SCRIPT" = "" ]; then
    echo -e "\e[31mLa commande '$SCRIPT' n'est pas installé...\e[0m"
    sudo apt-get install r-base
    if [ "$?" != "0" ]; then
        exit 1
    fi
fi

#Lancement du script
echo -e "\e[32mGénération du PDF...\e[0m\n\n"
sudo $SCRIPT -e $CMD $1 $2 $3
mv -f $DIR"/"$NAME .
