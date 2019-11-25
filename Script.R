library(XML)

########################################################################################################
########################################### INITIALISATION #############################################
########################################################################################################

args <- commandArgs(trailingOnly = TRUE)

#Path pour VSoil:
path_dir_vsoil <- toString(args[1])
path_file_vsoil <- paste(path_dir_vsoil, "/vsoil_model_init_data.xml", sep = "")
path_return_status_vsoil <- paste(path_dir_vsoil, "/vsoil_run_exit_status.txt", sep = "")
path_progression_vsoil <- paste(path_dir_vsoil, "/vsoil_progression.txt", sep = "")
path_matrix_potential_vsoil <- paste(path_dir_vsoil, "/../matrix_potential.csv", sep = "")
path_observ_value_vsoil <- paste(path_dir_vsoil, "/../observ_value.csv", sep = "")

#Path pour ESPAS:
path_dir_espas <- toString(args[2])
path_ter_espas <- paste(path_dir_espas, "/Example/Wind_sdec/Wind_sdec.dat", sep = "")
path_matrix_potential_espas <- paste(path_dir_espas, "/lib/espas_potential.csv", sep = "")
path_calibration_espas <- paste(path_dir_espas, "/lib/calibration_espas.dat", sep = "")
path_masse_espas <- paste(path_dir_espas, "/lib/masse_espas.dat", sep = "")

########################################################################################################
################################# VERIFICATION DES DEUX REPERTOIRES ####################################
########################################################################################################
cat("1.Verification des deux repertoires:\n")
#Verification du nombre d'aguments:
if (path_dir_vsoil == "NA" || path_dir_espas == "NA" || toString(args[3]) != "NA") {
    stop("ERREUR: Nombre d'aguments invalide!\n")
} else {
    cat("Repertoire de VSoil:", path_dir_vsoil, "\n")
    cat("Repertoire d'ESPAS:", path_dir_espas, "\n")
}
#1.1.VSoil:
#1.1.1.VSoil Entrees:
cat("1.1.VSoil:\n")
cat("1.1.1.VSoil Entrees:\n")



#1.1.2.VSoil Sorties:
cat("1.1.2.VSoil Sorties:\n")

#1.2.ESPAS:
#1.2.1.ESPAS Entrees:
cat("1.2.ESPAS:\n")
cat("1.2.1.ESPAS Entrees:\n")

#1.2.2.ESPAS Sorties:
cat("1.2.2.ESPAS Sorties:\n")

########################################################################################################
################################## VERIFICATION DES DONNEES D ENTRE ####################################
########################################################################################################
cat("2.Verification des donnees d'entrees:\n")
#2.1.Validation du .ter:
cat("2.1.Validation du .ter:\n")

#2.2.Validation des donnees de calibration:
cat("2.2.Validation des donnees de calibration:\n")

#2.3.Masse et diametre:
cat("2.3.Masse et diametre:\n")

########################################################################################################
################################ VERIFICATION DES DONNEES DE SORTIE ####################################
########################################################################################################
cat("3.Verification des donnees de sorties:\n")
#3.1.Potentiels matriciels:
cat("3.1.Potentiels matriciels:\n")

#3.2.Observ_value:
cat("3.2.Observ_value:\n")
