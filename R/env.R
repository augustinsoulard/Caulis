#' @title Charger le fichier .env du projet
#' @description Lit un fichier `.env` (format `CLE=VALEUR`, compatible `readRenviron`)
#' et définit les variables d'environnement correspondantes. Appelée automatiquement
#' au chargement du package (`.onLoad`) si un fichier `.env` est trouvé.
#' @param path Chemin du fichier `.env`. Défaut : la variable `CAULIS_DOTENV`,
#'   sinon `.env` dans le dossier de travail.
#' @return Invisible, le vecteur des noms de variables définies.
#' @export
charger_env <- function(path = Sys.getenv("CAULIS_DOTENV", unset = ".env")) {
  if (!nzchar(path) || !file.exists(path)) return(invisible(character(0)))
  readRenviron(path)  # pose les variables KEY=VALUE dans l'environnement
  l <- readLines(path, warn = FALSE)
  l <- l[!grepl("^\\s*(#|$)", l)]  # ignore commentaires et lignes vides
  invisible(sub("=.*$", "", l))
}

#' @title Lire une variable d'environnement caulis avec valeur par défaut
#' @description Lit une variable d'environnement ; si elle est vide ou non définie,
#' retourne `default`.
#' @param var Nom de la variable d'environnement (ex. `"CAULIS_RENVIRON"`).
#' @param default Valeur par défaut si la variable est vide.
#' @return La valeur de la variable, ou `default`.
#' @export
caulis_env <- function(var, default = "") {
  v <- Sys.getenv(var, unset = "")
  if (nzchar(v)) v else default
}

.onLoad <- function(libname, pkgname) {
  # Charge le .env du projet en développement (dossier de travail ou CAULIS_DOTENV)
  charger_env()
}
