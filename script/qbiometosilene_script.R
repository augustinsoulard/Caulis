
# libraries
library(caulisroot)
library(sf)
library(openxlsx)

# Chargement du standard de données
con = copo()
standard_silene <-   dbGetQuery(con, "SELECT * FROM donnees.standard_donnees_silene")

# Utilisation de la fonciton

standard_final = qbiometosilene(
  donnees_path = file.choose(),
  standard_silene = dbGetQuery(con, "SELECT * FROM donnees.standard_donnees_silene"),
  structure = "BIODIV",
  origine = "Pu", # Pr ou Pu
  diffusion = 5, # 1 un5 selon ouverture des données
  type_loc = "précis",
  communes = dbGetQuery(con, "SELECT * FROM limiteadmin.communes_paca")
)

write.xlsx(standard_final,"donnees_silene.xlsx")
