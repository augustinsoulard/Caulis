SELECT ps.*
FROM bibliotaxa.point_silene ps
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 100)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (19, 20,41)
) AS buffer_zone
ON ST_Intersects(ps.geom, buffer_zone.geom_buffer);

-- Flore patrimoniale
SELECT ps.*
FROM public.point_silene_patri ps
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 10)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (1001)
) AS buffer_zone
ON ST_Intersects(ps.geom, buffer_zone.geom_buffer);



-- Ne fonctionne pas dans Qgis
SELECT 
    ps.*, 
    mep.*, 
    ps.geom  -- << ajout explicite
FROM bibliotaxa.point_silene ps
JOIN (
    SELECT ST_Union(ST_Buffer(geom, 50)) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (24, 29)
) AS buffer_zone
    ON ST_Intersects(ps.geom, buffer_zone.geom_buffer)
LEFT JOIN public.method_enjeu_paca mep
    ON ps.cd_ref = mep.CD_NOM;