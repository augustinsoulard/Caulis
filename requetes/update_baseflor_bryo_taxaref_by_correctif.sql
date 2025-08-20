-- 1. Mise à jour des lignes existantes
UPDATE public.baseflor_bryo_taxref b
SET floraison = c.floraison
FROM public.correctif_baseflor_bryo c
WHERE b.cd_ref = c.cd_nom;

-- 2. Insertion des lignes manquantes
INSERT INTO public.baseflor_bryo_taxref (cd_ref, floraison)
SELECT c.cd_nom AS cd_ref, c.floraison
FROM public.correctif_baseflor_bryo c
WHERE NOT EXISTS (
    SELECT 1 FROM public.baseflor_bryo_taxref b
    WHERE b.cd_ref = c.cd_nom
);


