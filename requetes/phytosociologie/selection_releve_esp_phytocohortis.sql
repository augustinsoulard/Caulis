SELECT 
p.espece,
p.abondance_dominance,
p.releve,
'NA' AS strate,
p.cd_nom
FROM phytosocio.releve_esp p
JOIN phytosocio.releve t ON p.releve = t.releve
WHERE t.projet = '30'
-- Ajouter une contrainte sur habitat_type
-- AND habitat_type = 'Pelouses sèches'