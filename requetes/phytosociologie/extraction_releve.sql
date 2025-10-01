SELECT phytosocio.releve_esp.*
FROM phytosocio.releve_esp
INNER JOIN phytosocio.releve ON phytosocio.releve_esp.releve = phytosocio.releve.releve
WHERE phytosocio.releve.habitat_type = 'Pelouse sèche';