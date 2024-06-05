# Definition du repertoire de fichiers
WD = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(WD)

# Charger les bibliotheques necessaires
if(!require("readxl")){install.packages("readxl")} ; library("readxl")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")



HABREF_70 <- read.csv("../HABREF_70.csv", sep=";")
HABREF_CORRESP_HAB_70 <- read.csv("../HABREF_CORRESP_HAB_70.csv", sep=";")
HABREF_CORRESP_TAXON_70 <- read.csv("../HABREF_CORRESP_TAXON_70.csv", sep=";")
HABREF_DESCRIPTION_70 <- read.csv("../HABREF_DESCRIPTION_70.csv", sep=";")

# 
PVF2_TAXON = taxon_hab(28)


# Appel de la fonction avec l'exemple "Que ile"
find_taxon_hab("Pol avic",PVF2_TAXON)
