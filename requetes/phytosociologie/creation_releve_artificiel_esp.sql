-- Si la table existe déjà, on la supprime pour éviter les erreurs
DROP TABLE IF EXISTS phytosocio.releve_artificiel_esp;

CREATE TABLE phytosocio.releve_artificiel_esp AS
WITH zone_etude AS (
    -- 1. Récupération de la zone
    SELECT geom FROM projet.zone_etude WHERE code = 30
),

points_filtrés AS (
    -- 2. On filtre d'abord les points dans la zone
    -- C'est plus rapide qu'un CROSS JOIN
    SELECT 
        t.id,
		t.cd_ref,
		t.nom_valide,
		t.nom_vernac,
        t.date_debut,
        t.observateu,
        t.geom
        -- Ajoutez ici les autres colonnes de t si nécessaire
    FROM bibliotaxa.point_silene t
    JOIN zone_etude z ON ST_Within(t.geom, z.geom) 
),

clustering AS (
    -- 3. Création des clusters (agglomérats)
    SELECT 
        *,
        -- ST_ClusterDBSCAN génère un ID de cluster pour les points proches (eps=5m)
        -- PARTITION BY assure qu'on ne groupe que si date et observateur sont identiques
        ST_ClusterDBSCAN(geom, eps := 5, minpoints := 1) 
        OVER (PARTITION BY observateu, DATE(date_debut)) AS cluster_id
    FROM points_filtrés
)

-- 4. Nommage final des agglomérats
SELECT 
    id,
	cd_ref,
	nom_valide,
	nom_vernac,
    date_debut,
    observateu,
    geom,
    -- On génère un nom unique 'RA' + numéro basé sur le groupe formé
    'RA' || DENSE_RANK() OVER (ORDER BY date_debut, observateu, cluster_id) AS releve_artificiel
FROM clustering;