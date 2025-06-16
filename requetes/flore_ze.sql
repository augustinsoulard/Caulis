-- Pour nos données internes
SELECT df.*
FROM donnees.flore df
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 100)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (24,29)
) AS buffer_zone
ON ST_Intersects(df.geom, buffer_zone.geom_buffer);

-- Pour la bibliographie
SELECT df.*
FROM bibliotaxa.point_silene_view df
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 100)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (43)
) AS buffer_zone
ON ST_Intersects(df.geom, buffer_zone.geom_buffer);
