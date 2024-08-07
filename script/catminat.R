#remotes::install_github("Rekyt/rtaxref")
# WEBSITE: https://rekyt.github.io/rtaxref/
# remotes::install_github("Rekyt/rtaxref")
# WEBSITE: https://rekyt.github.io/rtaxref/


# Charger les bibliotheques necessaires
if(!require("readxl")){install.packages("readxl")} ; library("readxl")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")
if(!require("remotes")){install.packages("remotes")} ; library("remotes")
if(!require("rtaxref")){install_github("Rekyt/rtaxref")} ; library("rtaxref")
source("function/taxabase.R")

#Chargement de baseflor
baseflor <- read_excel("data/catminat/baseflor.xlsx")

#Chargement de basebryo
basebryo <- read_excel("data/catminat/basebryo.xlsx")

#Chargement de TAXREF
load_data("TAXREF_17","data/TAXREF_17/TAXREFv17_FLORE_FR_SYN.csv",sep=",")

#Ajustement des noms de colonnes de basebryo
colnames(basebryo)[3] = "code_CATMINAT"
colnames(basebryo)[4] = "NOM_SCIENTIFIQUE"
colnames(basebryo)[5] = "INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE"
colnames(basebryo)[6] = "CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)"
colnames(basebryo)[7] = "INDICATION_DIFFERENTIELLE_1"
colnames(basebryo)[8] = "INDICATION_DIFFERENTIELLE_2"
colnames(basebryo)[10] = "Lichtzahl"
colnames(basebryo)[11] = "Temperaturzahl"
colnames(basebryo)[12] = "Kontinentalitat"
colnames(basebryo)[13] = "Feuchtzahl"
colnames(basebryo)[14] = "Reaktionszahl"
colnames(basebryo)[15] = "TYPE_BIOLOGIQUE"
basebryo["...16"] = NULL

#Ajustement des noms de colonnes de baseflor
colnames(baseflor)[38] = "Kontinentalitat"

#Fusion des 2 tables
common_columns <- intersect(names(baseflor), names(basebryo))
baseflor_bryo = merge(baseflor,basebryo,by=common_columns,all=T)

# Ajustement des rangs taxonomiques

baseflor_bryo$CD_NOM = "0"
baseflor_bryo$NOM_VALIDE = "NULL"

#Simplification des nom scientifique en retirant les auteurs
baseflor_bryo$NOM_SIMPLE = str_split(baseflor_bryo$NOM_SCIENTIFIQUE, "[:blank:][:upper:]",n=2, simplify = TRUE)[,1]
baseflor_bryo$NOM_SIMPLE = str_split(baseflor_bryo$NOM_SIMPLE, "\\(", n = 2, simplify = TRUE)[, 1]
baseflor_bryo$NOM_SIMPLE = str_split(baseflor_bryo$NOM_SIMPLE, "[:blank:]$", n = 2, simplify = TRUE)[, 1]

#Boucle de matching
for (i in 1:nrow(baseflor_bryo)){
  cat(i,"\n")
  reference = FALSE # Remise de  reference en faux
    tryCatch({
      t = rt_taxa_search(sciname = baseflor_bryo$NOM_SIMPLE[i],version = "17.0")
      if(any(t$id != t$referenceId)){
        reference = TRUE # Garder en mémoire que la taxon de base n'est pas celui de référence
      }
      if(ncol(t)>1){
        #Supression des synonymes
        if(nrow(t[t$id==t$referenceId,])>=1){t = t[t$id==t$referenceId,]}
        #Supression des sous-espèces si nécessaire
        if(nrow(t)>=1 & nrow(t[t$rankId=="ES",])>=1){t = t[t$rankId=="ES",]}
        #Supression des hybrides
        if(str_detect(baseflor_bryo$NOM_SIMPLE[i],"[:blank:]x[:blank:]")==FALSE){
          t = t[!str_detect(t$scientificName,"[:blank:]x[:blank:]"),]
        }
        if(reference == TRUE){
          t = rt_taxa_search(id = t$referenceId[1],version = "16.0")
        }
        
        #Attribution des valeurs de CD_NOM et NOM_VALIDE
        baseflor_bryo$CD_NOM[i] = t$referenceId[1]
        baseflor_bryo$NOM_VALIDE[i] = t$scientificName[1]}else{
          baseflor_bryo$CD_NOM[i] = "NOMATCH"
          baseflor_bryo$NOM_VALIDE[i] = "NOMATCH"
        }

  }, error = function(e) {
    baseflor_bryo$CD_NOM[i] = "NOMATCH"
    baseflor_bryo$NOM_VALIDE[i] = "NOMATCH"
  })

}


# Verification des différences
difference = baseflor_bryo[baseflor_bryo$NOM_VALIDE!=baseflor_bryo$NOM_SIMPLE,]
view(difference)

write.csv(baseflor_bryo,"data/catminat/baseflor_bryo.csv",fileEncoding = "UTF-8",row.names = F)
# baseflor_bryo = read.csv("data/catminat/baseflor_bryo.csv",h=T)

######## Prise en compte du correctif de baseflore_bryo
# Chargement du correctif
Correctif_baseflor_bryo <- read_excel("data/catminat/Correctif_baseflor_bryo.xlsx")

#Boucle de correction
for(i in 1:nrow(Correctif_baseflor_bryo)){
  if(nrow(baseflor_bryo[baseflor_bryo$CD_NOM == Correctif_baseflor_bryo$CD_NOM[i],])>=1){
    #remplacement des colonnes pour els epsèces concernées
    baseflor_bryo[baseflor_bryo$CD_NOM == Correctif_baseflor_bryo$CD_NOM[i],]$floraison = Correctif_baseflor_bryo$floraison[i]
    baseflor_bryo[baseflor_bryo$CD_NOM == Correctif_baseflor_bryo$CD_NOM[i],]$CARACTERISATION_ECOLOGIQUE_.HABITAT_OPTIMAL. =
      Correctif_baseflor_bryo$CARACTERISATION_ECOLOGIQUE_.HABITAT_OPTIMAL.[i]
    baseflor_bryo[baseflor_bryo$CD_NOM == Correctif_baseflor_bryo$CD_NOM[i],]$INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE = 
      Correctif_baseflor_bryo$INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE[i]
##############COMPLETERRRRRRR
  }
  
}



# Enregistrer le fichier final
write.csv2(baseflor_bryo,"data/catminat/baseflor_bryoTAXREFv17.csv",row.names = F,fileEncoding = "UTF-8",na="")

