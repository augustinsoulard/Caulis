if(!require("sf")){install.packages("sf")} ; library("sf")
source("function/taxabase.R")

############## CHOIX DU FICHIER SHP
shp = "Flore/FloreGBIF.shp"


gbifshp = st_read(shp)

taxrefgbif = find_taxaref(gbifshp$scientific,code_taxa_entree = gbifshp$taxonKey)
taxrefgbif[is.na(taxrefgbif$CD_REF),]

shpfinal = cbind(gbifshp,taxrefgbif)

st_write(shpfinal,shp,append=FALSE)
