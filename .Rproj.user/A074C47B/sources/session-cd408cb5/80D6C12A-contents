if(!require("sf")){install.packages("sf")} ; library("sf")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")
source("function/postgres/postgres_manip.R")
con = copo() # Connexion à la bdd
# Lecture des observation via INaturalist ou un fichier téléchargé ####
obs = inat_from_polygon(requete = "SELECT * FROM projet.zone_etude WHERE code IN (19);",
                        year = NULL,
                        maxresult = 10)

obs = read.csv(choose.files())


head(obs)

# Nettoyage des données ####
obs = obs[grepl(" ", obs$scientific_name)  & !is.na(obs$scientific_name) & obs$iconic_taxon_name == 'Plantae',]

# Modifier les longitudes des données privées ####
# Exemple : si coordinates_obscured est de type caractère
obs$latitude <- ifelse(obs$coordinates_obscured %in% c("true", TRUE), 
                       obs$private_latitude, 
                       obs$latitude)

obs$longitude <- ifelse(obs$coordinates_obscured %in% c("true", TRUE), 
                       obs$private_longitude, 
                       obs$longitude)
# Lecture de la BDD ####

flore_db <- st_read(con, query = "SELECT * FROM donnees.flore")
corresp_inat_taxref = dbGetQuery(con, "SELECT * FROM inaturalist.corresp_taxref")

# Jointure et récupération des champs intéressant ####


inat_to_add = left_join(obs,corresp_inat_taxref,by=c("taxon_id"="code_taxa_entree")) %>% 
                            select(CD_REF = cd_ref,
                                      nom = lb_nom,                                                                   
                                      observateur=user_name,
                                      date = observed_on,
                                      heure = time_observed_at,
                                      lieu = place_guess,
                                      statut = captive_cultivated,
                                      url,
                                      longitude,
                                      latitude,
                                      uuid)

# Ajout des valeurs pour les espèces cultivées ####

inat_to_add <- inat_to_add %>%
  mutate(Statut = case_when(
    Statut == "true" ~ "Planté",
    Statut == "false" ~ NA_character_,
    TRUE ~ Statut
  ))
# Convertire les dates
inat_to_add$Date <- as.Date(inat_to_add$Date)
inat_to_add$Heure <- as.POSIXct(inat_to_add$Heure)

# Définition ed l'origine
inat_to_add$origine = "INaturalist"

# Ajouter une colonne Z (exemple : altitude = 0)
inat_to_add$Z <- 0

# Recréer la géométrie avec longitude, latitude, Z
inat_to_add <- inat_to_add %>%
  st_drop_geometry() %>%  # Supprimer l'ancienne geometry si existante
  st_as_sf(coords = c("longitude", "latitude", "Z"), crs = 4326, dim = "XYZ") %>%
  st_transform(crs = 2154)

# Renommer + redéfinir géométrie
inat_to_add <- inat_to_add %>% rename(geom = geometry)
st_geometry(inat_to_add) <- "geom"

# 4. Puis écrire
insert_on_conflict(
  con = con,
  schema = "donnees",
  table = "flore",
  df = inat_to_add,
  key = "uuid"
)
