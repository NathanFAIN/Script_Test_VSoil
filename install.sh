#!/bin/bash

echo -e "Installation des dépendances...\n"
sudo apt-get install pandoc
sudo Rscript Scripts/install.R
echo -e "\e[32mIntallation fini!\e[0m"
