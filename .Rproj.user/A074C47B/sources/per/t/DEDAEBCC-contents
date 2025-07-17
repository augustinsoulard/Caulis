if(!require("caulisroot")){install.packages("caulisroot")} ; library("caulisroot")

# Charger les bibliotheques necessaires
if(!require("readxl")){install.packages("readxl")} ; library("readxl")
if(!require("tidyverse")){install.packages("tidyverse")} ; library("tidyverse")
source("function/taxabase.R")
source("function/postgres/postgres_manip.R")

con = copo()

#Import de la base de connaissance
BDC_STATUTS <-   dbGetQuery(con, "SELECT * FROM public.bdc_statuts_18")



# Import de TAXREF
TAXREF_FLORE_FR <- dbGetQuery(con, "SELECT * FROM public.taxrefv18_fr_plantae_ref") ### MODIFIER LA VERSION TAXREF
TAXREF_FLORE_FR$CD_NOM = as.character(TAXREF_FLORE_FR$cd_nom)### MODIFIER LA VERSION TAXREF

# Filtre de la base de connaissance pour la flore
BDC_STATUTS_FLORE = BDC_STATUTS %>% 
  filter(BDC_STATUTS$CD_NOM %in% TAXREF_FLORE_FR$cd_ref | BDC_STATUTS$CD_REF %in% TAXREF_FLORE_FR$cd_ref) %>%
  filter(LB_ADM_TR %in% c("Monde","Europe") |
           CD_ISO3166_1 %in% c("FXX","FRA") | 
           CD_ISO3166_2 %in% c("FR-13","FR-04","FR-05","FR-06","FR-83","FR-84","FR-U"))
#Creer le futur nom des colonnes
BDC_STATUTS_FLORE$LB_STATUT_COL = make.names(paste0(BDC_STATUTS_FLORE$LB_TYPE_STATUT,"_",
                                                       BDC_STATUTS_FLORE$LB_ADM_TR))


# Traitement du tableau pour l'horizontaliser

# Créer une table des statuts uniques pour chaque CD_REF
BDC_TO_JOIN <- BDC_STATUTS_FLORE %>%
  distinct(CD_REF, LB_STATUT_COL, CODE_STATUT) %>%
  rename(LB_STATUT = CODE_STATUT)

# Transformer les statuts en colonnes avec pivot_wider
BDC_TO_JOIN_WIDE <- BDC_TO_JOIN %>%
  pivot_wider(names_from = LB_STATUT_COL, values_from = LB_STATUT, values_fn = list(LB_STATUT = ~ paste(unique(.), collapse = ", ")))

# Jointure finale avec TAXREF_FLORE_FR
TAXREF_FLORE_JOIN <- TAXREF_FLORE_FR %>%
  left_join(BDC_TO_JOIN_WIDE, by = c("cd_ref"="CD_REF"))


#### Ajout des plantes indicatrices ZH et des EEEs
#Chargement flore ZH
FloreZH = dbGetQuery(con, "SELECT * FROM statuts.florezh")
FloreZH$cd_ref = updatetaxa(FloreZH$cd_nom)
TAXREF_FLORE_JOIN = left_join(TAXREF_FLORE_JOIN,FloreZH,by=c("cd_ref"="cd_ref"))

# Chargement flore EEE
TAB_EVEE_PACA <- dbGetQuery(con, "SELECT * FROM statuts.evee_paca")
TAB_EVEE_PACA$cd_ref = updatetaxa(as.numeric(TAB_EVEE_PACA$cd_nom))
TAB_EVEE_PACA = TAB_EVEE_PACA %>% dplyr::select(cd_ref,categorie_paca = categorie_paca)
TAB_EVEE_PACA$cd_ref = as.integer(TAB_EVEE_PACA$cd_ref)

# Jointure flore EVEE
TAXREF_FLORE_JOIN = left_join(TAXREF_FLORE_JOIN,TAB_EVEE_PACA,by=c("cd_ref"="cd_ref"))

# Chargement enjeu CBN
ENJEU_CBN <- dbGetQuery(con, "SELECT * FROM statuts.enjeux_med_reseda_2020")
ENJEU_CBN$cd_refv18 = as.double(ENJEU_CBN$cd_refv18)
ENJEU_CBN = ENJEU_CBN %>% dplyr::select(CD_NOM=cd_refv18,ENJEU_CONSERVATION=enjeu)

# Jointure enjeu CBN
TAXREF_FLORE_JOIN$CD_NOM = as.double(TAXREF_FLORE_JOIN$CD_NOM)
TAXREF_FLORE_JOIN = left_join(TAXREF_FLORE_JOIN,ENJEU_CBN,by=c("CD_NOM"="CD_NOM"))


TAXREF_FLORE_JOIN$TRIGRAMME = trigrammisation(nom_valide =TAXREF_FLORE_JOIN$nom_valide,
                                              lb_nom = TAXREF_FLORE_JOIN$lb_nom,
                                              rang = TAXREF_FLORE_JOIN$rang)
#Selection des colonnes pour le tableau final
TAXREF_FLORE_JOIN = TAXREF_FLORE_JOIN %>% dplyr::select(cd_nom = CD_NOM,
                                                       trigramme=TRIGRAMME,
                                                       nom_valide=nom_valide,
                                                       nom_vern=nom_vern,
                                                       famille=famille,
                                                       sous_famille=sous_famille,
                                                       indigenat = fr, 
                                                       evee = categorie_paca,
                                                       dh = Directive.Habitat_France.métropolitaine,
                                                       pn = Protection.nationale_France.métropolitaine,
                                                       lrn = Liste.rouge.nationale_France.métropolitaine,
                                                       pr = Protection.régionale_Provence.Alpes.Côte.d.Azur,
                                                       pr_corr = Protection.régionale_Provence.Alpes.Côte.d.Azur,
                                                       lrr = Liste.rouge.régionale_Provence.Alpes.Côte.d.Azur,
                                                       znieff = ZNIEFF.Déterminantes_Provence.Alpes.Côte.d.Azur,
                                                       pd04 = Protection.départementale_Alpes.de.Haute.Provence,
                                                       pd05 = Protection.départementale_Hautes.Alpes,
                                                       pd06 = Protection.départementale_Alpes.Maritimes,
                                                       pd83 = Protection.départementale_Var,
                                                       pd84 = Protection.départementale_Vaucluse,
                                                       enjeu_cbn = ENJEU_CONSERVATION,
                                                       indicatrice_zh = indic_zh,
                                                       barcelonne =Convention.de.Barcelone_France.métropolitaine,
                                                       berne = Convention.de.Berne_France.métropolitaine,
                                                       mondiale = Liste.rouge.mondiale_Monde,
                                                       europe = Liste.rouge.européenne_Europe
)

## Mise en forme colonne ZNIEFF
TAXREF_FLORE_JOIN[!is.na(TAXREF_FLORE_JOIN$znieff),]$znieff = "D"

#Création de la colonne Protection AuRA
protectionpaca <- function(x) {
  valeur <- NULL
  if (!is.na(x["pn"]) && x["pn"] != "-") {
    valeur <- paste0(valeur, " ", "PN")
  }
  if (!is.na(x["pr"]) && x["pr"] != "-") {
    valeur <- paste0(valeur, " ", "PR")
  }
  if (!is.na(x["pd04"]) && x["pd04"] != "-") {
    valeur <- paste0(valeur, " ", "PD04")
  }
  if (!is.na(x["pd05"]) && x["pd05"] != "-") {
    valeur <- paste0(valeur, " ", "PD05")
  }
  if (!is.na(x["pd06"]) && x["pd06"] != "-") {
    valeur <- paste0(valeur, " ", "PD06")
  }
  if (!is.na(x["pd83"]) && x["pd83"] != "-") {
    valeur <- paste0(valeur, " ", "PD83")
  }
  if (!is.na(x["pd84"]) && x["pd84"] != "-") {
    valeur <- paste0(valeur, " ", "PD84")
  }
  if (is.null(valeur)) {
    valeur <- "-"
  }
  return(valeur)
}


TAXREF_FLORE_JOIN$protection_paca = apply(TAXREF_FLORE_JOIN,1,protectionpaca)

###############Ajout de baseflor################
baseflor_bryoTAXREF <- dbGetQuery(con, "SELECT * FROM public.baseflor_bryo_taxref")

baseflor_bryoTAXREF = baseflor_bryoTAXREF %>% select(CD_NOM=cd_ref,
                                                           floraison=floraison,ecologie = `CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)`,
                                                           syntaxon = INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE)

# Vecteur de correspondance des chiffres aux mois
correspondance_mois <- c("Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre")

# Fonction pour remplacer un chiffre par un mois
remplacer_chiffre_par_mois <- function(chiffre) {
  chiffres <- as.numeric(unlist(strsplit(chiffre, "-")))
  mois <- paste(correspondance_mois[chiffres], collapse = "-")
  return(mois)
}

# Appliquer la fonction sur la colonne du dataframe
baseflor_bryoTAXREF$floraison <- sapply(baseflor_bryoTAXREF$floraison, remplacer_chiffre_par_mois)

# jointure avec le reste du tableau
baseflor_bryoTAXREF$cd_ref = as.double(baseflor_bryoTAXREF$cd_ref)
joinbaseflor = left_join(TAXREF_FLORE_JOIN,baseflor_bryoTAXREF,by=c("cd_nom"="cd_ref"))

#Ajout de BDD_FICHE_FLORE
#Si pas de BDD_FLore :
joinbaseflor <- joinbaseflor %>% mutate(PATH_IMG = NA_character_,
         TEXTE_LEGEND_IMG = NA_character_)
join_BDD_IMG = joinbaseflor
# BDD_FICHE_FLORE <- read_excel("../../../BDD_FLORE_CONSTRUCT/BDD_FICHE_FLORE/BDD_FICHE_FLORE.xlsx", 
#                               sheet = "IMG")
# BDD_FICHE_FLORE = BDD_FICHE_FLORE %>% select(CD_NOM,PATH_IMG,TEXTE_LEGEND_IMG)
# join_BDD_IMG = left_join(joinbaseflor,BDD_FICHE_FLORE,by="CD_NOM")


#Retrait des duplicats
join_BDD_IMG = join_BDD_IMG[!duplicated(join_BDD_IMG$cd_nom),]
TAB_TO_EXPORT=join_BDD_IMG




#Enregistrement du tableau a integrer à la methode enjeu PACA
TABLEAU_GENERAL = TAB_TO_EXPORT %>% dplyr::select(
  cd_nom = cd_nom,
  trigramme = trigramme,
  nom_valide = nom_valide,
  nom_vern = nom_vern,
  famille = famille,
  sous_famille = sous_famille,
  indigenat = indigenat,
  evee = evee,
  dh = dh,
  pn = pn,
  lrn = lrn,
  pr = pr,
  pr_corr = pr_corr,
  lrr = lrr,
  znieff = znieff,
  pd04 = pd04,
  pd05 = pd05,
  pd06 = pd06,
  pd83 = pd83,
  pd84 = pd84,
  enjeu_cbn = enjeu_cbn,
  indicatrice_zh = indicatrice_zh,
  barcelonne = barcelonne,
  berne = berne,
  mondiale = mondiale,
  europe = europe,
  protection_paca = protection_paca,
  floraison = floraison,
  ecologie = `CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)`,
  syntaxon = INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE,
  path_img = PATH_IMG,
  texte_legend_img = TEXTE_LEGEND_IMG
)

write.csv(TABLEAU_GENERAL,file = "TAB_GEN_METH_ENJEU_PACA.csv",row.names = F,fileEncoding = "UTF-8",na="-")




