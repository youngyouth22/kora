-- =====================================================================
-- SkinProof — Supabase backend migration (single file, re-runnable)
-- Target: Supabase Postgres 15+ (SQL Editor or `supabase db push`)
--
-- WHAT THIS CREATES
--   1. Config + reference data (app_config, concern_types, task_templates)
--   2. Users: profiles, entitlements, notification_prefs, push_tokens, consents
--   3. Scans: scans, scan_concerns (+ Storage buckets & policies)
--   4. Routine: routine_items, routine_logs, checkins
--   5. Experiments: experiments, experiment_scans, notes (+ verdict engine)
--   6. Coach: messages (server-side daily limits)
--   7. Content: catalog_products, catalog_videos, saved_videos
--   8. STREAK SYSTEM: activity_days, streak_state, streak_events, milestones,
--      task_templates/user_tasks (Day 1-7 journey + daily plan), home_summary()
--   9. Ops: api_usage ledger, events, cancel_surveys, scan gate, GDPR helpers
--  10. Row Level Security on everything, least-privilege grants
--  11. Demo seed function (judge mode)
--
-- AFTER RUNNING (see the end of this file for the checklist):
--   * Auth > Providers: enable "Allow anonymous sign-ins"
--   * Edge Functions use the service_role key (never ship it in the app)
--   * RevenueCat webhook -> Edge Function -> UPDATE public.entitlements
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 0. Helpers
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- ---------------------------------------------------------------------
-- 1. Config + reference data
-- ---------------------------------------------------------------------
create table if not exists public.app_config (
  key         text primary key,
  value       jsonb not null,
  description text,
  updated_at  timestamptz not null default now()
);

create table if not exists public.concern_types (
  key          text primary key,          -- matches YouCam Skin Analysis concern names
  label        text not null,
  is_headline  boolean not null default false,
  sort_order   int not null default 100
);

-- ---------------------------------------------------------------------
-- 2. Users
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id                      uuid primary key references auth.users(id) on delete cascade,
  display_name            text,
  goals                   text[] not null default '{}',            -- max 3 concern keys (O03)
  skin_type               text check (skin_type in ('oily','dry','combination','normal','unknown')),
  sensitivities           text[] not null default '{}',            -- reactive, allergies, pregnant_nursing
  skin_tone_self          smallint check (skin_tone_self between 1 and 6),
  sun_habit               text check (sun_habit in ('never','sometimes','daily')),
  current_actives         text[] not null default '{}',            -- O05
  actives_started         text check (actives_started in ('lt_2w','2_8w','gt_2m')),
  timezone                text not null default 'UTC',             -- IANA name, e.g. America/New_York
  locale                  text not null default 'en',
  scan_weekday            smallint not null default 7 check (scan_weekday between 1 and 7),  -- ISO, 7 = Sunday
  scan_time               time not null default '18:00',
  age_confirmed           boolean not null default false,
  consent_version         text,                                    -- written only by record_consent()
  consent_at              timestamptz,
  keep_photos             boolean not null default true,
  onboarding_step         smallint not null default 0,
  onboarding_completed_at timestamptz,
  is_demo                 boolean not null default false,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now(),
  constraint goals_max_3 check (cardinality(goals) <= 3)
);

create table if not exists public.entitlements (
  user_id         uuid primary key references public.profiles(id) on delete cascade,
  is_pro          boolean not null default false,
  plan            text check (plan in ('monthly','annual')),
  status          text not null default 'none' check (status in ('none','trial','active','grace','expired','canceled')),
  expires_at      timestamptz,
  rc_app_user_id  text,
  updated_at      timestamptz not null default now()
);

create table if not exists public.notification_prefs (
  user_id                uuid primary key references public.profiles(id) on delete cascade,
  scan_reminder_enabled  boolean not null default true,
  routine_am_enabled     boolean not null default false,
  routine_am_time        time not null default '08:00',
  routine_pm_enabled     boolean not null default false,
  routine_pm_time        time not null default '21:30',
  results_enabled        boolean not null default true,
  streak_reminders       boolean not null default true,
  quiet_start            time not null default '21:00',
  quiet_end              time not null default '08:00',
  updated_at             timestamptz not null default now()
);

create table if not exists public.push_tokens (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  token        text not null unique,
  platform     text not null check (platform in ('ios','android','web')),
  created_at   timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);

-- Append-only consent log (proof of consent for face-image processing, ToS, privacy)
create table if not exists public.consents (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  type         text not null check (type in ('face_processing','terms','privacy','marketing','age_18')),
  version      text not null,
  accepted     boolean not null default true,
  app_version  text,
  accepted_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. Content catalog (read-only for the app)
-- ---------------------------------------------------------------------
create table if not exists public.catalog_products (
  id          uuid primary key default gen_random_uuid(),
  slug        text not null unique,
  name        text not null,
  brand       text,
  category    text check (category in ('cleanser','toner','serum','treatment','moisturizer','spf','mask','other')),
  actives     text[] not null default '{}',
  concerns    text[] not null default '{}',
  skin_types  text[] not null default '{}',
  good_for    text,
  skip_if     text,
  image_url   text,
  retailers   jsonb not null default '[]',   -- [{"name":"Retailer","url":"https://...","affiliate":true}]
  active      boolean not null default true,
  sort_order  int not null default 100,
  created_at  timestamptz not null default now()
);

create table if not exists public.catalog_videos (
  id               uuid primary key default gen_random_uuid(),
  youtube_id       text not null unique,
  title            text not null,
  channel_name     text not null,
  channel_url      text,
  duration_seconds int,
  concerns         text[] not null default '{}',
  level            text not null default 'beginner' check (level in ('beginner','intermediate','advanced')),
  takeaways        text[] not null default '{}',   -- your own editorial notes (C16)
  language         text not null default 'en',
  active           boolean not null default true,
  created_at       timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 4. Scans
-- ---------------------------------------------------------------------
create table if not exists public.scans (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  status        text not null default 'created'
                check (status in ('created','uploading','processing','done','failed','canceled')),
  mode          text not null default 'SD' check (mode in ('SD','HD')),
  api_file_id   text,
  api_task_id   text,
  error_code    text,
  overall_score numeric(5,2),
  skin_age      smallint,
  quality_ok    boolean not null default true,
  quality_flags jsonb not null default '{}',
  photo_path    text,                    -- storage path in bucket scan-photos (null if user keeps scores only)
  result_json   jsonb,                   -- raw provider result (no image data)
  is_demo       boolean not null default false,
  created_at    timestamptz not null default now(),
  completed_at  timestamptz
);

create table if not exists public.scan_concerns (
  id         uuid primary key default gen_random_uuid(),
  scan_id    uuid not null references public.scans(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  concern    text not null,              -- no FK on purpose: never fail ingestion on a new provider concern
  zone       text,                       -- HD only (forehead, nose, left_cheek...)
  raw_score  numeric(5,2) not null,      -- real score: used for trends and verdicts
  ui_score   numeric(5,2),               -- provider display score: stored, never shown
  mask_path  text                        -- storage path in bucket scan-masks
);
create unique index if not exists scan_concerns_unique on public.scan_concerns (scan_id, concern, coalesce(zone, ''));

-- ---------------------------------------------------------------------
-- 5. Routine
-- ---------------------------------------------------------------------
create table if not exists public.routine_items (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references public.profiles(id) on delete cascade,
  name                text not null,
  brand               text,
  step_type           text not null default 'other'
                      check (step_type in ('cleanser','toner','serum','treatment','moisturizer','spf','mask','other')),
  actives             text[] not null default '{}',
  period              text not null default 'both' check (period in ('am','pm','both')),
  days                smallint[],                         -- ISO weekdays 1..7, null = every day
  started_on          date,
  active              boolean not null default true,
  sort_order          int not null default 100,
  catalog_product_id  uuid references public.catalog_products(id) on delete set null,
  ingredients_raw     text,                               -- OCR text (C09)
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint routine_days_valid check (days is null or days <@ array[1,2,3,4,5,6,7]::smallint[])
);

create table if not exists public.routine_logs (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  item_id    uuid not null references public.routine_items(id) on delete cascade,
  log_date   date not null,
  period     text not null default 'am' check (period in ('am','pm')),
  done       boolean not null default true,
  created_at timestamptz not null default now(),
  unique (item_id, log_date, period)
);

create table if not exists public.checkins (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  scan_id      uuid references public.scans(id) on delete set null,
  checkin_date date not null default current_date,
  skin_feel    smallint check (skin_feel between 1 and 3),   -- 1 worse, 2 same, 3 better
  new_products boolean,
  note         text,
  created_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 6. Experiments
-- ---------------------------------------------------------------------
create table if not exists public.experiments (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  item_id       uuid references public.routine_items(id) on delete set null,
  title         text not null,                              -- product name snapshot
  targets       text[] not null,                            -- 1..2 concern keys
  planned_days  int not null default 42 check (planned_days between 14 and 180),
  started_at    timestamptz not null default now(),
  started_on    date not null default current_date,
  ended_at      timestamptz,
  status        text not null default 'active' check (status in ('active','paused','completed','stopped')),
  verdict       jsonb,
  adherence     numeric(4,3),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint targets_1_2 check (cardinality(targets) between 1 and 2)
);

create table if not exists public.experiment_scans (
  experiment_id uuid not null references public.experiments(id) on delete cascade,
  scan_id       uuid not null references public.scans(id) on delete cascade,
  role          text not null check (role in ('baseline','followup')),
  primary key (experiment_id, scan_id)
);

create table if not exists public.notes (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  experiment_id uuid references public.experiments(id) on delete cascade,
  text          text not null check (char_length(text) between 1 and 2000),
  created_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 7. Coach
-- ---------------------------------------------------------------------
create table if not exists public.messages (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  role       text not null check (role in ('user','assistant','system')),
  content    text not null check (char_length(content) between 1 and 8000),
  context    jsonb,                                  -- which data the coach used (shown in UI)
  feedback   smallint not null default 0 check (feedback in (-1,0,1)),
  tokens_in  int,
  tokens_out int,
  created_at timestamptz not null default now()
);

create table if not exists public.saved_videos (
  user_id    uuid not null references public.profiles(id) on delete cascade,
  video_id   uuid not null references public.catalog_videos(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, video_id)
);

-- ---------------------------------------------------------------------
-- 8. STREAK SYSTEM + daily tasks
-- ---------------------------------------------------------------------
-- One row per day with at least one qualifying action (drives the calendar dots)
create table if not exists public.activity_days (
  user_id      uuid not null references public.profiles(id) on delete cascade,
  day          date not null,                         -- the user's LOCAL date
  actions      int  not null default 0,
  had_scan     boolean not null default false,
  had_routine  boolean not null default false,
  had_task     boolean not null default false,
  had_checkin  boolean not null default false,
  is_freeze    boolean not null default false,        -- day protected by a streak freeze
  created_at   timestamptz not null default now(),
  primary key (user_id, day)
);

create table if not exists public.streak_state (
  user_id                    uuid primary key references public.profiles(id) on delete cascade,
  current_streak             int  not null default 0,   -- daily streak (days)
  longest_streak             int  not null default 0,
  last_active_date           date,
  freezes_available          int  not null default 1 check (freezes_available >= 0),
  freezes_used_total         int  not null default 0,
  weekly_scan_streak         int  not null default 0,   -- consecutive weeks with >= 1 scan
  longest_weekly_scan_streak int  not null default 0,
  last_scan_week             date,                      -- Monday of the last week with a scan
  weekly_joker_available     boolean not null default true,
  updated_at                 timestamptz not null default now()
);

create table if not exists public.streak_events (
  id            bigint generated always as identity primary key,
  user_id       uuid not null references public.profiles(id) on delete cascade,
  type          text not null check (type in ('increment','reset','freeze_used','freeze_earned',
                                              'weekly_increment','weekly_joker_used','weekly_reset')),
  day           date,
  streak_after  int,
  meta          jsonb not null default '{}',
  created_at    timestamptz not null default now()
);

create table if not exists public.milestones (
  user_id     uuid not null references public.profiles(id) on delete cascade,
  type        text not null,                          -- streak_7, first_scan, first_verdict, weekly_streak_4 ...
  reached_at  timestamptz not null default now(),
  meta        jsonb not null default '{}',
  primary key (user_id, type)
);

-- "First Steps" (Day 1-7 journey) and "Daily Plan" templates
create table if not exists public.task_templates (
  key            text primary key,
  section        text not null check (section in ('first_steps','daily_plan')),
  day_number     smallint check (day_number between 1 and 7),   -- first_steps only
  title          text not null,
  subtitle       text,
  icon           text,
  deep_link      text,
  activity_kind  text not null default 'task' check (activity_kind in ('task','routine','checkin')),
  sort_order     int not null default 100,
  requires_pro   boolean not null default false,
  active         boolean not null default true,
  constraint first_steps_need_day check (section <> 'first_steps' or day_number is not null)
);

create table if not exists public.user_tasks (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles(id) on delete cascade,
  template_key  text not null references public.task_templates(key) on update cascade on delete cascade,
  for_date      date,                                  -- null = one-time first-step task
  status        text not null default 'todo' check (status in ('todo','done','skipped')),
  completed_at  timestamptz,
  created_at    timestamptz not null default now()
);
create unique index if not exists user_tasks_once   on public.user_tasks (user_id, template_key) where for_date is null;
create unique index if not exists user_tasks_daily  on public.user_tasks (user_id, template_key, for_date) where for_date is not null;

-- ---------------------------------------------------------------------
-- 9. Ops
-- ---------------------------------------------------------------------
create table if not exists public.api_usage (            -- provider-unit ledger (service role only)
  id         bigint generated always as identity primary key,
  user_id    uuid references public.profiles(id) on delete set null,
  kind       text not null check (kind in ('scan','coach','ocr','other')),
  units      numeric(10,2) not null default 0,
  ref_id     uuid,
  meta       jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.events (               -- lightweight analytics (insert-only from the app)
  id         bigint generated always as identity primary key,
  user_id    uuid references public.profiles(id) on delete set null,
  name       text not null,
  props      jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.cancel_surveys (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references public.profiles(id) on delete set null,
  reason     text not null check (reason in ('too_expensive','no_results','forgot','privacy','other')),
  details    text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------
create index if not exists scans_user_created_idx      on public.scans (user_id, created_at desc);
create index if not exists scans_user_done_idx         on public.scans (user_id, created_at desc) where status = 'done';
create index if not exists scans_task_idx              on public.scans (api_task_id) where api_task_id is not null;
create index if not exists scan_concerns_user_idx      on public.scan_concerns (user_id, concern);
create index if not exists routine_items_user_idx      on public.routine_items (user_id) where active;
create index if not exists routine_logs_user_date_idx  on public.routine_logs (user_id, log_date desc);
create index if not exists checkins_user_idx           on public.checkins (user_id, checkin_date desc);
create index if not exists experiments_user_idx        on public.experiments (user_id, status);
create index if not exists notes_exp_idx               on public.notes (experiment_id, created_at desc);
create index if not exists messages_user_idx           on public.messages (user_id, created_at desc);
create index if not exists activity_days_user_idx      on public.activity_days (user_id, day desc);
create index if not exists streak_events_user_idx      on public.streak_events (user_id, created_at desc);
create index if not exists user_tasks_user_idx         on public.user_tasks (user_id, for_date);
create index if not exists api_usage_user_idx          on public.api_usage (user_id, created_at desc);
create index if not exists events_name_idx             on public.events (name, created_at desc);
create index if not exists catalog_products_concerns   on public.catalog_products using gin (concerns);
create index if not exists catalog_videos_concerns     on public.catalog_videos using gin (concerns);

-- updated_at triggers
drop trigger if exists trg_profiles_updated on public.profiles;
create trigger trg_profiles_updated before update on public.profiles for each row execute function public.set_updated_at();
drop trigger if exists trg_routine_items_updated on public.routine_items;
create trigger trg_routine_items_updated before update on public.routine_items for each row execute function public.set_updated_at();
drop trigger if exists trg_experiments_updated on public.experiments;
create trigger trg_experiments_updated before update on public.experiments for each row execute function public.set_updated_at();
drop trigger if exists trg_entitlements_updated on public.entitlements;
create trigger trg_entitlements_updated before update on public.entitlements for each row execute function public.set_updated_at();
drop trigger if exists trg_notif_updated on public.notification_prefs;
create trigger trg_notif_updated before update on public.notification_prefs for each row execute function public.set_updated_at();
drop trigger if exists trg_streak_updated on public.streak_state;
create trigger trg_streak_updated before update on public.streak_state for each row execute function public.set_updated_at();

-- =====================================================================
-- SEED: config, concerns, task templates
-- =====================================================================
insert into public.app_config (key, value, description) values
  ('streak_qualifying_kinds', '["scan","routine","task","checkin"]', 'Activity kinds that keep the daily streak alive'),
  ('streak_max_freezes',      '2',   'Max streak freezes a user can bank'),
  ('streak_freeze_every_days','7',   'Earn 1 freeze every N streak days'),
  ('streak_max_gap_days',     '2',   'A freeze can bridge at most N missed days at once'),
  ('streak_milestones',       '[3,7,14,30,60,100]', 'Daily streak lengths that unlock a milestone'),
  ('weekly_joker_every_weeks','4',   'Weekly-scan joker is refilled every N weeks of weekly streak'),
  ('scan_min_interval_days',  '5',   'Pro users: warn when scanning again before N days'),
  ('scan_max_per_day',        '3',   'Hard cap of scan attempts per rolling 24h (protects provider units)'),
  ('free_scans',              '1',   'Number of free completed scans for non-Pro users'),
  ('coach_daily_limit_free',  '3',   'Coach messages per local day (free)'),
  ('coach_daily_limit_pro',   '30',  'Coach messages per local day (Pro)'),
  ('noise_by_concern',        '{"default":3}', 'Score noise threshold (points) per concern. CALIBRATE with 5 same-condition scans'),
  ('score_higher_is_better',  'true','Set to false if the provider scale is inverted (verify in the API docs)'),
  ('demo_mode',               'false','When true, authenticated users may call seed_demo_data() for themselves')
on conflict (key) do nothing;

insert into public.concern_types (key, label, is_headline, sort_order) values
  ('acne','Acne',true,1), ('redness','Redness',true,2), ('age_spot','Dark spots',true,3),
  ('texture','Texture',true,4), ('pore','Pores',true,5), ('moisture','Hydration',true,6),
  ('wrinkle','Wrinkles',false,7), ('firmness','Firmness',false,8), ('radiance','Radiance',false,9),
  ('oiliness','Oiliness',false,10), ('dark_circle_v2','Dark circles',false,11), ('eye_bag','Eye bags',false,12)
on conflict (key) do nothing;

insert into public.task_templates (key, section, day_number, title, subtitle, icon, deep_link, activity_kind, sort_order) values
  ('fs_first_scan',       'first_steps', 1, 'Take your first skin scan',        '30 seconds, guided',        'scan',   '/scan/guide',           'task', 10),
  ('fs_set_reminder',     'first_steps', 1, 'Set your weekly scan reminder',    'One reminder, no spam',     'bell',   '/profile/notifications','task', 20),
  ('fs_add_product',      'first_steps', 2, 'Add your first product',           'Build your routine',        'bottle', '/routine/add',          'task', 30),
  ('fs_how_it_works',     'first_steps', 2, 'Learn how your plan works',        '1 minute',                  'book',   '/learn',                'task', 40),
  ('fs_meet_coach',       'first_steps', 3, 'Meet your AI coach',               'Ask anything about skin',   'chat',   '/coach',                'task', 50),
  ('fs_log_routine',      'first_steps', 4, 'Complete your first full routine', 'Tick every step',           'check',  '/routine',              'task', 60),
  ('fs_start_experiment', 'first_steps', 5, 'Start your first product test',    'Find out if it works',      'flask',  '/experiment/new',       'task', 70),
  ('fs_watch_video',      'first_steps', 6, 'Watch a skin-science video',       'Learn from experts',        'play',   '/learn',                'task', 80),
  ('fs_week_review',      'first_steps', 7, 'Review your first week',           'See what changed',          'chart',  '/progress',             'task', 90),
  ('dp_morning',          'daily_plan', null, 'Morning routine',                'Cleanse, treat, protect',   'sun',    '/routine?period=am',    'routine', 10),
  ('dp_evening',          'daily_plan', null, 'Evening routine',                'Cleanse and repair',        'moon',   '/routine?period=pm',    'routine', 20),
  ('dp_checkin',          'daily_plan', null, 'How does your skin feel today?', '2 taps',                    'smile',  '/checkin',              'checkin', 30),
  ('dp_tip',              'daily_plan', null, 'Read today''s tip',              '1 minute',                  'book',   '/learn',                'task', 40)
on conflict (key) do nothing;

-- =====================================================================
-- CORE HELPERS (internal)
-- =====================================================================
create or replace function public.cfg(p_key text)
returns jsonb language sql stable set search_path = '' as $$
  select value from public.app_config where key = p_key
$$;

create or replace function public.cfg_int(p_key text, p_default int)
returns int language sql stable set search_path = '' as $$
  select coalesce((select (value #>> '{}')::int from public.app_config where key = p_key), p_default)
$$;

create or replace function public.is_pro(p_user uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce((select e.is_pro and (e.expires_at is null or e.expires_at > now())
                   from public.entitlements e where e.user_id = p_user), false)
$$;

create or replace function public.local_today(p_user uuid)
returns date language plpgsql stable security definer set search_path = '' as $$
declare tz text;
begin
  select timezone into tz from public.profiles where id = p_user;
  begin
    return (now() at time zone coalesce(tz, 'UTC'))::date;
  exception when others then
    return (now() at time zone 'UTC')::date;
  end;
end $$;

create or replace function public.local_day_start(p_user uuid)
returns timestamptz language plpgsql stable security definer set search_path = '' as $$
declare tz text;
begin
  select timezone into tz from public.profiles where id = p_user;
  begin
    return (public.local_today(p_user)::timestamp at time zone coalesce(tz, 'UTC'));
  exception when others then
    return (public.local_today(p_user)::timestamp at time zone 'UTC');
  end;
end $$;

-- Accept the client's local date only if it is within +-1 day of the server's view
create or replace function public.clamp_day(p_user uuid, p_day date)
returns date language plpgsql stable security definer set search_path = '' as $$
declare t date := public.local_today(p_user);
begin
  if p_day is null or abs(p_day - t) > 1 then return t; end if;
  return p_day;
end $$;

create or replace function public.journey_day(p_user uuid, p_day date)
returns int language plpgsql stable security definer set search_path = '' as $$
declare tz text; created timestamptz; start_day date;
begin
  select timezone, created_at into tz, created from public.profiles where id = p_user;
  if created is null then return 1; end if;
  begin
    start_day := (created at time zone coalesce(tz, 'UTC'))::date;
  exception when others then
    start_day := (created at time zone 'UTC')::date;
  end;
  return greatest(1, (p_day - start_day) + 1);
end $$;

-- =====================================================================
-- NEW USER BOOTSTRAP (also fires for anonymous sign-ins)
-- =====================================================================
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id) values (new.id) on conflict (id) do nothing;
  insert into public.streak_state (user_id) values (new.id) on conflict (user_id) do nothing;
  insert into public.entitlements (user_id) values (new.id) on conflict (user_id) do nothing;
  insert into public.notification_prefs (user_id) values (new.id) on conflict (user_id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill for users that already exist (safe to re-run)
insert into public.profiles (id) select id from auth.users on conflict (id) do nothing;
insert into public.streak_state (user_id) select id from public.profiles on conflict (user_id) do nothing;
insert into public.entitlements (user_id) select id from public.profiles on conflict (user_id) do nothing;
insert into public.notification_prefs (user_id) select id from public.profiles on conflict (user_id) do nothing;

-- =====================================================================
-- STREAK ENGINE
-- =====================================================================
-- Core: apply one qualifying activity for a local day. INTERNAL (not callable by clients).
create or replace function public._apply_activity(p_user uuid, p_kind text, p_day date)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  st          public.streak_state%rowtype;
  qual        jsonb := public.cfg('streak_qualifying_kinds');
  max_fr      int   := public.cfg_int('streak_max_freezes', 2);
  fr_every    int   := public.cfg_int('streak_freeze_every_days', 7);
  max_gap     int   := public.cfg_int('streak_max_gap_days', 2);
  jk_every    int   := public.cfg_int('weekly_joker_every_weeks', 4);
  is_q        boolean;
  gap         int;
  missing     int;
  i           int;
  m           int;
  increased   boolean := false;
  was_reset   boolean := false;
  froze       int := 0;
  earned      boolean := false;
  wk          date;
  wk_gap      int;
  w_inc       boolean := false;
  w_joker     boolean := false;
  w_reset     boolean := false;
  new_ms      jsonb := '[]'::jsonb;
begin
  is_q := coalesce(qual ? p_kind, true);

  -- 1) calendar mark
  insert into public.activity_days (user_id, day, actions, had_scan, had_routine, had_task, had_checkin)
  values (p_user, p_day, 1, p_kind = 'scan', p_kind = 'routine', p_kind = 'task', p_kind = 'checkin')
  on conflict (user_id, day) do update set
    actions     = public.activity_days.actions + 1,
    had_scan    = public.activity_days.had_scan    or excluded.had_scan,
    had_routine = public.activity_days.had_routine or excluded.had_routine,
    had_task    = public.activity_days.had_task    or excluded.had_task,
    had_checkin = public.activity_days.had_checkin or excluded.had_checkin,
    is_freeze   = false;

  insert into public.streak_state (user_id) values (p_user) on conflict (user_id) do nothing;
  select * into st from public.streak_state where user_id = p_user for update;

  -- 2) daily streak
  if is_q then
    if st.last_active_date is null then
      st.current_streak := 1; increased := true;
    elsif p_day > st.last_active_date then
      gap := p_day - st.last_active_date;
      if gap = 1 then
        st.current_streak := st.current_streak + 1; increased := true;
      else
        missing := gap - 1;
        if missing <= st.freezes_available and missing <= max_gap and st.current_streak > 0 then
          st.freezes_available  := st.freezes_available - missing;
          st.freezes_used_total := st.freezes_used_total + missing;
          froze := missing;
          for i in 1..missing loop
            insert into public.activity_days (user_id, day, actions, is_freeze)
            values (p_user, st.last_active_date + i, 0, true)
            on conflict (user_id, day) do nothing;
          end loop;
          st.current_streak := st.current_streak + 1; increased := true;
          insert into public.streak_events (user_id, type, day, streak_after, meta)
          values (p_user, 'freeze_used', p_day, st.current_streak, jsonb_build_object('days_covered', missing));
        else
          insert into public.streak_events (user_id, type, day, streak_after, meta)
          values (p_user, 'reset', p_day, 1, jsonb_build_object('previous', st.current_streak));
          st.current_streak := 1; was_reset := true; increased := true;
        end if;
      end if;
    end if;

    if increased then
      if st.current_streak > st.longest_streak then st.longest_streak := st.current_streak; end if;
      st.last_active_date := p_day;
      insert into public.streak_events (user_id, type, day, streak_after)
      values (p_user, 'increment', p_day, st.current_streak);

      if fr_every > 0 and st.current_streak % fr_every = 0 and st.freezes_available < max_fr then
        st.freezes_available := st.freezes_available + 1; earned := true;
        insert into public.streak_events (user_id, type, day, streak_after)
        values (p_user, 'freeze_earned', p_day, st.current_streak);
      end if;

      for m in select jsonb_array_elements_text(coalesce(public.cfg('streak_milestones'), '[]'::jsonb))::int loop
        if st.current_streak = m then
          insert into public.milestones (user_id, type, meta)
          values (p_user, 'streak_' || m, jsonb_build_object('days', m))
          on conflict (user_id, type) do nothing;
          if found then new_ms := new_ms || to_jsonb('streak_' || m); end if;
        end if;
      end loop;
    end if;
  end if;

  -- 3) weekly scan streak (>= 1 scan per ISO week, 1 joker)
  if p_kind = 'scan' then
    wk := date_trunc('week', p_day::timestamp)::date;
    if st.last_scan_week is null then
      st.weekly_scan_streak := 1; w_inc := true;
    elsif wk > st.last_scan_week then
      wk_gap := (wk - st.last_scan_week) / 7;
      if wk_gap = 1 then
        st.weekly_scan_streak := st.weekly_scan_streak + 1; w_inc := true;
      elsif wk_gap = 2 and st.weekly_joker_available then
        st.weekly_joker_available := false;
        st.weekly_scan_streak := st.weekly_scan_streak + 1; w_inc := true; w_joker := true;
      else
        st.weekly_scan_streak := 1; w_reset := true;
      end if;
    end if;
    if st.last_scan_week is null or wk > st.last_scan_week then st.last_scan_week := wk; end if;

    if w_inc then
      if jk_every > 0 and st.weekly_scan_streak % jk_every = 0 then st.weekly_joker_available := true; end if;
      if st.weekly_scan_streak > st.longest_weekly_scan_streak then
        st.longest_weekly_scan_streak := st.weekly_scan_streak;
      end if;
      insert into public.streak_events (user_id, type, day, streak_after, meta)
      values (p_user, case when w_joker then 'weekly_joker_used' else 'weekly_increment' end, p_day,
              st.weekly_scan_streak, '{}'::jsonb);
      if st.weekly_scan_streak in (4, 12) then
        insert into public.milestones (user_id, type, meta)
        values (p_user, 'weekly_streak_' || st.weekly_scan_streak, jsonb_build_object('weeks', st.weekly_scan_streak))
        on conflict (user_id, type) do nothing;
        if found then new_ms := new_ms || to_jsonb('weekly_streak_' || st.weekly_scan_streak); end if;
      end if;
    elsif w_reset then
      if st.weekly_scan_streak > st.longest_weekly_scan_streak then
        st.longest_weekly_scan_streak := st.weekly_scan_streak;
      end if;
      insert into public.streak_events (user_id, type, day, streak_after)
      values (p_user, 'weekly_reset', p_day, 1);
    end if;
  end if;

  update public.streak_state set
    current_streak             = st.current_streak,
    longest_streak             = st.longest_streak,
    last_active_date           = st.last_active_date,
    freezes_available          = st.freezes_available,
    freezes_used_total         = st.freezes_used_total,
    weekly_scan_streak         = st.weekly_scan_streak,
    longest_weekly_scan_streak = st.longest_weekly_scan_streak,
    last_scan_week             = st.last_scan_week,
    weekly_joker_available     = st.weekly_joker_available
  where user_id = p_user;

  return jsonb_build_object(
    'current_streak', st.current_streak, 'longest_streak', st.longest_streak,
    'increased', increased, 'was_reset', was_reset, 'freezes_used', froze, 'freeze_earned', earned,
    'weekly_scan_streak', st.weekly_scan_streak, 'weekly_joker_used', w_joker,
    'new_milestones', new_ms);
end $$;

-- Compact streak JSON used by several RPCs
create or replace function public._streak_json(p_user uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare s public.streak_state%rowtype; today date := public.local_today(p_user);
begin
  select * into s from public.streak_state where user_id = p_user;
  if not found then
    return jsonb_build_object('current',0,'longest',0,'last_active_date',null,'active_today',false,
      'at_risk',false,'freezes',0,'weekly_scan_streak',0,'longest_weekly_scan_streak',0,'weekly_joker',true);
  end if;
  return jsonb_build_object(
    'current', s.current_streak, 'longest', s.longest_streak, 'last_active_date', s.last_active_date,
    'active_today', s.last_active_date = today,
    'at_risk', s.current_streak > 0 and s.last_active_date < today,
    'freezes', s.freezes_available,
    'weekly_scan_streak', s.weekly_scan_streak, 'longest_weekly_scan_streak', s.longest_weekly_scan_streak,
    'weekly_joker', s.weekly_joker_available);
end $$;

-- Client RPC: log a non-sensitive activity (reading a tip, using the coach, writing a note)
-- Scans and routine ticks are credited ONLY by database triggers, so they cannot be faked.
create or replace function public.log_activity(p_kind text, p_local_day date default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if p_kind not in ('task','checkin','learn','coach','note') then
    raise exception 'invalid activity kind: %', p_kind using errcode = '22023';
  end if;
  return public._apply_activity(u, p_kind, public.clamp_day(u, p_local_day));
end $$;

-- Client RPC: call when the app opens. Applies lazy resets and returns the streak state.
create or replace function public.refresh_streak()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  u uuid := auth.uid();
  s public.streak_state%rowtype;
  today date; missing int; wk date; wk_gap int;
  max_gap int := public.cfg_int('streak_max_gap_days', 2);
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  insert into public.streak_state (user_id) values (u) on conflict (user_id) do nothing;
  select * into s from public.streak_state where user_id = u for update;
  today := public.local_today(u);

  if s.last_active_date is not null and s.current_streak > 0 then
    missing := today - s.last_active_date - 1;      -- fully missed days before today
    if missing >= 1 and missing > least(s.freezes_available, max_gap) then
      insert into public.streak_events (user_id, type, day, streak_after, meta)
      values (u, 'reset', today, 0, jsonb_build_object('previous', s.current_streak, 'lazy', true));
      update public.streak_state set current_streak = 0 where user_id = u;
    end if;
  end if;

  if s.last_scan_week is not null and s.weekly_scan_streak > 0 then
    wk := date_trunc('week', today::timestamp)::date;
    wk_gap := (wk - s.last_scan_week) / 7;
    if wk_gap >= 3 or (wk_gap = 2 and not s.weekly_joker_available) then
      insert into public.streak_events (user_id, type, day, streak_after, meta)
      values (u, 'weekly_reset', today, 0, jsonb_build_object('previous', s.weekly_scan_streak, 'lazy', true));
      update public.streak_state set weekly_scan_streak = 0 where user_id = u;
    end if;
  end if;

  return public._streak_json(u);
end $$;

-- =====================================================================
-- ACTIVITY TRIGGERS (server-side credit)
-- =====================================================================
create or replace function public.trg_routine_log_activity()
returns trigger language plpgsql security definer set search_path = '' as $$
declare t date := public.local_today(new.user_id);
begin
  if new.done and new.log_date between t - 1 and t then      -- no back-dating beyond yesterday
    perform public._apply_activity(new.user_id, 'routine', new.log_date);
  end if;
  return null;
end $$;
drop trigger if exists trg_routine_logs_ins on public.routine_logs;
create trigger trg_routine_logs_ins after insert on public.routine_logs
  for each row when (new.done) execute function public.trg_routine_log_activity();
drop trigger if exists trg_routine_logs_upd on public.routine_logs;
create trigger trg_routine_logs_upd after update of done on public.routine_logs
  for each row when (new.done and not old.done) execute function public.trg_routine_log_activity();

create or replace function public.trg_scan_done()
returns trigger language plpgsql security definer set search_path = '' as $$
declare n int;
begin
  -- demo scans never touch streaks
  if new.is_demo then return null; end if;

  perform public._apply_activity(new.user_id, 'scan', public.local_today(new.user_id));

  select count(*) into n from public.scans where user_id = new.user_id and status = 'done';
  if n = 1 then
    insert into public.milestones (user_id, type) values (new.user_id, 'first_scan') on conflict do nothing;
  elsif n = 2 then
    insert into public.milestones (user_id, type) values (new.user_id, 'second_scan') on conflict do nothing;
  end if;

  -- link as follow-up to every active experiment (baseline links are created by start_experiment)
  insert into public.experiment_scans (experiment_id, scan_id, role)
  select e.id, new.id, 'followup'
  from public.experiments e
  where e.user_id = new.user_id and e.status = 'active' and e.started_at < new.created_at
  on conflict do nothing;
  return null;
end $$;
drop trigger if exists trg_scans_done on public.scans;
create trigger trg_scans_done after update of status on public.scans
  for each row when (new.status = 'done' and old.status is distinct from 'done')
  execute function public.trg_scan_done();

create or replace function public.trg_task_done()
returns trigger language plpgsql security definer set search_path = '' as $$
declare k text;
begin
  select activity_kind into k from public.task_templates where key = new.template_key;
  perform public._apply_activity(new.user_id, coalesce(k, 'task'), public.local_today(new.user_id));
  return null;
end $$;
drop trigger if exists trg_user_tasks_done on public.user_tasks;
create trigger trg_user_tasks_done after update of status on public.user_tasks
  for each row when (new.status = 'done' and old.status <> 'done')
  execute function public.trg_task_done();

create or replace function public.trg_checkin_activity()
returns trigger language plpgsql security definer set search_path = '' as $$
declare t date := public.local_today(new.user_id);
begin
  if new.checkin_date between t - 1 and t then
    perform public._apply_activity(new.user_id, 'checkin', new.checkin_date);
  end if;
  return null;
end $$;
drop trigger if exists trg_checkins_ins on public.checkins;
create trigger trg_checkins_ins after insert on public.checkins
  for each row execute function public.trg_checkin_activity();

-- =====================================================================
-- DAILY TASKS (Day 1-7 journey + daily plan)
-- =====================================================================
create or replace function public.ensure_daily_tasks(p_day date default null)
returns void language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); d date; jd int;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  d  := public.clamp_day(u, p_day);
  jd := public.journey_day(u, d);

  insert into public.user_tasks (user_id, template_key, for_date)
  select u, t.key, d from public.task_templates t
  where t.active and t.section = 'daily_plan' and (not t.requires_pro or public.is_pro(u))
  on conflict do nothing;

  if jd between 1 and 7 then
    insert into public.user_tasks (user_id, template_key, for_date)
    select u, t.key, null from public.task_templates t
    where t.active and t.section = 'first_steps' and t.day_number <= jd
    on conflict do nothing;
  end if;
end $$;

create or replace function public.complete_task(p_key text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); today date; n int;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  today := public.local_today(u);
  perform public.ensure_daily_tasks(today);
  update public.user_tasks
     set status = 'done', completed_at = now()
   where user_id = u and template_key = p_key and status = 'todo'
     and (for_date is null or for_date = today);
  get diagnostics n = row_count;
  return jsonb_build_object('completed', n > 0, 'streak', public._streak_json(u));
end $$;

-- =====================================================================
-- HOME SCREEN PAYLOAD (one round-trip for C01)
-- =====================================================================
create or replace function public.home_summary(p_day date default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  u uuid := auth.uid(); d date; jd int; js date; p public.profiles%rowtype;
  last_scan timestamptz; last_scan_day date; due date; base date; wd int;
  min_d int := public.cfg_int('scan_min_interval_days', 5);
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  d  := public.clamp_day(u, p_day);
  perform public.ensure_daily_tasks(d);
  perform public.refresh_streak();
  select * into p from public.profiles where id = u;
  jd := public.journey_day(u, d);
  js := d - jd + 1;

  select max(created_at) into last_scan from public.scans where user_id = u and status = 'done';
  if last_scan is null then
    due := d;
  else
    last_scan_day := (last_scan at time zone coalesce(p.timezone, 'UTC'))::date;
    base := last_scan_day + min_d;
    wd   := extract(isodow from base)::int;
    due  := base + ((p.scan_weekday - wd + 7) % 7);
  end if;

  return jsonb_build_object(
    'today', d,
    'is_pro', public.is_pro(u),
    'profile', jsonb_build_object('display_name', p.display_name, 'goals', p.goals, 'timezone', p.timezone),
    'streak', public._streak_json(u),
    'journey', jsonb_build_object(
      'day', jd,
      'days', (select coalesce(jsonb_agg(jsonb_build_object(
                  'day', n, 'date', js + n - 1,
                  'done', exists (select 1 from public.activity_days a
                                  where a.user_id = u and a.day = js + n - 1 and (a.actions > 0 or a.is_freeze)),
                  'is_today', n = jd) order by n), '[]'::jsonb)
              from generate_series(1, 7) n)),
    'tasks', jsonb_build_object(
      'first_steps', (select coalesce(jsonb_agg(jsonb_build_object(
                          'key', t.key, 'title', t.title, 'subtitle', t.subtitle, 'icon', t.icon,
                          'deep_link', t.deep_link, 'day', t.day_number,
                          'status', coalesce(ut.status, 'todo'),
                          'locked', t.day_number > jd) order by t.day_number, t.sort_order), '[]'::jsonb)
                      from public.task_templates t
                      left join public.user_tasks ut
                        on ut.user_id = u and ut.template_key = t.key and ut.for_date is null
                      where t.active and t.section = 'first_steps'),
      'daily_plan',  (select coalesce(jsonb_agg(jsonb_build_object(
                          'key', t.key, 'title', t.title, 'subtitle', t.subtitle, 'icon', t.icon,
                          'deep_link', t.deep_link, 'status', coalesce(ut.status, 'todo'),
                          'locked', t.requires_pro and not public.is_pro(u)) order by t.sort_order), '[]'::jsonb)
                      from public.task_templates t
                      left join public.user_tasks ut
                        on ut.user_id = u and ut.template_key = t.key and ut.for_date = d
                      where t.active and t.section = 'daily_plan')),
    'next_scan', jsonb_build_object('last_scan_at', last_scan, 'due_date', due, 'is_due', due <= d),
    'latest_scan', (select jsonb_build_object('id', s.id, 'overall_score', s.overall_score,
                           'skin_age', s.skin_age, 'created_at', s.created_at)
                    from public.scans s where s.user_id = u and s.status = 'done'
                    order by s.created_at desc limit 1),
    'active_experiments', (select coalesce(jsonb_agg(jsonb_build_object(
                           'id', e.id, 'title', e.title, 'targets', e.targets, 'planned_days', e.planned_days,
                           'day_number', (d - e.started_on) + 1,
                           'adherence', public._experiment_adherence(e.id)) order by e.started_at), '[]'::jsonb)
                           from public.experiments e where e.user_id = u and e.status = 'active')
  );
end $$;

-- Calendar screen (Me tab): dots for active days, scans, frozen days, experiment start/end
create or replace function public.calendar_month(p_month date default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); m0 date; m1 date;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  m0 := date_trunc('month', coalesce(p_month, public.local_today(u))::timestamp)::date;
  m1 := (m0::timestamp + interval '1 month')::date;
  return jsonb_build_object(
    'month', m0,
    'days', (select coalesce(jsonb_agg(jsonb_build_object(
               'day', a.day, 'actions', a.actions, 'had_scan', a.had_scan, 'had_routine', a.had_routine,
               'had_task', a.had_task, 'had_checkin', a.had_checkin, 'is_freeze', a.is_freeze) order by a.day), '[]'::jsonb)
             from public.activity_days a where a.user_id = u and a.day >= m0 and a.day < m1),
    'experiments', (select coalesce(jsonb_agg(jsonb_build_object(
               'id', e.id, 'title', e.title, 'starts', e.started_on,
               'ends', coalesce(e.ended_at::date, e.started_on + e.planned_days)) order by e.started_on), '[]'::jsonb)
             from public.experiments e
             where e.user_id = u and e.started_on < m1 and coalesce(e.ended_at::date, e.started_on + e.planned_days) >= m0));
end $$;

-- =====================================================================
-- EXPERIMENTS: adherence, verdict engine, lifecycle
-- =====================================================================
create or replace function public._experiment_adherence(p_exp uuid)
returns numeric language plpgsql stable security definer set search_path = '' as $$
declare e public.experiments%rowtype; it public.routine_items%rowtype; d0 date; d1 date; expected int; done_n int;
begin
  select * into e from public.experiments where id = p_exp;
  if not found or e.item_id is null then return null; end if;
  select * into it from public.routine_items where id = e.item_id;
  if not found then return null; end if;
  d0 := e.started_on;
  d1 := least(coalesce(e.ended_at::date, public.local_today(e.user_id)), e.started_on + e.planned_days);
  if d1 < d0 then return null; end if;
  select count(*) into expected from generate_series(0, d1 - d0) g
   where it.days is null or extract(isodow from (d0 + g))::int = any (it.days);
  select count(distinct l.log_date) into done_n from public.routine_logs l
   where l.item_id = e.item_id and l.done and l.log_date between d0 and d1;
  if expected = 0 then return null; end if;
  return round(least(1, done_n::numeric / expected), 3);
end $$;

-- Verdict heuristic (transparent, not a medical test). See blueprint chapter 11.9.
create or replace function public.compute_experiment_verdict(p_exp uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  e public.experiments%rowtype;
  tgt text; arr jsonb := '[]'::jsonb;
  base numeric; post numeric; post_n int; n_after int; q numeric; adh numeric;
  noise numeric; delta numeric; v text; conf text; end_ts timestamptz;
  cfg jsonb := coalesce(public.cfg('noise_by_concern'), '{"default":3}'::jsonb);
  higher boolean := coalesce((public.cfg('score_higher_is_better') #>> '{}')::boolean, true);
begin
  select * into e from public.experiments where id = p_exp;
  if not found then raise exception 'experiment not found' using errcode = 'P0002'; end if;
  if auth.uid() is not null and e.user_id <> auth.uid() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  end_ts := coalesce(e.ended_at, now());
  adh := coalesce(public._experiment_adherence(p_exp), 0);

  select count(*) into n_after from public.scans s
   where s.user_id = e.user_id and s.status = 'done' and s.created_at > e.started_at and s.created_at <= end_ts;
  select coalesce(avg(case when s.quality_ok then 1.0 else 0.0 end), 1) into q from public.scans s
   where s.user_id = e.user_id and s.status = 'done' and s.created_at > e.started_at and s.created_at <= end_ts;

  foreach tgt in array e.targets loop
    select avg(c.raw_score) into base
      from public.experiment_scans es
      join public.scan_concerns c on c.scan_id = es.scan_id and c.concern = tgt
     where es.experiment_id = p_exp and es.role = 'baseline';

    select avg(c.raw_score), count(distinct s.id) into post, post_n
      from public.scans s
      join public.scan_concerns c on c.scan_id = s.id and c.concern = tgt
     where s.user_id = e.user_id and s.status = 'done'
       and s.created_at > e.started_at and s.created_at <= end_ts
       and s.created_at >= end_ts - interval '21 days';

    noise := coalesce((cfg ->> tgt)::numeric, (cfg ->> 'default')::numeric, 3);
    delta := case when base is null or post is null then null
                  else case when higher then post - base else base - post end end;

    if base is null or post is null or n_after < 3 or coalesce(post_n, 0) < 2 or adh < 0.5 then
      v := 'not_enough_data';
    elsif tgt = 'redness' and delta <= -noise then
      v := 'possible_irritation';
    elsif delta >= 2 * noise then v := 'visible_effect';
    elsif delta >= noise      then v := 'slight_effect';
    elsif abs(delta) < noise  then v := 'no_clear_signal';
    else v := 'slight_decline';
    end if;

    conf := case when n_after >= 5 and adh >= 0.80 and q >= 0.8 then 'high'
                 when n_after >= 4 and adh >= 0.65               then 'medium'
                 else 'low' end;

    arr := arr || jsonb_build_object(
      'concern', tgt, 'baseline', round(base, 1), 'post', round(post, 1), 'delta', round(delta, 1),
      'noise', noise, 'verdict', v, 'confidence', conf, 'scans_after', n_after,
      'adherence', round(adh, 2), 'quality_ratio', round(q, 2));
  end loop;

  return jsonb_build_object('experiment_id', p_exp, 'primary', arr -> 0, 'targets', arr, 'computed_at', now());
end $$;

create or replace function public.start_experiment(p_item uuid, p_targets text[], p_planned_days int default 42)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  u uuid := auth.uid(); it public.routine_items%rowtype;
  ids uuid[]; recent int; warns jsonb := '[]'::jsonb; new_id uuid;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select * into it from public.routine_items where id = p_item and user_id = u;
  if not found then raise exception 'product not found' using errcode = 'P0002'; end if;
  if p_targets is null or cardinality(p_targets) not between 1 and 2 then
    raise exception 'choose 1 or 2 targets' using errcode = '22023';
  end if;
  if p_planned_days not between 14 and 180 then
    raise exception 'planned_days must be between 14 and 180' using errcode = '22023';
  end if;

  select count(*) into recent from public.scans
   where user_id = u and status = 'done' and created_at >= now() - interval '7 days';
  if recent = 0 then
    raise exception 'baseline_required' using errcode = 'P0001', hint = 'Scan first to set your baseline';
  end if;

  select array_agg(id) into ids from (
    select id from public.scans
     where user_id = u and status = 'done' and created_at >= now() - interval '14 days'
     order by created_at desc limit 2) s;

  if exists (select 1 from public.experiments
              where user_id = u and status in ('active','paused') and targets && p_targets) then
    warns := warns || to_jsonb('overlap_same_target'::text);
  end if;

  insert into public.experiments (user_id, item_id, title, targets, planned_days, started_on)
  values (u, p_item, it.name, p_targets, p_planned_days, public.local_today(u))
  returning id into new_id;

  insert into public.experiment_scans (experiment_id, scan_id, role)
  select new_id, x, 'baseline' from unnest(ids) x;

  return jsonb_build_object('experiment_id', new_id, 'baseline_scan_ids', to_jsonb(ids), 'warnings', warns);
end $$;

create or replace function public.set_experiment_status(p_exp uuid, p_status text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); e public.experiments%rowtype;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select * into e from public.experiments where id = p_exp and user_id = u for update;
  if not found then raise exception 'experiment not found' using errcode = 'P0002'; end if;
  if p_status not in ('active','paused','stopped') then
    raise exception 'use finalize_experiment() to complete' using errcode = '22023';
  end if;
  if e.status in ('completed','stopped') then
    raise exception 'experiment already closed' using errcode = '22023';
  end if;
  update public.experiments
     set status = p_status,
         ended_at = case when p_status = 'stopped' then now() else ended_at end
   where id = p_exp;
  return jsonb_build_object('experiment_id', p_exp, 'status', p_status);
end $$;

create or replace function public.finalize_experiment(p_exp uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); v jsonb; e public.experiments%rowtype;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select * into e from public.experiments where id = p_exp and user_id = u for update;
  if not found then raise exception 'experiment not found' using errcode = 'P0002'; end if;
  if e.status = 'completed' and e.verdict is not null then return e.verdict; end if;

  update public.experiments set ended_at = coalesce(ended_at, now()) where id = p_exp;
  v := public.compute_experiment_verdict(p_exp);
  update public.experiments
     set status = 'completed', verdict = v, adherence = public._experiment_adherence(p_exp)
   where id = p_exp;
  insert into public.milestones (user_id, type) values (u, 'first_verdict') on conflict do nothing;
  return v;
end $$;

-- =====================================================================
-- SCAN GATE (protects your provider units) + service-side scan writers
-- =====================================================================
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
   where user_id = p_user and created_at >= now() - interval '24 hours';
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

create or replace function public.can_start_scan()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  return public.scan_gate(u);
end $$;

-- Edge Function (service role) writes the provider result atomically. Idempotent.
create or replace function public.complete_scan(
  p_scan uuid, p_overall numeric, p_skin_age int, p_concerns jsonb,
  p_result jsonb default null, p_units numeric default 0, p_quality_ok boolean default true)
returns void language plpgsql security definer set search_path = '' as $$
declare s public.scans%rowtype;
begin
  select * into s from public.scans where id = p_scan for update;
  if not found then raise exception 'scan not found' using errcode = 'P0002'; end if;
  if s.status = 'done' then return; end if;

  insert into public.scan_concerns (scan_id, user_id, concern, zone, raw_score, ui_score, mask_path)
  select p_scan, s.user_id, c ->> 'concern', nullif(c ->> 'zone', ''),
         (c ->> 'raw_score')::numeric, nullif(c ->> 'ui_score', '')::numeric, nullif(c ->> 'mask_path', '')
    from jsonb_array_elements(coalesce(p_concerns, '[]'::jsonb)) c
  on conflict do nothing;

  insert into public.api_usage (user_id, kind, units, ref_id) values (s.user_id, 'scan', coalesce(p_units, 0), p_scan);

  update public.scans
     set overall_score = p_overall, skin_age = p_skin_age, result_json = p_result,
         quality_ok = p_quality_ok, status = 'done', completed_at = now(), error_code = null
   where id = p_scan;                                   -- fires streak + milestones trigger
end $$;

create or replace function public.fail_scan(p_scan uuid, p_error_code text)
returns void language sql security definer set search_path = '' as $$
  update public.scans set status = 'failed', error_code = p_error_code, completed_at = now()
   where id = p_scan and status <> 'done'
$$;

-- =====================================================================
-- COACH: server-side daily limits
-- =====================================================================
create or replace function public.coach_remaining()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare u uuid := auth.uid(); lim int; used int;
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  lim := case when public.is_pro(u) then public.cfg_int('coach_daily_limit_pro', 30)
              else public.cfg_int('coach_daily_limit_free', 3) end;
  select count(*) into used from public.messages
   where user_id = u and role = 'user' and created_at >= public.local_day_start(u);
  return jsonb_build_object('limit', lim, 'used', used, 'remaining', greatest(lim - used, 0));
end $$;

create or replace function public.trg_messages_limit()
returns trigger language plpgsql security definer set search_path = '' as $$
declare lim int; used int;
begin
  if new.role = 'user' and auth.uid() is not null then
    lim := case when public.is_pro(new.user_id) then public.cfg_int('coach_daily_limit_pro', 30)
                else public.cfg_int('coach_daily_limit_free', 3) end;
    select count(*) into used from public.messages
     where user_id = new.user_id and role = 'user' and created_at >= public.local_day_start(new.user_id);
    if used >= lim then
      raise exception 'coach_limit_reached' using errcode = 'P0001', hint = 'Daily coach limit reached';
    end if;
  end if;
  return new;
end $$;
drop trigger if exists trg_messages_limit on public.messages;
create trigger trg_messages_limit before insert on public.messages
  for each row execute function public.trg_messages_limit();

-- =====================================================================
-- CONSENT + PRIVACY (GDPR/BIPA-style helpers)
-- =====================================================================
create or replace function public.record_consent(p_type text, p_version text, p_app_version text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if p_type not in ('face_processing','terms','privacy','marketing','age_18') then
    raise exception 'invalid consent type' using errcode = '22023';
  end if;
  insert into public.consents (user_id, type, version, app_version) values (u, p_type, p_version, p_app_version);
  if p_type = 'face_processing' then
    update public.profiles set consent_version = p_version, consent_at = now() where id = u;
  elsif p_type = 'age_18' then
    update public.profiles set age_confirmed = true where id = u;
  end if;
end $$;

-- Returns the Storage paths the Edge Function must delete through the Storage API
-- (never delete storage.objects rows with SQL: the files would stay orphaned).
create or replace function public.delete_my_photos()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); photos text[]; masks text[];
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select coalesce(array_agg(photo_path), '{}') into photos from public.scans where user_id = u and photo_path is not null;
  select coalesce(array_agg(mask_path), '{}')  into masks  from public.scan_concerns where user_id = u and mask_path is not null;
  update public.scans set photo_path = null where user_id = u and photo_path is not null;
  update public.scan_concerns set mask_path = null where user_id = u and mask_path is not null;
  return jsonb_build_object('photo_paths', to_jsonb(photos), 'mask_paths', to_jsonb(masks));
end $$;

-- Step 1 of account deletion: wipes all rows (cascade) and returns files to delete.
-- Step 2 (Edge Function): remove storage files, then auth.admin.deleteUser(uid).
create or replace function public.delete_my_account_data()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); photos text[]; masks text[];
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select coalesce(array_agg(photo_path), '{}') into photos from public.scans where user_id = u and photo_path is not null;
  select coalesce(array_agg(mask_path), '{}')  into masks  from public.scan_concerns where user_id = u and mask_path is not null;
  delete from public.profiles where id = u;               -- cascades to every user table
  return jsonb_build_object('photo_paths', to_jsonb(photos), 'mask_paths', to_jsonb(masks));
end $$;

create or replace function public.export_my_data()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  return jsonb_build_object(
    'exported_at', now(),
    'profile',      (select to_jsonb(p) from public.profiles p where p.id = u),
    'scans',        (select coalesce(jsonb_agg(to_jsonb(s) - 'result_json'), '[]'::jsonb) from public.scans s where s.user_id = u),
    'scan_concerns',(select coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb) from public.scan_concerns c where c.user_id = u),
    'routine_items',(select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from public.routine_items r where r.user_id = u),
    'routine_logs', (select coalesce(jsonb_agg(to_jsonb(l)), '[]'::jsonb) from public.routine_logs l where l.user_id = u),
    'experiments',  (select coalesce(jsonb_agg(to_jsonb(e)), '[]'::jsonb) from public.experiments e where e.user_id = u),
    'notes',        (select coalesce(jsonb_agg(to_jsonb(n)), '[]'::jsonb) from public.notes n where n.user_id = u),
    'checkins',     (select coalesce(jsonb_agg(to_jsonb(k)), '[]'::jsonb) from public.checkins k where k.user_id = u),
    'messages',     (select coalesce(jsonb_agg(to_jsonb(m)), '[]'::jsonb) from public.messages m where m.user_id = u),
    'activity_days',(select coalesce(jsonb_agg(to_jsonb(a)), '[]'::jsonb) from public.activity_days a where a.user_id = u),
    'streak',       (select to_jsonb(s) from public.streak_state s where s.user_id = u),
    'milestones',   (select coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb) from public.milestones x where x.user_id = u),
    'consents',     (select coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb) from public.consents c where c.user_id = u));
end $$;

-- Service-only: users who chose "scores only" -> purge their photos soon after analysis
create or replace function public.photos_to_purge(p_older_than interval default '1 hour')
returns table (user_id uuid, scan_id uuid, photo_path text)
language sql stable security definer set search_path = '' as $$
  select s.user_id, s.id, s.photo_path
    from public.scans s join public.profiles p on p.id = s.user_id
   where p.keep_photos = false and s.photo_path is not null and s.created_at < now() - p_older_than
$$;

create or replace function public.mark_photos_purged(p_scan_ids uuid[])
returns void language sql security definer set search_path = '' as $$
  update public.scans set photo_path = null where id = any (p_scan_ids)
$$;

-- =====================================================================
-- DEMO / JUDGE MODE: realistic 7-week history (synthetic, flagged is_demo)
-- =====================================================================
create or replace function public.seed_demo_data(p_user uuid default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  t uuid; caller uuid := auth.uid(); today date; tz text;
  offs int[] := array[49,42,35,28,21,14,7,0];     -- days ago: 2 baseline scans, then 6 follow-ups
  idx int; sid uuid; ts timestamptz; item uuid; exp_id uuid; i int; d date; cur int; longest int;
  v jsonb; ex_start timestamptz;
begin
  t := coalesce(p_user, caller);
  if t is null then raise exception 'user required' using errcode = '22023'; end if;
  if caller is not null then
    if t <> caller then raise exception 'forbidden' using errcode = '42501'; end if;
    if coalesce((public.cfg('demo_mode') #>> '{}')::boolean, false) is not true then
      raise exception 'demo mode is disabled' using errcode = '42501';
    end if;
  end if;
  select timezone into tz from public.profiles where id = t;
  if not found then raise exception 'profile not found' using errcode = 'P0002'; end if;
  today := public.local_today(t);

  -- clean previous demo data
  delete from public.experiments where user_id = t and title like '%(demo)';
  delete from public.scans where user_id = t and is_demo;
  delete from public.routine_items where user_id = t and name like '%(demo)';
  delete from public.messages where user_id = t and context ->> 'demo' = 'true';
  delete from public.activity_days where user_id = t;
  delete from public.streak_events where user_id = t;
  delete from public.milestones where user_id = t;
  delete from public.user_tasks where user_id = t;

  update public.profiles set is_demo = true, display_name = coalesce(display_name, 'Amina'),
         goals = array['age_spot','redness'], skin_type = 'combination', sun_habit = 'daily',
         current_actives = array['retinoid'], actives_started = '2_8w',
         age_confirmed = true, onboarding_completed_at = coalesce(onboarding_completed_at, now()),
         consent_version = coalesce(consent_version, 'demo'), consent_at = coalesce(consent_at, now())
   where id = t;
  update public.entitlements set is_pro = true, plan = 'annual', status = 'active',
         expires_at = now() + interval '30 days' where user_id = t;

  -- routine
  insert into public.routine_items (user_id, name, brand, step_type, actives, period, started_on, sort_order)
  values (t, 'Gentle cleanser (demo)', null, 'cleanser', '{}', 'both', today - 60, 10);
  insert into public.routine_items (user_id, name, brand, step_type, actives, period, started_on, sort_order)
  values (t, 'Retinol serum 0.3% (demo)', null, 'treatment', array['retinol'], 'pm', today - 42, 20)
  returning id into item;
  insert into public.routine_items (user_id, name, brand, step_type, actives, period, started_on, sort_order)
  values (t, 'Daily moisturizer (demo)', null, 'moisturizer', '{}', 'both', today - 60, 30);
  insert into public.routine_items (user_id, name, brand, step_type, actives, period, started_on, sort_order)
  values (t, 'Mineral SPF 50 (demo)', null, 'spf', array['zinc_oxide'], 'am', today - 60, 40);

  -- experiment started 42 days ago (baseline = the two oldest scans)
  ex_start := now() - interval '42 days' + interval '1 hour';
  insert into public.experiments (user_id, item_id, title, targets, planned_days, started_at, started_on, status)
  values (t, item, 'Retinol serum 0.3% (demo)', array['age_spot'], 42, ex_start, today - 42, 'active')
  returning id into exp_id;

  -- 8 weekly scans with believable trends (dark spots improve, redness stable)
  for idx in 0..7 loop
    ts := now() - make_interval(days => offs[idx + 1]);
    insert into public.scans (user_id, status, mode, overall_score, skin_age, quality_ok, is_demo, created_at, completed_at)
    values (t, 'done', 'SD', null, 36 - (idx / 3), true, true, ts, ts)
    returning id into sid;

    insert into public.scan_concerns (scan_id, user_id, concern, raw_score, ui_score)
    select sid, t, c.concern,
           round((c.base + c.gain * greatest(0, idx - 1)
                  + ((abs(hashtext(sid::text || c.concern)) % 7) - 3) * 0.4)::numeric, 2),
           null
      from (values ('age_spot', 58.0, 2.4), ('redness', 71.0, 0.1), ('texture', 58.0, 0.6),
                   ('pore', 60.0, 0.05), ('moisture', 66.0, 0.5), ('acne', 78.0, 0.3)) as c(concern, base, gain);

    update public.scans set overall_score = (select round(avg(raw_score), 2) from public.scan_concerns where scan_id = sid)
     where id = sid;

    insert into public.experiment_scans (experiment_id, scan_id, role)
    values (exp_id, sid, case when idx <= 1 then 'baseline' else 'followup' end);
  end loop;

  -- routine adherence on the test product: perfect for 12 days, ~80% before
  for i in 0..42 loop
    d := today - i;
    if i < 12 or (abs(hashtext(d::text)) % 100) < 80 then
      insert into public.routine_logs (user_id, item_id, log_date, period, done)
      values (t, item, d, 'pm', true) on conflict do nothing;
    end if;
  end loop;

  -- the routine_logs triggers above already credited today/yesterday: wipe and rebuild cleanly
  delete from public.activity_days where user_id = t;
  delete from public.streak_events where user_id = t;
  delete from public.milestones where user_id = t;

  -- rebuild the streak calendar from the demo data
  insert into public.activity_days (user_id, day, actions, had_scan, had_routine)
  select t, x.d, count(*), bool_or(x.src = 'scan'), bool_or(x.src = 'routine')
    from (select l.log_date as d, 'routine' as src from public.routine_logs l where l.user_id = t and l.done
          union all
          select (s.created_at at time zone coalesce(tz, 'UTC'))::date, 'scan'
            from public.scans s where s.user_id = t and s.is_demo) x
   group by x.d;

  cur := 0; d := today;
  while exists (select 1 from public.activity_days a where a.user_id = t and a.day = d) loop
    cur := cur + 1; d := d - 1;
  end loop;
  select coalesce(max(n), 0) into longest from (
    select count(*) n from (select a.day - (row_number() over (order by a.day))::int as g
                              from public.activity_days a where a.user_id = t) q group by g) r;

  insert into public.streak_state (user_id) values (t) on conflict (user_id) do nothing;
  update public.streak_state set current_streak = cur, longest_streak = greatest(longest, cur),
         last_active_date = case when cur > 0 then today else null end,
         freezes_available = 2, freezes_used_total = 1,
         weekly_scan_streak = 8, longest_weekly_scan_streak = 8,
         last_scan_week = date_trunc('week', today::timestamp)::date, weekly_joker_available = true
   where user_id = t;

  insert into public.milestones (user_id, type)
  select t, m from (values ('first_scan'), ('second_scan'), ('weekly_streak_4')) v(m)
  on conflict do nothing;
  insert into public.milestones (user_id, type)
  select t, 'streak_' || m from unnest(array[3,7,14,30,60,100]) m where m <= greatest(longest, cur)
  on conflict do nothing;

  -- first steps done, daily plan fresh
  insert into public.user_tasks (user_id, template_key, for_date, status, completed_at)
  select t, k.key, null, 'done', now() - interval '40 days' from public.task_templates k where k.section = 'first_steps';

  -- close the experiment with the real verdict engine
  update public.experiments set ended_at = now() where id = exp_id;
  v := public.compute_experiment_verdict(exp_id);
  update public.experiments set status = 'completed', verdict = v,
         adherence = public._experiment_adherence(exp_id) where id = exp_id;
  insert into public.milestones (user_id, type) values (t, 'first_verdict') on conflict do nothing;

  insert into public.messages (user_id, role, content, context) values
    (t, 'user', 'Is my retinol working for my dark spots?', '{"demo": true}'),
    (t, 'assistant', 'Based on your last 8 scans, your dark-spot score rose about 11 points since you started. That is a visible effect with medium-to-high confidence. Keep using it, add sunscreen every morning, and re-check in 4 weeks. This is an estimate, not medical advice.', '{"demo": true, "used": ["scans","routine","experiment"]}');

  return jsonb_build_object('user_id', t, 'experiment_id', exp_id, 'verdict', v -> 'primary',
                            'current_streak', cur, 'longest_streak', greatest(longest, cur), 'scans', 8);
end $$;

-- =====================================================================
-- ROW LEVEL SECURITY
-- =====================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'app_config','concern_types','profiles','entitlements','notification_prefs','push_tokens','consents',
    'catalog_products','catalog_videos','scans','scan_concerns','routine_items','routine_logs','checkins',
    'experiments','experiment_scans','notes','messages','saved_videos','activity_days','streak_state',
    'streak_events','milestones','task_templates','user_tasks','api_usage','events','cancel_surveys']
  loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Reference / catalog data: readable by everyone, writable only by service role
drop policy if exists concern_types_read   on public.concern_types;
create policy concern_types_read   on public.concern_types   for select to anon, authenticated using (true);
drop policy if exists task_templates_read  on public.task_templates;
create policy task_templates_read  on public.task_templates  for select to anon, authenticated using (active);
drop policy if exists catalog_products_read on public.catalog_products;
create policy catalog_products_read on public.catalog_products for select to anon, authenticated using (active);
drop policy if exists catalog_videos_read  on public.catalog_videos;
create policy catalog_videos_read  on public.catalog_videos  for select to anon, authenticated using (active);
drop policy if exists app_config_read      on public.app_config;
create policy app_config_read      on public.app_config      for select to authenticated using (true);

-- profiles
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles for select to authenticated using (id = (select auth.uid()));
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- Read-only for the client (written by triggers / RPCs / service role)
do $$
declare t text;
begin
  foreach t in array array['scans','scan_concerns','experiments','entitlements','activity_days',
                           'streak_state','streak_events','milestones','user_tasks','consents']
  loop
    execute format('drop policy if exists %I on public.%I', t || '_select_own', t);
    execute format('create policy %I on public.%I for select to authenticated using (user_id = (select auth.uid()))',
                   t || '_select_own', t);
  end loop;
end $$;

drop policy if exists experiment_scans_select_own on public.experiment_scans;
create policy experiment_scans_select_own on public.experiment_scans for select to authenticated
  using (exists (select 1 from public.experiments e where e.id = experiment_id and e.user_id = (select auth.uid())));

-- Full CRUD on own rows
do $$
declare t text;
begin
  foreach t in array array['routine_items','routine_logs','notes','saved_videos','push_tokens','checkins','notification_prefs']
  loop
    execute format('drop policy if exists %I on public.%I', t || '_own_all', t);
    execute format('create policy %I on public.%I for all to authenticated
                    using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))',
                   t || '_own_all', t);
  end loop;
end $$;

-- Coach messages: client may insert its OWN user messages and rate answers; assistant rows come from the service role
drop policy if exists messages_select_own on public.messages;
create policy messages_select_own on public.messages for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists messages_insert_own on public.messages;
create policy messages_insert_own on public.messages for insert to authenticated
  with check (user_id = (select auth.uid()) and role = 'user');
drop policy if exists messages_update_feedback on public.messages;
create policy messages_update_feedback on public.messages for update to authenticated
  using (user_id = (select auth.uid()) and role = 'assistant') with check (user_id = (select auth.uid()));

drop policy if exists consents_insert_own on public.consents;
create policy consents_insert_own on public.consents for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists events_insert_own on public.events;
create policy events_insert_own on public.events for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists cancel_surveys_insert_own on public.cancel_surveys;
create policy cancel_surveys_insert_own on public.cancel_surveys for insert to authenticated with check (user_id = (select auth.uid()));
-- api_usage: RLS on, no policy => service role only

-- =====================================================================
-- GRANTS (least privilege; RLS still applies on top)
-- =====================================================================
revoke all on all tables    in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from public, anon, authenticated;

grant select on public.concern_types, public.task_templates, public.catalog_products, public.catalog_videos to anon, authenticated;
grant select on public.app_config to authenticated;
grant select on public.profiles, public.scans, public.scan_concerns, public.experiments, public.experiment_scans,
                public.entitlements, public.activity_days, public.streak_state, public.streak_events,
                public.milestones, public.user_tasks, public.consents, public.messages to authenticated;

-- columns a user may edit on their own profile (is_demo, created_at, consent_* are NOT included)
grant update (display_name, goals, skin_type, sensitivities, skin_tone_self, sun_habit, current_actives,
              actives_started, timezone, locale, scan_weekday, scan_time, age_confirmed, keep_photos,
              onboarding_step, onboarding_completed_at) on public.profiles to authenticated;

grant select, insert, update, delete on public.routine_items, public.routine_logs, public.notes,
      public.saved_videos, public.push_tokens, public.checkins, public.notification_prefs to authenticated;
grant insert on public.messages, public.consents, public.events, public.cancel_surveys to authenticated;
grant update (feedback) on public.messages to authenticated;

grant all on all tables    in schema public to service_role;
grant all on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;

-- RPCs callable by signed-in users (anonymous sign-ins included)
grant execute on function
  public.log_activity(text, date), public.refresh_streak(), public.ensure_daily_tasks(date),
  public.complete_task(text), public.home_summary(date), public.calendar_month(date),
  public.start_experiment(uuid, text[], int), public.set_experiment_status(uuid, text),
  public.finalize_experiment(uuid), public.compute_experiment_verdict(uuid),
  public.can_start_scan(), public.coach_remaining(), public.record_consent(text, text, text),
  public.delete_my_photos(), public.delete_my_account_data(), public.export_my_data(),
  public.seed_demo_data(uuid)
to authenticated;

-- =====================================================================
-- STORAGE (private buckets, per-user folders: <user_id>/<scan_id>/...)
-- =====================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('scan-photos', 'scan-photos', false, 10485760, array['image/jpeg','image/png']),
  ('scan-masks',  'scan-masks',  false,  5242880, array['image/png'])
on conflict (id) do update set public = false,
  file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "scan_photos_select_own" on storage.objects;
create policy "scan_photos_select_own" on storage.objects for select to authenticated
  using (bucket_id = 'scan-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
drop policy if exists "scan_photos_insert_own" on storage.objects;
create policy "scan_photos_insert_own" on storage.objects for insert to authenticated
  with check (bucket_id = 'scan-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
drop policy if exists "scan_photos_delete_own" on storage.objects;
create policy "scan_photos_delete_own" on storage.objects for delete to authenticated
  using (bucket_id = 'scan-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
-- masks are written by the Edge Function (service role); users can only read their own
drop policy if exists "scan_masks_select_own" on storage.objects;
create policy "scan_masks_select_own" on storage.objects for select to authenticated
  using (bucket_id = 'scan-masks' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- =====================================================================
-- REALTIME (app subscribes instead of polling: scan status, streak, tasks, experiments)
-- =====================================================================
do $$
declare t text;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach t in array array['scans','streak_state','user_tasks','experiments'] loop
      begin
        execute format('alter publication supabase_realtime add table public.%I', t);
      exception when duplicate_object then null;
      end;
    end loop;
  end if;
end $$;

commit;

-- =====================================================================
-- AFTER RUNNING — CHECKLIST
--  1. Authentication > Sign In / Providers: enable "Allow anonymous sign-ins" (needed for the
--     pre-account onboarding). Later link Apple/Google/email to the same user.
--  2. Never put the service_role key in the Flutter app. Edge Functions use it to:
--       - create a scan row (after calling  select public.scan_gate('<user>')),
--       - call the YouCam API, store masks in bucket scan-masks (path <user_id>/<scan_id>/<concern>.png),
--       - finish with  select public.complete_scan(scan_id, overall, skin_age, concerns_json, result_json, units)
--         or  select public.fail_scan(scan_id, error_code)
--       - update public.entitlements from your RevenueCat webhook.
--  3. Set the timezone from the app on first launch:
--       update profiles set timezone = 'America/New_York' where id = auth.uid();
--  4. Calibrate score noise:  update app_config set value = '{"default":3,"age_spot":2.5}' where key='noise_by_concern';
--     Verify the provider scale and set score_higher_is_better accordingly.
--  5. Demo / judge mode:  update app_config set value='true' where key='demo_mode';
--     then in the app (signed-in demo user):  select public.seed_demo_data();
--     (or from the SQL editor:  select public.seed_demo_data('<user-uuid>');)
--     Remember to switch demo_mode back to 'false' for production.
--  6. Flutter calls (supabase.rpc): home_summary, refresh_streak, complete_task, log_activity,
--     calendar_month, can_start_scan, start_experiment, finalize_experiment, coach_remaining,
--     record_consent, delete_my_photos, delete_my_account_data, export_my_data.
-- =====================================================================
