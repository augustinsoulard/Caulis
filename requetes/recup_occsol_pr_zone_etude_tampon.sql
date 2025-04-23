SELECT ps.*
FROM occsol.mos_mamp_2017 ps
JOIN (
    SELECT ST_Transform(
               ST_Union(
                   ST_Buffer(ST_Transform(geom, 2154), 100)
               ), 2154
           ) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (24, 29)
) AS buffer_zone
ON ST_Intersects(ST_Transform(ps.geom, 2154), buffer_zone.geom_buffer);

SELECT ps.*
FROM occsol.carhab_13_eunis ps
JOIN (
    SELECT ST_Transform(
               ST_Union(
                   ST_Buffer(ST_Transform(geom, 2154), 100)
               ), 2154
           ) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (24, 29)
) AS buffer_zone
ON ST_Intersects(ST_Transform(ps.geom, 2154), buffer_zone.geom_buffer);

SELECT ps.*
FROM occsol.carhab_13_hic ps
JOIN (
    SELECT ST_Transform(
               ST_Union(
                   ST_Buffer(ST_Transform(geom, 2154), 100)
               ), 2154
           ) AS geom_buffer
    FROM projet.zone_etude
    WHERE code IN (24, 29)
) AS buffer_zone
ON ST_Intersects(ST_Transform(ps.geom, 2154), buffer_zone.geom_buffer);



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