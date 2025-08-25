CREATE OR REPLACE VIEW statuts.eee_faune_listes_occitanie_rmc AS
SELECT
    COALESCE(o.cd_ref, r.cd_nom) AS cd_nom,
    COALESCE(o.lb_nom, r.lb_nom) AS lb_nom,
    -- Autres colonnes spécifiques à chaque table
    o.categorie_occ, o.impact_majoritaire,  -- Colonnes spécifiques à la table Occitanie
    r.mediterraneen_hors_corse, r.cours_eau_rapide,r.cours_eau_lent,r.zones_humides_continentales,r.zones_humides_littorales   -- Colonnes spécifiques à la table RMC
FROM
    statuts.eee_faune_liste_occitanie o
FULL OUTER JOIN
    statuts.eee_faune_liste_rmc r
ON
    o.cd_ref = r.cd_nom;
