CREATE OR REPLACE VIEW statuts.vw_fiche_eee_flore_occitanie AS
WITH best_photo AS (
    SELECT p.*
    FROM statuts.path_photo_esp p
    JOIN (
        SELECT cd_nom, MAX(priorite) AS max_priorite
        FROM statuts.path_photo_esp
        GROUP BY cd_nom
    ) f ON p.cd_nom = f.cd_nom AND p.priorite = f.max_priorite
),
invmed AS (
    SELECT
        cd_ref AS cd_nom,
        invmed_categorie_occ,
        invmed_origine,
        invmed_milieux,
        invmed_date_intro,
        rmc_mediterraneen_hors_corse
    FROM statuts.liste_eee_occitanie_invmed_rmc
)
SELECT
    bp.cd_nom,
    bp.priorite,
    bp.path,
    invmed.invmed_categorie_occ,
    invmed.invmed_origine,
    invmed.invmed_milieux,
    invmed.invmed_date_intro,
    invmed.rmc_mediterraneen_hors_corse,
    to_jsonb(t1) AS dscpt_esp,
    to_jsonb(t2) AS dscpt_habitats_esp,
    to_jsonb(t3) AS dscpt_risque_eee,
    -- Colonnes de public.taxrefv18
    tax."nom_valide",
    tax."nom_vern",
    tax."cd_ref" AS cd_ref_taxref,
    tax."famille",
    tax."fr",
    -- Colonnes de public.baseflor_bryo_taxref
    bf."TYPE_BIOLOGIQUE",
    bf."CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)",
    bf."floraison",
    bf."Lumière",
    bf."Température",
    bf."Continentalité",
    bf."Humidité_atmosphérique",
    bf."Humidité_édaphique",
    bf."Réaction_du_sol_(pH)",
    bf."Niveau_trophique",
    bf."Salinité",
    bf."Texture",
    bf."Matière_organique",
    bf."Nutrients"
FROM best_photo bp
LEFT JOIN statuts.dscpt_esp t1 USING (cd_nom)
LEFT JOIN statuts.dscpt_habitats_esp t2 USING (cd_nom)
LEFT JOIN statuts.dscpt_risque_eee t3 USING (cd_nom)
LEFT JOIN invmed USING (cd_nom)
LEFT JOIN public.taxrefv18 tax ON bp.cd_nom = tax."cd_nom"
LEFT JOIN public.baseflor_bryo_taxref bf ON tax."cd_ref" = bf."cd_ref";
