# remotes::install_github("Rekyt/rtaxref")
# WEBSITE: https://rekyt.github.io/rtaxref/


# Charger les bibliotheques necessaires
if(!require("caulisroot")){install.packages("caulisroot")} ; library("caulisroot")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")
if(!require("remotes")){install.packages("remotes")} ; library("remotes")
if(!require("rtaxref")){install_github("Rekyt/rtaxref")} ; library("rtaxref")
source("function/taxabase.R")
source("function/postgres/postgres_manip.R")

con = copo()

#Chargement de baseflor
baseflor <- dbGetQuery(con, "SELECT * FROM public.baseflor")

#Chargement de basebryo
basebryo <- dbGetQuery(con, "SELECT * FROM public.basebryo_esp")

#Ajustement des noms de colonnes de basebryo
colnames(basebryo)[2] = "N°_Taxinomique_BDNFF"
colnames(basebryo)[3] = "N°_Nomenclatural_BDNFF"
colnames(basebryo)[4] = "code_CATMINAT"
colnames(basebryo)[5] = "NOM_SCIENTIFIQUE"
colnames(basebryo)[6] = "INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE"
colnames(basebryo)[7] = "CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)"
colnames(basebryo)[8] = "INDICATION_DIFFERENTIELLE_1"
colnames(basebryo)[9] = "INDICATION_DIFFERENTIELLE_2"
colnames(basebryo)[11] = "Lichtzahl"
colnames(basebryo)[12] = "Temperaturzahl"
colnames(basebryo)[13] = "Kontinentalitat"
colnames(basebryo)[14] = "Feuchtzahl"
colnames(basebryo)[15] = "Reaktionszahl"
colnames(basebryo)[16] = "TYPE_BIOLOGIQUE"

#Ajustement des noms de colonnes de baseflor
colnames(baseflor)[40] = "Kontinentalitat"

#Fusion des 2 tables
common_columns <- intersect(names(baseflor), names(basebryo))
baseflor_bryo = merge(baseflor,basebryo,by=common_columns,all=T)

match_baseflor_taxref = find_taxaref(
  baseflor_bryo$NOM_SCIENTIFIQUE,
    code_taxa_entree = baseflor_bryo$`N°_Taxinomique_BDNFF`, 
    ref='taxref',
    input_ref="baseflor"
)

baseflor_bryo = match_baseflor_taxref %>% select(cd_ref,lb_nom) %>% cbind(baseflor_bryo)


######## Prise en compte du correctif de baseflore_bryo
# Chargement du correctif
correctif_baseflor_bryo<- dbGetQuery(con, "SELECT * FROM public.correctif_baseflor_bryo")
correctif_baseflor_bryo$cd_ref = updatetaxa(correctif_baseflor_bryo$cd_nom)

# Injection des corrections


library(dplyr)

# Appliquer le correctif sans renommer les colonnes
baseflor_bryo_taxref <- baseflor_bryo %>%
  full_join(
    correctif_baseflor_bryo %>%
      select(cd_ref, lb_nom, floraison, 
             `CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)` = caract_eco_hab_optimal, 
             `INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE` = indicat_phytoscio_caract),
    by = "cd_ref",
    suffix = c("", "_corr")
  ) %>%
  mutate(
    lb_nom = coalesce(lb_nom_corr, lb_nom),
    floraison = coalesce(floraison_corr, floraison),
    `CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)` = coalesce(`CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)_corr`, `CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)`),
    `INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE` = coalesce(`INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE_corr`, `INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE`)
  ) %>%
  select(-ends_with("_corr"))



# Enregistrer le fichier final dans la bdd
write_to_schema(con,"public","baseflor_bryo_taxref",baseflor_bryo,append = FALSE, overwrite = TRUE)



