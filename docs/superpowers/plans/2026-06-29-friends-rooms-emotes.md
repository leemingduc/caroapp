# Friends, Custom Rooms, Emotes & Quick Chat – Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Friends system, 6-digit custom PvP rooms, a purchasable Emote system, and a fixed Quick Chat panel to Caro Arena.

**Architecture:** Each feature gets its own dedicated service/screen file following the existing pattern (`lib/services/`, `lib/screens/`). Database changes are isolated into one migration file. Emotes and quick chat use Supabase Realtime Broadcast (no database writes) to communicate during a live PvP match via the already-existing `pvp_match_$matchId` channel.

**Tech Stack:** Flutter/Dart, Supabase (Postgres, RLS, Realtime Broadcast, Postgres Changes), SharedPreferences (profile cache), existing `app_language.dart` for localization.

## Global Constraints

- All UI must match the existing dark slate color palette (`Color(0xFF0F172A)` background, `Color(0xFF00F2FE)` cyan accent).
- All user-facing strings must be added to `lib/app_language.dart` (both Vietnamese and English), never hardcoded.
- Follow the existing `DbService` / `PvpService` pattern: static methods, try/catch, return typed results.
- All new Supabase tables must have RLS enabled and replica identity full.
- Emote purchase cost: 50 diamonds each. Default unlocked emotes: `["wave", "angry", "laugh"]`.
- Quick chat messages are fixed (8 items), no icons.
- Room codes are exactly 6 numeric digits, generated client-side.
- The `custom_rooms` and `friends` tables must be added to `supabase_realtime` publication.

---

## Task 1: Database Migration

**Files:**
- Create: `supabase/migrations/20260629195800_friends_and_custom_rooms.sql`

- [ ] Create the migration SQL file (see design spec for full SQL content including friends table, custom_rooms table, unlocked_emotes column, join_custom_room RPC, RLS policies, realtime publication).
- [ ] Apply migration to Supabase project (run via Supabase dashboard or CLI).
- [ ] Verify tables exist: profiles.unlocked_emotes, friends, custom_rooms.
- [ ] Commit: `git commit -m "db: add friends, custom_rooms tables and unlocked_emotes column"`

---

## Task 2: Update UserProfile Model

**Files:**
- Modify: `lib/models/user_profile.dart`

- [ ] Add `unlockedEmotes` field (List<String>, default `['wave','angry','laugh']`).
- [ ] Update `copyWith`, `toMap` (encode as JSON string), `fromMap` (use parseList helper, fallback to `['wave','angry','laugh']`).
- [ ] Commit: `git commit -m "feat: add unlockedEmotes to UserProfile model"`

---

## Task 3: Localization Strings

**Files:**
- Modify: `lib/app_language.dart`

- [ ] Append new getters to `AppText` class for: friends UI, custom room UI, emote shop UI, quick chat (8 messages list getter).
- [ ] Commit: `git commit -m "feat: add localization strings for friends/rooms/emotes/quickchat"`

---

## Task 4: FriendsService

**Files:**
- Create: `lib/services/friends_service.dart`

Implement static methods:
- [ ] `findProfileByEmail(email)` -> `Future<Map?>` (query profiles table).
- [ ] `sendRequest(userId, friendEmail)` -> `Future<String>` ('sent'|'exists'|'not_found'|'error').
- [ ] `getFriends(userId)` -> `Future<List<Map>>` (accepted friendships, joins with profile email/last_seen_at).
- [ ] `getPendingReceived(userId)` -> `Future<List<Map>>` (pending where friend_id=userId).
- [ ] `acceptRequest(requestId)` -> `Future<bool>` (update status='accepted').
- [ ] `removeRelationship(relationshipId)` -> `Future<bool>` (delete by id).
- [ ] Commit: `git commit -m "feat: add FriendsService"`

---

## Task 5: FriendsDialog Screen

**Files:**
- Create: `lib/screens/friends_dialog.dart`
- Modify: `lib/main.dart`

- [ ] Create `FriendsDialog` widget with TabController(length:3): Friends tab, Requests tab, Search tab.
- [ ] Friends tab: ListView of accepted friends with online indicator (last_seen_at < 5 min) and Remove button.
- [ ] Requests tab: ListView of pending received requests with Accept/Decline buttons.
- [ ] Search tab: Email TextField + "Kết bạn" button + result feedback message.
- [ ] In `lib/main.dart`: add import, add `_openFriends()` method, add Friends `TextButton.icon` in the diamond card Row (between Shop and Leaderboard).
- [ ] Commit: `git commit -m "feat: add FriendsDialog and friends button on main screen"`

---

## Task 6: PvpRoomService + CustomRoomDialog

**Files:**
- Create: `lib/services/pvp_room_service.dart`
- Create: `lib/screens/custom_room_dialog.dart`
- Modify: `lib/main.dart`

- [ ] Create `PvpRoomService` with: `createRoom(hostId)`, `cancelRoom(roomCode)`, `joinRoom(roomCode, guestId, guestEmail)`.
- [ ] Create `CustomRoomDialog` with 3 pages (AnimatedSwitcher): Choose mode page, Create room page (shows code + spinner + copy button), Join room page (6-digit input).
- [ ] In Choose page: "Auto matchmaking" pops and calls `onMatchReady('','X','')`. "Create room" calls `createRoom`, subscribes to Realtime on `custom_rooms` for host. "Join room" navigates to join page.
- [ ] In `lib/main.dart`: add `_showPvpModeDialog()` method. In `_buildModeChip`, replace `_startMatchmaking()` call with `_showPvpModeDialog()`. In `onMatchReady` callback: empty matchId triggers `_startMatchmaking()`, non-empty calls `_initializePvpMatch()`.
- [ ] Commit: `git commit -m "feat: add 6-digit custom room PvP mode"`

---

## Task 7: EmoteConfig Model + Emotes Tab in ShopDialog

**Files:**
- Create: `lib/models/emote_config.dart`
- Modify: `lib/screens/shop_dialog.dart`

- [ ] Create `EmoteConfig` with id, emoji, nameVi, nameEn, cost. List of 10: wave(0), angry(0), laugh(0), cry(50), surprised(50), love(50), cool(50), thinking(50), sleep(50), wink(50).
- [ ] In `ShopDialog`: change TabController length to 3. Add `_buyEmote(EmoteConfig)` async method (deduct 50 diamonds, update `unlockedEmotes`, save profile). Add `_buildEmotesTab()` returning a 4-column GridView of emotes (owned=highlighted, locked=show price).
- [ ] Commit: `git commit -m "feat: add EmoteConfig and Emotes tab to ShopDialog"`

---

## Task 8: In-Game Emote & Quick Chat (Realtime Broadcast)

**Files:**
- Create: `lib/screens/emote_chat_panel.dart`
- Modify: `lib/main.dart`

- [ ] Create `EmoteChatPanel` bottom-sheet widget with 2 tabs: Emotes grid (5 cols, locked=darkened with lock icon), Quick Chat list (8 plain text messages, no icons). Calls `onSend({emoteId, chatMessage})`.
- [ ] In `lib/main.dart` `_CaroGameScreenState`: add 8 state fields (`_myFloatingEmote`, `_oppFloatingEmote`, `_myChatBubble`, `_oppChatBubble`, 4 timers). Add `_sendEmoteOrChat()` (broadcasts via `_pvpMatchChannel`). Add `_openEmotePanel()`. In `_subscribeToPvpMatch()`, register `.onBroadcast` for 'emote' and 'chat' events to set opp state with auto-clear timers. Cancel all emote timers in `_cleanupPvpState()`.
- [ ] Update `_buildPlayerRow` signature to accept `showEmoteButton`, `floatingEmoji`, `chatBubble`. Wrap in `Stack` to show `_FloatingEmoteBubble` (float-up + fade animation) and `_ChatBubbleWidget` (fade-in/out). Add 😊 icon button that calls `_openEmotePanel()`.
- [ ] Update `_buildScoreboardCard()` calls to `_buildPlayerRow` to pass emote state.
- [ ] Add `_FloatingEmoteBubble` and `_ChatBubbleWidget` StatefulWidget classes at bottom of `lib/main.dart`.
- [ ] Commit: `git commit -m "feat: in-game emote and quick chat with Supabase broadcast"`

---

## Task 9: Verification

- [ ] Run `flutter analyze` — expect 0 errors.
- [ ] Run `flutter test` — all existing tests pass.
- [ ] Run `flutter build apk --debug` — build succeeds.
- [ ] Manual smoke test: friends flow, create/join room, emote shop purchase, in-game emote send/receive, quick chat send/receive.
- [ ] Final commit: `git commit -m "feat: complete friends, custom rooms, emotes and quick chat"`
