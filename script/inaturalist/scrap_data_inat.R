if(!require("caulisroot")){install.packages("caulisroot")} ; library("caulisroot")

con = copo()
scrap_data_inat(requete=NULL,
                           year=NULL,
                           maxresult=900,
                           filter_user_login = "augustinsoulard")
  