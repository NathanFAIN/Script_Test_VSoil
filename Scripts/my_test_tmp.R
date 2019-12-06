library(XML)
library(usethis)
library(crayon)
library(diffobj)

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
                    diffFile(path_file1, path_file2)
                    stop(red("Les valeurs diffèrent à la colonne ", i, " et la line ", j," ( ", unlist(data1[i])[j], " != ", unlist(data2[i])[j], " )\n"), call. = FALSE)
                } else {
                    cat(red("Les valeurs diffèrent à la colonne ", i, " et la line ", j," ( ", unlist(data1[i])[j], " != ", unlist(data2[i])[j], " )\n"))
                }
            }
        }
    }
    if (data_error == FALSE) {
        cat(green(path_file1, " et ", path_file2, " ont les mêmes valeus.\n"))
    } else {
        diffFile(path_file1, path_file2, tab.stops=1, disp.width=200)
    }
}

compare_files_lines <- function(path_file1, path_file2, epsilon)
{
    data1 <- readLines(path_file1)
    data2 <- readLines(path_file2)
    lines_data1 <- length(data1)
    lines_data2 <- length(data2)

    #Vérification du meme nombre de lines dans les deux fichiers:
    if (all(is.na(unlist(data1[lines_data1])))) {
        lines_data1 = lines_data1 - 1
    }
    if (all(is.na(unlist(data2[lines_data2])))) {
        lines_data2 = lines_data2 - 1
    }
    if (lines_data1 != lines_data2) {
        if (stop_script == TRUE) {
            stop(red(path_file1, " et ", path_file2, " n'ont pas le même nombre de lines", ".\n Ils ont respectivement ", lines_data1, " et ", lines_data2, " colonnes\n"), call. = FALSE)
        } else {
            cat(red(path_file1, " et ", path_file2, " n'ont pas le même nombre de lines", ".\n Ils ont respectivement ", lines_data1, " et ", lines_data2, " colonnes\n"))
        }
    } else {
        cat(green(path_file1, " et ", path_file2, " ont le même nombre de lines: ", lines_data1, " colones\n"))
    }
    #Vérification des valeurs dans les deux fichiers:
    data_error <- FALSE
    for (i in 1:lines_data1) {
        if (lines_data2 > i && !is.na(as.numeric(data1[i])) && !is.na(as.numeric(data2[i])) && abs(as.numeric(data1[i]) - as.numeric(data2[i])) > epsilon) {
            data_error <- TRUE
            if (stop_script == TRUE) {
                diffFile(path_file1, path_file2)
                stop(red("Les valeurs diffèrent à la line ", i," ( ", data1[i], " != ", data2[i], " )\n"), call. = FALSE)
            } else {
                cat(red("Les valeurs diffèrent à la line ", i," ( ", data1[i], " != ", data2[i], " )\n"))
            }
        }
    }
    if (data_error == FALSE) {
        cat(green(path_file1, " et ", path_file2, " ont les mêmes valeus.\n"))
    } else {
        diffFile(path_file1, path_file2, tab.stops=1, disp.width=200)
    }
}




\newpage


\textcolor{lightgray}{This is lightgray.}

\textcolor{gray}{This is gray.}

\textcolor{darkgray}{This is darkgray.}

\textcolor{lime}{This is lime.}

\textcolor{green}{This is green.}

\textcolor{olive}{This is olive.}

\textcolor{teal}{This is teal.}

\textcolor{blue}{This is blue.}

\textcolor{cyan}{This is cyan.}

\textcolor{brown}{This is brown.}

\textcolor{magenta}{This is magenta.}

\textcolor{red}{This is red.}

\textcolor{violet}{This is violet.}

\textcolor{orange}{This is orange.}

\textcolor{purple}{This is purple.}

\textcolor{pink}{This is pink.}

\textcolor{yellow}{This is yellow.}

\textcolor{white}{This is white.} The proceeding text is white. .
