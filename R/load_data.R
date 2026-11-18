#' @title load_data
#' @description Charge un fichier CSV dans l'environnement global sous le nom donné, si l'objet n'existe pas déjà.
#' @param data_name Nom de l'objet à créer dans l'environnement global.
#' @param path Chemin vers le fichier CSV.
#' @param sep Séparateur de colonnes (défaut ";").
#' @param header Ligne d'en-tête présente ? (défaut TRUE).
#' @export
load_data <- function(data_name, 
                      path, 
                      sep = ";", 
                      header = TRUE) {
  # Vérifiez si l'objet 'data_name' existe déjà
  if (!exists(data_name,envir = .GlobalEnv)) {
    # Si l'objet n'existe pas, chargez les données
    assign(data_name, read.csv(path, sep = sep, header = header), envir = .GlobalEnv)
  }
}
