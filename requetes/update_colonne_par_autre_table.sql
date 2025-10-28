UPDATE statuts.pna_messicole tc
SET cd_refv18 = ts.cd_ref
FROM public.taxrefv18 ts
WHERE tc.cd_nom = ts.cd_nom;
