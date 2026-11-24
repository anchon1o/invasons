-- INVASONS · actualización do ranking (22-nov-2026)
-- Executar en Supabase → proxecto xogos → SQL Editor → New query → pegar todo → Run
-- Pódese executar máis dunha vez sen problema.

-- 1) Acepta calquera xogo (presente ou futuro) cun nome curto en minúsculas.
--    Así non volverá fallar ao engadir modos novos.
alter table public.inv_scores drop constraint if exists inv_scores_variant_check;
alter table public.inv_scores add constraint inv_scores_variant_check
  check (variant ~ '^[a-z]{2,20}$');

-- 2) Máis marxe de puntos (as rachas multiplican).
alter table public.inv_scores drop constraint if exists inv_scores_score_check;
alter table public.inv_scores add constraint inv_scores_score_check
  check (score between 0 and 100000000);
