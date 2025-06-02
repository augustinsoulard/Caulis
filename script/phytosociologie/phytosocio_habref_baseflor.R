if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")

source("function/postgres/postgres_manip.R")
source("function/sig.R")
source("function/taxabase.R")

con = copo() # Connexion à la bdd


# Chargement des données
habref_esp = dbGetQuery(con, "
SELECT *
FROM habref.habref_corresp_taxon_70 AS t1
LEFT JOIN habref.habref_70 AS t2
  ON t1.cd_hab_entree = t2.cd_hab
WHERE t2.cd_typo IN ('4', '7', '8', '22', '18', '28', '107', '100');
")


# Charger les données de QBiome
charger_gpkg(layers = c("Flore","Releve_Phyto"))
