library(XML)
library(usethis)
library(crayon)
library(diffobj)

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
path_observ_value_espas <- paste(path_dir_espas, "/lib/observ_value_espas.csv", sep = "")
path_return_status_espas <- paste(path_dir_espas, "/lib/return_status.dat", sep = "")

########################################################################################################
########################################## FONCTIONS UTILES ############################################
########################################################################################################

#Fonction pour verifier l'existance d'un fichier:
check_file <- function(path_file)
{
    if(!file.exists(path_file) || dir.exists(path_file)) {
       stop(red("Chemin invalide: ", path_file, "\n"), call. = FALSE)
    } else {
        cat(green("Chemin valide: ", path_file, "\n"))
    }
}

#Fonction pour verifier l'existance d'un dossier:
check_dir <- function(path_dir)
{
    if(!dir.exists(path_dir)) {
        stop(red("Chemin invalide: ", path_dir, "\n"), call. = FALSE)
    } else {
        cat(green("Chemin valide: ", path_dir, "\n"))
    }
}

#Fonction pour verifier le contenu d'un fichier:
check_contents_file <- function(path_file, value_name, contents)
{
    contents_test <- readChar(path_file, c(nchar(toString(contents))))
    if (contents_test[1] != contents) {
        stop(red(value_name, " invalide (obtenu '", contents_test[1], "' mais attendu '", contents,"')\n"), call. = FALSE)
    } else {
        cat(green(value_name, " valide: ", path_file, " -> ", contents_test[1], "\n"))
    }
}

#Fonction pour comparer le nombre de lines de deux data:
compare_line <- function(data1, data2, path_file1, path_file2)
{
    if (length(data1) != length(data2)) {
        diffFile(path_file1, path_file2, tab.stops=1, disp.width=200)
        stop(red("Les fichiers ", path_file1, " et ", path_file2, " n'ont pas le même nombre de colones: ",length(data1),  length(data2) , "\n"), call. = FALSE, domain = NULL)
    } else if (length(unlist(data1)) != length(unlist(data2))) {
        diffFile(path_file1, path_file2, tab.stops=1, disp.width=200)
        stop(red("Les fichiers ", path_file1, " et ", path_file2, " n'ont pas le même nombre de lines: ",length(unlist(data1)),  length(unlist(data2)) , "\n"), call. = FALSE, domain = NULL)
    }
}

#Fonction pour comparer le contenu de deux data:
compare_data <- function(data1, data2, epsilon, path_file1, path_file2)
{
    cmp_data <- ifelse(abs(unlist(data1) - unlist(data2)) > epsilon, TRUE, FALSE)
    if (is.element(TRUE, cmp_data)) {
        index <- which.max(cmp_data)
        cat(index, "\n")
        line <- (index - 1) %% length(unlist(data1[1])) + 1
        colone <- ceiling(index / length(unlist(data1[1])))
        diffFile(path_file1, path_file2, tab.stops=1, disp.width=200)
        stop(red("Valeur '", unlist(data1[colone])[line], "' est invalide, LINE: ", line, "COLONE: ",colone , "\n"), call. = FALSE, domain = NULL)
    }
}

#Fonction pour comparer le contenu de deux fichiers:
compare_files <- function(path_file1, path_file2, epsilon, sep)
{
    data1 <- read.delim(path_file1, header = TRUE, sep = sep)
    data2 <- read.delim(path_file2, header = TRUE, sep = sep)
    compare_line(data1, data2, path_file1, path_file2)
    cat(green("Les fichiers ", path_file1, " et ", path_file2, " ont le même nombre de lignes.\n"))
    compare_data(data1, data2, epsilon, path_file1, path_file2)
    cat(green("Les fichiers ", path_file1, " et ", path_file2, " ont des valeurs identiques.\n"))
}

#Fonction pour comparer les valeurs observees:
compare_files_bis <- function(path_file1, path_file2, epsilon, sep)
{
    data1 <- read.delim(path_file1, header = TRUE, sep = sep)
    data2 <- read.delim(path_file2, header = TRUE, sep = sep)
    compare_line(data1, data2, path_file1, path_file2)
    cat(green("Les fichiers ", path_file1, " et ", path_file2, " ont le même nombre de lignes.\n"))
    compare_data(data1[1], data2[1], 0.2, path_file1, path_file2)
    compare_data(data1[2], data2[2], epsilon, path_file1, path_file2)
    cat(green("Les fichiers ", path_file1, " et ", path_file2, " ont des valeurs identiques.\n"))
}


#Fonction pour comparer deux nombres:
check_epsilon <- function(value1, value2, epsilon, path_file1, path_file2)
{
    if (is.na(as.numeric(value1)) || is.na(as.numeric(value2)) || abs(as.numeric(value1) - as.numeric(value2)) > epsilon) {
        diffFile(path_file1, path_file2, tab.stops=1, disp.width=200)
        stop(red("Valeur: ", value1, " différente de: ", value2, "\n"), call. = FALSE)
    }
}

compare_files_lines <- function(path_file1, path_file2, epsilon)
{
    data1 <- readLines(path_file1)
    data2 <- readLines(path_file2)
    lines_data1 <- length(data1)
    lines_data2 <- length(data2)

#   Vérification du meme nombre de lines dans les deux fichiers:
    if (lines_data1 != lines_data2) {
        stop(red(path_file1, " et ", path_file2, " n'ont pas le même nombre de lines", ".\n Ils ont respectivement ", lines_data1, " et ", lines_data2, " colonnes\n"), call. = FALSE)
    } else {
        cat(green(path_file1, " et ", path_file2, " ont le même nombre de lines: ", lines_data1, " colones\n"))
    }
#   Vérification des valeurs dans les deux fichiers:
    check_epsilon(data1[11], data2[11], 0.001, path_file1, path_file2)
    check_epsilon(data1[11], data2[11], 0.001, path_file1, path_file2)
    check_epsilon(data1[17], data2[17], 0.001, path_file1, path_file2)
    check_epsilon(data1[20], data2[20], 0.001, path_file1, path_file2)
    check_epsilon(data1[23], data2[23], 0.001, path_file1, path_file2)
    check_epsilon(data1[26], data2[26], 0.001, path_file1, path_file2)
    check_epsilon(data1[29], data2[29], 0.001, path_file1, path_file2)
    cat(green(path_file1, " et ", path_file2, " ont les mêmes valeus.\n"))
}

########################################################################################################
################################# VERIFICATION DES DEUX REPERTOIRES ####################################
########################################################################################################
#Verification du nombre d'aguments:
cat(bold$underline("1.Verification des deux repertoires:\n"))
if (is.na(args[1]) || is.na(args[2]) || !is.na(args[3])) {
    stop(red("Nombre d'aguments invalide!\n"), call. = FALSE)
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
# compare_files(path_ter_vsoil, path_ter_espas, 100, "\t")

#2.2.Validation des donnees de calibration:
cat(underline$italic("2.2.Validation des donnees de calibration:\n"))
compare_files(path_calibration_vsoil, path_calibration_espas, 0.001, "\t")

#2.3.Masse et diametre:
cat(underline$italic("2.3.Masse et diametre:\n"))
compare_files_lines(path_mass_vsoil, path_mass_espas, 0.001)

########################################################################################################
################################ VERIFICATION DES DONNEES DE SORTIE ####################################
########################################################################################################
cat(bold$underline("3.Verification des donnees de sorties:\n"))
#3.1.Potentiels matriciels:
cat(underline$italic("3.1.Potentiels matriciels:\n"))
compare_files(path_matrix_potential_vsoil, path_matrix_potential_espas, 0.001, ";")

#3.2.Observ_value:
cat(underline$italic("3.2.Observ_value:\n"))
compare_files_bis(path_observ_value_vsoil, path_observ_value_espas, 0.001, ";")
