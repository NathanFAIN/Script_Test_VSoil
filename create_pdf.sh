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
echo -e "\e[32mGénération du PDF...\e[0m\n\n"
sudo Rscript -e 'rmarkdown::render("Scripts/generate_pdf.Rmd",output_file="check_VSoil.pdf")' $1 $2
