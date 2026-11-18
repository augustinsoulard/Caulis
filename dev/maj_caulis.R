# Mise à jour du package caulis : documentation (NAMESPACE + man/) puis chargement en dev
devtools::document(".")
devtools::load_all(".")

# Pour installer le package dans la librairie R :
# devtools::install(".")
