-- get_flore_patri_biodiv_projet
SELECT pf.*, met.*
FROM donnees.flore pf
JOIN statuts.method_enjeu_paca met ON met.cd_nom = pf.cd_ref
WHERE pf.projet = 'Combes Jauffrey'
  AND (
      met.interet_paca IN ('MAJEUR', 'TRES FORT', 'FORT', 'MODERE', 'DD')
      OR met.protection_paca <> '-'
  );