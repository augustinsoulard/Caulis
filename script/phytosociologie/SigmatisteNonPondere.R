if(!require("sf")){install.packages("sf")} ; library("sf")
if(!require("foreign")){install.packages("foreign")} ; library("foreign") # Pour read.dbf
if(!require("RVAideMemoire")){install.packages("RVAideMemoire")} ; library("RVAideMemoire")
if(!require("vegan")){install.packages("vegan")} ; library("vegan")
source("function/taxabase.R")
source("function/habref_function.R")


#Chargement des données  KIT BOTA QFIELD
Flore = read.dbf("FLore/Flore.dbf")


# Prépration du tableau de relevé à partir du KIT BOTA QFIELD
FloreRELEVE = Flore %>% filter(!is.na(releve)==TRUE) %>% select(releve,lb_nom) %>% mutate(P = 1)
FloreRELEVE$CD_NOM = findtaxa(FloreRELEVE$lb_nom)


#Charement de taxref
TAXREFv17 = read.csv("data/TAXREF_17/TAXREFv17_FLORE_FR_SYN.csv",h=T)
TAXREFv17tojoin = TAXREFv17 %>% select(CD_NOM, LB_NOM)

#Chargement des données de références

PVF2 = taxon_hab(28)
PVF2$CD_NOM = updatetaxa(PVF2$CD_NOM)
PVF2 = PVF2[!match(PVF2$CD_NOM,FloreRELEVE$CD_NOM,nomatch=0)==0,]
PVF2 = PVF2 %>% filter(!is.na(CD_NOM))
PVF2 = left_join(PVF2,TAXREFv17tojoin,by='CD_NOM')

#Comptage des occurences des syntaxons en correspondance aux espèces
PVF2 %>% count(LB_HAB_FR,sort = T)



PVF2contingence = PVF2 %>% select(LB_HAB_FR,LB_NOM) %>% mutate(P = 1) %>%
  pivot_wider(names_from = LB_HAB_FR, values_from = P,values_fill = list(P = 0))

#Préparation du tableau de contingence
tabContingence = FloreRELEVE %>% pivot_wider(names_from = RELEVE, values_from = P, values_fill = list(P = 0))
tabContingence = left_join(tabContingence,PVF2contingence,by="LB_NOM")

#Nommer les lignes par les noms d'espèces
row.names(tabContingence) = tabContingence$LB_NOM

#Création du tableau DEDOU
DEDOU = tabContingence*-1+1
DEDOU = DEDOU %>%  select(-CD_NOM, -LB_NOM)
colnames(DEDOU) = paste0('n',colnames(DEDOU))
DEDOU = cbind(tabContingence,DEDOU)

#Réalisation de l'AFC
AFC<-cca(t(DEDOU[,3:ncol(DEDOU)]))
summaryAFC = summary(AFC)
summaryAFC

MVA.synt(AFC)
stressplot(AFC)

# Extraire les scores des espèces et des sites
species_scores <- as.data.frame(scores(AFC, display = "species"))
sites_scores <- as.data.frame(scores(AFC, display = "sites"))

# Ajouter les noms des espèces et des sites aux dataframes
species_scores$species <- rownames(species_scores)
sites_scores$sites <- rownames(sites_scores)

# Filtrer les relevés (sites) qui ne commencent pas par 'n'
sites_scores_filtered <- sites_scores %>%
  filter(!grepl("^n", rownames(sites_scores)))

# Visualiser avec ggplot2 et ggrepel
if(!require("ggrepel")){install.packages("ggrepel")} ; library("ggrepel")

ggplot() +
  geom_point(data = species_scores, aes(x = CA1, y = CA2), color = "blue") +
  geom_point(data = sites_scores_filtered, aes(x = CA1, y = CA2), color = "red") +
  geom_text_repel(data = species_scores, aes(x = CA1, y = CA2, label = species), color = "blue", max.overlaps = 20) +
  geom_text_repel(data = sites_scores_filtered, aes(x = CA1, y = CA2, label = sites), color = "red", max.overlaps = Inf) +
  labs(title = "AFC des données FloreRELEVE", x = "CA1", y = "CA2")
ggsave('AFC.jpg',  width = 3000,height =2000,units='px')

if(!require("xlsx")){install.packages("xlsx")} ; library("xlsx")
write.xlsx(tabContingence,"tabContingence.xlsx")
