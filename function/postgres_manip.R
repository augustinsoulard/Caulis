write_to_schema <- function(con, schema, table, data, append = FALSE, overwrite = FALSE) {
  # Vérifie si le schéma existe (et lève une erreur sinon)
  existing_schemas <- dbGetQuery(con, "SELECT schema_name FROM information_schema.schemata;")$schema_name
  if (!(schema %in% existing_schemas)) {
    stop(paste("Le schéma", schema, "n'existe pas dans la base de données."))
  }
  
  # Construction du nom qualifié (schema.table)
  full_table_name <- SQL(paste0(schema, ".", table))
  
  # Écriture dans la table
  dbWriteTable(
    con,
    name = full_table_name,
    value = data,
    append = append,
    overwrite = overwrite,
    row.names = FALSE
  )
}


inat_from_polygon = function(requete = "SELECT * FROM projet.zone_etude WHERE code IN (29)",year = NULL,
maxresult = 1000){
  # Charger ton polygone (ex : shapefile ou GeoJSON)
  requete_sql <- requete
  polygone <- st_read(con, query = requete_sql)
  polygone <- st_transform(polygone, crs = 4326)
  
  
  # Convertir en WKT
  bbox <- st_bbox(polygone)
  nelat <- bbox["ymax"]
  nelng <- bbox["xmax"]
  swlat <- bbox["ymin"]
  swlng <- bbox["xmin"]
  
  # Définir les coordonnées de la boîte englobante : sud, ouest, nord, est
  bounds = c(swlat, swlng, nelat, nelng)
  
  # Récupérer les observations ####
  obs = get_inat_obs(bounds = bounds,year = year, maxresults = maxresult)
  
  return(obs)
  
}
