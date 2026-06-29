# Design Specification: Friends, Custom Rooms, Emotes & Quick Chat

This document details the architecture, design, and implementation plan for introducing the Friends List system, 6-digit Custom Room multiplayer matching, Emote Shop & in-game triggers, and a Quick Chat system (without icons) into Caro Arena.

---

## 1. Feature Specifications

### 1.1 Friends List Feature (`FriendsDialog`)
A dedicated entry point on the Main Screen will open a **Friends Dialog**.
*   **Database Table (`friends`)**:
    *   `id` (uuid, primary key)
    *   `user_id` (uuid, requester, references profiles)
    *   `friend_id` (uuid, receiver, references profiles)
    *   `status` (text: `'pending'`, `'accepted'`)
    *   `created_at`, `updated_at` (timestamptz)
    *   `unique(user_id, friend_id)` constraint
*   **Capabilities**:
    *   **Search**: Users can search another user by email.
    *   **Add Friend**: Sends a request (`status = 'pending'`).
    *   **List Friends**: Displays all accepted friends. Queries `(user_id = auth.uid() OR friend_id = auth.uid()) AND status = 'accepted'`.
    *   **Pending Requests**: Displays received pending requests (`friend_id = auth.uid() AND status = 'pending'`) and allows Accept/Decline.
    *   **Online Status**: Displays whether a friend is online based on `last_seen_at` within the last 5 minutes.
    *   **Remove Friend**: Allows deleting any accepted or pending friendship row.

### 1.2 Custom Room with 6-Digit ID
Allows playing against a friend by creating a room and sharing a 6-digit numeric code.
*   **Database Table (`custom_rooms`)**:
    *   `room_code` (text, primary key, exactly 6 characters)
    *   `host_id` (uuid, references profiles, not null)
    *   `guest_id` (uuid, references profiles, nullable)
    *   `match_id` (uuid, references pvp_matches, nullable)
    *   `status` (text: `'waiting'`, `'matched'`, `'closed'`)
    *   `created_at`, `updated_at` (timestamptz)
*   **Flow**:
    1.  **Host** clicks "Tạo phòng" -> App generates a random 6-digit string -> inserts into `custom_rooms` (status: `waiting`, guest_id: `null`) -> Host subscribes to realtime updates for this `room_code`.
    2.  **Guest** clicks "Vào phòng" -> Inputs the 6-digit code -> App queries `custom_rooms` for a record with status `waiting`.
        *   If found, updates `guest_id = guestUserId` and status = `'matched'`.
        *   Creates a `pvp_matches` record.
        *   Updates the `custom_rooms` record with `match_id = newPvpMatchId`.
    3.  **Host** receives the realtime update containing `match_id` -> both navigate to `CaroGameScreen` in PvP Online mode using the match ID.

### 1.3 Emote Shop & Gameplay Triggers
*   **Database Column**:
    *   `profiles.unlocked_emotes`: text/json, defaults to `'["wave", "angry", "laugh"]'`.
*   **Emote Shop (Tab in `ShopDialog`)**:
    *   Users can purchase locked emotes for **50 diamonds** each.
    *   **List of 10 Emotes**:
        *   *Free (3)*: 👋 (wave), 😡 (angry), 😄 (laugh)
        *   *Paid (7)*: 😭 (cry), 😲 (surprised), 🥰 (love), 😎 (cool), 🤔 (thinking), 😴 (sleep), 😉 (wink)
*   **Realtime Gameplay Usage**:
    *   In `CaroGameScreen` (PvP Online mode), an Emote button (smiley icon) next to the player's avatar opens a popup panel showing unlocked emotes.
    *   Selecting an emote broadcasts it via the Supabase Realtime channel `pvp_match_$matchId` (Event: `emote`).
    *   The receiver's App listens to the broadcast and displays a floating/fading-out emote emoji bubble over the sender's avatar.

### 1.4 Quick Chat Feature (No Icons)
Allows sending pre-configured messages instantly during online play.
*   **8 Quick Chat Messages**:
    1. "Chào đối thủ! Chúc may mắn."
    2. "Bạn đánh hay quá!"
    3. "Chờ tôi một chút nhé..."
    4. "Cảm ơn nhé!"
    5. "Xin lỗi, sơ suất quá!"
    6. "Chơi tiếp ván nữa không?"
    7. "Đừng đầu hàng nhé!"
    8. "Chúc mừng chiến thắng!"
*   **Flow**:
    *   In the Emote/Chat panel, the user can switch to the "Chat" tab to see these 8 options.
    *   Tapping a sentence broadcasts it via the Supabase Realtime channel `pvp_match_$matchId` (Event: `chat`).
    *   The message displays as a floating speech bubble or message toast near the sender's card for 4 seconds.

---

## 2. Database Schema Changes

We will create a new migration `supabase/migrations/20260629195800_friends_and_custom_rooms.sql`:

```sql
-- 1. Add unlocked_emotes to profiles table
alter table public.profiles
  add column if not exists unlocked_emotes text not null default '["wave", "angry", "laugh"]';

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

-- 3. Create custom_rooms table
create table if not exists public.custom_rooms (
  room_code text primary key check (length(room_code) = 6),
  host_id uuid not null references public.profiles(id) on delete cascade,
  guest_id uuid references public.profiles(id) on delete cascade,
  match_id uuid references public.pvp_matches(id) on delete set null,
  status text not null default 'waiting' check (status in ('waiting', 'matched', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 4. Enable Row Level Security (RLS)
alter table public.friends enable row level security;
alter table public.custom_rooms enable row level security;

-- 5. Friends RLS Policies
create policy "Users can view their own friendships"
  on public.friends for select
  to authenticated
  using (auth.uid() = user_id or auth.uid() = friend_id);

create policy "Users can insert friendship requests"
  on public.friends for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update their received friendship requests"
  on public.friends for update
  to authenticated
  using (auth.uid() = friend_id)
  with check (auth.uid() = friend_id);

create policy "Users can delete their friendships"
  on public.friends for delete
  to authenticated
  using (auth.uid() = user_id or auth.uid() = friend_id);

-- 6. Custom Rooms RLS Policies
create policy "Anyone authenticated can view custom rooms"
  on public.custom_rooms for select
  to authenticated
  using (true);

create policy "Users can create custom rooms"
  on public.custom_rooms for insert
  to authenticated
  with check (auth.uid() = host_id);

create policy "Users can update custom rooms they join or host"
  on public.custom_rooms for update
  to authenticated
  using (true);

create policy "Users can delete custom rooms they host"
  on public.custom_rooms for delete
  to authenticated
  using (auth.uid() = host_id);

-- 7. Register tables for Realtime replication
begin;
  alter publication supabase_realtime add table public.custom_rooms;
exception
  when duplicate_object then null;
end;

begin;
  alter publication supabase_realtime add table public.friends;
exception
  when duplicate_object then null;
end;
```

---

## 3. UI/UX Changes in Frontend (Flutter)

### 3.1 Main Screen Header Updates
We will add a "Bạn bè" button alongside "Cửa hàng" and "Bảng xếp hạng" inside the diamond card on the Main Screen.
*   **Icon**: `Icons.people_rounded` with color `Color(0xFF4CAF50)` (green).
*   **Action**: Triggers `_openFriends()`, showing `FriendsDialog`.

### 3.2 Friends Dialog (`FriendsDialog`)
Create a custom dialog screen styled with glassmorphism/deep slate background:
*   **Tabs**:
    1.  **Bạn bè (Friends List)**: Shows active friends. Displays their emails, stats, and a green indicator if online (`last_seen_at` <= 5 minutes). Contains a "Xóa bạn" (Remove) button.
    2.  **Lời mời (Requests)**: Shows pending requests received. Displays "Đồng ý" (Accept) and "Từ chối" (Decline) buttons.
    3.  **Tìm kiếm (Search)**: A text field to input email, search, and click "Kết bạn" (Send Request).
*   **Offline Mode fallback**: If Supabase connection fails, it displays mock offline friends.

### 3.3 Custom Room Join UI
When the user clicks "Chơi Online (PVP)", we will display a Dialog asking them to choose:
1.  **Ghép trận tự động** (Auto Matchmaking - standard flow).
2.  **Tạo phòng riêng** (Create Custom Room). Displays a 6-digit generated room ID and lists a "Đang chờ đối thủ..." (Waiting for opponent) spinner. Host listens to updates.
3.  **Vào phòng riêng** (Join Custom Room). Opens a text field for the user to type the 6-digit code. Upon clicking "Vào", it joins the match.

### 3.4 Emote & Quick Chat Panel (During PvP Online)
In `CaroGameScreen` PvP Online:
*   We will add a smiley emoji button (`Icons.insert_emoticon_rounded`) next to the user's avatar.
*   Tapping it opens a bottom sheet or floating bubble with two tabs:
    *   **Tab 1: Biểu cảm (Emotes)**: Display a grid of the 10 emojis. Locked emojis are greyed out with a lock icon. Unlocked ones can be clicked.
    *   **Tab 2: Chat nhanh (Quick Chat)**: Display the 8 pre-added sentences without icons.
*   When sent:
    *   The emoji or text is broadcast over the match's Supabase channel.
    *   A widget animation overlays above the player's avatar. For emotes: the emoji emoji floats up and fades out. For chat: a standard speech bubble containing the message fades in/out.

---

## 4. Verification Plan

### 4.1 Database Migrations
Run supabase migration up locally and verify table schemas are successfully updated.

### 4.2 Friends Feature Tests
*   Login with Player A and Player B.
*   Player A searches Player B's email -> sends request.
*   Player B opens Friends List -> Lời mời -> accepts request.
*   Check both players now see each other in their Friends List with online status.

### 4.3 Custom Room Tests
*   Player A clicks "Tạo phòng riêng" -> Gets "493821" code.
*   Player B clicks "Vào phòng riêng" -> Types "493821" -> Clicks join.
*   Verify both players immediately transition to the Caro PvP Game Screen and can play moves.

### 4.4 Emote & Quick Chat Shop & Live Play Tests
*   Verify that only 3 emotes are unlocked by default.
*   Go to Shop Dialog -> Biểu cảm -> purchase a paid emote for 50 diamonds -> verify diamond deduction and unlocking.
*   Enter a PvP custom match or online match -> send wave, cry, and quick chat messages -> verify they render in real-time above/next to the correct avatar.
