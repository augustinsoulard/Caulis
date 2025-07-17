-- Flore patrimoniale et normale 10 m autour de la zone d'étude
SELECT ps.*
FROM bibliotaxa.point_silene_view ps
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 10)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (43)
) AS buffer_zone
ON ST_Intersects(ps.geom, buffer_zone.geom_buffer);

-- Flore patrimoniale et normale 3000 m autour de la zone d'étude
SELECT ps.*
FROM bibliotaxa.point_silene_view ps
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 3000)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (24)
) AS buffer_zone
ON ST_Intersects(ps.geom, buffer_zone.geom_buffer);
