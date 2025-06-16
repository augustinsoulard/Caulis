ALTER TABLE bibliotaxa.point_silene ADD COLUMN releve_id integer;

CREATE VIEW bibliotaxa.point_silene_2024 AS
SELECT *
FROM bibliotaxa.point_silene
WHERE date_debut >= '2024-01-01' 
  AND date_debut < '2025-01-01';


WITH clusters AS (
  SELECT
    observateu,
    date_debut,
    ST_ClusterWithin(geom, 5) AS cluster_array
  FROM bibliotaxa.point_silene_2024
  GROUP BY observateu, date_debut
),
exploded AS (
  SELECT
    observateu,
    date_debut,
    unnest(cluster_array) AS cluster_geom,
    generate_series(1, array_length(cluster_array, 1)) AS cluster_idx
  FROM clusters
),
clustered_points AS (
  SELECT
    p.id,
    e.observateu,
    e.date_debut,
    e.cluster_idx
  FROM exploded e
  JOIN bibliotaxa.point_silene_2024 p
    ON ST_DWithin(p.geom, e.cluster_geom, 0.00001)  -- tolérance minuscule
   AND p.observateu = e.observateu
   AND p.date_debut = e.date_debut
),
ranked AS (
  SELECT
    id,
    dense_rank() OVER (
      ORDER BY date_debut, observateu, cluster_idx
    ) AS releve_id_num
  FROM clustered_points
)
UPDATE bibliotaxa.point_silene_2024 p
SET releve_id = r.releve_id_num
FROM ranked r
WHERE p.id = r.id;





