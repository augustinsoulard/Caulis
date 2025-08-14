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
  TAXREFv17_FLORE_FR_SYN = dbGetQuery(con, "SELECT * FROM public.taxref_flore_fr_syn")
  TAXREFv17_FLORE_FR_SYN$cd_nom = as.character(TAXREFv17_FLORE_FR_SYN$cd_nom)
  liste_cd_nom = data.frame("cd_nom" = as.character(liste_cd_nom))
  liste_cd_nom_join = left_join(liste_cd_nom,TAXREFv17_FLORE_FR_SYN,by="cd_nom") %>% dplyr::select(cd_ref)
  CD_NOM_actuel = liste_cd_nom_join$cd_ref
  return(CD_NOM_actuel)
}


################### DANS CAULISOOT MAIS A TRAITER
findtaxa <- function(listetaxa,
                     data = NULL,
                     referenciel = "taxref",
                     actualisation_cd_nom = TRUE,
                     cd_nom_type="character") {
  
  # Vérifier que listetaxa est un nom de colonne unique
  if (!is.character(listetaxa) || length(listetaxa) != 1) {
    stop("'listetaxa' doit être un nom de colonne (une seule chaîne de caractères).")
  }
  
  # Charger le référentiel
  if (referenciel == "taxref") {
    taxref <- dbGetQuery(con, "SELECT * FROM public.taxref_flore_fr_syn")
  } else {
    stop("Seul le référentiel 'taxref' est pris en charge.")
  }
  
  # Déterminer si l'entrée est un vecteur ou une colonne dans un data.frame fourni
  if (is.null(data)) {
    # Cas d'un vecteur simple
    data <- data.frame(lb_nom = listetaxa, stringsAsFactors = FALSE)
    input_type <- "vector"
  } else {
    # Cas d'un data.frame
    if (!is.data.frame(data)) {
      stop("'data' doit être un data.frame.")
    }
    if (!(listetaxa %in% names(data))) {
      stop(paste0("La colonne '", listetaxa, "' est absente du data.frame fourni."))
    }
    data <- dplyr::rename(data, lb_nom = !!listetaxa)
    input_type <- "dataframe"
  }
  
  # Jointure
  listetaxa_join <- dplyr::left_join(data, taxref, by = "lb_nom", relationship = "many-to-many")
  
  # Actualisation cd_nom si demandé
  if (actualisation_cd_nom) {
    listetaxa_join$cd_nom <- updatetaxa(listetaxa_join$cd_nom)
  }
  
  #choix du type
  listetaxa_join$cd_nom <- switch(cd_nom_type,
                                  character = as.character(listetaxa_join$cd_nom),
                                  integer   = as.integer(listetaxa_join$cd_nom))
  
  # Résultat selon type d'entrée
  if (input_type == "vector") {
    return(listetaxa_join$cd_nom)
  } else {
    return(listetaxa_join)
  }
}


majuscule_hors_premier_mot <- function(chaine) {
  # Si " x " est présent, on ne modifie rien
  if (grepl(" x ", chaine)) {
    return(chaine)
  }
  
  # Sinon, on garde le premier mot, puis on enlève les suivants s'ils commencent par une majuscule
  mots <- unlist(strsplit(chaine, " "))
  if (length(mots) <= 1) return(chaine)
  
  premier <- mots[1]
  reste <- mots[-1]
  
  # Supprime les mots en majuscule dans le reste
  reste_filtré <- reste[!grepl("^[A-Z]", reste)]
  
  return(paste(c(premier, reste_filtré), collapse = " "))
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
  entree$lb_taxa_entree = sapply(entree$lb_taxa_entree, majuscule_hors_premier_mot)# retirer les mot avec majuscule hor spremier mot ou hybrides
  entree$lb_taxa_entree = gsub("[^[:alnum:] ]", "", entree$lb_taxa_entree)
  entree$lb_taxa_entree = gsub("[[:space:]]+$", "", entree$lb_taxa_entree)
  entree$lb_taxa_entree <- sapply(entree$lb_taxa_entree, function(x) {
    # Si la chaîne contient " subsp", " var", ou " f", on ne modifie pas
    if (grepl(" subsp| var| f", x)) {
      return(x)
    } else if (grepl(" x ", x)) {
      # Si la chaîne contient " x ", on garde les trois premiers mots
      mots <- strsplit(x, " ")[[1]]
      return(paste(mots[1:min(3, length(mots))], collapse = " "))
    } else {
      # Sinon, on garde les deux premiers mots
      mots <- strsplit(x, " ")[[1]]
      return(paste(mots[1:min(2, length(mots))], collapse = " "))
    }
  }) #ENCORE A VERIFIER
  
  
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
  
  if(input_ref=="baseflor"){
    taxref$lb_nom = taxref$lb_nom %>% 
      str_replace(' subsp.',' subsp') %>% 
      str_replace(' var.',' var') %>%
      str_replace(' f.',' f')
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

