CREATE TEMP TABLE bdc_statuts_flore AS
SELECT *
FROM bdc_statuts_18 b
WHERE b."CD_NOM" IN (SELECT cd_ref FROM public."taxrefv18_FR_plantae_ref")
   OR b."CD_REF" IN (SELECT cd_ref FROM public."taxrefv18_FR_plantae_ref")
  AND (
       "LB_ADM_TR" IN ('Monde', 'Europe')
    OR "CD_ISO3166_1" IN ('FXX', 'FRA')
    OR "CD_ISO3166_2" IN ('FR-13','FR-04','FR-05','FR-06','FR-83','FR-84','FR-U')
  );


CREATE TEMP TABLE bdc_statuts_flore_col AS
SELECT 
  "CD_REF",
  CONCAT("LB_TYPE_STATUT", '_', "LB_ADM_TR") AS lb_statut_col,
  "CODE_STATUT"
FROM bdc_statuts_flore;

-- Pivoter la table
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- renvoie la chaîne de colonnes à insérer dans le AS ct(...)
SELECT 
  'cd_ref TEXT, ' || string_agg(format('"%s" TEXT', lb_statut_col), ', ' ORDER BY lb_statut_col) AS column_list
FROM (
  SELECT lb_statut_col
  FROM bdc_statuts_flore_col
) AS cols;

SELECT *
FROM crosstab(
  $$
    SELECT 
      "CD_REF", 
      CONCAT("LB_TYPE_STATUT", '_', "LB_ADM_TR") AS lb_statut_col,
      "CODE_STATUT"
    FROM bdc_statuts_flore_col
    ORDER BY 1, 2
  $$,
  $$
    SELECT DISTINCT CONCAT("LB_TYPE_STATUT", '_', "LB_ADM_TR") 
    FROM bdc_statuts_flore_col
    ORDER BY 1
  $$
) AS ct (
  -- ⬇️ À remplacer par le résultat de la requête colonne générée ci-dessus
  cd_ref TEXT,
  "EN_Europe" TEXT,
  "EN_FR-13" TEXT,
  "LC_Monde" TEXT,
  ...
);