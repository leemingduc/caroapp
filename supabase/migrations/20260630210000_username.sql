-- ============================================================
-- Migration: Username / Display Name
-- Date: 2026-06-30
-- ============================================================

-- 1. Add display_name and rename_count columns to profiles
alter table public.profiles
  add column if not exists display_name text,
  add column if not exists rename_count integer not null default 0;

-- 2. Unique index on display_name (case-insensitive), allowing NULL
create unique index if not exists profiles_display_name_unique_idx
  on public.profiles (lower(display_name))
  where display_name is not null;

-- 3. RPC: set_display_name
--    - Validates name (non-empty, max 20 chars, unique case-insensitive)
--    - First rename is free (rename_count == 0 after insert means first time setting)
--    - Subsequent renames cost: min(5000, 100 * 2^(rename_count - 1)) diamonds
--    - Returns the updated profile row
create or replace function public.set_display_name(
  p_user_id uuid,
  p_display_name text
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trimmed text;
  v_cost integer;
  v_current_rename_count integer;
  v_current_diamonds integer;
  v_profile public.profiles;
begin
  -- Auth check
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'Not allowed';
  end if;

  v_trimmed := trim(p_display_name);

  -- Validation
  if v_trimmed = '' or v_trimmed is null then
    raise exception 'Display name cannot be empty';
  end if;

  if char_length(v_trimmed) < 4 or char_length(v_trimmed) > 20 then
    raise exception 'Display name must be between 4 and 20 characters';
  end if;

  -- Check uniqueness (case-insensitive), excluding self
  if exists (
    select 1 from public.profiles
    where lower(display_name) = lower(v_trimmed)
      and id <> p_user_id
  ) then
    raise exception 'Display name already taken';
  end if;

  -- Get current state
  select rename_count, diamonds
  into v_current_rename_count, v_current_diamonds
  from public.profiles
  where id = p_user_id;

  -- Calculate cost
  -- rename_count 0 means never set before → first set is free
  -- rename_count 1+ means has been set → costs diamonds
  if v_current_rename_count = 0 then
    v_cost := 0;  -- First time: free
  else
    -- cost = min(5000, 100 * 2^(rename_count - 1))
    v_cost := least(5000, 100 * power(2, v_current_rename_count - 1)::integer);
  end if;

  -- Check sufficient diamonds
  if v_current_diamonds < v_cost then
    raise exception 'Not enough diamonds. Need % diamonds', v_cost;
  end if;

  -- Apply update
  update public.profiles
  set
    display_name = v_trimmed,
    rename_count = rename_count + 1,
    diamonds = diamonds - v_cost,
    updated_at = now()
  where id = p_user_id
  returning * into v_profile;

  return v_profile;
end;
$$;

-- 4. Grant execution to authenticated users
grant execute on function public.set_display_name(uuid, text) to authenticated;

-- 5. Helper function to calculate rename cost (for client-side display)
create or replace function public.get_rename_cost(p_rename_count integer)
returns integer
language sql
immutable
as $$
  select case
    when p_rename_count = 0 then 0
    else least(5000, (100 * power(2, p_rename_count - 1))::integer)
  end
$$;

grant execute on function public.get_rename_cost(integer) to authenticated;
