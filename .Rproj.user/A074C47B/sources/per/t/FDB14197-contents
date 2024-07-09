taxaGBIF = read.csv2("https://zenodo.org/records/12698335/files/taxonPatriNatGBIF202403.csv?download=1")
source("function/taxabase.R")

#On filtre les plantes
taxaGBIF = taxaGBIF %>% filter(kingdom == "Plantae")
taxrefgbif = find_taxaref(taxaGBIF$scientificName[100000:101000])
