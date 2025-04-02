-- Mise à jour du cd_ref de la METHODE ENJEU PACA
ALTER TABLE method_enjeu_paca
ADD COLUMN cd_ref INTEGER;

UPDATE method_enjeu_paca mep
SET cd_ref = t.cd_ref
FROM taxrefv18 t
WHERE mep.cd_nom = t.cd_nom;


SELECT * FROM method_enjeu_paca


-- Mise à jour du cd_ref des points SILENE
ALTER TABLE bibliotaxa.point_silene
ADD COLUMN cd_nom INTEGER;
UPDATE bibliotaxa.point_silene SET cd_nom = cd_ref;


UPDATE bibliotaxa.point_silene p
SET cd_ref = t.cd_ref
FROM taxrefv18 t
WHERE p.cd_nom = t.cd_nom;