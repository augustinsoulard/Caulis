-- 1️⃣ Fonction qui met à jour la table fiches.data_fiche_evee_occitanie
CREATE OR REPLACE FUNCTION fiches.maj_fiche_depuis_statuts()
RETURNS TRIGGER AS $$
BEGIN
    -- Met à jour uniquement les colonnes nécessaires
    UPDATE fiches.data_fiche_evee_occitanie f
    SET 
        nom_vernaculaire = NEW.nom_vern_invmmed,
        nom_valide = NEW."nom_taxon_invmed&ajout",
        rmc_mediterraneen_hors_corse = NEW.rmc_mediterraneen_hors_corse,
        rmc_continental = NEW.rmc_continental,
        invmed_categorie_occ = NEW.invmed_categorie_occ
    WHERE f.cd_nom = NEW.cd_ref;  -- ⚠ correspondance cd_nom (table fiches) ↔ cd_ref (table statuts)

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 2️⃣ Trigger qui se déclenche UNIQUEMENT si certaines colonnes changent
DROP TRIGGER IF EXISTS trig_maj_fiche ON statuts.liste_eee_occitanie_invmed_rmc;

CREATE TRIGGER trig_maj_fiche
AFTER UPDATE OF 
    nom_vern_invmmed, 
    "nom_taxon_invmed&ajout", 
    rmc_mediterraneen_hors_corse, 
    rmc_continental, 
    invmed_categorie_occ
ON statuts.liste_eee_occitanie_invmed_rmc
FOR EACH ROW
EXECUTE FUNCTION fiches.maj_fiche_depuis_statuts();


-- 3️⃣ (Optionnel) Trigger pour la création d’une nouvelle ligne
DROP TRIGGER IF EXISTS trig_insert_fiche ON statuts.liste_eee_occitanie_invmed_rmc;

CREATE TRIGGER trig_insert_fiche
AFTER INSERT
ON statuts.liste_eee_occitanie_invmed_rmc
FOR EACH ROW
EXECUTE FUNCTION fiches.maj_fiche_depuis_statuts();


CREATE INDEX IF NOT EXISTS idx_fiches_cd_nom 
ON fiches.data_fiche_evee_occitanie(cd_nom);

CREATE INDEX IF NOT EXISTS idx_statuts_cd_ref 
ON statuts.liste_eee_occitanie_invmed_rmc(cd_ref);

