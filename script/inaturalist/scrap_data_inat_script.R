library(dplyr)
library(sf)
library(leaflet)
library(rinat)
library(stringr)
if(!require("rtaxref")){install_github("Rekyt/rtaxref")} ; library("rtaxref")
library(caulis)

con = copo()
scrap_data_inat(requete=NULL,
                           year=NULL,
                           maxresult=1000,
                           filter_user_login = NULL)


dbDisconnect(con)
