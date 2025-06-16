-- Flore patrimoniale et normale
SELECT ps.*
FROM bibliotaxa.point_silene_view ps
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 10)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (43)
) AS buffer_zone
ON ST_Intersects(ps.geom, buffer_zone.geom_buffer);

