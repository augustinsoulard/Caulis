CREATE OR REPLACE VIEW view_baseflore_bryo_taxref AS
SELECT
    b.*,
    COALESCE(c.lb_nom, b."lb_nom") AS lb_nom_mis_a_jour,
    COALESCE(c.floraison, b.floraison) AS floraison_mise_a_jour,
    COALESCE(c.caract_eco_hab_optimal, b."CARACTERISATION_ECOLOGIQUE_(HABITAT_OPTIMAL)") AS caract_eco_hab_optimal_mis_a_jour,
    COALESCE(c.indicat_phytoscio_caract, b."INDICATION_PHYTOSOCIOLOGIQUE_CARACTERISTIQUE") AS indicat_phytoscio_caract_mis_a_jour
FROM
     public.baseflor_bryo_taxref b
LEFT JOIN
    public.correctif_baseflor_bryo c ON b.cd_ref::text = c.cd_nom::text;
