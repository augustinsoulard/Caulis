copo = function(){ #COnnexion à la bdd POstgres
  # Préparation de la BDD ####
  ### Déclaraiton des variables d'environnement pour l'authentification ####
  Sys.setenv(R_ENVIRON = "G:/Mon Drive/Administratif/hz/.Renviron")
  readRenviron(Sys.getenv("R_ENVIRON"))
  Sys.setenv(PGUSER = Sys.getenv("PGUSER"), PGPASSWORD = Sys.getenv("PGPASSWORD")) # Lancer cette commade avec les bons indentifiant
  
  
  ### Chargement des packages ####
  if(!require("RPostgreSQL")){install.packages("RPostgreSQL")} ; library("RPostgreSQL")
  if(!require("RPostgres")){install.packages("RPostgres")} ; library("RPostgres")
  
  
  # Charger le driver PostgreSQL
  drv <- dbDriver("PostgreSQL")
  
  # Se connecter à la base de données
  con <- dbConnect(RPostgres::Postgres(), dbname = "BiodiversitySQL")
  return(con)
}

write_to_schema <- function(con, schema, table, data, append = FALSE, overwrite = FALSE) {
  # Vérifie si le schéma existe (et lève une erreur sinon)
  existing_schemas <- dbGetQuery(con, "SELECT schema_name FROM information_schema.schemata;")$schema_name
  if (!(schema %in% existing_schemas)) {
    stop(paste("Le schéma", schema, "n'existe pas dans la base de données."))
  }
}
insert_on_conflict <- function(con, schema, table, df, key) {
  stopifnot(key %in% names(df))
  requireNamespace("glue")
  requireNamespace("DBI")
  requireNamespace("sf")
  
  temp_table <- paste0("temp_", table)
  
  # Forcer les noms de colonnes en minuscules (PostgreSQL les stocke ainsi par défaut)
  names(df) <- tolower(names(df))
  key <- tolower(key)
  
  # Supprimer l'ancienne table temporaire si elle existe
  DBI::dbExecute(con, glue::glue("DROP TABLE IF EXISTS {temp_table}"))
  
  # Créer une table temporaire avec la structure de la table cible
  DBI::dbExecute(con, glue::glue("
    CREATE TEMP TABLE {temp_table} AS
    SELECT * FROM {schema}.{table} LIMIT 0;
  "))
  
  # Lire la structure de la table temporaire
  temp_structure <- DBI::dbGetQuery(con, glue::glue("SELECT * FROM {temp_table} LIMIT 0"))
  temp_colnames <- names(temp_structure)
  
  # Vérifier que toutes les colonnes du df existent dans la structure SQL
  missing_cols <- setdiff(names(df), temp_colnames)
  
  if (length(missing_cols) > 0) {
    stop(glue::glue("❌ Erreur : les colonnes suivantes sont absentes de la table '{schema}.{table}' : {paste(missing_cols, collapse = ', ')}"))
  }
  
  # Réorganiser le df pour correspondre à l'ordre des colonnes SQL
  df <- df[, temp_colnames[temp_colnames %in% names(df)]]
  
  # Écriture dans la table temporaire
  sf::st_write(df, dsn = con, layer = temp_table, append = TRUE, quiet = TRUE)
  
  # Génération des colonnes
  cols_all <- names(df)
  cols_update <- setdiff(cols_all, key)
  
  set_clause <- paste0(cols_update, " = EXCLUDED.", cols_update, collapse = ",\n    ")
  cols_sql <- paste(cols_all, collapse = ", ")
  
  # Requête d'insertion avec gestion de conflit
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
