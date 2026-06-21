-- 1. Create pvp_matches table
create table if not exists public.pvp_matches (
  id uuid primary key default gen_random_uuid(),
  player1_id uuid not null references public.profiles(id) on delete cascade,
  player2_id uuid not null references public.profiles(id) on delete cascade,
  player1_email text not null,
  player2_email text not null,
  board jsonb not null default '{}'::jsonb,
  is_x_turn boolean not null default true,
  winner text check (winner in ('X', 'O', 'draw')),
  last_move text,
  last_move_at timestamptz not null default now(),
  status text not null default 'playing' check (status in ('playing', 'finished')),
  board_size integer not null default 15,
  win_length integer not null default 5,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2. Create matchmaking_queue table
create table if not exists public.matchmaking_queue (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  email text not null,
  board_size integer not null default 15,
  win_length integer not null default 5,
  status text not null default 'waiting' check (status in ('waiting', 'matched', 'cancelled')),
  match_id uuid references public.pvp_matches(id) on delete set null,
  created_at timestamptz not null default now()
);

-- 3. Enable Row Level Security (RLS)
alter table public.pvp_matches enable row level security;
alter table public.matchmaking_queue enable row level security;

-- 4. Set replica identity full for realtime tracking
alter table public.pvp_matches replica identity full;
alter table public.matchmaking_queue replica identity full;

-- 5. Table Grants
grant select, delete on public.matchmaking_queue to authenticated;
grant select on public.pvp_matches to authenticated;

-- 6. RLS Policies
do $$
begin
  -- Policy for pvp_matches (users can read matches they participate in)
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'pvp_matches' and policyname = 'Users can view their own pvp matches'
  ) then
    create policy "Users can view their own pvp matches"
    on public.pvp_matches for select
    to authenticated
    using (auth.uid() = player1_id or auth.uid() = player2_id);
  end if;

  -- Policy for matchmaking_queue (users can read their own queue rows)
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'matchmaking_queue' and policyname = 'Users can view their own matchmaking row'
  ) then
    create policy "Users can view their own matchmaking row"
    on public.matchmaking_queue for select
    to authenticated
    using (auth.uid() = user_id);
  end if;

  -- Policy for matchmaking_queue (users can delete/cancel their own queue entry)
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'matchmaking_queue' and policyname = 'Users can delete their own matchmaking row'
  ) then
    create policy "Users can delete their own matchmaking row"
    on public.matchmaking_queue for delete
    to authenticated
    using (auth.uid() = user_id);
  end if;
end
$$;

-- 7. RPC functions
-- join_matchmaking: Atomic matchmaking queue placement & player pairing
create or replace function public.join_matchmaking(
  p_user_id uuid,
  p_email text,
  p_board_size integer,
  p_win_length integer
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_opponent record;
  v_match_id uuid;
  v_result jsonb;
begin
  -- Ensure correct auth
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'Not allowed';
  end if;

  -- 1. Remove current user from matchmaking queue first
  delete from public.matchmaking_queue where user_id = p_user_id;
  
  -- 2. Clean up old dead matchmaking queues (older than 2 minutes)
  delete from public.matchmaking_queue where created_at < now() - interval '2 minutes';
  
  -- 3. Search for a waiting opponent with same settings
  select * into v_opponent
  from public.matchmaking_queue
  where status = 'waiting'
    and user_id <> p_user_id
    and board_size = p_board_size
    and win_length = p_win_length
  order by created_at asc
  limit 1
  for update skip locked;
  
  if v_opponent.user_id is not null then
    -- Found opponent! Create a match
    v_match_id := gen_random_uuid();
    
    insert into public.pvp_matches (
      id,
      player1_id,
      player2_id,
      player1_email,
      player2_email,
      board_size,
      win_length,
      status
    )
    values (
      v_match_id,
      v_opponent.user_id, -- player 1 is the one who was waiting
      p_user_id,          -- player 2 is the one who just joined
      v_opponent.email,
      p_email,
      p_board_size,
      p_win_length,
      'playing'
    );
    
    -- Update opponent's queue status
    update public.matchmaking_queue
    set status = 'matched', match_id = v_match_id
    where user_id = v_opponent.user_id;
    
    -- Insert current user's status as matched
    insert into public.matchmaking_queue (user_id, email, board_size, win_length, status, match_id)
    values (p_user_id, p_email, p_board_size, p_win_length, 'matched', v_match_id);
    
    v_result := jsonb_build_object(
      'match_id', v_match_id,
      'status', 'matched',
      'role', 'O', -- Player 2 plays as O
      'opponent_email', v_opponent.email
    );
  else
    -- No opponent, insert current user to queue as waiting
    insert into public.matchmaking_queue (user_id, email, board_size, win_length, status, match_id)
    values (p_user_id, p_email, p_board_size, p_win_length, 'waiting', null);
    
    v_result := jsonb_build_object(
      'match_id', null,
      'status', 'waiting',
      'role', 'X', -- Player 1 plays as X
      'opponent_email', null
    );
  end if;
  
  return v_result;
end;
$$;

-- make_pvp_move: Atomic move registration and turn switching
create or replace function public.make_pvp_move(
  p_match_id uuid,
  p_user_id uuid,
  p_board jsonb,
  p_is_x_turn boolean,
  p_winner text,
  p_last_move text
)
returns void
language plpgsql
security definer
as $$
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'Not allowed';
  end if;

  update public.pvp_matches
  set
    board = p_board,
    is_x_turn = p_is_x_turn,
    winner = p_winner,
    last_move = p_last_move,
    last_move_at = now(),
    status = case when p_winner is not null then 'finished' else 'playing' end,
    updated_at = now()
  where id = p_match_id 
    and (player1_id = p_user_id or player2_id = p_user_id)
    and status = 'playing';
end;
$$;

-- record_pvp_match_result: Finish and distribute diamond rewards (+20 to winner)
create or replace function public.record_pvp_match_result(
  p_match_id uuid,
  p_winner_id uuid,
  p_loser_id uuid,
  p_is_draw boolean
)
returns void
language plpgsql
security definer
as $$
declare
  v_match record;
begin
  if auth.uid() is null or (auth.uid() <> p_winner_id and auth.uid() <> p_loser_id) then
    raise exception 'Not allowed';
  end if;

  select * into v_match from public.pvp_matches where id = p_match_id;
  if v_match.status <> 'playing' then
    return;
  end if;

  -- Update match status to finished
  update public.pvp_matches
  set 
    status = 'finished',
    winner = case when p_is_draw then 'draw' when p_winner_id = player1_id then 'X' else 'O' end,
    updated_at = now()
  where id = p_match_id and status = 'playing';

  if p_is_draw then
    update public.profiles set draws = draws + 1 where id in (p_winner_id, p_loser_id);
  else
    -- Winner gets +20 diamonds, wins count increments
    update public.profiles set diamonds = diamonds + 20, wins_pvc = wins_pvc + 1 where id = p_winner_id;
    -- Loser losses count increments
    update public.profiles set losses_pvc = losses_pvc + 1 where id = p_loser_id;
  end if;
end;
$$;

-- Grant execution to authenticated users
grant execute on function public.join_matchmaking(uuid, text, integer, integer) to authenticated;
grant execute on function public.make_pvp_move(uuid, uuid, jsonb, boolean, text, text) to authenticated;
grant execute on function public.record_pvp_match_result(uuid, uuid, uuid, boolean) to authenticated;

-- Enable realtime subscription for tables
do $$
begin
  begin
    alter publication supabase_realtime add table public.matchmaking_queue;
  exception
    when duplicate_object then null;
    when undefined_object then null;
  end;

  begin
    alter publication supabase_realtime add table public.pvp_matches;
  exception
    when duplicate_object then null;
    when undefined_object then null;
  end;
end
$$;
