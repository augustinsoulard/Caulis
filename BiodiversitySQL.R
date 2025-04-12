# Préparation de la BDD ####
### Déclaraiton des variables d'environnement pour l'authentification ####
Sys.setenv(PGUSER = "nom_utilisateur", PGPASSWORD = "mot_de_passe") # Lancer cette commade avec les bons indentifiant


### Chargement des packages ####
if(!require("RPostgreSQL")){install.packages("RPostgreSQL")} ; library("RPostgreSQL")
if(!require("RPostgres")){install.packages("RPostgres")} ; library("RPostgres")


# Charger le driver PostgreSQL
drv <- dbDriver("PostgreSQL")

# Se connecter à la base de données
con <- dbConnect(RPostgres::Postgres(), dbname = "BiodiversitySQL")


# Vérifier la connexion
dbListTables(con)

# Voir toutes les tables
dbGetQuery(con, "
  SELECT table_schema, table_name 
  FROM information_schema.tables 
  WHERE table_type = 'BASE TABLE'
    AND table_schema NOT IN ('pg_catalog', 'information_schema')
")

# Les requêtes ####
data <- dbGetQuery(con, "SELECT * FROM taxasearch LIMIT 10;")
print(data)



dbDisconnect(con)
