library(XML)
library(usethis)
library(devtools)
library(crayon)

########################################################################################################
########################################### INITIALISATION #############################################
########################################################################################################

#stoper le script quand une erreur est detecte
stop_script <- FALSE

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
path_calibration_espas <- paste(path_dir_espas, "/lib/calibration_espas.dat", sep = "")
path_mass_espas <- paste(path_dir_espas, "/lib/masse_espas.dat", sep = "")
path_ter_espas <- paste(path_dir_espas, "/Example/Wind_sdec/Wind_sdec.dat", sep = "")
path_matrix_potential_espas <- paste(path_dir_espas, "/lib/espas_potential.csv", sep = "")
path_observ_value_espas <- paste(path_dir_espas, "/lib/observ_value.csv", sep = "")
path_return_status_espas <- paste(path_dir_espas, "/lib/return_status.dat", sep = "")

########################################################################################################
########################################## FONCTIONS UTILES ############################################
########################################################################################################

check_file <- function(path_file)
{
    if(!file.exists(path_file) || dir.exists(path_file)) {
        if (stop_script == TRUE) {
            stop(red("Chemin invalide: ", path_file, "\n"), call. = FALSE)
        } else {
            cat(red("Chemin invalide: ", path_file, "\n"))
        }
    } else {
        cat(green("Chemin valide: ", path_file, "\n"))
    }
}

check_dir <- function(path_dir)
{
    if(!dir.exists(path_dir)) {
        if (stop_script == TRUE) {
            stop(red("Chemin invalide: ", path_dir, "\n"), call. = FALSE)
        } else {
            cat(red("Chemin invalide: ", path_dir, "\n"))
        }
    } else {
        cat(green("Chemin valide: ", path_dir, "\n"))
    }
}

check_contents_file <- function(path_file, name, contents)
{
    contents_test <- readChar(path_file, c(nchar(toString(contents))))
    if (contents_test[1] != contents) {
        if (stop_script == TRUE) {
            stop(red(name, " invalide (obtenu '", contents_test[1], "' mais attendu '", contents,"')\n"), call. = FALSE)
        } else {
            cat(red(name, " invalide (obtenu '", contents_test[1], "' mais attendu '", contents,"')\n"))
        }
    } else {
        cat(green(name, " valide: ", path_file, " -> ", contents_test[1], "\n"))
    }
}

########################################################################################################
################################# VERIFICATION DES DEUX REPERTOIRES ####################################
########################################################################################################
#Verification du nombre d'aguments:
cat(bold$underline("1.Verification des deux repertoires:\n"))
if (path_dir_vsoil == "NA" || path_dir_espas == "NA" || toString(args[3]) != "NA") {
    stop(red("Nombre d'aguments invalide!\n"))
} else {
    cat(blue$italic("Repertoire de VSoil: ", path_dir_vsoil, "\n"))
    cat(blue$italic("Repertoire d'ESPAS: ", path_dir_espas, "\n"))
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
check_contents_file(path_return_status_vsoil, "Return status", "0")
#Verification de la progression de VSoil:
check_contents_file(path_progression_vsoil, "Progression status", "100")

#1.2.ESPAS:
cat(underline$italic("1.2.ESPAS:\n"))
check_dir(path_dir_espas)
#1.2.1.ESPAS Entrees:
cat(underline$italic("1.2.1.ESPAS Entrees:\n"))
check_file(path_calibration_espas)
check_file(path_mass_espas)
check_file(path_ter_espas)

#1.2.2.ESPAS Sorties:
cat(underline$italic("1.2.2.ESPAS Sorties:\n"))
check_file(path_matrix_potential_espas)
check_file(path_observ_value_espas)
check_file(path_return_status_espas)
#Verification du return_status d'ESPAS:
check_contents_file(path_return_status_espas, "Return status", "0")

########################################################################################################
################################## VERIFICATION DES DONNEES D ENTRE ####################################
########################################################################################################
cat(bold$underline("2.Verification des donnees d'entrees:\n"))
#2.1.Validation du .ter:
cat(underline$italic("2.1.Validation du .ter:\n"))

#2.2.Validation des donnees de calibration:
cat(underline$italic("2.2.Validation des donnees de calibration:\n"))

#2.3.Masse et diametre:
cat(underline$italic("2.3.Masse et diametre:\n"))

########################################################################################################
################################ VERIFICATION DES DONNEES DE SORTIE ####################################
########################################################################################################
cat(bold$underline("3.Verification des donnees de sorties:\n"))
#3.1.Potentiels matriciels:
cat(underline$italic("3.1.Potentiels matriciels:\n"))

#3.2.Observ_value:
cat(underline$italic("3.2.Observ_value:\n"))
