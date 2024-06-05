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
  
  typo = HABREF_70 %>% filter(CD_TYPO == FCD_TYPO)
  
  
  typo_taxa = left_join(typo,HABREF_CORRESP_TAXON_70,by=c("CD_HAB"="CD_HAB_ENTRE"))
  return(typo_taxa)
}
###############################################################################
PVF2_TAXON = taxon_hab(28)



#########################TEST FONCTION SEARCH

taxa_search = "Pol ave"
typo_taxa = PVF2_TAXON
colomn_name = "NOM_CITE"
colomn_name2 = "NOM_CITE_MATCH"


############################################################   find_taxon_hab    
find_taxon_hab <- function(taxa_search,
                           typo_taxa,colomn_name = "NOM_CITE",
                           colomn_name2 = "NOM_CITE_MATCH",
                           colhab = "LB_HAB_FR",
                           FCD_TYPO = NULL){
  # Utilisation de str_split avec un motif pour diviser le texte
  texte_split <- strsplit(taxa_search, " ")[[1]]  # Utilisation de [[1]] pour extraire le vecteur de chaînes
  
  # Ajouter '.*' à chaque élément de texte_split
  texte_split <- paste0(texte_split, '.*')
  
  # Combiner les éléments de texte_split en une seule chaîne de caractères
  texte_pour_grep <- paste(texte_split, collapse = "")
  
  # Utilisation de grep pour trouver les correspondances dans la base de données
  resultats_grep <- typo_taxa[grep(texte_pour_grep, typo_taxa[[colomn_name]],
                                   paste0(typo_taxa[[colomn_name]]," ",typo_taxa[[colomn_name2]]), 
                                   ignore.case = TRUE)
                              , ]
  resultats_hab = resultats_grep[colhab]
  
  return(list(resultats_grep,resultats_hab))
}
###############################################################################

# Appel de la fonction avec l'exemple "Que ile"
find_taxon_hab("Pol avic",PVF2_TAXON)



############################################################   hab_match
# Nécessite d'avoir chargé un tableau de correspondance habitats - taxons avec la fonction taxon_hab
hab_match = function(taxon_hab_data,
                     data_flore,
                     dataflore_type = "kit_bota",
                     groupe_type = "hab"){
  # utiliser les chemins du kit_bota Qfield
  if(dataflore_type == "kit_bota"){
    data_flore = st_read("Flore/Flore.shp")
    data_flore$CD_NOM = findtaxa(data_flore$lb_nom)
  }
  if(groupe_type == "hab"){
    data_hab = st_read("Habitats/HABITATS_POLYGONES.shp")
    data_hab$fid_hab = 1:nrow(data_hab)
  }
  
  
  intersection_habflore = st_intersection(data_flore, data_hab)
  intersection_habflore = intersection_habflore %>% select(CD_NOM,LB_NOM = lb_nom,HABLABEL = hablabel,fid_hab,geometry)
  intersection_habflore$habid = paste0(intersection_habflore$HABLABEL,"_",intersection_habflore$fid_hab)

}
