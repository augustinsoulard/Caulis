SELECT
    p.releve_artificiel AS releve,
    'inconnue' AS strate,
    1 AS abondance_dominance,
    t.lb_nom AS espece
FROM phytosocio.releve_artificiel_esp_mamp p
JOIN public.taxrefv18 t ON p.cd_ref = t.cd_nom
WHERE p.date_debut > '2020-01-01'
  AND p.releve_artificiel IN (
      SELECT releve_artificiel
      FROM phytosocio.releve_artificiel_esp_mamp
      GROUP BY releve_artificiel
      HAVING COUNT(*) >= 3
  );