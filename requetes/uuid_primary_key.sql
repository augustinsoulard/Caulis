-- Retirer la clef primaire existante
ALTER TABLE statuts.path_photo_esp DROP CONSTRAINT data_fiche_evee_occitanie_pkey_3;

-- AJouter une colonne uuid en clé primaire
ALTER TABLE statuts.path_photo_esp
ADD COLUMN id uuid DEFAULT gen_random_uuid();