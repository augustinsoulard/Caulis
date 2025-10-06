SELECT
    h.cd_hab,
    h.lb_code,
    h.lb_hab_fr AS Habitat,
    STRING_AGG(DISTINCT t.nom_cite, ', ') AS especes_diagnostics,
    d.valeurs AS Description,
    STRING_AGG(DISTINCT s.cd_source, ', ') AS Sources
FROM
    habref.habref_70 h
LEFT JOIN
    habref.habref_corresp_taxon_70 ct ON h.cd_hab = ct.cd_hab_entree
LEFT JOIN
    habref.habref_corresp_taxon_70 t ON ct.cd_nom = t.cd_nom
LEFT JOIN
    habref.habref_description_70 d ON h.cd_hab = d.cd_hab
LEFT JOIN
    habref.habref_lien_sources_70 s ON h.cd_hab = s.cd_hab_lien_sources
WHERE
    h.LB_HAB_FR LIKE '%Teucrio polii-Festucetum cinereae%'
    --OR d.VALEURS LIKE '%Xerobromion%'
	-- OR h.lb_code LIKE '%E1.272%'
GROUP BY
    h.cd_hab, h.lb_code, h.lb_hab_fr, d.valeurs;

--- Le script abouti
SELECT
    h.cd_hab,
    h.lb_code,
    h.lb_hab_fr AS Habitat,
    STRING_AGG(DISTINCT t.nom_cite, ', ') AS especes_diagnostics,
    STRING_AGG(DISTINCT d.lb_hab_field || ' : ' || d.valeurs, '; ') AS description,
    STRING_AGG(DISTINCT hc.lb_code || ': ' || hc.lb_hab_fr, '; ') AS habitats_correspondants,
	STRING_AGG(DISTINCT src.lb_source_complet, ', ') AS sources
FROM
    habref.habref_70 h
LEFT JOIN
    habref.habref_corresp_taxon_70 ct ON h.cd_hab = ct.cd_hab_entree
LEFT JOIN
    habref.habref_corresp_taxon_70 t ON ct.cd_nom = t.cd_nom
LEFT JOIN
    habref.habref_description_70 d ON h.cd_hab = d.cd_hab
-- Jointure avec la table de lien entre habitat et source
LEFT JOIN
    habref.habref_lien_sources_70 ls ON h.cd_hab = ls.cd_hab_lien_sources
-- Jointure avec la table des sources pour obtenir le nom complet
LEFT JOIN
    habref.habref_sources_70 src ON ls.cd_source = src.cd_source
LEFT JOIN
    habref.habref_corresp_hab_70 ch ON h.cd_hab = ch.cd_hab_entree
LEFT JOIN
    habref.habref_70 hc ON ch.cd_hab_sortie = hc.cd_hab
WHERE
    h.LB_HAB_FR LIKE '%Mesobromenion erecti%'
	--OR d.VALEURS LIKE '%Xerobromion%'
	--h.lb_code = 'E1.2'
	--t.nom_cite LIKE '%Adonis flammea%'
GROUP BY
    h.cd_hab, h.lb_code, h.lb_hab_fr;

