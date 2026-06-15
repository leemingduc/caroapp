create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  diamonds integer not null default 100,
  wins_pvc integer not null default 0,
  losses_pvc integer not null default 0,
  draws integer not null default 0,
  unlocked_skins text not null default '["default"]',
  unlocked_themes text not null default '["default"]',
  selected_skin text not null default 'default',
  selected_theme text not null default 'default',
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists email text,
  add column if not exists diamonds integer not null default 100,
  add column if not exists wins_pvc integer not null default 0,
  add column if not exists losses_pvc integer not null default 0,
  add column if not exists draws integer not null default 0,
  add column if not exists unlocked_skins text not null default '["default"]',
  add column if not exists unlocked_themes text not null default '["default"]',
  add column if not exists selected_skin text not null default 'default',
  add column if not exists selected_theme text not null default 'default',
  add column if not exists last_seen_at timestamptz not null default now(),
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.pvc_match_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text not null,
  outcome text not null check (outcome in ('win', 'loss', 'draw')),
  ai_difficulty text not null,
  board_size integer not null,
  win_length integer not null,
  moves_count integer not null,
  diamond_delta integer not null default 0,
  diamonds_after integer not null default 0,
  wins_pvc_after integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists profiles_leaderboard_idx
  on public.profiles (diamonds desc, wins_pvc desc, updated_at desc);

create index if not exists pvc_match_history_user_created_idx
  on public.pvc_match_history (user_id, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.pvc_match_history enable row level security;

alter table public.profiles replica identity full;

grant select, insert, update on public.profiles to authenticated;
grant select, insert on public.pvc_match_history to authenticated;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'Profiles are visible to leaderboard'
  ) then
    create policy "Profiles are visible to leaderboard"
    on public.profiles for select
    to authenticated
    using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'Users can insert own profile'
  ) then
    create policy "Users can insert own profile"
    on public.profiles for insert
    to authenticated
    with check (auth.uid() = id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'Users can update own profile'
  ) then
    create policy "Users can update own profile"
    on public.profiles for update
    to authenticated
    using (auth.uid() = id)
    with check (auth.uid() = id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'pvc_match_history' and policyname = 'Users can read own pvc history'
  ) then
    create policy "Users can read own pvc history"
    on public.pvc_match_history for select
    to authenticated
    using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'pvc_match_history' and policyname = 'Users can insert own pvc history'
  ) then
    create policy "Users can insert own pvc history"
    on public.pvc_match_history for insert
    to authenticated
    with check (auth.uid() = user_id);
  end if;
end
$$;

create or replace function public.pvc_win_reward(p_ai_difficulty text)
returns integer
language sql
immutable
as $$
  select case p_ai_difficulty
    when 'easy' then 5
    when 'amateur' then 10
    when 'medium' then 20
    when 'semiPro' then 40
    when 'professional' then 80
    else 0
  end
$$;

create or replace function public.record_pvc_match(
  p_user_id uuid,
  p_email text,
  p_outcome text,
  p_ai_difficulty text,
  p_board_size integer,
  p_win_length integer,
  p_moves_count integer
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reward integer;
  v_profile public.profiles;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'Not allowed';
  end if;

  if p_outcome not in ('win', 'loss', 'draw') then
    raise exception 'Invalid outcome';
  end if;

  v_reward := case when p_outcome = 'win' then public.pvc_win_reward(p_ai_difficulty) else 0 end;

  insert into public.profiles (id, email)
  values (p_user_id, p_email)
  on conflict (id) do update
  set
    email = excluded.email,
    last_seen_at = now();

  update public.profiles
  set
    email = p_email,
    diamonds = diamonds + v_reward,
    wins_pvc = wins_pvc + case when p_outcome = 'win' then 1 else 0 end,
    losses_pvc = losses_pvc + case when p_outcome = 'loss' then 1 else 0 end,
    draws = draws + case when p_outcome = 'draw' then 1 else 0 end,
    last_seen_at = now()
  where id = p_user_id
  returning * into v_profile;

  insert into public.pvc_match_history (
    user_id,
    email,
    outcome,
    ai_difficulty,
    board_size,
    win_length,
    moves_count,
    diamond_delta,
    diamonds_after,
    wins_pvc_after
  )
  values (
    p_user_id,
    p_email,
    p_outcome,
    p_ai_difficulty,
    p_board_size,
    p_win_length,
    p_moves_count,
    v_reward,
    v_profile.diamonds,
    v_profile.wins_pvc
  );

  return v_profile;
end;
$$;

grant execute on function public.record_pvc_match(
  uuid,
  text,
  text,
  text,
  integer,
  integer,
  integer
) to authenticated;

do $$
begin
  begin
    alter publication supabase_realtime add table public.profiles;
  exception
    when duplicate_object then null;
    when undefined_object then null;
  end;
end
$$;
