if (requireNamespace("caulis", quietly = TRUE)) {
  library("caulis")
}

con = copo()

resultat <- find_taxaref(
  lb_taxa_entree = c("Ranunculus aquatilis subsp. aquatilis", "Centaurea jacea"),
  ref = "taxref",
  taxagroup = "flore"
)
