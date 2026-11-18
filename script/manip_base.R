renv::install("devtools")

usethis::use_git_ignore()# ne pas transmettre les .RData etc... (déjà sur le projet)


# NAMESPACE
roxygen2::roxygenise()


# (Re)génère la doc et installe ton package ####
devtools::install(dependencies = TRUE, force = TRUE)
devtools::document()  # pour régénérer la documentation
devtools::build()     # pour construire le package
# puis si tu veux tester
devtools::load_all()


# usethis::create_package()  # le package s'appelle désormais "caulis" (à la racine du dépôt)





# Méthode problème packages  ####
renv::activate()

# Installe les 4 dépendances + quelques deps usuelles de sf
renv::install(c("rinat", "leaflet"))
Y
# Optionnel : vérifie les libs externes vues par sf
sf::sf_extSoftVersion()

# Fige l’état de l’env
renv::snapshot()


#############Nettoyage après corrumtion
devtools::clean_dll()  # Nettoie les DLLs compilées
devtools::clean_vignettes()  # Nettoie les vignettes
devtools::clean_source_pkg()  # Nettoie les sources
# remove.packages("caulis")  # ancien nom : caulisroot



