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