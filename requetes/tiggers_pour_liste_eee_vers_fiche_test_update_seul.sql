UPDATE fiches.data_fiche_evee_occitanie f
SET 
    nom_vern = split_part(s.nom_vern_invmmed, ',', 1),
    nom_valide = s.nom_taxon_invmed_et_ajout
FROM statuts.liste_eee_occitanie_invmed_rmc s
WHERE s.cd_ref::integer = f.cd_nom; -- cast de cd_ref en entier
