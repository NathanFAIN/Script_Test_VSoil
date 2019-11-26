library(XML)
library(usethis)
library(devtools)
library(crayon)

########################################################################################################
########################################## FONCTIONS UTILES ############################################
########################################################################################################

check_file <- function(path_file)
{
    if(!file.exists(path_file) || dir.exists(path_file)){
        stop(red("Chemin invalide: ", path_file, "\n"), call. = FALSE)
    } else {
        cat(green("Chemin valide: ", path_file, "\n"))
    }
}

check_dir <- function(path_dir)
{
    if(!dir.exists(path_dir)){
        stop(red("Chemin invalide: ", path_dir, "\n"), call. = FALSE)
    } else {
        cat(green("Chemin valide: ", path_dir, "\n"))
    }
}

########################################################################################################
########################################### INITIALISATION #############################################
########################################################################################################

args <- commandArgs(trailingOnly = TRUE)

#Path pour VSoil:
path_dir_vsoil <- toString(args[1])
path_file_vsoil <- paste(path_dir_vsoil, "/run_infos/vsoil_model_init_data.xml", sep = "")
path_return_status_vsoil <- paste(path_dir_vsoil, "/run_infos/vsoil_run_exit_status.txt", sep = "")
path_progression_vsoil <- paste(path_dir_vsoil, "/run_infos/vsoil_progression.txt", sep = "")
path_matrix_potential_vsoil <- paste(path_dir_vsoil, "/matrix_potential.csv", sep = "")
path_observ_value_vsoil <- paste(path_dir_vsoil, "/observ_value.csv", sep = "")

#Path pour ESPAS:
path_dir_espas <- toString(args[2])
path_ter_espas <- paste(path_dir_espas, "/Example/Wind_sdec/Wind_sdec.dat", sep = "")
path_matrix_potential_espas <- paste(path_dir_espas, "/lib/espas_potential.csv", sep = "")
path_calibration_espas <- paste(path_dir_espas, "/lib/calibration_espas.dat", sep = "")
path_masse_espas <- paste(path_dir_espas, "/lib/masse_espas.dat", sep = "")

########################################################################################################
################################# VERIFICATION DES DEUX REPERTOIRES ####################################
########################################################################################################
#Verification du nombre d'aguments:
cat(underline$bold("1.Verification des deux repertoires:\n"))
if (path_dir_vsoil == "NA" || path_dir_espas == "NA" || toString(args[3]) != "NA") {
    stop(red("Nombre d'aguments invalide!\n"))
} else {
    cat(yellow$italic("Repertoire de VSoil: ", path_dir_vsoil, "\n"))
    cat(yellow$italic("Repertoire d'ESPAS: ", path_dir_espas, "\n"))
}
#1.1.VSoil:
cat(underline$italic("1.1.VSoil:\n"))
check_dir(path_dir_vsoil)
#1.1.1.VSoil Entrees:
cat(underline$italic("1.1.1.VSoil Entrees:\n"))
check_file(path_file_vsoil)
doc = xmlParse(path_file_vsoil)
node_ter = getNodeSet(doc ,"//module[@name='espace_ret']/layer[@id=1]/parameter[@name='path_wind_ter']")
node_calibration = getNodeSet(doc ,"//module[@name='espace_ret']/layer[@id=1]/parameter[@name='path_wind_calibartion']")
node_mass_settings = getNodeSet(doc ,"//module[@name='espace_ret']/layer[@id=1]/parameter[@name='path_wind_masse_settings']")

if (length(node_ter) == 1 && length(node_calibration) == 1 && length(node_mass_settings) == 1) {
  path_ter_vsoil <- xmlAttrs(node_ter[[1]])[["originalValue"]]
  path_calibration_vsoil <- xmlAttrs(node_calibration[[1]])[["originalValue"]]
  path_mass_settings_vsoil <- xmlAttrs(node_mass_settings[[1]])[["originalValue"]]
} else {
  stop(red("Format invalide du .xml: ", path_file_vsoil, "\n"))
}
check_file(path_ter_vsoil)
check_file(path_calibration_vsoil)
check_file(path_mass_settings_vsoil)
#1.1.2.VSoil Sorties:
cat(underline$italic("1.1.2.VSoil Sorties:\n"))
check_file(path_return_status_vsoil)
check_file(path_progression_vsoil)
check_file(path_matrix_potential_vsoil)
check_file(path_observ_value_vsoil)
#Verification du return_status de VSoil:
return_status <- readChar(path_return_status_vsoil, c(1))
if (return_status[1] != "0") {
  stop(red("Return status invalide (obtenu '", return_status[1], "' mais attendu ' 0 ')\n"))
} else {
  cat(green("Return status valide: ", path_return_status_vsoil, " -> ", return_status[1], "\n"))
}
#Verification de la progression de VSoil:
progression <- readChar(path_progression_vsoil, c(3))
if (progression[1] != "100") {
  stop(red("ERREUR: Progression status invalide (obtenu '", progression[1], "' mais attendu ' 100 ')\n"))
} else {
  cat(green("Progression valide: ", path_progression_vsoil, " -> ", progression[1], "\n"))
}

#1.2.ESPAS:
#1.2.1.ESPAS Entrees:
cat(underline$italic("1.2.ESPAS:\n"))
cat(underline$italic("1.2.1.ESPAS Entrees:\n"))

#1.2.2.ESPAS Sorties:
cat(underline$italic("1.2.2.ESPAS Sorties:\n"))

########################################################################################################
################################## VERIFICATION DES DONNEES D ENTRE ####################################
########################################################################################################
cat(underline$bold("2.Verification des donnees d'entrees:\n"))
#2.1.Validation du .ter:
cat(underline$italic("2.1.Validation du .ter:\n"))

#2.2.Validation des donnees de calibration:
cat(underline$italic("2.2.Validation des donnees de calibration:\n"))

#2.3.Masse et diametre:
cat(underline$italic("2.3.Masse et diametre:\n"))

########################################################################################################
################################ VERIFICATION DES DONNEES DE SORTIE ####################################
########################################################################################################
cat(underline$bold("3.Verification des donnees de sorties:\n"))
#3.1.Potentiels matriciels:
cat(underline$italic("3.1.Potentiels matriciels:\n"))

#3.2.Observ_value:
cat(underline$italic("3.2.Observ_value:\n"))
