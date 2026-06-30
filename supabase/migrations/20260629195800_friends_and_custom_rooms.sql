-- ============================================================
-- Migration: Friends, Custom Rooms, and Emotes column
-- ============================================================

-- 1. Add unlocked_emotes column to profiles
alter table public.profiles
  add column if not exists unlocked_emotes text not null default '["wave","angry","laugh"]';

-- 2. Create friends table
create table if not exists public.friends (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  friend_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint unique_friendship unique (user_id, friend_id),
  constraint self_friend_check check (user_id <> friend_id)
);

alter table public.friends enable row level security;
alter table public.friends replica identity full;
grant select, insert, update, delete on public.friends to authenticated;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='friends' and policyname='Users can view their own friendships') then
    create policy "Users can view their own friendships"
      on public.friends for select to authenticated
      using (auth.uid() = user_id or auth.uid() = friend_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='friends' and policyname='Users can insert friendship requests') then
    create policy "Users can insert friendship requests"
      on public.friends for insert to authenticated
      with check (auth.uid() = user_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='friends' and policyname='Users can update received friendship requests') then
    create policy "Users can update received friendship requests"
      on public.friends for update to authenticated
      using (auth.uid() = friend_id)
      with check (auth.uid() = friend_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='friends' and policyname='Users can delete their friendships') then
    create policy "Users can delete their friendships"
      on public.friends for delete to authenticated
      using (auth.uid() = user_id or auth.uid() = friend_id);
  end if;
end
$$;

-- 3. Create custom_rooms table
create table if not exists public.custom_rooms (
  room_code text primary key check (length(room_code) = 6 and room_code ~ '^[0-9]{6}$'),
  host_id uuid not null references public.profiles(id) on delete cascade,
  guest_id uuid references public.profiles(id) on delete cascade,
  match_id uuid references public.pvp_matches(id) on delete set null,
  status text not null default 'waiting' check (status in ('waiting', 'matched', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.custom_rooms enable row level security;
alter table public.custom_rooms replica identity full;
grant select, insert, update, delete on public.custom_rooms to authenticated;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='custom_rooms' and policyname='Authenticated users can view custom rooms') then
    create policy "Authenticated users can view custom rooms"
      on public.custom_rooms for select to authenticated using (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='custom_rooms' and policyname='Users can create custom rooms') then
    create policy "Users can create custom rooms"
      on public.custom_rooms for insert to authenticated
      with check (auth.uid() = host_id);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='custom_rooms' and policyname='Users can update custom rooms') then
    create policy "Users can update custom rooms"
      on public.custom_rooms for update to authenticated using (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='custom_rooms' and policyname='Users can delete custom rooms they host') then
    create policy "Users can delete custom rooms they host"
      on public.custom_rooms for delete to authenticated
      using (auth.uid() = host_id);
  end if;
end
$$;

-- 4. RPC: join_custom_room – atomically sets guest_id, creates pvp_match, sets match_id
create or replace function public.join_custom_room(
  p_room_code text,
  p_guest_id uuid,
  p_guest_email text
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_room record;
  v_match_id uuid;
begin
  if auth.uid() is null or auth.uid() <> p_guest_id then
    raise exception 'Not allowed';
  end if;

  select * into v_room
  from public.custom_rooms
  where room_code = p_room_code and status = 'waiting'
  for update skip locked;

  if v_room.room_code is null then
    return jsonb_build_object('status', 'not_found');
  end if;

  if v_room.host_id = p_guest_id then
    return jsonb_build_object('status', 'self_join');
  end if;

  -- Create the pvp_matches record
  v_match_id := gen_random_uuid();
  insert into public.pvp_matches (
    id, player1_id, player2_id, player1_email, player2_email,
    board_size, win_length, status
  )
  select
    v_match_id,
    v_room.host_id,
    p_guest_id,
    (select email from public.profiles where id = v_room.host_id),
    p_guest_email,
    15, 5, 'playing';

  -- Update the room
  update public.custom_rooms
  set guest_id = p_guest_id,
      match_id = v_match_id,
      status   = 'matched',
      updated_at = now()
  where room_code = p_room_code;

  return jsonb_build_object(
    'status',    'matched',
    'match_id',  v_match_id,
    'role',      'O',
    'host_email',(select email from public.profiles where id = v_room.host_id)
  );
end;
$$;

grant execute on function public.join_custom_room(text, uuid, text) to authenticated;

-- 5. Enable Realtime for new tables
do $$
begin
  begin
    alter publication supabase_realtime add table public.friends;
  exception when duplicate_object then null; when undefined_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.custom_rooms;
  exception when duplicate_object then null; when undefined_object then null;
  end;
end
$$;
