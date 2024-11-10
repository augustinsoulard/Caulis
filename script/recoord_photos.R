if(!require("readxl")){install.packages("readxl")} ; library("readxl")
if(!require("writexl")){install.packages("writexl")} ; library("writexl")
if(!require("exifr")){install.packages("exifr")} ; library("exifr")
if(!require("exiftoolr")){install.packages("exiftoolr")} ; library("exiftoolr")
if(!require("sf")){install.packages("sf")} ; library("sf")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")




dossier_photos <- "D:/Association/SLP/Ateliers/20241110_Bryologie/QFLORE/DCIM"
photos <- list.files(dossier_photos, pattern = "\\.jpe?g$", full.names = TRUE)


metadata <- read_exif(photos)


###Lecture geopackage
fichier_gpkg <- "D:/Association/SLP/Ateliers/20241110_Bryologie/QFLORE/donnees.gpkg"
photo <- st_read(fichier_gpkg,layer = "photo")
donnees <- st_read(fichier_gpkg,layer = "Flore_P")
photo = left_join(photo,donnees,by=c("Reference"="uuid"))
photo$geometry = as.character(photo$geometry)
photo$GPSLatitude = 0
photo$GPSLongitude = 0

for( i in 1:nrow(photo)){
  cat(i,"\n")
  photo$GPSLatitude[i]= str_extract_all(photo$geometry[i], "-?\\d*\\.?\\d+")[[1]][1]
  photo$GPSLongitude[i] = str_extract_all(photo$geometry[i], "-?\\d*\\.?\\d+")[[1]][2]
  photo$nom_fichier[i]= str_sub(photo$Photo[i], 6,nchar(photo$Photo[i]))
}

data_sf  = st_as_sf(photo, coords = c("GPSLatitude", "GPSLongitude"), crs = 2154)
data_wgs84 <- st_transform(data_sf, crs = 4326)

for( i in 1:nrow(data_wgs84)){
  cat(i,"\n")
  data_wgs84$GPSLatitude[i]= str_extract_all(data_wgs84$geometry[i], "-?\\d*\\.?\\d+")[[1]][2]
  data_wgs84$GPSLongitude[i] = str_extract_all(data_wgs84$geometry[i], "-?\\d*\\.?\\d+")[[1]][1]
}
photo = data_wgs84

#suppression des NA :
photo = photo[!is.na(photo$nom_fichier),]

exiftool_path <- "D:/Logiciel/ExifTool/exiftool.exe"
# Boucle pour modifier les métadonnées GPS de chaque photo
for (i in seq_along(photos)) {
  # Nom du fichier photo sans le chemin complet
  nom_fichier <- basename(photos[i])
  
  # Filtrer pour obtenir les nouvelles coordonnées de ce fichier
  nouvelle_coord <- photo[photo$nom_fichier == nom_fichier,]
  
  if (nrow(nouvelle_coord) > 0) {
    latitude <- nouvelle_coord$GPSLatitude
    longitude <- nouvelle_coord$GPSLongitude
  }
  # Sauvegarder les nouvelles coordonnées GPS dans les photos
  system2(exiftool_path, args = c(paste0("-GPSLatitude=",latitude), paste0("-GPSLongitude=",longitude), photos[i]))
}

# Vérificaiton
metadata_modifiees <- read_exif(photos)
metadata_modifiees$GPSLatitude

