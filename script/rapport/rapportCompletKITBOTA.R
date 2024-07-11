################################################################################
###################CREATION DU FICHIER RMARKDOWN################################
################################################################################
if(!require("knitr")){install.packages("knitr")} ; library("knitr")
if(!require("flextable")){install.packages("flextable")} ; library("flextable")
if(!require("sf")){install.packages("sf")} ; library("sf")

#Chargement des fichiers
pathHABITATS_POLYGONES = "Habitats/HABITATS_POLYGONES.shp"
pathRELEVE_HABITAT = "Habitats/RELEVE_HABITAT.shp"
HABITATS_POLYGONES = st_read(pathHABITATS_POLYGONES)
RELEVE_HABITAT = st_read(pathRELEVE_HABITAT)

# Fonction qui enregistre les sorties de R pour 
con <- file("rapportCompletKITBOTA.Rmd", open = "wt", encoding = "UTF-8")
sink(con,split=T)
cat("---
title: \"Rapport complet KIT BOTA QFIELD\"
date: \"`r Sys.Date()`\"
output:
  word_document: 
    reference_docx: \"style/word_styles_references.dotm\"
---
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
``` \n \n")
for(i in 1:nrow(HABITATS_POLYGONES)){
  
  
}


LIST_RELEVE = levels(as.factor(DATARELEVE_JOIN$RELEVE))
for(i in 1:length(LIST_RELEVE)){
  cat("### Relevé : ",LIST_RELEVE[i],"\n \n")
  JOIN_DATA[JOIN_DATA$RELEVE==LIST_RELEVE[i],]
  cat("Tableau des espèces : 
```{r ",paste0("ESP",LIST_RELEVE[i]),",echo=TRUE}
flextable(JOIN_DATA[JOIN_DATA$RELEVE==LIST_RELEVE[",i,"],])
``` 
\n \n")
  cat("Tableau des relevés : 
```{r", paste0("RELEVE",LIST_RELEVE[i]),",echo=TRUE}
knitr::kable(DATARELEVE_JOIN[DATARELEVE_JOIN$RELEVE==LIST_RELEVE[",i,"],])
``` 
\n \n")
  cat(paste0("![](",DATAPHYTO[DATAPHYTO$RELEVE == LIST_RELEVE[i],]$RP_PHOTO1[1],") \n \n"))
  
}


### Fin de la session d'enregistrement du texte
sink()
close(con)

#Test knit
rmarkdown::render("rapportCompletKITBOTA.Rmd",output_format = "word_document",output_file = "rapportCompletKITBOTA.docx")


