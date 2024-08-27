# Charger les bibliotheques necessaires
if(!require("readxl")){install.packages("readxl")} ; library("readxl")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")
if(!require("sf")){install.packages("sf")} ; library("sf")
source("function/taxabase.R")



# FCD_TYPO = 28 # PVF2
############################################################   taxon_hab    
taxon_hab = function(FCD_TYPO = "28"){
  
  load_data("TYPOREF_70", "data/HABREF_70/TYPOREF_70.csv")
  load_data("HABREF_70", "data/HABREF_70/HABREF_70.csv")
  load_data("HABREF_CORRESP_TAXON_70","data/HABREF_70/HABREF_CORRESP_TAXON_70.csv")
  
  typo = HABREF_70 %>% filter(CD_TYPO %in% FCD_TYPO)
  
  
  typo_taxa = left_join(typo,HABREF_CORRESP_TAXON_70,by=c("CD_HAB"="CD_HAB_ENTRE"))
  return(typo_taxa)
}
###############################################################################


############################################################   find_taxon_hab    
find_taxon_hab <- function(taxa_search,
                           colomn_name = "NOM_CITE",
                           colomn_name2 = "NOM_CITE_MATCH",
                           FCD_TYPO = 28){
  typo_taxa = taxon_hab(FCD_TYPO = FCD_TYPO)
  # Utilisation de str_split avec un motif pour diviser le texte
  texte_split <- strsplit(taxa_search, " ")[[1]]  # Utilisation de [[1]] pour extraire le vecteur de chaînes
  
  # Ajouter '.*' à chaque élément de texte_split
  texte_split <- paste0(texte_split, '.*')
  
  # Combiner les éléments de texte_split en une seule chaîne de caractères
  texte_pour_grep <- paste(texte_split, collapse = "")
  
  # Utilisation de grep pour trouver les correspondances dans la base de données
  resultats_grep <- typo_taxa[grep(texte_pour_grep, typo_taxa$NOM_CITE,
                                   paste0(typo_taxa$NOM_CITE," ",typo_taxa$NOM_CITE_MATCH), 
                                   ignore.case = TRUE)
                              , ]
  resultats_hab = resultats_grep %>% select(NOM_CITE,LB_CODE,LB_HAB_FR)
  
  return(resultats_hab)
}
###############################################################################

########################################################## hab_join
hab_join = function(liste_CD_HAB,
                    FCD_TYPO=28){
  
  load_data("HABREF_CORRESP_HAB_70", "data/HABREF_70/HABREF_CORRESP_HAB_70.csv")
  load_data("HABREF_70", "data/HABREF_70/HABREF_70.csv")
  data_CD_HAB = data.frame(CD_HAB_ENTRE = liste_CD_HAB)
  
  # if(FCD_TYPO!=107){
  #   CORRESP107 = HABREF_CORRESP_HAB_70 %>% 
  #     filter(CD_TYPO_ENTRE == FCD_TYPO & CD_TYPO_SORTIE == 107) %>% 
  #     select(CD_HAB_ENTRE,CD_HAB_107 = CD_HAB_SORTIE)
  # }
  
  if(FCD_TYPO!=7){
    CORRESP7 = HABREF_CORRESP_HAB_70 %>% 
      filter(CD_TYPO_ENTRE == FCD_TYPO & CD_TYPO_SORTIE == 7) %>%
      select(CD_HAB_ENTRE,CD_HAB_7 = CD_HAB_SORTIE)
    data_CD_HAB=left_join(data_CD_HAB,CORRESP7,by="CD_HAB_ENTRE")
    join7 = HABREF_70 %>% select(CD_HAB,CD_EUNIS12 = LB_CODE,LB_EUNIS12 = LB_HAB_FR)
    data_CD_HAB = left_join(data_CD_HAB,join7,by=c("CD_HAB_7"="CD_HAB"))
  }
  
  if(FCD_TYPO!=8){
    CORRESP8 = HABREF_CORRESP_HAB_70 %>% 
      filter(CD_TYPO_ENTRE == FCD_TYPO & CD_TYPO_SORTIE == 8) %>%
      select(CD_HAB_ENTRE,CD_HAB_8 = CD_HAB_SORTIE)
    data_CD_HAB=left_join(data_CD_HAB,CORRESP8,by="CD_HAB_ENTRE")
    join8 = HABREF_70 %>% select(CD_HAB,CD_HIC = LB_CODE,LB_HIC = LB_HAB_FR)
    data_CD_HAB = left_join(data_CD_HAB,join8,by=c("CD_HAB_8"="CD_HAB"))
  }
  
  if(FCD_TYPO!=22){
    CORRESP22 = HABREF_CORRESP_HAB_70 %>% 
      filter(CD_TYPO_ENTRE == FCD_TYPO & CD_TYPO_SORTIE == 22) %>%
      select(CD_HAB_ENTRE,CD_HAB_22 = CD_HAB_SORTIE)
    data_CD_HAB=left_join(data_CD_HAB,CORRESP22,by="CD_HAB_ENTRE")
    join22 = HABREF_70 %>% select(CD_HAB,CD_CB = LB_CODE,LB_CB = LB_HAB_FR)
    data_CD_HAB = left_join(data_CD_HAB,join22,by=c("CD_HAB_22"="CD_HAB"))
  }
  
  return(data_CD_HAB)
}
########################################################## 


############################################################   hab_match
# Nécessite d'avoir chargé un tableau de correspondance habitats - taxons avec la fonction taxon_hab
hab_match = function(data_flore,
                     dataflore_type = "kit_bota",
                     flore_path = "Flore/Flore.shp",
                     groupe_type = "hab",
                     FCD_TYPO = 28, #Typologie d'habitats 28 = PVF2, 107 = EUNIS 202
                     seuil = 2 # Nombre d'espèce correspondante par groupe d'analyse
){
  # utiliser les chemins du kit_bota Qfield
  if(dataflore_type == "kit_bota"){
    data_flore = st_read("Flore/Flore.shp")
    data_flore$CD_NOM = findtaxa(data_flore$lb_nom)
  }
  if(groupe_type == "hab"){
    data_hab = st_read("Habitats/HABITATS_POLYGONES.shp")
    data_hab$habid = paste0(data_hab$hablabel,"_",1:nrow(data_hab))
  }
  
  
  intersection_habflore = st_intersection(data_hab,data_flore)
  intersection_habflore = intersection_habflore %>% select(CD_NOM,LB_NOM = lb_nom,HABLABEL = hablabel,habid,geometry)
  
  #Chargement du référentiel
  TYPO_HAB = taxon_hab(FCD_TYPO = FCD_TYPO)
  #boucle de mise en interaction flore/habitats
  init = 0
  for(i in 1:nrow(data_hab)){
    floreturn = intersection_habflore %>% filter(habid == data_hab$habid[i])
    if(nrow(floreturn)>0){
      floreturn$count = 1
      floreturn = left_join(floreturn,TYPO_HAB,by="CD_NOM") %>% select(habid,CD_NOM,CD_HAB,LB_CODE,LB_HAB_FR,count) %>%
        filter(!is.na(CD_HAB))
      if(nrow(floreturn)>0){
        agg = aggregate(count~CD_HAB,data = floreturn,FUN=sum) %>% 
          arrange(desc(count)) %>% filter(count >= seuil)
        floreturnAGG = floreturn %>% select(habid,CD_HAB,LB_CODE,LB_HAB_FR)
        if(init == 0){
          init = 1
          habmatch = right_join(floreturnAGG,agg,by="CD_HAB")
        }else{  habmatch = rbind(habmatch,right_join(floreturnAGG,agg,by="CD_HAB"))}
      }
    }
    
  }
  habjoin = hab_join(habmatch$CD_HAB,FCD_TYPO = 28)
  habmatch = left_join(habmatch,habjoin,by=c("CD_HAB"="CD_HAB_ENTRE"))
  
  return(habmatch)
  
  
}
###################################################### contingFclipboard
#lecture de tableau de contingence pour des relevés phytosociologiques
contingFclipboard = function(){
  tabContingenceCLIP = read.delim("clipboard", header = TRUE)
  tabContingenceCLIP = tabContingenceCLIP[rowSums(tabContingenceCLIP[,-1])>0,]
  return(tabContingenceCLIP)
}
