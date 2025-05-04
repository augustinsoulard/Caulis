# Chargement des packages ####
if(!require("sf")){install.packages("sf")} ; library("sf")
if(!require("httr")){install.packages("httr")} ; library("httr")
if(!require("jsonlite")){install.packages("jsonlite")} ; library("jsonlite")
if(!require("rtaxref")){install_github("Rekyt/rtaxref")} ; library("rtaxref")
source("function/taxabase.R")
source("function/postgres_manip.R")

# Charger ton polygone (ex : shapefile ou GeoJSON)
requete_sql <- "SELECT * FROM projet.zone_etude WHERE code IN (29,30);"
polygone <- st_read(con, query = requete_sql)
polygone <- st_transform(polygone, crs = 4326)


# Convertir en WKT
bbox <- st_bbox(polygone)
nelat <- bbox["ymax"]
nelng <- bbox["xmax"]
swlat <- bbox["ymin"]
swlng <- bbox["xmin"]

# Construire l'URL API avec le paramètre `polygon=`
url <- paste0("https://api.inaturalist.org/v1/observations?",
              "nelat=", nelat,
              "&nelng=", nelng,
              "&swlat=", swlat,
              "&swlng=", swlng,
              "&per_page=10000")

# Faire la requête
res <- GET(url)
data <- fromJSON(content(res, as = "text"), flatten = TRUE)

# Accéder aux observations
obs <- data$results

head(obs)
obs = obs[obs$taxon.rank_level <=15 & !is.na(obs$taxon.rank_level) & obs$taxon.iconic_taxon_name == 'Plantae',]

# Tester de voir si la base de données connait les codes taxon INaturalist ####

dbGetQuery(con, "SELECT * FROM inaturalist.corresp_taxref")

# A REMPLIRIIR

obs_unknow = obs

# Travail sur les valeurs unique non reconnues ####

unknow_taxa = unique(obs_unknow[, c("taxon.name", "taxon.id")])

# find_taxaref ####

new_corresp = find_taxaref(unknow_taxa$taxon.name,unknow_taxa$taxon.id, ref ='taxref')
view(new_corresp)


# Nouvelles correspondances ####

write_to_schema(con, "inaturalist", "corresp_taxref", new_corresp, append = TRUE)


