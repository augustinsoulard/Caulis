SELECT column_name
FROM information_schema.columns
WHERE table_name = 'bdc_statuts_18'
  AND table_schema = 'public' -- ou ton schéma si différent
ORDER BY ordinal_position;

CREATE TABLE statuts.method_enjeu_paca_reordonnee AS
SELECT 
  "id",
  "cd_nom",
  "cd_ref",
  "trigramme",
  "nom_valide",
  "nom_vern",
  "famille",
  "sous_famille",
  "indigenat",
  "evee",
  "dh",
  "pn",
  "lrn",
  "pr",
  "lrr",
  "znieff",
  "pd04",
  "pd05",
  "pd06",
  "pd83",
  "pd84",
  "enjeu_cbn",
  "indicatrice_zh",
  "barcelonne",
  "berne",
  "mondiale",
  "europe",
  "protection_paca",
  "floraison",
  "ecologie",
  "syntaxon",
  "path_img",
  "texte_legend",
  "Point_indigenat",
  "Point_lrn",
  "Point_znieff",
  "Point_lrr",
  "Point_eee",
  "Point_enjeu_cbn",
   "point_biodiv",
  "total_point",
  "dd_rate",
  "interet_paca",
  "protection_paca_1"
FROM public.method_enjeu_paca
ORDER BY "nom_valide" ASC

ALTER TABLE public.method_enjeu_paca RENAME TO method_enjeu_paca_backup;

ALTER TABLE statuts.method_enjeu_paca_reordonnee RENAME TO method_enjeu_paca;

SELECT DISTINCT 
  m."cd_nom",
  m."nom_valide"
FROM statuts.method_enjeu_paca m
LEFT JOIN public.taxrefv18_fr_plantae_ref t ON m."cd_nom" = t."cd_nom"
WHERE t."cd_nom" IS NULL;

SELECT DISTINCT 
  t."cd_nom",
  t."nom_valide"
FROM public.taxrefv18_fr_plantae_ref t
LEFT JOIN statuts.method_enjeu_paca m ON t."cd_nom" = m."cd_nom"
WHERE m."cd_nom" IS NULL;


DELETE FROM statuts.method_enjeu_paca m
WHERE NOT EXISTS (
  SELECT 1
  FROM public.taxrefv18_fr_plantae_ref t
  WHERE t.cd_nom = m.cd_nom
);

SELECT c1.column_name
FROM information_schema.columns c1
JOIN information_schema.columns c2 
  ON c1.column_name = c2.column_name
WHERE c1.table_schema = 'statuts'
  AND c1.table_name = 'method_enjeu_paca'
  AND c2.table_schema = 'public'
  AND c2.table_name = 'taxrefv18_fr_plantae_ref'
ORDER BY c1.column_name;


INSERT INTO statuts.method_enjeu_paca (
  "cd_nom","cd_ref", "nom_valide","nom_vern", "famille", "sous_famille"
)
SELECT 
  t."cd_nom",t."cd_ref", t."nom_valide",t."nom_vern", t."famille", t."sous_famille"
FROM public.taxrefv18_fr_plantae_ref t
WHERE NOT EXISTS (
  SELECT 1
  FROM statuts.method_enjeu_paca m
  WHERE m.cd_nom = t.cd_nom
);


ALTER TABLE statuts.method_enjeu_paca
ALTER COLUMN "point_indigenat" TYPE INTEGER USING "point_indigenat"::integer,
ALTER COLUMN "point_lrn" TYPE INTEGER USING "point_lrn"::integer,
ALTER COLUMN "point_znieff" TYPE INTEGER USING "point_znieff"::integer,
ALTER COLUMN "point_lrr" TYPE INTEGER USING "point_lrr"::integer,
ALTER COLUMN "point_eee" TYPE INTEGER USING "point_eee"::integer,
ALTER COLUMN "point_enjeu_cbn" TYPE INTEGER USING "point_enjeu_cbn"::integer;


ALTER TABLE statuts.method_enjeu_paca
DROP COLUMN IF EXISTS total_point;

ALTER TABLE statuts.method_enjeu_paca
ADD COLUMN total_point INT GENERATED ALWAYS AS (
  COALESCE("point_indigenat", 0) +
  COALESCE("point_lrn", 0) +
  COALESCE("point_znieff", 0) +
  COALESCE("point_lrr", 0) +
  COALESCE("point_eee", 0) +
  COALESCE("point_enjeu_cbn", 0)+
  COALESCE("point_biodiv", 0)
) STORED;

