write_to_schema <- function(con, schema, table, data, append = FALSE, overwrite = FALSE) {
  # Vérifie si le schéma existe (et lève une erreur sinon)
  existing_schemas <- dbGetQuery(con, "SELECT schema_name FROM information_schema.schemata;")$schema_name
  if (!(schema %in% existing_schemas)) {
    stop(paste("Le schéma", schema, "n'existe pas dans la base de données."))
  }
  
insert_on_conflict <- function(con, schema, table, df, key) {
    stopifnot(key %in% names(df))
    requireNamespace("glue")
    requireNamespace("DBI")
    requireNamespace("sf")
    
    temp_table <- paste0("temp_", table)
    
    # Forcer noms de colonnes en minuscule
    names(df) <- tolower(names(df))
    key <- tolower(key)
    
    # Supprimer l'ancienne table temporaire
    DBI::dbExecute(con, glue::glue("DROP TABLE IF EXISTS {temp_table}"))
    
    # Créer une nouvelle table temporaire vide avec la bonne structure
    DBI::dbExecute(con, glue::glue("
    CREATE TEMP TABLE {temp_table} AS
    SELECT * FROM {schema}.{table} LIMIT 0;
  "))
    
    # Lire la structure de la table temporaire pour ajuster les colonnes et leur ordre
    temp_structure <- DBI::dbGetQuery(con, glue::glue("SELECT * FROM {temp_table} LIMIT 0"))
    common_cols <- intersect(names(temp_structure), names(df))
    df <- df[, common_cols]
    
    # Écriture dans la table temporaire
    sf::st_write(df, dsn = con, layer = temp_table, append = TRUE, quiet = TRUE)
    
    # Génération des colonnes pour INSERT
    cols_all <- names(df)
    cols_update <- setdiff(cols_all, key)
    
    set_clause <- paste0(cols_update, " = EXCLUDED.", cols_update, collapse = ",\n    ")
    cols_sql <- paste(cols_all, collapse = ", ")
    
    # Requête finale
    query <- glue::glue("
    INSERT INTO {schema}.{table} ({cols_sql})
    SELECT {cols_sql} FROM {temp_table}
    ON CONFLICT ({key}) DO UPDATE
    SET
      {set_clause};
  ")
    
    # Exécution
    DBI::dbExecute(con, query)
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
