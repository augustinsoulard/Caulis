# Chargement des packages ####
if(!require("sf")){install.packages("sf")} ; library("sf")
if(!require("leaflet")){install.packages("leaflet")} ; library("leaflet")
if(!require("rinat")){install.packages("rinat")} ; library("rinat")
if(!require("rtaxref")){install_github("Rekyt/rtaxref")} ; library("rtaxref")
source("function/taxabase.R")
source("function/postgres_manip.R")

# Lecture des observation via INaturalist ou un fichier téléchargé ####
obs = inat_from_polygon(requete = "SELECT * FROM projet.zone_etude WHERE code IN (19);",
                  year = NULL,
                  maxresult = 10)

obs = read.csv(choose.files())


head(obs)
obs = obs[grepl(" ", obs$scientific_name)  & !is.na(obs$scientific_name) & obs$iconic_taxon_name == 'Plantae',]

# Possibilité de charger un fichier csv téléchargé


# Tester de voir si la base de données connait les codes taxon INaturalist ####

corresp_know = dbGetQuery(con, "SELECT * FROM inaturalist.corresp_taxref")

# A REMPLIRIIR

obs_unknow = obs %>% filter(!obs$taxon_id %in% corresp_know$code_taxa_entree)


# Travail sur les valeurs unique non reconnues ####

unknow_taxa = unique(obs_unknow[, c("scientific_name", "taxon_id")])

# find_taxaref ####

new_corresp = find_taxaref(unknow_taxa$scientific_name,unknow_taxa$taxon_id, ref ='taxref')
view(new_corresp)


# Nouvelles correspondances ####

write_to_schema(con, "inaturalist", "corresp_taxref", new_corresp, append = TRUE)


