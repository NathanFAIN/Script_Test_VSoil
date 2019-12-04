# Cahier des charges

## Validation des valeurs dans le programme VSoil


# Sommaire

## I) Contexte et présentation du projet

```
1.Contexte
2.Objectif
```

## II) Solutions et résultats attendus

```
Introduction: prérequis
1.Vérification des deux répertoires
1.1.VSoil
1.1.1.VSoil Entrées
1.1.2.VSoil Sorties
1.2.ESPAS
1.2.1.ESPAS Entrées
1.2.2.ESPAS Sorties
2.Vérification des données d'entrées
2.1.Validation du .ter
2.2.Validation des données de calibration
2.3.Masse et diamètre
3.Vérification des données de sorties
3.1.Potentiels matriciels
3.2.Valeurs observées
4.Conclusion
```

## I) Contexte et présentation du projet:

**1.Contexte:** ​ Module de VSoil "espas_ret" permettant la détermination des propriétés
hydrodynamiques d'un sol. Intégrer les fonctionnalités de l'application ESPAS dans des
modules de VSoil. Nous possédons donc deux application nous prenetant de faire
l’estimation: VSoil et ESPAS. L’application ESPAS a la particularité de d’exécuter un binaire
qui s’occupera de faire tout les calcules.
**2.Objectif:** ​ Vérifier que les valeurs lues dans les fichiers donné en paramètre soient valides
et que les résultats obtenus soient similaires/cohérents avec ceux d'ESPAS.
Le script de vérification sera fait avec le langage R. Celui-ci prendra deux arguments: le
répertoire où s’est déroulé la simulation de VSoil et le répertoire des fichiers à envoyer en
entrée à l’application ESPAS.
(On pourra dans le futur ajouter un troisième argument: l’écart epsilon accepté entre les données VSoil et
ESPAS)


## II) Solutions et résultats attendus

**Introduction: prérequis.**
Quand une erreur est détectée dans le fichier, la ligne, la valeur, la cause de l’erreur ainsi
qu’une courbe affichant les deux jeux de valeurs remis en cause sont affichés.
Les valeurs d’entré et de sortie de l'application ESPAS étant valident, nous nous en
servirons pour les comparer avec celles de VSoil. Si il y a une différence significative entre
les valeurs de VSoil et celles d’ESPAS, le script de test s'interrompra et affichera un
message d’erreur correspondant au donné invalide.
Le script détaillera précisément chaques étapes et jeu de valeurs vérifier, il se calquera sur
ce cahier des charges et donc procédera exactement dans le même ordre.
On peut séparer la vérification des données en trois étapes:

- Vérification des deux répertoires -> si tout les fichiers à vérifier existent.
- Les données d'entrées ⟶ *.ter, données de calibration, de masse et de taille.
- Les données de sorties ⟶ potentiel matriciel et valeurs observées (matrix_potential.csv et
observ_value.csv).
Cependant pour vérifier les données d’entrée de VSoil (.dat), il nous faut ces mêmes
données venant d’ESPAS. Dans ESPAS, la plupart de ces donnée sont rentrées
manuellement par l’utilisateur et non stockées dans des fichier en sortie. Il est donc
indispensable de modifier le code d’ESPAS pour pouvoir avoir une trace des masses et
calibrations rentrées manuellement dans l’application.
Le format des fichiers supplémentaires créés pour valider les entrés seront identique à ceux
de VSoil (“calibration_*.dat”, “masse_*.dat”) pour rester le plus cohérent possible. Leur nom
seront respectivement “calibration_espas.dat” et “masse_espas.dat”.
⟶ ​Il convient donc de créer un premier fichier nommé “lib/calibration_espas.dat” regroupant
comme dans VSoil toutes les données liées à calibration. Ce nouveau fichier aura la même
mise en page et donc le même format que celui présent dans VSoil. Pour cela l'extrait de
code suivant correspondant à la méthode “​createCalibrationFile​” qui prendra en paramètre le
nombre de capteurs, l’utilisation des capteur, la position des capteurs, le alpha des capteurs,
le alpha0 des capteurs, le beta des capteurs, le beta0 des capteurs, le seuilMin des capteurs
et le seuilMax des capteurs est nécessaire. Cette méthode devra être ajouté dans le fichier
“src/wind/Utility.java” (dans la class ​Utility​):
```
public static void createCalibrationFile(int nb_capt, boolean[] actif, float[] pos, float[] alpha, float[] alpha0, float[]
beta, float[] beta0, float[] seuilMin, float[] seuilMax)
{
    try
    {
// Creation et ecriture dans le fichier calibration_data.csv
BufferedWriter bw = new BufferedWriter(new FileWriter("calibration_espas.dat"));
String line = new
String("NumCapt\tfonct.(1/0)\tOrdre\tProf(cm)\talpha(m/mV/C)\talpha0(m/mV)\tbeta(m/C)\tbeta0(m)\tseuilmin(m)\t
seuilmax(m)\n");


bw.write(line, 0, line.length());
for (int index = 0; index < nb_capt; index++) {
line = new String((index + 1) + "\t" + (actif[index] == true? "1" : "0") + "\t" + (index + 1) + "\t" +
String.format("%.3f", pos[index]) + "\t" + String.format("%.8f", alpha[index]) + "\t" + String.format("%.8f",
alpha0[index]) + "\t" + String.format("%.8f", beta[index]) + "\t" + String.format("%.8f", beta0[index]) + "\t" +
String.format("%.8f", seuilMin[index]) + "\t" + String.format("%.8f", seuilMax[index]) + "\n");
bw.write(line, 0, line.length());
}
bw.close();
System.out.println("calibration_espas.dat created");
}
catch(java.io.IOException ioe)
{
System.out.println("Error file");
}
}
```
⟶ ​Il convient donc également de créer un second fichier nommé “lib/masse_espas.dat”
regroupant comme dans VSoil toutes les données liées à la masse et au diamètre. Le fichier
aura le même format que celui présent dans VSoil. Cela signifie que les paramètres seront
noté dans le même ordres que dans les fichier VSoil: (​diamint, hautcyl, xmascyl, xmasat,
xmasolsec, xmaseq1 et htot)​ et aura également des lignes de commentaire entre chaque
valeurs​. ​Pour cela l'extrait de code suivant correspondant à la méthode “​createMassFile​” qui
prendra en paramètre le diamètre intérieur du cylindre, la hauteur du cylindre, la masse de la
tare utilisée, la masse totale de l'échantillon humide, la masse nette de sol sec à 105 degrés,
la masse de la première séquence et hauteur totale du système expérimental est
nécessaire. Cette méthode devra être ajouté dans le fichier “src/wind/Utility.java” (dans la
class ​Utility​):
```
public static void createMassFile(float diamint, float hautcyl, float xmascyl, float xmasat, float xmasolsec, float
xmaseq1, float htot)
{
try
{
// Creation et ecriture dans le fichier espas_potential.csv
String line = null;
BufferedWriter bw = new BufferedWriter(new FileWriter("masse_espas.dat"));
line = new
String("***************************************************************\nNONE\n*********************************************
******************\n");
bw.write(line, 0, line.length());
line = new String("Nom de l'operateur de l'experience (50 car. max):\n");
bw.write(line, 0, line.length());
line = new String("NONE\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------\nProvenance/horizon/nom de fichier
du sol utilise (50 car. max):\n");
bw.write(line, 0, line.length());
line = new String("NONE\n");
bw.write(line, 0, line.length());


line = new String("---------------------------------------------------------------\nDiametre interieur du cylindre
(cm):\n");
bw.write(line, 0, line.length());
line = new String(String.format("%.4f", diamint) + "\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------\nHauteur du cylindre (cm):\n");
bw.write(line, 0, line.length());
line = new String(String.format("%.4f", hautcyl) + "\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------\nMasse de la tare utilisée (g):\n");
bw.write(line, 0, line.length());
line = new String(String.format("%.4f", xmascyl) + "\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------\nMasse totale de l'echantillon humide
(solsec + eau + tare) (g)\n");
bw.write(line, 0, line.length());
line = new String(String.format("%.4f", xmasat) + "\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------\nMasse nette de sol sec a 105 degre
(g)\n");
bw.write(line, 0, line.length());
line = new String(String.format("%.4f", xmasolsec) + "\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------\nMasse de la premiere sequence
(g)\n");
bw.write(line, 0, line.length());
line = new String(String.format("%.4f", xmaseq1) + "\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------\nHauteur totale du systeme
experimental (>0,cm)\n");
bw.write(line, 0, line.length());
line = new String(String.format("%.4f", htot) + "\n");
bw.write(line, 0, line.length());
line = new String("---------------------------------------------------------------");
bw.write(line, 0, line.length());
bw.close();
System.out.println("masse_espas.dat created");
}
catch(java.io.IOException ioe)
{
System.out.println("Error file");
}
}
```
⟶ ​De même pour les potentiels matriciels venant de l’application ESPAS. Le code java
d’ESPAS sera modifié pour permettre leur réécriture dans un fichier nommé
“espas_potential.csv”. Ce nouveau fichier aura la même mise en page et donc le même
format que celui présent dans VSoil. Pour cela l'extrait de code suivant correspondant à la
méthode “​createPotentialFile​” en n’oubliant pas d’ajouter les import “​import
wind.acquisition.EnsParamAcquisition​” et “​import wind.windException.NotAllowedOperationException​”. Cette
méthode devra être ajouté dans le fichier “src/wind/Utility.java” (dans la class ​Utility​):

```
public static void createPotentialFile(EnsParamAcquisition ens, int nb_capt, float[] pos, float[] alpha, float[]
alpha0, float[] beta, float[] beta0, float[] seuilMin, float[] seuilMax, int[] tensio, float[] tempb, float htot, float[]
valTemps)
{
try
{
// Creation et ecriture dans le fichier espas_potential.csv
String line = new String("time");
for (int index = 0; index < nb_capt; index++) {
line = new String(line + ";P" + index);
}
line = new String(line + "\n");
BufferedWriter bw = new BufferedWriter(new FileWriter("espas_potential.csv"));
bw.write(line, 0, line.length());
float[][] valeurs = new float[nb_capt][tensio.length + 10000];
for (int index = 0; index < tensio.length; index++) {
valeurs[index] = Utility.getPotentiel(ens.getValues("Capteur" + String.valueOf(tensio[index]),true),
alpha[index], alpha0[index], beta[index], beta0[index], tempb, htot, pos[index], seuilMin[index],seuilMax[index]);
}
for (int index = 0; index < valeurs[0].length; index++) {
line = new String(valTemps != null? String.format("%.0f", valTemps[index] * 60) : "0");
for (int index_bis = 0; index_bis < nb_capt; index_bis++) {
line = new String(line + ";" + String.format("%.8f", valeurs[index_bis][index]));
}
line = new String(line + "\n");
bw.write(line, 0, line.length());
}
bw.close();
System.out.println("espas_potential.csv created");
}
catch(java.io.IOException ioe)
{
System.out.println("Error file");
}
catch(NotAllowedOperationException naoe)
{
System.out.println("NotAllowedOperationException");
}
catch(NameNotFoundException nnfe)
{
System.out.println("NameNotFoundException");
}
}
```
⟶ ​De plus il nous est impossible de vérifier si le binaire fortran lancé via l’application ESPAS
a bien fonctionné et si celui-ci a pu aller jusqu’au bout du processus (si le programme fortran
s’est bien exécuté). Pour cela il est nécessaire de créer un nouveau fichier de
“return_status” nous permettant d'enregistrer la valeur renvoyé par le binaire à la fin de son
exécution. Il faudra donc à nouveau ajouter deux méthode dans la classe “Utility” présent
dans le fichier “src/wind/Utility.java”. La première méthode nous permettra de supprimer
l’ancien fichier "return_status.dat" contenant le return status de la dernière exécution du
binaire:
```
public static void deleteReturnStatusFile()
{
File return_status_file = new File("return_status.dat");
return_status_file.delete();
}
La seconde méthode permettra de créer le fichier nommé "return_status.dat" contenant le
return status du binaire fortran:
public static void createReturnStatusFile(int exitValue)
{
try
{
// Creation et ecriture dans le fichier return_status.dat
BufferedWriter bw = new BufferedWriter(new FileWriter("return_status.dat"));
String line = new String(exitValue + "\n");
bw.write(line, 0, line.length());
bw.close();
System.out.println("return_status.dat created");
}
catch(java.io.IOException ioe)
{
System.out.println("Error file");
}
}
```
Il faudra appeler les trois nouvelles méthodes “​createCalibrationFile​”, “​createMassFile​” et
“​createPotentialFile​” à la ligne 250 de la méthode “​PotentielsPanel​” de la classe “​PotentielsPanel​”
dans le fichier “src/wind/ihm/PotentielsPanel.java” comme ci-joint:
```
Utility.createPotentialFile(ens, nb_capt, pos, alpha, alpha0, beta, beta0, seuilMin, seuilMax, tensio, tempb, htot,
valTemps);
Utility.createMassFile(((Float)(trait.getEnsParamTraitement("description").getParam("diamint").getValeur())).float
Value(), ((Float)(trait.getEnsParamTraitement("description").getParam("hautcyl").getValeur())).floatValue(),
((Float)(trait.getEnsParamTraitement("description").getParam("xmascyl").getValeur())).floatValue(),
((Float)(trait.getEnsParamTraitement("description").getParam("xmasat").getValeur())).floatValue(),
((Float)(trait.getEnsParamTraitement("description").getParam("xmasolsec").getValeur())).floatValue(),
((Float)(trait.getEnsParamTraitement("description").getParam("xmaseq1").getValeur())).floatValue(),
((Float)(trait.getEnsParamTraitement("description").getParam("htot").getValeur())).floatValue());
Utility.createCalibrationFile(nb_capt, actif, pos, alpha, alpha0, beta, beta0, seuilMin, seuilMax);
```
La méthode “"​deleteReturnStatusFile​” permet de supprimer le fichier avant l’exécution du binaire
fortran, pour être sur que le fichier "return_status.dat" récupéré par la suite dans le script de
vérification R soit bien celui généré lors de la derniere execution d’ESPAS.
Elle devra être appelé à la ligne 250 de la méthode “​PotentielsPanel​” de la classe
“​PotentielsPanel​” dans le fichier “src/wind/ihm/PotentielsPanel.java” comme ci-joint:
```
Utility.deleteReturnStatusFile();
```
La méthode “​createReturnStatusFile​” prend en argument un ​int exitValue ​contenant la valeur du
return satuts du binaire fortran. Elle sera donc appelé juste après la fin de l'exécution du
binaire. La méthode sera appelé à la ligne 285 de la méthode “​lancerTraitement​” de la classe
“​Traitement​” dans le fichier “src/wind/Traitement.java” comme ci-joint:
```
Utility.createReturnStatusFile(exitValue);
```
Après ses modification du code java de l'application ESPAS, celui-ci ne recevra plus aucune
modification dans ce document.
De plus nous avons un fichier de sortie dans l’application ESPAS nous donnant les valeurs
observées mais pas avec le même format que celui récupéré dans VSoil (.csv).
Il faudra donc créer un fichier avec cette fois-ci le bon format. Le nouveau fichier de sortie
s'appellera: “​observ_value_espas.csv​”. Celui-ci sera créé dans la subroutine “​observ​” (ligne 2966)
dans le code fortran nomé par défaut “​windnewSansNagGNU_5f​”, il suffira de remplacer cette
subroutine par le code suivant:
```
c ***************************************************************
subroutine observ(nob1,y1)
c ***************************************************************
c
c recherche des sequences pour lesquelles au moins nbactif tensiometres
c sont actifs
c calcul du vecteur des humidites volumiques moyennes observees
c pour les sequences ou au moins nbactif tensiometres sont actifs
c
c sorties:
c nob1:nombre d'observations pour l'estimation h(teta)
c y1:vecteur des humidites volumiques moyennes de la colonne
c observees
c
implicit double precision (a-h,o-z)
c
include 'comwindnew.inc'
c
dimension y1(10000)
c
c initialisations
j=
nlast=nfirst+nreel-
row=1000.d
pi=3.1415d
c
c calcul de la densite seche du sol
volume=(pi*(diam**2)/4.d0)*zmax
c print *,'diam= ',diam,' zmax= ',zmax,' xmasse= ',xmasse


ros=xmasse/volume
gamad=ros/row
c print *,'gamad',gamad
c
c print *, 'nfirst',nfirst,', nlast=',nlast
open (unit = 84, file='observ_value_espas.csv', action = 'write')
write(84, *) 'time ; value'
c boucle sur les sequences a considerer
do 10 iseq=nfirst,nlast
c test sur le caractere actif de la sequence
if(ntactif(iseq).ge.nbactif)then
c la sequence est active
j=j+
c print*,'la sequence est active ',iseq
xmw=xmashum(iseq)-xmasse
c print *,'xmw= ', xmw,' xmashum = ', xmashum(iseq)
c print *,' iseq = ',iseq, 'xmasse =',xmasse
w=xmw/xmasse
c print *,'w= ',w
teta=w*gamad
c print *,'teta = ',teta
y1(j)=teta
cprint *,'j= ',j,'teta=',y1(j)
write(84,*) temps(j)*3600,';',y1(j)
c else
c print*,'NON ACTIVE la sequence',iseq
endif
10 continue
c
nob1=j
close (84)
c
c test sur le nombre de donnees utilisables
if(nob1.lt.ntest)then
write(*,*)' '
write(*,*)'********** WARNING **********'
write(*,*)'subroutine observ'
write(*,*) nob1,' moisture points were calculated whereas'
write(*,*) ntest,' points are required for the ',
& 'h(theta) fitting.'
write(*,*)'Increase the time interval for processing or',
& ' decrease'
write(*,*)'the Minimal # of valid time steps in the'
write(*,*)'General Parameters Panel !'
write(*,*)'********** End of the program'
stop
endif
c
c 1000 format(1x,f12.1,';',f8.4)


c
return
end
```
Une fois ceci étant fait, il faut compiler à nouveau le code fortran via l’aide de la commande
“​gfortran windnewSansNagGNU_5f​” ou “​f77 windnewSansNagGNU_5f​”, le fichier
“​windnewSansNagGNU_5f​” étant le fichier où se trouve le code modifié de fortran.
La partie des prérequis est fin, aucune modification supplémentaire ne sera appliqué au
codes des deux applications ESPAS et VSoil.


**1.Vérification des deux répertoires:**
Il faut tout d’abord vérifier que l’utilisateur a bien donné deux paramètre au programme. Si
cela n’est pas le cas, le programme se stop.
Vérifier que les deux chemins donnés en paramètre soient valides.
**1.1.VSoil** ​: Le premier argument étant le répertoire où s’est déroulé la simulation de VSoil, il
faut récupérer tous les chemins des fichiers à vérifier en fonction de celui-ci.
**1.1.1.VSoil Entrées**
Dans le répertoire de VSoil (premier argument) se trouve le fichier
“run_info/vsoil_model_init_data.xml” où sont notés en partie tous les fichiers et
paramètres utilisés dans le module de VSoil. Il faut tout d'abord vérifier l’existance du
fichier .xml puis vérifier que les chemins des fichiers suivant notés dans le .xml soient
valides. Le chemin du .xml est trouvé grâce au premier argument (exemple: $ARG
+“run_info/vsoil_model_init_data.xml” ).
Vérification de la présence des fichiers:

- “un_info/vsoil_model_init_data.xml”
- “calibration_*.dat” ​(noté dans le .xml) Obtenable avec: `module[@name='espace_ret'],
layer[@id=1], parameter[@name='path_wind_ter']`
- “masse_*.dat” ​(noté dans le .xml) Obtenable avec: `module[@name='espace_ret'], layer[@id=1],
parameter[@name='path_wind_calibartion']`
- “*.ter” ​(noté dans le .xml) Obtenable avec: `module[@name='espace_ret'], layer[@id=1],
parameter[@name='path_wind_mass_settings’]`
Si un de ces fichiers n’est pas présent, l’afficher dans le terminal puis stopper le
script.

**1.1.2.VSoil Sorties**
Pour la vérification de la présence des fichiers de sortie de VSoil, tous les fichiers
listés ci-dessous sont trouvés en fonction du répertoire de VSoil (premier argument)
donné par l’utilisateur (exemple: $ARG1 +“matrix_potential.csv”).
Vérification de la présence des fichiers:
- “matrix_potential.csv”
- “observ_value.csv”
- “run_info/vsoil_exit_status.txt”
- “run_info/vsoil_progression.txt”
Vérification du return status de l’aplication VSoil présent dans le fichier
“run_info/vsoil_exit_status.txt” soit bien 0 (aucune erreur).
Vérification que de la progression de l’aplication VSoil présent dans le fichier
“run_info/vsoil_progression.txt” soit bien 100% (fini).
Si un de ces fichiers n’est pas présent ou que le return status/la progression n’est
pas valide, l’afficher dans le terminal puis stopper le script.


**1.2.ESPAS** ​: Le second argument étant le répertoire où se situe l’application ESPAS, il faut
vérifier que tous les chemins des fichiers en fonction du répertoire donné par l’utilisateur
soient présent (exemple: $ARG2 +“lib/calibration_espas.dat”).
**1.2.1.ESPAS Entrées**
Vérification de la présence des fichers:

- “Example/Wind_sdec/Wind_sdec.ter”
- “lib/calibration_espas.dat”
- “lib/masse_espas.dat”
Si un de ces fichiers n’est pas présent, l’afficher dans le terminal puis stopper le
script.

**1.2.2.ESPAS Sorties**
Vérification de la présence des fichers:
- “lib/espas_potential.csv”
- “lib/return_status.dat”
- “lib/observ_value.csv”
Vérification du return status du binaire lancé par ESPAS présent dans le fichier
“lib/return_status.dat” soit bien “0” (aucune erreur). Si celui-ci contient “0” cela veut
dire que le programme s’est bien fini, sinon cela veut dire qu’il y a une erreur.
Si un de ces fichiers ne contient pas “0”, l’afficher dans le terminal puis stopper le
script.


**2.Validation des données d'entrées:**
En théorie l’écart doit être nul entre les données d'entrées d’ESPAS et les données
d'entrées de VSoil (étant donné que les paramètres saisis sont les mêmes). Cependant il se
peut que lors de l’écriture d’un fichier d’entré venant d’ESPAS le code java fasse un mauvais
arrondi des décimal (Exemple 1.00399 au lieu de 1.00400). Il faudra prendre en compte ce
possible mauvais arrondi et donc prévoir un epsilon très faible: epsilon = 10^(-6).
**2.1.Validation du .ter:** ​ 
Présent dans les deux applications (“*.ter”).
Les deux fichier étant à priori les mêmes (les applications ESPAS et VSoil demande le
même format pour le .ter). Il suffira d’ouvrir les deux fichiers et de comparer valeur par valeur
la validité de celle-ci.
Comparer les fichier les deux “.ter” avec les critères suivant:

- Vérifier le même nombre de colonnes et de lignes.
- Vérifier valeurs identiques avec aucun écart accepté (Diff entre les deux .ter).
Si les deux colonnes sont différents: afficher un graphique montrant les deux jeux de valeurs
en fonction du temps puis stopper le script.

**2.2.Validation des données de calibration:** ​ 
Présent dans les deux applications
(VSoil:“calibration_*.dat”, ESPAS: “lib/calibration_espas.dat”).
Le format des deux fichier à vérifier est identique. La méthode pour vérifier la validité du
fichier sera la même que celle employé pour vérifier les deux “.ter”.
Comparer les fichier “calibration_*.dat” et “lib/calibration_espas.dat” avec les critères suivant:
- Vérifier le même nombre de colonnes et de lignes.
- Vérifier valeurs identiques avec aucun écart accepté.
Si les deux colonnes sont différents: afficher un graphique montrant les deux jeux de valeurs
en fonction du temps puis stopper le script.

**2.3.Validation des données de masse et de diamètre:** ​ 
Présent dans les deux applications
(VSoil: “masse_*.dat”, ESPAS: “lib/masse_espas.dat”).
Le format des deux fichier à vérifier est identique, ce qui simplifie la tâche pour les
comparer.
Ces deux fichiers où se trouvent toutes les informations sur les dimensions et les masses de
l’échantillons contient de nombreuses lignes de commentaires. Lors de la vérification de ses
données, de nombreuses lignes vont être ignoré (deux lignes sur trois seront “sauté”) dans
les deux fichiers. De plus les 10 premières lignes ne nous sont d’aucun intérêt, la vérification
des valeur commencera donc à la ligne 11.
Comparer les fichier “masse_*.dat” et “lib/masse_espas.dat” avec le critère suivant:
- Vérifier valeurs identiques avec aucun écart accepté.


Si les deux valeurs sont différents: afficher les deux valeurs dans le terminal puis stopper le
script.
**3.Vérification des données de sorties:**
L’écart doit être minime entre les données d'entrées d’ESPAS et les données de sorties de
VSoil.
**3.1.Potentiels matriciels:** ​ Présent dans les deux applications (ESPAS:
“lib/espas_potential.csv”, VSoil: “matrix_potential.csv”)
Les deux fichier “espas_potential.csv” et “matrix_potential.csv” ont le même format, ils
contiennent tous les deux une première colonne où est noté le temps de la séquence puis X
colonnes correspondant aux X capteurs actifs. Il suffira donc d’ouvrir les deux fichiers et de
comparer les valeurs une à une.
Ces deux fichiers devront être identique, nous n’accepterons qu’un léger écart entre les
valeurs attendus et les valeurs de VSoil.

Comparer les fichier “espas_potential.csv” et “matrix_potential.csv” avec les critères suivant:

- Même longueurs de colonnes et de lignes.
- Même valeurs à un epsilon près (Diff entre les deux fichier).
- epsilon = 10^(-4)
Si les deux colonnes diffèrent: afficher un graphique montrant les deux jeux de valeurs en
fonction du temps puis stopper le script. 

**3.2.Observ_value:** ​ Présent dans les deux applications (ESPAS: “observ_value.csv”, VSoil:
“observ_value.csv”)
Les deux fichiers ont exactement le même format, il est donc facile de les comparer.
Le fichier “observ_value.csv” contient deux colonnes: temps et la valeur au temps donné. Il
suffira de comparer les fichiers avec les critères suivant:
- Même longueurs de colonnes (deux colonnes) et de lignes.
- Même valeurs à un epsilon près (Diff entre les deux fichier).
Si les deux colonnes diffèrent: afficher un graphique montrant les deux jeux de valeurs en
fonction du temps puis stopper le script.


**4.Conclusion:**
Si aucune erreur/incohérence n’est trouvé dans l’application VSoil, le script se termine
naturellement (return status: 0) en affichant que la vérification s’est bien déroulé et que
l’application VSoil donne est résultat juste pour ce jeu de données.


