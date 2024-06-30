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

find_taxaref <- function(code_taxa_entre,
                         lb_taxa_entre,
                         code_taxa_sortie,
                         lb_taxa_sortie
                         ){

  entre = data.frame(code_taxa_entre = code_taxa_entre,lb_taxa_entre = lb_taxa_entre)
  sortie = data.frame(code_taxa_sortie = code_taxa_sortie,lb_taxa_sortie = lb_taxa_sortie)
  
  for (i in 1:nrow(baseflor_bryo)){
    cat(i,"\n")
    reference = FALSE # Remise de  reference en faux
    tryCatch({
      
      # Utilisation de str_split avec un motif pour diviser le texte
      texte_split <- strsplit(sortie$code_taxa_sortie, " ")[[1]]  # Utilisation de [[1]] pour extraire le vecteur de chaînes
      
      # Ajouter '.*' à chaque élément de texte_split
      texte_split <- paste0(texte_split, '.*')
      
      # Combiner les éléments de texte_split en une seule chaîne de caractères
      texte_pour_grep <- paste(texte_split, collapse = "")
      
      # Utilisation de grep pour trouver les correspondances dans la base de données
      resultats_grep <- entre[grep(texte_pour_grep, entre$lb_taxa_entre, 
                                    ignore.case = TRUE)
                               , ]
      resultats_hab = resultats_grep %>% select(NOM_CITE,LB_CODE,LB_HAB_FR)
      
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
  


  
  return(XXXXXXXXXXXXXXXX)
}
###############################################################################
