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
  load_data("TAXREFv17_FLORE_FR_SYN","data/TAXREF_17/TAXREFv17_FLORE_FR_SYN.csv",sep=",")
  TAXREFv17_FLORE_FR_SYN$CD_NOM = as.character(TAXREFv17_FLORE_FR_SYN$CD_NOM)
  liste_cd_nom = as.character(liste_cd_nom)
  liste_cd_nom = data.frame("CD_NOM" = liste_cd_nom)
  liste_cd_nom_join = left_join(liste_cd_nom,TAXREFv17_FLORE_FR_SYN,by="CD_NOM") %>% select(CD_REF)
  CD_NOM_actuel = liste_cd_nom_join$CD_REF
  return(CD_NOM_actuel)
}


###################Renvoie le CD_NOM actualisé à partir d'une liste d'espèce
findtaxa = function(listetaxa,
                    referenciel = "taxref",
                    correspondance_type = "simple",
                    actualisation_CD_NOM = TRUE){
 
   if(referenciel == "taxref"){
     
     taxref = dbGetQuery(con, "SELECT * FROM public.taxref_flore_fr_syn")
     
   }
  if(correspondance_type=="simple"){
    listetaxa = data.frame("LB_NOM" = listetaxa)
    listetaxa_join = left_join(listetaxa,taxadata,by="LB_NOM")
    CD_NOM = listetaxa_join$CD_NOM
    }
    return(CD_NOM)
}

############################################################   find_taxaref 
# Réalise un match entre 2 référentiels taxonomiques

find_taxaref <- function(
                         lb_taxa_entree,
                         code_taxa_entree = NA, 
                         ref='taxref',
                         input_ref="inaturalist"
){
  entree = data.frame(code_taxa_entree = code_taxa_entree,lb_taxa_entree = lb_taxa_entree)

  if(ref == 'taxref'){
    taxref = dbGetQuery(con, "SELECT * FROM public.taxref_flore_fr_syn")
  }

  #Préparation du tableau entree
  entree <- entree %>%
    mutate(cd_nom = NA_character_)
  entree <- entree %>%
    mutate(lb_nom = NA_character_)
  entree <- entree %>%
    mutate(rang = NA_character_)
  
  # Correction des adjectifs de rangs
  entree$lb_taxa_entree = str_replace(entree$lb_taxa_entree,'ssp.','subsp.')
  
  # Supprimer les mots entre parenthèses
  entree$lb_taxa_entree = gsub("\\(.*?\\)", "", entree$lb_taxa_entree)
  entree$lb_taxa_entree = gsub("\\b(?!subsp\\.|var\\.)\\w+\\.", "", entree$lb_taxa_entree, perl=TRUE)
  entree$lb_taxa_entree = gsub("\\s+", " ", entree$lb_taxa_entree)
  
  
  # Ajoute une colonne de RANG au tableau entree
  for(i in 1:nrow(entree)){
    cat('rang : ',i,'/',nrow(entree),'\n')
    if(str_detect(entree$lb_taxa_entree[i],'subsp.')){
      entree$rang[i] = 'SSES'
    }
    else if(str_detect(entree$lb_taxa_entree[i],'var.')){
      entree$rang[i] = 'VAR'
    }
    else{entree$rang[i] = 'ES'}
  }
  
  # Dénition des colonnes cd_nom et lb_nom par défaut
  entree$cd_nom = '_NOMATCH'
  entree$lb_nom = '_NOMATCH'
  
  # Retirer les marqueurs d'infrataxons pour la correspondance avec Inaturalist
  if(input_ref=="inaturalist"){
    taxref$lb_nom = taxref$lb_nom %>% 
    str_replace(' subsp.','') %>% 
    str_replace(' var.','') %>%
    str_replace(' f.','')
  }
  
  
  for (i in 1:nrow(entree)) {
    cat('CORRESP : ',i,'/',nrow(entree),'\n')

    # Trouver les correspondances
    if(str_detect(entree$lb_taxa_entree[i]," x ")){
      
      taxref_rang = taxref[taxref$rang==entree$rang[i],]
      
    } else {
      taxref_rang = taxref[taxref$rang==entree$rang[i] & !str_detect(taxref$lb_nom," x "),]
    }
    matches <- str_detect(taxref_rang$lb_nom,fixed(entree$lb_taxa_entree[i]))
    
    # Pour Inaturalist tenter de faire une correpsondance des sous-espèces
    if(input_ref=="inaturalist" & !any(matches)){
      taxref_rang = taxref[taxref$rang=="SSES",]
      matches <- str_detect(taxref_rang$lb_nom,fixed(entree$lb_taxa_entree[i]))
    }
    
    # Vérifier les hybrides
    
    if(any(matches)){
      lb_nom = taxref_rang[matches==TRUE,]$lb_nom
      cd_nom = taxref_rang[matches==TRUE,]$cd_nom
      
     # Mettre à jour la colonne CD_NOM pour les correspondances trouvées
      entree$cd_nom[i] <- cd_nom
      entree$lb_nom[i] <- lb_nom
    }

  }
  #Mise à jour du code CD_REF
  entree$cd_ref = updatetaxa(entree$cd_nom)
  
  return(entree)
}
