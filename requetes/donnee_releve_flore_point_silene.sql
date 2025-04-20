

SELECT *
FROM bibliotaxa.point_silene t
WHERE EXISTS (
    SELECT 1
    FROM bibliotaxa.point_silene t2
    WHERE 
        t2.id <> t.id -- s'assurer que ce n’est pas lui-même
        AND DATE(t.date_debut) = DATE(t2.date_debut) -- comparer les dates au jour près
        AND t2.observateu = t.observateu
        AND t2.geom = t.geom
);