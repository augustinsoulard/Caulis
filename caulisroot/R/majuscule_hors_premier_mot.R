#' @title Suppression des mots en majuscules sauf le premier
#'
#' @description
#' Fonction qui conserve uniquement le premier mot d'une chaîne de caractères
#' et supprime les mots suivants qui commencent par une majuscule.
#' Les chaînes contenant " x " (hybrides) sont conservées inchangées.
#'
#' @param chaine Chaîne de caractères à traiter
#'
#' @return Chaîne de caractères avec uniquement le premier mot conservé
#' (les mots suivants commençant par une majuscule sont supprimés)
#'
#' @examples
#' majuscule_hors_premier_mot("Ranunculus aquatilis subsp. Aquatilis")
#' majuscule_hors_premier_mot("Chene vert")
#' majuscule_hors_premier_mot("Quercus robur x petraea")
#'
#' @export
#'
#'
majuscule_hors_premier_mot <- function(chaine) {

  # Si " x " est présent, on ne modifie rien (cas des hybrides)
  if (grepl(" x ", chaine)) {
    return(chaine)
  }

  # Sinon, on garde le premier mot, puis on enlève les suivants s'ils commencent par une majuscule
  mots <- unlist(strsplit(chaine, " "))

  if (length(mots) <= 1) return(chaine)

  premier <- mots[1]
  reste <- mots[-1]

  # Supprime les mots en majuscule dans le reste
  reste_filtré <- reste[!grepl("^[A-Z]", reste)]

  return(paste(c(premier, reste_filtré), collapse = " "))
}


majuscule_hors_premier_mot <- function(chaine) {
  # Si " x " est présent, on ne modifie rien
  if (grepl(" x ", chaine)) {
    return(chaine)
  }

  # Sinon, on garde le premier mot, puis on enlève les suivants s'ils commencent par une majuscule
  mots <- unlist(strsplit(chaine, " "))
  if (length(mots) <= 1) return(chaine)

  premier <- mots[1]
  reste <- mots[-1]

  # Supprime les mots en majuscule dans le reste
  reste_filtré <- reste[!grepl("^[A-Z]", reste)]

  return(paste(c(premier, reste_filtré), collapse = " "))
}
