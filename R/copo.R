#' @title copo
#' @description Fonction permettant de se connecter à la base de données PostgreSQL en utilisant un fichier `.Renviron`.
#' @return Une connexion active à la base PostgreSQL (objet de type `DBIConnection`)
#' @details La fonction suppose que le fichier `.Renviron` contient les variables d’environnement `PGUSER` et `PGPASSWORD`, et que la base `BiodiversitySQL` est accessible.
#' @examples
#' \dontrun{
#' con = copo()
#' BDC_STATUTS <-   dbGetQuery(con, "SELECT * FROM public.bdc_statuts_18")
#' }
#' @export


copo = function(){ #COnnexion à la bdd POstgres
  # Préparation de la BDD ####
  ### Déclaration des variables d'environnement pour l'authentification ####
  # Le chemin du fichier des secrets (.Renviron : PGUSER, PGPASSWORD, clés API)
  # est lu dans la variable d'environnement CAULIS_RENVIRON (voir .env / .env.example)
  chemin_renviron <- caulis_env("CAULIS_RENVIRON")
  if (!nzchar(chemin_renviron) || !file.exists(chemin_renviron)) {
    stop("Variable CAULIS_RENVIRON non définie ou fichier introuvable : '", chemin_renviron,
         "'. Définissez-la dans le fichier .env du projet (voir .env.example).")
  }
  Sys.setenv(R_ENVIRON = chemin_renviron)
  readRenviron(chemin_renviron)
  Sys.setenv(PGUSER = Sys.getenv("PGUSER"), PGPASSWORD = Sys.getenv("PGPASSWORD"))


  ### Chargement des packages ####



  # Se connecter à la base de données
  con <- dbConnect(RPostgres::Postgres(), dbname = "BiodiversitySQL")
  return(con)
}
