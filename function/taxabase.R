if(!require("readxl")){install.packages("readxl")} ; library("readxl")
if(!require("readODS")){install.packages("readODS")} ; library("readODS")
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
  taxadata$CD_NOM = as.character(taxadata$CD_NOM)
  liste_cd_nom = as.character(liste_cd_nom)
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

############################################################   find_taxaref 
#############Réalise un match entre 2 référentiels taxonomiques

find_taxaref <- function(
                         lb_taxa_entree,code_taxa_entree = NA, ref='taxref'
){
  entree = data.frame(code_taxa_entree = code_taxa_entree,lb_taxa_entree = lb_taxa_entree)

  if(ref == 'taxref'){
    load_data("taxref","data/TAXREF_17/TAXREFv17_FLORE_FR_SYN.csv",sep=",")
    taxaref = taxref
  }

  #Préparation du tableau entree
  entree <- entree %>%
    mutate(CD_NOM = NA_character_)
  entree <- entree %>%
    mutate(LB_NOM = NA_character_)
  entree <- entree %>%
    mutate(RANG = NA_character_)
  
  # Correction des adjectifs de rangs
  entree$lb_taxa_entree = str_replace(entree$lb_taxa_entree,'ssp.','subsp.')
  
  # Supprimer les mots entre parenthèses
  entree$lb_taxa_entree = gsub("\\(.*?\\)", "", entree$lb_taxa_entree)
  entree$lb_taxa_entree = gsub("\\b(?!subsp\\.|var\\.)\\w+\\.", "", entree$lb_taxa_entree, perl=TRUE)
  entree$lb_taxa_entree = gsub("\\s+", " ", entree$lb_taxa_entree)
  
  # Ajoute une colonne de RANG au tableau entree
  for(i in 1:nrow(entree)){
    if(str_detect(entree$lb_taxa_entree[i],'subsp.')){
      entree$RANG[i] = 'SSES'
    }
    else if(str_detect(entree$lb_taxa_entree[i],'var.')){
      entree$RANG[i] = 'VAR'
    }
    else{entree$RANG[i] = 'ES'}
  }
  
  
  for (i in 1:nrow(taxaref)) {
    cat(i,'/',nrow(taxadata),'\n')
    lb_nom <- taxaref$LB_NOM[i]
    cd_nom <- taxaref$CD_NOM[i]
    
    # Trouver les correspondances
    matches <- str_detect(entree[entree$RANG == taxadata$RANG[i],]$lb_taxa_entree, fixed(lb_nom))
    
    # Mettre à jour la colonne CD_NOM pour les correspondances trouvées
    entree[entree$RANG == taxadata$RANG[i],]$CD_NOM[matches] <- cd_nom
    entree[entree$RANG == taxadata$RANG[i],]$LB_NOM[matches] <- lb_nom
  }
  entree[is.na(entree$CD_NOM),]$CD_NOM = '_NOMATCH'
  entree[is.na(entree$LB_NOM),]$LB_NOM = '_NOMATCH'
  
  #Mise à jour du code CD_REF
  entree$CD_REF = updatetaxa(entree$CD_NOM)
  
  return(entree)
}


