# Chargement des packages ####
if(!require("sf")){install.packages("sf")} ; library("sf")
if(!require("httr")){install.packages("httr")} ; library("httr")
if(!require("jsonlite")){install.packages("jsonlite")} ; library("jsonlite")


# Charger ton polygone (ex : shapefile ou GeoJSON)
polygone <- st_read("mon_polygone.geojson") # ou .shp
#polygone = dbGetQuery(con, "SELECT * FROM projet.zone_projet WHERE zone_projet IN (29,30);")

# Convertir en WKT
wkt <- st_as_text(st_geometry(polygone)[1])  # Si plusieurs polygones, adapter

# Construire l'URL API avec le paramètre `polygon=`
url <- paste0("https://api.inaturalist.org/v1/observations?per_page=100&polygon=", URLencode(wkt))

# Faire la requête
res <- GET(url)
data <- fromJSON(content(res, as = "text"), flatten = TRUE)

# Accéder aux observations
obs <- data$results
head(obs)
