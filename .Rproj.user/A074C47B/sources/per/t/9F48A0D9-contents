if(!require("readxl")){install.packages("readxl")} ; library("readxl")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")

# Permet de charger un tableay en attribuant un nom 
load_data <- function(data_name, 
                      path, 
                      sep = ";", 
                      header = TRUE) {
  # Vérifiez si l'objet 'data_name' existe déjà
  if (!exists(data_name,envir = .GlobalEnv)) {
    # Si l'objet n'existe pas, chargez les données
    assign(data_name, read.csv(path, sep = sep, header = header), envir = .GlobalEnv)
  }
}


###################Passe le CD_NOM en CD_REF
updatetaxa = function(liste_cd_nom){
  load_data("taxadata","data/TAXREF_17/TAXREFv17_FLORE_FR_SYN.csv",sep=",")
  liste_cd_nom = data.frame("CD_NOM" = liste_cd_nom)
  liste_cd_nom_join = left_join(liste_cd_nom,taxadata,by="CD_NOM") %>% select(CD_REF)
  CD_NOM_actuel = liste_cd_nom_join$CD_REF
  return(CD_NOM_actuel)
}


###################Renvoie le CD_NOM actualisé à partir d'une liste d'espèce
findtaxa = function(listetaxa,
                    referenciel = "TAXREF_70",
                    correspondance_type = "simple",
                    actualisation_CD_NOM = TRUE){
 
   if(referenciel == "TAXREF_70"){
     load_data("taxadata","data/TAXREF_17/TAXREFv17_FLORE_FR.csv",sep=",")
   }
  if(correspondance_type=="simple"){
    listetaxa = data.frame("LB_NOM" = listetaxa)
    listetaxa_join = left_join(listetaxa,taxadata,by="LB_NOM")
    CD_NOM = listetaxa_join$CD_NOM
    
    #Actualisation du CD_NOM
    if(actualisation_CD_NOM == TRUE){
      CD_NOM = updatetaxa(CD_NOM)      
    }
    return(CD_NOM)
  }
}

######################        A FINIRRR           ###############################"
############################################################   find_taxaref 
#############Réalise un match entre 2 référentiels taxonomiques

find_taxaref <- function(code_taxa_entre,lb_taxa_entre,code_taxa_sortie,lb_taxa_sortie){
  # Utilisation de str_split avec un motif pour diviser le texte
  entre = data.frame(code_taxa_entre = code_taxa_entre,lb_taxa_entre = lb_taxa_entre)
  sortie = data.frame(code_taxa_sortie = code_taxa_sortie,lb_taxa_sortie = lb_taxa_sortie)
  
  #mettre une boucle for pour répéter pour chaque espèce
  # S'imsprirer de l'algorithme de décision dans catminat.R (celui qui sera justement remplacé)
  texte_split <- strsplit(sortie$code_taxa_sortie, " ")[[1]]  # Utilisation de [[1]] pour extraire le vecteur de chaînes
  
  # Ajouter '.*' à chaque élément de texte_split
  texte_split <- paste0(texte_split, '.*')
  
  # Combiner les éléments de texte_split en une seule chaîne de caractères
  texte_pour_grep <- paste(texte_split, collapse = "")
  
  # Utilisation de grep pour trouver les correspondances dans la base de données
  resultats_grep <- sortie[grep(texte_pour_grep, sortie$lb_taxa_sortie, 
                                   ignore.case = TRUE)
                              , ]
  resultats_hab = resultats_grep %>% select(NOM_CITE,LB_CODE,LB_HAB_FR)
  
  return(resultats_hab)
}
###############################################################################
