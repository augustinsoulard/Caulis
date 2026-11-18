#' @title find_taxaref
#' @description
#' Recherche les correspondances entre une liste de taxons (issus d'une source externe, par ex. iNaturalist)
#' et la base TAXREF (ou autre référentiel taxonomique). Nettoie, standardise et enrichit les entrées,
#' puis associe les codes et rangs correspondants depuis le référentiel.
#'
#' @param lb_taxa_entree Vector de chaînes de caractères. Libellés de taxons à rechercher (ex. noms scientifiques).
#' @param code_taxa_entree Vector (optionnel). Codes des taxons d'entrée, si disponibles (défaut : NA).
#' @param ref Character. Référentiel de correspondance, par défaut "taxref".
#' @param input_ref Character. Source des noms d'entrée ("inaturalist", "baseflor", etc.), utilisé pour ajuster la correspondance (défaut : "inaturalist").
#' @param taxagroup Character. Sourcer des noms d'entrée ("flore", "faune" ou fonge), utilisé pour ajuster la correspondance au bon groupe taxonomique (défaut : "tout").
#'
#' @return Un data.frame avec, pour chaque taxon d'entrée : le code d'entrée, le libellé nettoyé,
#' le rang, les codes et noms correspondants dans TAXREF (ou référentiel choisi), et le code cd_ref mis à jour.
#'
#' @details
#' La fonction effectue des opérations de nettoyage sur les noms de taxons,
#' corrige certains formats (ex. ssp. → subsp.), supprime les parenthèses et mots parasites,
#' détermine le rang (espèce, sous-espèce, variété…), puis cherche la correspondance exacte dans le référentiel taxonomique choisi.
#'
#' @examples
#' \dontrun{
#' find_taxaref(
#'   lb_taxa_entree = c("Ranunculus aquatilis subsp. aquatilis", "Centaurea jacea"),
#'   code_taxa_entree = c(NA, NA),
#'   ref = "taxref",
#'   input_ref = "inaturalist",
#'   taxagroup = "flore"
#' )
#' }
#'#' @author Augustin (package QBiome)
#' @keywords taxref inaturalist faune flore cd_nom cd_ref
#'
#' @import dplyr
#' @import stringr
#'
#' @encoding UTF-8
#' @export



find_taxaref <- function(
    lb_taxa_entree,
    code_taxa_entree = NA,
    ref='taxref',
    input_ref="inaturalist",
    taxagroup = "tout"
){
  # Chargement des librairies

  # ---> CORRECTION 1 : On crée une colonne dédiée au nettoyage (lb_taxa_clean) <---
  entree = data.frame(
    code_taxa_entree = code_taxa_entree,
    lb_taxa_entree = lb_taxa_entree,
    lb_taxa_clean = lb_taxa_entree # Copie de travail
  )
  
  if(ref == 'taxref' & taxagroup =="flore"){
    taxref = dbGetQuery(con, "SELECT * FROM public.taxref_flore_fr_syn")
  } else if(ref == 'taxref' & taxagroup =="faune"){
    taxref =dbGetQuery(con, "SELECT * FROM public.taxrefv18 WHERE regne = 'Animalia'")
  }else if(taxagroup == "tout"){
    taxref =dbGetQuery(con, "SELECT * FROM public.taxrefv18_fr")
  }
  
  #Préparation du tableau entree
  entree <- entree %>%
    mutate(cd_nom = NA_character_,
           lb_nom = NA_character_,
           rang = NA_character_)
  
  # ---> CORRECTION 2 : On applique tous les regex sur lb_taxa_clean, PAS sur lb_taxa_entree <---
  
  # Correction des adjectifs de rangs
  entree$lb_taxa_clean = str_replace(entree$lb_taxa_clean,'ssp.','subsp.')
  
  # Supprimer les mots entre parenthèses
  entree$lb_taxa_clean = gsub("\\(.*?\\)", "", entree$lb_taxa_clean)
  entree$lb_taxa_clean = gsub("\\b(?!subsp\\.|var\\.)\\w+\\.", "", entree$lb_taxa_clean, perl=TRUE)
  entree$lb_taxa_clean = gsub("\\s+", " ", entree$lb_taxa_clean)
  entree$lb_taxa_clean = sapply(entree$lb_taxa_clean, majuscule_hors_premier_mot)
  entree$lb_taxa_clean = gsub("[^[:alnum:] ]", "", entree$lb_taxa_clean)
  entree$lb_taxa_clean = gsub("[[:space:]]+$", "", entree$lb_taxa_clean)
  entree$lb_taxa_clean <- sapply(entree$lb_taxa_clean, function(x) {
    if (grepl(" subsp| var| f", x)) {
      return(x)
    } else if (grepl(" x ", x)) {
      mots <- strsplit(x, " ")[[1]]
      return(paste(mots[1:min(3, length(mots))], collapse = " "))
    } else {
      mots <- strsplit(x, " ")[[1]]
      return(paste(mots[1:min(2, length(mots))], collapse = " "))
    }
  })
  
  # Ajoute une colonne de RANG au tableau entree (basé sur lb_taxa_clean)
  for(i in 1:nrow(entree)){
    # cat('rang : ',i,'/',nrow(entree),'\n') # Tu peux commenter ça pour moins de spam console
    if(str_detect(entree$lb_taxa_clean[i],'subsp.')){
      entree$rang[i] = 'SSES'
    }
    else if(str_detect(entree$lb_taxa_clean[i],'var.')){
      entree$rang[i] = 'VAR'
    }
    else{entree$rang[i] = 'ES'}
  }
  
  # Définition des colonnes cd_nom et lb_nom par défaut
  entree$cd_nom = '_NOMATCH'
  entree$lb_nom = '_NOMATCH'
  
  # Retirer les marqueurs d'infrataxons pour la correspondance avec Inaturalist
  if(input_ref=="inaturalist"){
    taxref$lb_nom = taxref$lb_nom %>%
      str_replace(' subsp.','') %>%
      str_replace(' var.','') %>%
      str_replace(' f.','')
  }
  
  if(input_ref=="baseflor"){
    taxref$lb_nom = taxref$lb_nom %>%
      str_replace(' subsp.',' subsp') %>%
      str_replace(' var.',' var') %>%
      str_replace(' f.',' f')
  }
  
  for (i in 1:nrow(entree)) {
    # cat('CORRESP : ',i,'/',nrow(entree),'\n')
    
    # Trouver les correspondances
    if(str_detect(entree$lb_taxa_clean[i]," x ")){
      taxref_rang = taxref[taxref$rang==entree$rang[i],]
    } else {
      taxref_rang = taxref[taxref$rang==entree$rang[i] & !str_detect(taxref$lb_nom," x "),]
    }
    
    # ---> CORRECTION 3 : Le match se fait avec lb_taxa_clean <---
    matches <- str_detect(taxref_rang$lb_nom, fixed(entree$lb_taxa_clean[i]))
    
    # Pour Inaturalist tenter de faire une correspondance des sous-espèces
    if(input_ref=="inaturalist" & !any(matches)){
      taxref_rang = taxref[taxref$rang=="SSES",]
      matches <- str_detect(taxref_rang$lb_nom, fixed(entree$lb_taxa_clean[i]))
    }
    
    if(any(matches)){
      lb_nom = taxref_rang[matches==TRUE,]$lb_nom
      cd_nom = taxref_rang[matches==TRUE,]$cd_nom
      
      entree$cd_nom[i] <- cd_nom
      entree$lb_nom[i] <- lb_nom
    }
  }
  
  # Mise à jour du code CD_REF
  entree$cd_ref = updatetaxa(entree$cd_nom, taxagroup = "tout")
  
  # Optionnel : retirer la colonne propre si on n'en a plus besoin en sortie
  entree <- entree %>% select(-lb_taxa_clean)
  
  return(entree)
}