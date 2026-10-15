-- =====================================================================
-- SkinProof — migration 2: support for the Edge Functions
-- Run AFTER 20261012000000_skinproof_init.sql
--   * RevenueCat webhook -> entitlements (idempotent, ordered, testable in SQL)
--   * coach_context(): compact, photo-free snapshot of the user's data for the AI coach
-- Re-runnable.
-- =====================================================================
begin;

-- ---------------------------------------------------------------------
-- RevenueCat bookkeeping
-- ---------------------------------------------------------------------
alter table public.entitlements
  add column if not exists last_event_ms bigint,
  add column if not exists product_id    text,
  add column if not exists period_type   text,
  add column if not exists store         text,
  add column if not exists environment   text,
  add column if not exists will_renew    boolean;

create table if not exists public.revenuecat_events (
  event_id     text primary key,                 -- RevenueCat event.id: guarantees idempotency
  type         text not null,
  app_user_id  text,
  user_id      uuid references public.profiles(id) on delete set null,
  event_ts_ms  bigint,
  status       text not null default 'received'
               check (status in ('received','applied','duplicate','ignored','stale','unresolved')),
  note         text,
  payload      jsonb not null,
  received_at  timestamptz not null default now()
);
create index if not exists revenuecat_events_user_idx on public.revenuecat_events (user_id, received_at desc);
alter table public.revenuecat_events enable row level security;      -- no policy => service role only

insert into public.app_config (key, value, description) values
  ('revenuecat_pro_entitlement', '"pro"',  'RevenueCat entitlement identifier that unlocks Pro'),
  ('revenuecat_product_plans',   '{}',     'Map store product id -> plan, e.g. {"skinproof_annual":"annual","skinproof_monthly":"monthly"}'),
  ('revenuecat_accept_sandbox',  'true',   'Accept SANDBOX events (keep true for the hackathon demo, set false in production)')
on conflict (key) do nothing;

-- Applies ONE RevenueCat webhook event. Service role only.
-- Rules (from RevenueCat docs): CANCELLATION does not remove access (user keeps it until expiry),
-- EXPIRATION removes it (except SUBSCRIPTION_PAUSED), events can arrive twice or out of order.
create or replace function public.apply_revenuecat_event(p_event jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  ev_id    text := p_event ->> 'id';
  ev_type  text := p_event ->> 'type';
  app_uid  text := p_event ->> 'app_user_id';
  ts       bigint := nullif(p_event ->> 'event_timestamp_ms', '')::bigint;
  exp_ms   bigint := nullif(p_event ->> 'expiration_at_ms', '')::bigint;
  env      text := p_event ->> 'environment';
  period   text := p_event ->> 'period_type';
  prod     text := coalesce(nullif(p_event ->> 'new_product_id', ''), p_event ->> 'product_id');
  ents     jsonb := coalesce(p_event -> 'entitlement_ids', '[]'::jsonb);
  ent_name text := coalesce(public.cfg('revenuecat_pro_entitlement') #>> '{}', 'pro');
  plans    jsonb := coalesce(public.cfg('revenuecat_product_plans'), '{}'::jsonb);
  accept_sbx boolean := coalesce((public.cfg('revenuecat_accept_sandbox') #>> '{}')::boolean, true);
  uid uuid; cand text; prev bigint; cur public.entitlements%rowtype;
  expires timestamptz; v_plan text; new_status text; new_pro boolean; renew boolean; v_note text;
begin
  if ev_id is null or ev_type is null then
    raise exception 'invalid revenuecat event' using errcode = '22023';
  end if;

  insert into public.revenuecat_events (event_id, type, app_user_id, event_ts_ms, payload)
  values (ev_id, ev_type, app_uid, ts, p_event)
  on conflict (event_id) do nothing;
  if not found then return jsonb_build_object('status', 'duplicate'); end if;

  if ev_type = 'TEST' then
    update public.revenuecat_events set status = 'ignored', note = 'test event' where event_id = ev_id;
    return jsonb_build_object('status', 'ignored', 'reason', 'test');
  end if;
  if env = 'SANDBOX' and not accept_sbx then
    update public.revenuecat_events set status = 'ignored', note = 'sandbox not accepted' where event_id = ev_id;
    return jsonb_build_object('status', 'ignored', 'reason', 'sandbox');
  end if;
  if jsonb_array_length(ents) > 0 and not (ents ? ent_name) then
    update public.revenuecat_events set status = 'ignored', note = 'other entitlement' where event_id = ev_id;
    return jsonb_build_object('status', 'ignored', 'reason', 'other_entitlement');
  end if;

  -- resolve the Supabase user: app_user_id should be the auth user uuid (Purchases.logIn(uid)); aliases as fallback
  for cand in
    select app_uid
    union all
    select jsonb_array_elements_text(coalesce(p_event -> 'aliases', '[]'::jsonb))
  loop
    begin
      uid := cand::uuid;
      if exists (select 1 from public.profiles where id = uid) then exit; end if;
      uid := null;
    exception when invalid_text_representation then
      uid := null;
    end;
  end loop;
  if uid is null then
    update public.revenuecat_events set status = 'unresolved', note = 'no matching profile' where event_id = ev_id;
    return jsonb_build_object('status', 'unresolved');
  end if;

  select * into cur from public.entitlements where user_id = uid for update;
  if not found then
    insert into public.entitlements (user_id) values (uid) returning * into cur;
  end if;
  if ts is not null and cur.last_event_ms is not null and ts <= cur.last_event_ms then
    update public.revenuecat_events set status = 'stale', user_id = uid, note = 'older than last applied event'
     where event_id = ev_id;
    return jsonb_build_object('status', 'stale', 'user_id', uid);
  end if;

  expires := case when exp_ms is null then cur.expires_at else to_timestamp(exp_ms / 1000.0) end;
  v_plan := coalesce(plans ->> prod,
                   case when prod ilike '%year%' or prod ilike '%annual%' then 'annual'
                        when prod ilike '%month%' then 'monthly' end,
                   cur.plan);
  new_pro := cur.is_pro; new_status := cur.status; renew := cur.will_renew; v_note := null;

  if ev_type in ('INITIAL_PURCHASE','RENEWAL','UNCANCELLATION','PRODUCT_CHANGE','SUBSCRIPTION_EXTENDED',
                 'TEMPORARY_ENTITLEMENT_GRANT','NON_RENEWING_PURCHASE') then
    new_pro := true;
    new_status := case when period = 'TRIAL' then 'trial' else 'active' end;
    renew := ev_type <> 'NON_RENEWING_PURCHASE';
  elsif ev_type = 'CANCELLATION' then
    if (p_event ->> 'cancel_reason') = 'CUSTOMER_SUPPORT' or (expires is not null and expires <= now()) then
      new_pro := false; new_status := 'canceled'; v_note := 'refund or already expired';
    else
      new_status := 'canceled'; v_note := 'auto-renew off; access kept until expiry';
    end if;
    renew := false;
  elsif ev_type = 'BILLING_ISSUE' then
    new_status := 'grace'; v_note := 'billing issue; access kept during grace period';
  elsif ev_type = 'EXPIRATION' then
    if (p_event ->> 'expiration_reason') = 'SUBSCRIPTION_PAUSED' then
      v_note := 'paused: access not revoked';
    else
      new_pro := false; new_status := 'expired'; renew := false;
    end if;
  else
    update public.revenuecat_events set status = 'ignored', user_id = uid, note = 'event type not handled' where event_id = ev_id;
    return jsonb_build_object('status', 'ignored', 'reason', 'unhandled_type', 'type', ev_type);
  end if;

  update public.entitlements set
    is_pro = new_pro, status = new_status, plan = v_plan, expires_at = expires,
    rc_app_user_id = coalesce(app_uid, rc_app_user_id), last_event_ms = coalesce(ts, last_event_ms),
    product_id = coalesce(prod, product_id), period_type = coalesce(period, period_type),
    store = coalesce(p_event ->> 'store', store), environment = coalesce(env, environment), will_renew = renew
  where user_id = uid;

  update public.revenuecat_events set status = 'applied', user_id = uid, note = v_note where event_id = ev_id;
  return jsonb_build_object('status', 'applied', 'user_id', uid, 'is_pro', new_pro, 'entitlement_status', new_status,
                            'expires_at', expires);
end $$;

-- ---------------------------------------------------------------------
-- Coach context: what the AI is allowed to know (never the photo)
-- ---------------------------------------------------------------------
create or replace function public.coach_context()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  u uuid := auth.uid(); p public.profiles%rowtype; latest uuid; prev uuid; n int;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select * into p from public.profiles where id = u;
  select count(*) into n from public.scans where user_id = u and status = 'done';
  select id into latest from public.scans where user_id = u and status = 'done' order by created_at desc limit 1;
  select id into prev   from public.scans where user_id = u and status = 'done' order by created_at desc offset 1 limit 1;

  return jsonb_build_object(
    'today', public.local_today(u),
    'is_pro', public.is_pro(u),
    'profile', jsonb_build_object(
      'goals', p.goals, 'skin_type', p.skin_type, 'sensitivities', p.sensitivities,
      'skin_tone_self', p.skin_tone_self, 'sun_habit', p.sun_habit,
      'current_actives', p.current_actives, 'timezone', p.timezone),
    'scan_count', n,
    'recent_scans', (select coalesce(jsonb_agg(jsonb_build_object(
          'date', (s.created_at at time zone coalesce(p.timezone, 'UTC'))::date,
          'overall', s.overall_score, 'skin_age', s.skin_age, 'quality_ok', s.quality_ok) order by s.created_at desc), '[]'::jsonb)
        from (select * from public.scans where user_id = u and status = 'done' order by created_at desc limit 8) s),
    'concerns_latest', (select coalesce(jsonb_agg(jsonb_build_object(
          'concern', c.concern, 'label', coalesce(t.label, c.concern), 'score', round(c.raw_score, 1),
          'previous', round(pc.raw_score, 1), 'delta', round(c.raw_score - pc.raw_score, 1)) order by t.sort_order nulls last), '[]'::jsonb)
        from public.scan_concerns c
        left join public.concern_types t on t.key = c.concern
        left join public.scan_concerns pc on pc.scan_id = prev and pc.concern = c.concern and coalesce(pc.zone,'') = coalesce(c.zone,'')
        where c.scan_id = latest and (c.zone is null or c.zone = 'whole')),
    'routine', (select coalesce(jsonb_agg(jsonb_build_object(
          'name', r.name, 'step', r.step_type, 'actives', r.actives, 'period', r.period, 'started_on', r.started_on)
          order by r.sort_order), '[]'::jsonb)
        from public.routine_items r where r.user_id = u and r.active),
    'experiments', (select coalesce(jsonb_agg(jsonb_build_object(
          'title', e.title, 'targets', e.targets, 'status', e.status, 'planned_days', e.planned_days,
          'day_number', (public.local_today(u) - e.started_on) + 1,
          'verdict', e.verdict -> 'primary') order by e.started_at desc), '[]'::jsonb)
        from (select * from public.experiments where user_id = u order by started_at desc limit 4) e),
    'streak', public._streak_json(u));
end $$;

-- ---------------------------------------------------------------------
-- Fixes found while writing the Edge Functions
-- ---------------------------------------------------------------------
-- 1) Only scans that actually reached the provider (task created) count toward the daily cap,
--    so abandoned attempts (photo never uploaded) cannot lock a user out.
create or replace function public.scan_gate(p_user uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  pro boolean := public.is_pro(p_user);
  done_n int; last_at timestamptz; today_n int; week_n int;
  free_n  int := public.cfg_int('free_scans', 1);
  min_d   int := public.cfg_int('scan_min_interval_days', 5);
  max_day int := public.cfg_int('scan_max_per_day', 3);
begin
  select count(*), max(created_at) into done_n, last_at
    from public.scans where user_id = p_user and status = 'done';
  select count(*) into today_n from public.scans
   where user_id = p_user and api_task_id is not null and created_at >= now() - interval '24 hours';
  select count(*) into week_n from public.scans
   where user_id = p_user and status = 'done' and created_at >= now() - interval '7 days';

  if not pro and done_n >= free_n then
    return jsonb_build_object('allowed', false, 'reason', 'pro_required', 'is_pro', false, 'scans_done', done_n);
  end if;
  if today_n >= max_day then
    return jsonb_build_object('allowed', false, 'reason', 'daily_cap', 'is_pro', pro, 'scans_done', done_n);
  end if;
  if pro and last_at is not null and last_at > now() - make_interval(days => min_d) then
    return jsonb_build_object(
      'allowed', week_n < 2, 'reason', case when week_n < 2 then null else 'too_soon' end,
      'warning', 'too_soon', 'next_allowed_at', last_at + make_interval(days => min_d),
      'is_pro', true, 'scans_done', done_n, 'last_scan_at', last_at);
  end if;
  return jsonb_build_object('allowed', true, 'is_pro', pro, 'scans_done', done_n, 'last_scan_at', last_at);
end $$;

-- 2) Provider masks may come back as JPEG (docs example) or PNG
update storage.buckets set allowed_mime_types = array['image/png','image/jpeg','image/webp'] where id = 'scan-masks';

-- ---------------------------------------------------------------------
-- Privileges (new objects inherit default grants: lock them down)
-- ---------------------------------------------------------------------
revoke all on public.revenuecat_events from anon, authenticated;
grant all on public.revenuecat_events to service_role;
revoke execute on function public.apply_revenuecat_event(jsonb) from public, anon, authenticated;
grant  execute on function public.apply_revenuecat_event(jsonb) to service_role;
revoke execute on function public.coach_context() from public, anon;
grant  execute on function public.coach_context() to authenticated, service_role;

commit;
