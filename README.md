# Caulis

Caulis (la tige, en latin) est l'architecture de travail R pour les écologues botanistes : des données et des outils structurants auxquels se rajoute l'expertise naturaliste.

## Installation du package

```r
# Depuis GitHub
devtools::install_github("augustinsoulard/Caulis")

# En local (clone du dépôt)
devtools::install("chemin/vers/Caulis")
```

```r
library(caulis)
```

## Contenu du package (dossier `R/`)

- **Connexion & PostgreSQL/PostGIS** : `copo()`, `write_to_schema()`, `insert_on_conflict()`, `inat_from_polygon()`
- **Taxonomie / TAXREF** : `find_taxaref()`, `findtaxa()`, `updatetaxa()`, `majuscule_hors_premier_mot()`, `trigrammisation()`
- **iNaturalist** : `scrap_data_inat()`
- **SIG & cartographie** : `charger_gpkg()`, `crible_point_to_atlas_grid()`, `atlas_grid_map_for_spsheet()`, `qbiometosilene()`
- **Habitats EUNIS/HIC** : `hablegendation()`, `left_until_dash()`, `right_after_dash()`, `rarete_occurence()`, `taxon_hab()`, `find_taxon_hab()`, `hab_join()`, `hab_match()`
- **Phytosociologie** : `contingentation()`
- **Divers** : `load_data()`

## Configuration locale : le fichier `.env`

Tous les chemins machine (fichier des secrets, exiftool, dossiers de données externes) sont lus via des **variables d'environnement** définies dans un fichier `.env` à la racine du projet :

- `.env` : vos valeurs réelles — **jamais committé** (dans `.gitignore`)
- `.env.example` : le modèle à copier, committé

Le package charge automatiquement le `.env` à son chargement (`charger_env()` dans `R/env.R`). Clés utilisées :

| Variable | Rôle | Exemple |
|---|---|---|
| `CAULIS_RENVIRON` | Fichier des **secrets** (PGUSER, PGPASSWORD, clés API) — externe au dépôt | `D:/NextCloud/Documents/A_PERSO/Administratif/hz/.Renviron` |
| `CAULIS_EXIFTOOL` | Chemin de `exiftool.exe` | `D:/Logiciel/ExifTool/exiftool.exe` |
| `CAULIS_DRIVE_PARTAGE` | Racine du Drive partagé (données clients) | `G:/Drive partagés` |
| `CAULIS_TEMP` | Dossier temporaire | `D:/TEMP` |
| `CAULIS_DATA_DIR` | Racine des données du projet (défaut `data`) | `data` |

Lecture dans le code : `caulis_env("CAULIS_RENVIRON")` (avec valeur par défaut en 2e argument). Aucun identifiant n'est en dur dans le dépôt : `copo()` lit `CAULIS_RENVIRON`, qui pointe vers le `.Renviron` externe contenant `PGUSER`/`PGPASSWORD`.

## Outils projet (hors build du package)

Le dépôt contient aussi, exclus du package via `.Rbuildignore` : `script/` (scripts d'analyse), `requetes/` (SQL), `rmarkdown/` (rapports), `style/` (styles QGIS/SLD), `data/` (jeux de données), `doc/`, `ai/`, `modeleur/`.

## Développement

```r
devtools::load_all(".")   # charger le package en dev
devtools::document(".")   # régénérer NAMESPACE + man/
devtools::check(".")      # R CMD check
```

Voir aussi `dev/maj_caulis.R`.

## Historique

Ancien package `caulisroot` (archivé sur GitHub) fusionné dans `caulis` à partir de la v0.10.0.
