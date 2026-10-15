-- =====================================================================
-- SkinProof — migration 3: "seen" tracking for streak celebrations
-- Run AFTER migrations 1 and 2. Re-runnable.
--
-- Why: the app must show a milestone screen / "fresh start" card EXACTLY ONCE.
-- The server records unseen milestones and streak events; the app asks for them
-- (pending_celebrations) and acknowledges them (mark_celebrations_seen).
-- =====================================================================
begin;

-- Backfill only when the columns are first created, so existing history is not replayed as "new".
do $$
begin
  if not exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'milestones' and column_name = 'seen_at') then
    alter table public.milestones add column seen_at timestamptz;
    update public.milestones set seen_at = reached_at;
  end if;
  if not exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'streak_events' and column_name = 'seen_at') then
    alter table public.streak_events add column seen_at timestamptz;
    update public.streak_events set seen_at = created_at;
  end if;
end $$;

create index if not exists milestones_unseen_idx    on public.milestones (user_id) where seen_at is null;
create index if not exists streak_events_unseen_idx on public.streak_events (user_id) where seen_at is null;

-- Demo accounts never replay a wall of celebrations (seed_demo_data inserts history in bulk).
create or replace function public.trg_demo_seen()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if exists (select 1 from public.profiles where id = new.user_id and is_demo) then
    new.seen_at := now();
  end if;
  return new;
end $$;
drop trigger if exists trg_milestones_demo_seen on public.milestones;
create trigger trg_milestones_demo_seen before insert on public.milestones
  for each row execute function public.trg_demo_seen();
drop trigger if exists trg_streak_events_demo_seen on public.streak_events;
create trigger trg_streak_events_demo_seen before insert on public.streak_events
  for each row execute function public.trg_demo_seen();

-- What the app should celebrate / explain now (oldest first). Events older than 14 days are ignored.
create or replace function public.pending_celebrations()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  return jsonb_build_object(
    'milestones', (select coalesce(jsonb_agg(jsonb_build_object(
                      'type', m.type, 'reached_at', m.reached_at, 'meta', m.meta) order by m.reached_at), '[]'::jsonb)
                   from public.milestones m where m.user_id = u and m.seen_at is null),
    'events', (select coalesce(jsonb_agg(jsonb_build_object(
                      'id', e.id, 'type', e.type, 'day', e.day, 'streak_after', e.streak_after, 'meta', e.meta)
                      order by e.created_at), '[]'::jsonb)
               from public.streak_events e
               where e.user_id = u and e.seen_at is null
                 and e.type in ('reset','weekly_reset','freeze_used','freeze_earned','weekly_joker_used')
                 and e.created_at > now() - interval '14 days'));
end $$;

-- Acknowledge what was shown. NULL arrays = acknowledge everything pending.
create or replace function public.mark_celebrations_seen(p_milestone_types text[] default null, p_event_ids bigint[] default null)
returns void language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  update public.milestones set seen_at = now()
   where user_id = u and seen_at is null and (p_milestone_types is null or type = any (p_milestone_types));
  update public.streak_events set seen_at = now()
   where user_id = u and seen_at is null and (p_event_ids is null or id = any (p_event_ids));
end $$;

revoke execute on function public.pending_celebrations() from public, anon;
revoke execute on function public.mark_celebrations_seen(text[], bigint[]) from public, anon;
grant  execute on function public.pending_celebrations() to authenticated, service_role;
grant  execute on function public.mark_celebrations_seen(text[], bigint[]) to authenticated, service_role;
revoke execute on function public.trg_demo_seen() from public, anon, authenticated;

commit;
