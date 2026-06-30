-- Update set_display_name to enforce 4–20 character minimum
-- and allow name reuse (unique index already handles this via NULL / UPDATE semantics)

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

  -- Validation: non-empty
  if v_trimmed = '' or v_trimmed is null then
    raise exception 'Display name cannot be empty';
  end if;

  -- Validation: length 4–20 characters
  if char_length(v_trimmed) < 4 or char_length(v_trimmed) > 20 then
    raise exception 'Display name must be between 4 and 20 characters';
  end if;

  -- Check uniqueness (case-insensitive), excluding self
  -- Note: name reuse is naturally allowed — unique index only covers current values
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
  if v_current_rename_count = 0 then
    v_cost := 0;
  else
    -- cost = min(5000, 100 * 2^(rename_count - 1))
    v_cost := least(5000, (100 * power(2, v_current_rename_count - 1))::integer);
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

grant execute on function public.set_display_name(uuid, text) to authenticated;
