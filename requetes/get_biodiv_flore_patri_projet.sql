-- get_flore_patri_biodiv_projet
SELECT pf.*, met.cd_nom,met.indigenat,met.invmed,met."DH",met."LRN",met."LRR",met."ZNIEFF",met."ENJEU_CBN",
met."indicatrice_ZH",met.floraison,met.ecologie,met.interet_paca,met.protection_paca_1 AS protection
FROM donnees.flore pf
JOIN statuts.method_enjeu_paca met ON met.cd_nom = pf.cd_ref
WHERE pf.projet = 'Combes Jauffrey'
  AND (
      met.interet_paca IN ('MAJEUR', 'TRES FORT', 'FORT', 'MODERE', 'DD')
      OR met.protection_paca <> '-'
  );