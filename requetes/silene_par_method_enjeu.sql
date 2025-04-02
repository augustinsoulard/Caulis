CREATE OR REPLACE VIEW point_silene_patri AS
SELECT 
    b.cd_ref,
    b.geom,
    b.date_debut,
    b.nom_valide,
    b.nom_vernac,
    a."INTERET_PACA",
    a."PROTECTION_PACA"
FROM 
    bibliotaxa.point_silene AS b
INNER JOIN 
    public.method_enjeu_paca AS a
ON 
    a.cd_ref = b.cd_ref
WHERE 
    a."INTERET_PACA" IN ('MAJEUR','TRES FORT', 'FORT', 'MODERE','DD')
    OR a."PROTECTION_PACA" <> '-';


SELECT * FROM public.point_silene_patri
