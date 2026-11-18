library(dplyr)
library(sf)
library(leaflet)
library(rinat)
library(stringr)
if(!require("rtaxref")){install_github("Rekyt/rtaxref")} ; library("rtaxref")
source("R/scrap_data_inat.R")
source("R/taxabase.R")
source("R/copo.R")
source("R/find_taxaref.R")
source("R/postgres/postgres_manip.R")
source("R/updatetaxa.R")
source("R/write_to_schema.R")

con = copo()
scrap_data_inat(requete=NULL,
                           year=NULL,
                           maxresult=1000,
                           filter_user_login = NULL)


dbDisconnect(con)
