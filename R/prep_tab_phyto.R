#' @title contingentation
#' @description Construit le tableau de contingentation (présence/absence) d'un relevé phytosociologique.
#' @param releve Vecteur des noms de relevés.
#' @param lb_nom Vecteur des libellés de taxons.
#' @export
contingentation = function(releve,lb_nom){
  data = data.frame(releve = releve, lb_nom = lb_nom)
  data = data %>% filter(!is.na(releve)==TRUE)
  data$CD_NOM = findtaxa(data$lb_nom)
  data = data %>% mutate(P=1) %>% dcast(lb_nom + CD_NOM ~ releve, value.var = "P", fun.aggregate = sum, fill = 0)
  return(data)
}
