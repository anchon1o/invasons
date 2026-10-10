-- =====================================================================
-- INVASONS · ranking no proxecto de Supabase "xogos"  (prefixo inv_)
-- Pegar enteiro en: Supabase → proxecto xogos → SQL Editor → New query → Run
-- Pódese executar máis dunha vez sen problema.
-- =====================================================================

create table if not exists public.inv_scores (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  day         date not null default ((now() at time zone 'Europe/Madrid')::date),
  player_id   uuid not null,
  name        text not null check (char_length(btrim(name)) between 1 and 20),
  variant     text not null check (variant in ('reto','notas','harmonicos','melodicos','acordes','tonalidades')),
  score       integer not null check (score between 0 and 1000000),
  level       integer,
  constraint inv_reto_max check (variant <> 'reto' or score <= 20)
);

-- No reto diario, unha soa puntuación por persoa e día
create unique index if not exists inv_scores_reto_un
  on public.inv_scores (player_id, day) where variant = 'reto';
create index if not exists inv_scores_var_day on public.inv_scores (variant, day);

-- Seguridade: calquera pode ler e engadir, ninguén pode editar nin borrar
alter table public.inv_scores enable row level security;
drop policy if exists inv_scores_read  on public.inv_scores;
drop policy if exists inv_scores_write on public.inv_scores;
create policy inv_scores_read  on public.inv_scores for select to anon, authenticated using (true);
create policy inv_scores_write on public.inv_scores for insert to anon, authenticated with check (true);
grant select, insert on public.inv_scores to anon, authenticated;

-- Ranking: p_variant = reto | notas | harmonicos | melodicos | acordes | tonalidades
--          p_period  = hoxe | semana | sempre   (hora de España)
-- Reto: "hoxe" = puntuación de hoxe; "semana"/"sempre" = suma dos retos.
-- Resto: mellor puntuación de cada persoa no período.
create or replace function public.inv_ranking(p_variant text, p_period text default 'sempre', p_n integer default 10)
returns table (pos bigint, name text, score bigint, games bigint)
language sql stable
as $$
  with hoxe as (select (now() at time zone 'Europe/Madrid')::date as d),
  base as (
    select s.player_id, s.name, s.score, s.created_at
    from public.inv_scores s, hoxe
    where s.variant = p_variant
      and ( p_period = 'sempre'
         or (p_period = 'hoxe'   and s.day = hoxe.d)
         or (p_period = 'semana' and s.day >= date_trunc('week', hoxe.d)::date) )
  ),
  agg as (
    select player_id,
           (array_agg(name order by created_at desc))[1] as name,
           case when p_variant = 'reto' and p_period <> 'hoxe' then sum(score) else max(score) end as score,
           count(*) as games,
           min(created_at) as first_at
    from base group by player_id
  )
  select row_number() over (order by score desc, first_at asc) as pos,
         name, score::bigint, games
  from agg
  order by score desc, first_at asc
  limit least(greatest(coalesce(p_n,10),1),50);
$$;
grant execute on function public.inv_ranking(text, text, integer) to anon, authenticated;
