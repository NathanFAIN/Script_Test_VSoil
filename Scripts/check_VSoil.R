library(XML)
library(usethis)
library(crayon)

########################################################################################################
########################################### INITIALISATION #############################################
########################################################################################################

#Stoper le script quand une erreur est detecte:
stop_script <- FALSE

#Recuperer les aguments:
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

#Fonction pour verifier l'existance d'un fichier:
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

#Fonction pour verifier l'existance d'un dossier:
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

#Fonction pour verifier le contenu d'un fichier:
check_contents_file <- function(path_file, value_name, contents)
{
    contents_test <- readChar(path_file, c(nchar(toString(contents))))
    if (contents_test[1] != contents) {
        if (stop_script == TRUE) {
            stop(red(value_name, " invalide (obtenu '", contents_test[1], "' mais attendu '", contents,"')\n"), call. = FALSE)
        } else {
            cat(red(value_name, " invalide (obtenu '", contents_test[1], "' mais attendu '", contents,"')\n"))
        }
    } else {
        cat(green(value_name, " valide: ", path_file, " -> ", contents_test[1], "\n"))
    }
}

#Fonction pour comparer le contenu de deux fichiers:
compare_files <- function(path_file1, path_file2, epsilon, sep)
{
    data1 <- read.delim(path_file1, header = TRUE, sep = sep)
    data2 <- read.delim(path_file2, header = TRUE, sep = sep)
    colones_data1 <- length(data1)
    colones_data2 <- length(data2)
    #Vérification du meme nombre de colonnes dans les deux fichiers:
    if (all(is.na(unlist(data1[colones_data1])))) {
        colones_data1 = colones_data1 - 1
    }
    if (all(is.na(unlist(data2[colones_data2])))) {
        colones_data2 = colones_data2 - 1
    }
    if (colones_data1 != colones_data2) {
        if (stop_script == TRUE) {
            stop(red(path_file1, " et ", path_file2, " n'ont pas le même nombre de colonnes", ".\n Ils ont respectivement ", colones_data1, " et ", colones_data2, " colonnes\n"), call. = FALSE)
        } else {
            cat(red(path_file1, " et ", path_file2, " n'ont pas le même nombre de colonnes", ".\n Ils ont respectivement ", colones_data1, " et ", colones_data2, " colonnes\n"))
        }
    } else {
        cat(green(path_file1, " et ", path_file2, " ont le même nombre de colonnes: ", colones_data1, " colones\n"))
    }
    #Vérification du meme nombre de lignes dans les deux fichiers:
    data_error <- FALSE
    for (i in 1:colones_data1) {
        if(colones_data2 > i && length(unlist(data1[i])) != length(unlist(data2[i]))) {
            data_error <- TRUE
            if (stop_script == TRUE) {
                stop(red(path_file1, " et ", path_file2, " n'ont pas le même nombre de lignes (colonne ", i, ").\n Ils ont respectivement ", length(unlist(data1[i])), " et ", length(unlist(data2[i])), " lignes\n"), call. = FALSE)
            } else {
                cat(red(path_file1, " et ", path_file2, " n'ont pas le même nombre de lignes (colonne ", i, ").\n Ils ont respectivement ", length(unlist(data1[i])), " et ", length(unlist(data2[i])), " lignes\n"))
            }
        }
    }
    if (data_error == FALSE) {
        cat(green(path_file1, " et ", path_file2, " ont le même nombre de lines.\n"))
    }
    #Vérification des valeurs dans les deux fichiers:
    data_error <- FALSE
    for (i in 1:colones_data1) {
        for (j in 1:length(unlist(data1[i]))) {
            if (colones_data2 > i && length(unlist(data2[i])) > j && abs(unlist(data1[i])[j] - unlist(data2[i])[j]) > epsilon) {
                data_error <- TRUE
                if (stop_script == TRUE) {
                    stop(red("Les valeurs vennant du .ter diffèrent à la colonne ", i, " et la line ", j," ( ", unlist(data1[i])[j], " != ", unlist(data2[i])[j], " )\n"), call. = FALSE)
                } else {
                    cat(red("Les valeurs vennant du .ter diffèrent à la colonne ", i, " et la line ", j," ( ", unlist(data1[i])[j], " != ", unlist(data2[i])[j], " )\n"))
                }
            }
        }
    }
    if (data_error == FALSE) {
        cat(green(path_file1, " et ", path_file2, " ont les mêmes valeus.\n"))
    }
}

########################################################################################################
################################# VERIFICATION DES DEUX REPERTOIRES ####################################
########################################################################################################
#Verification du nombre d'aguments:
cat(bold$underline("1.Verification des deux repertoires:\n"))
if (path_dir_vsoil == "NA" || path_dir_espas == "NA" || toString(args[3]) != "NA") {
    if (stop_script == TRUE) {
        stop(red("Nombre d'aguments invalide!\n"), call. = FALSE)
    } else {
        cat(red("Nombre d'aguments invalide!\n"))
    }
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
node_mass_settings = getNodeSet(doc ,"//module[@name='espace_ret']/layer[@id=1]/parameter[@name='path_wind_mass_settings']")

if (length(node_ter) == 1 && length(node_calibration) == 1 && length(node_mass_settings) == 1) {
    path_ter_vsoil <- xmlAttrs(node_ter[[1]])[["originalValue"]]
    path_calibration_vsoil <- xmlAttrs(node_calibration[[1]])[["originalValue"]]
    path_mass_vsoil <- xmlAttrs(node_mass_settings[[1]])[["originalValue"]]
} else {
    stop(red("Format invalide du .xml: ", path_file_vsoil, "\n"))
}
check_file(path_ter_vsoil)
check_file(path_calibration_vsoil)
check_file(path_mass_vsoil)
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
compare_files(path_ter_vsoil, path_ter_espas, 1, "\t")

#2.2.Validation des donnees de calibration:
cat(underline$italic("2.2.Validation des donnees de calibration:\n"))
compare_files(path_mass_vsoil, path_mass_espas, 0.0001, "\t")

#2.3.Masse et diametre:
cat(underline$italic("2.3.Masse et diametre:\n"))
compare_files(path_calibration_vsoil, path_calibration_espas, 0.0001, "\t")

########################################################################################################
################################ VERIFICATION DES DONNEES DE SORTIE ####################################
########################################################################################################
cat(bold$underline("3.Verification des donnees de sorties:\n"))
#3.1.Potentiels matriciels:
cat(underline$italic("3.1.Potentiels matriciels:\n"))
compare_files(path_matrix_potential_vsoil, path_matrix_potential_espas, 0.0001, "\t")

#3.2.Observ_value:
cat(underline$italic("3.2.Observ_value:\n"))
compare_files(path_observ_value_vsoil, path_observ_value_espas, 0.0001, "\t")
