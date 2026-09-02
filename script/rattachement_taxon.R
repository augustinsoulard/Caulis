if (file.exists("caulisroot/DESCRIPTION")) {
  devtools::load_all("caulisroot")
}

con = copo()

resultat <- find_taxaref(
  lb_taxa_entree = c("Ranunculus aquatilis subsp. aquatilis", "Centaurea jacea"),
  ref = "taxref",
  taxagroup = "flore"
)
