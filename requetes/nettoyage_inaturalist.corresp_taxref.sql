SELECT * FROM inaturalist.corresp_taxref
WHERE cd_nom != cd_ref::text

SELECT * FROM inaturalist.corresp_taxref
WHERE lb_nom_valide = 'NA'

SELECT * FROM inaturalist.corresp_taxref
WHERE cd_ref IS NULL OR lb_nom_syn = '_NOMATCH'