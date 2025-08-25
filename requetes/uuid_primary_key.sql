-- Retirer la clef primaire existante
ALTER TABLE statuts.path_photo_esp DROP CONSTRAINT data_fiche_evee_occitanie_pkey_3;

-- AJouter une colonne uuid en clé primaire
ALTER TABLE statuts.eee_faune_liste_occitanie
ADD COLUMN id uuid DEFAULT gen_random_uuid();

-- Ajouter un primary key avec une colonne existante
ALTER TABLE statuts.eee_faune_liste_occitanie ADD CONSTRAINT eee_faune_liste_occitanie_pkey PRIMARY KEY (cd_nom);

-- Vérifier qu'il n'y pas de doublon dans cd_nom
SELECT cd_nom, COUNT(*)
FROM statuts.eee_faune_liste_occitanie
GROUP BY cd_nom

-- Vérifier qu'il n'y pas de valeurs NULL dans cd_nom
SELECT COUNT(*) 
FROM statuts.eee_faune_liste_occitanie
WHERE cd_nom IS NULL;
HAVING COUNT(*) > 1;