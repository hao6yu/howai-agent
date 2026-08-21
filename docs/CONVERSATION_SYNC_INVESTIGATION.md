# Investigation: Local conversation lost + remote sync shows many conversations but no messages

**Date:** 2026-08-19
**Component:** Conversation / message sync (local SQLite ⇄ Supabase)
**Trigger scenario:** Testing new conversations that attach images; after a few rounds the local conversation disappears and the left drawer fills with many synced conversations that have no messages.

## Remediation status (implemented 2026-08-20)

The destructive sync risks identified here are now addressed in app version
`2.0.4+49` and Supabase migrations
`20260821001125_conversation_tombstones_and_keyset_sync.sql` and
`20260821005325_harden_conversation_sync_identity.sql`:

- Conversation and message downloads use immutable UUID keyset pagination;
  mutable offset pagination is no longer used.
- A missing row in a remote snapshot is never interpreted as deletion.
- Conversation deletion uses an immutable `deleted_at` tombstone in SQLite and
  Supabase. Other devices purge only after receiving that explicit marker.
- Supabase converts DELETE requests from older app versions into tombstones,
  deletes the remote child messages transactionally, and prevents stale
  clients from clearing or rewriting a tombstone.
- The SQLite outbox quarantines missing, unsupported, and superseded work with
  a reason instead of silently marking it complete.
- Existing message UUID mappings are checked against their expected remote
  conversation before reuse.
- Existing local messages now adopt repaired remote `image_urls`; a blank remote
  value cannot erase a pending local attachment reference.
- Legacy messages without `client_id` are claimed in bounded, set-based batches.
  Startup no longer performs one remote validation request for every local
  message that already has a mapping.
- Cached conversation UUID mappings are accepted only after their owner and
  stable `client_id` are verified, preventing a stale mapping from updating the
  wrong remote row.
- New conversations obtain their remote UUID before realtime subscription, so
  realtime setup no longer silently stops at the first local-only state.
- Realtime subscriptions are generation-scoped, so a slow subscription from a
  previous chat cannot win after the user switches conversations.
- Clear Chat History writes durable tombstones only for the selected profile;
  it no longer mixes a global remote delete with a profile-scoped local delete.
- Chat photos are uploaded to the private `chat-attachments` bucket, restored
  through signed URLs, and removed in bounded Storage batches when their
  conversation deletion completes.

The production audit found 3 accounts with more than 200 conversations and 4
accounts with at least one conversation longer than 200 messages (17 such
conversations total). Those accounts were most exposed to the old pagination
behavior. Both migrations are live in production. The identity-claim and
tombstone paths were smoke-tested transactionally through authenticated and
anonymous sessions, the post-migration Supabase advisors found no new findings,
and all 196 Flutter tests pass.

## Symptom summary

1. A locally-created conversation vanishes from the device.
2. The left-side drawer (conversation list) shows many conversations pulled from the remote server, but message previews / bodies are missing. (Note: message *text* uploads fine as `content`, so "missing messages" here points to the download side — message rows not being fetched/merged — rather than text sync failing.)
3. Most heavily reproduced when sending messages that carry image attachments.

The two symptoms are **not** established to share a single root cause. This report treats them as two potentially separate defects and analyzes each independently:

- **Symptom 1 (blank/missing photos):** user-attached images are stored only as local paths and are lost across sync (display shows a message with no image).
- **Symptom 2 (local conversation deleted, drawer fills with conversations that have no messages):** a deletion/reconciliation issue where a locally-owned conversation is removed and replaced by many remote rows.

## Architecture (where the sync logic lives)

- `lib/services/database_service.dart` — local SQLite schema + outbox queue.
- `lib/services/sync_service.dart` — upload (outbox drain) + download (remote pull) + realtime subscriptions.
- `lib/services/id_mapping_service.dart` — maps durable local INTEGER ids ⇄ Supabase UUIDs (in-memory + SharedPreferences).
- `lib/models/chat_message.dart` — message model, including `toSupabase()` / `fromSupabase()` serialization.
- `lib/providers/conversation_provider.dart` — the source of truth for the drawer list; reads from SQLite only, no direct network fetch.
- `lib/widgets/conversation_drawer.dart` — renders `provider.conversations`.
- `lib/services/chat_image_preprocessor.dart`, `image_service.dart`, `message_media_service.dart` — image handling.

### Conversations table
`database_service.dart:172-183, 1262-1272, 1554-1581`

### chat_messages table
`database_service.dart:499-524`
Notable attachment columns: `image_paths` (LOCAL file paths), `image_urls` (SUPABASE STORAGE URLs), `file_paths`.

### sync_outbox (durable upload queue)
`database_service.dart:526-544` — every insert conversation/message/update is enqueued here so uploads are idempotent and retryable (via `client_id`).

## Findings (candidates, unproven)

### BUG A (Symptom 1 — upload side): user-attached images never reach the remote server

When the user sends a message with an image, the image is stored **only as a local file path** in `chat_messages.image_paths`. The remote upload path (`chat_message.toSupabase()`) **serializes only `image_urls`**, which is `null` for these locally-attached images.

Relevant lines:
- Upload of attachments is never triggered — `image_service.uploadImageToSupabase()` is called only for profile avatars (`providers/profile_provider.dart:131`), never for chat attachments.
- `chat_image_preprocessor.encodeImageForVision()` (`services/chat_image_preprocessor.dart:48-70`) produces a `data:image;base64` payload for the live OpenAI vision call, but its comment explicitly notes it is never persisted.
- `toSupabase()` serializes only `image_urls` (not `image_paths`) — `chat_message.dart:117`.
- The legacy migration path uploads even less — no image data at all — `services/migration_service.dart:161-166`.

**Consequence (upload side):** user message *text* syncs fine (uploaded as `content`); only the attached image is absent. This is a local-only feature.

### BUG A2 (the second half, previously missing): downloaded `image_urls` are never rendered

Even once `image_urls` is populated and synced, the image still will not show. The media resolver inspects only `message.imagePaths`:
- `message_media_service.resolve()` (`services/message_media_service.dart:47`) — reads `imagePaths`/`filePaths` only.
- `message_media_service.dart:initial()` (`services/message_media_service.dart:17-37`) — reads only `imagePaths`.
- `chat_message_widget.dart:349` — resolves via the same path-only logic.

`imageUrls` is deserialized by `fromSupabase()` (`chat_message.dart:152-154`) but never handed to the renderer. So both directions are broken: upload drops the image, and the client never renders a remote `image_url`.

### BUG C: brand-new conversations can miss their UUID at realtime-watch setup

`ai_chat_screen._setupRealtimeSync()` (`services/sync_service.dart` watch path, `ai_chat_screen.dart:285-313`) looks up `getConversationUUID`. On a brand-new conversation the UUID may not exist until `createConversation` → outbox → `_uploadConversation()` completes, so the realtime subscription is silently skipped (the `catch` at line 310 swallows it). The initial sync then depends solely on the periodic 30s poll.

### BUG D: deletion path may remove a locally-owned conversation, but the trigger is unproven

`sync_service.dart:348-379` (`_removeConversationsDeletedRemotely()`) deletes local rows a remote snapshot no longer contains. This is guarded by `isStillMappedTo(...)` and a `ConversationDeletionBaseline` (`sync_reconciliation_policy.dart`) to avoid dropping rows uploaded mid-flight.

A brand-new conversation without a mapping at snapshot start is **excluded** from deletion candidates. If it already has a mapping, that mapping is normally stored only *after* the remote row was created. So the deletion race described earlier does **not** follow from the baseline guard alone. To actually delete a locally-owned conversation here, one of these still has to hold (none proven):
- unstable pagination with **> 200 conversations**;
- RLS / session visibility mismatch (remote query omits rows the local client believes it owns);
- an actual remote deletion;
- a stale/rebound mapping (a local id mapped to the wrong UUID);
- an incomplete remote snapshot (partial download).

This bug is a candidate, not a demonstrated cause.

### BUG E: exact (not fuzzy) assistant dedup can hide a real turn, but only in the UI

`message_service.cleanupMessagesList()` (`services/message_service.dart:86-186`) does a second pass that merges two assistant messages within 90 seconds. The comparison is **exact equality**, not fuzzy/semantic: `sameText` (`prev.message.trim() == msg.message.trim()`, line 150) and `_jsonListEquals(prev.filePaths, msg.filePaths)` / `_jsonListEquals(prev.imagePaths, msg.imagePaths)` are literal list comparisons (lines 151-152, 188-196). The code comment calls it "semantic dedup", but it collapses only on identical text + files + images inside 90s.

Crucially, this operates on an **in-memory** message list. It **does not delete SQLite or Supabase rows** — it only collapses what is shown. So it can make a genuine second AI turn disappear from the chat view, but it is not storage-layer data loss.

### BUG F: silent aborts on account switch

`_downloadConversationMessages()` (`sync_service.dart:492`) and `_downloadRemoteConversations()` early-return on `if (!_hasActiveUserContext) return;`. Intended for account switches, but combined with BUG C a mid-download account/user change can leave remote rows unloaded until the next tick.

### BUG G: permanently-failing uploads retry indefinitely (attempt counter not capped)

`failSyncOperation` stores `nextAttempts = attempts + 1` unbounded (`database_service.dart:965`); only the backoff *calculation* is bounded: `boundedAttempts = nextAttempts > 8 ? 8 : nextAttempts` then `1 << boundedAttempts`, capped at 300s (`database_service.dart:966-968`). So the `attempts` column keeps growing and the operation retries **indefinitely**, not "capped at 8 attempts".

Also, "oversized attachment" is a poor example here, because attachments are not part of the message upload payload (only `image_urls` is, and that is empty for user attachments) — so an attachment can never make the upload fail for that reason.

## Why the local conversation "disappears"

The deletion is only a **candidate** explanation, not a demonstrated sequence. To reproduce a locally-owned conversation being removed by `_removeConversationsDeletedRemotely()`, one of the triggers in BUG D must hold (unproven here). The image bug (BUG A) does not delete the conversation — it only leaves image-bearing messages without media on other clients. Do not treat these as one causal chain.

## Data/field mapping gaps

`toSupabase()` / `fromSupabase()` round-trip only covers text + `image_urls` (`chat_message.dart:111-164`). `image_paths` (the actual image the user attached) is neither uploaded nor read back. To make images sync, **both** directions must be fixed:
- Upload the attached image to Supabase Storage before/at send time (mirror `image_service.uploadImageToSupabase()`), populate `image_urls`.
- `toSupabase()` must transmit `image_urls` (already does at `chat_message.dart:117`) — so populate that field.
- `fromSupabase()` must **render** `image_urls` on the client — currently it only deserializes them (`chat_message.dart:152-154`) but the renderer (`message_media_service.resolve()`, `chat_message_widget.dart:349`) only reads `imagePaths`. The resolver must accept remote HTTP `image_urls`.

## File / line map

| Concern | File | Lines |
|---|---|---|
| conversations table schema | database_service.dart | 172-183, 1262-1272, 1554-1581 |
| chat_messages table schema | database_service.dart | 499-524 |
| sync_outbox + queue ops | database_service.dart | 526-544, 910-985 |
| client_id unique indexes | database_service.dart | 546-562 |
| Sync orchestration / outbox drain | sync_service.dart | 125-147, 214-259 |
| Conversation upload | sync_service.dart | 543-602 |
| Message upload | sync_service.dart | 671-717 |
| Download remote convs/messages | sync_service.dart | 303-518 |
| `_removeConversationsDeletedRemotely` | sync_service.dart | 348-379 |
| Realtime listener | sync_service.dart | 719-760 |
| Legacy back-fill | sync_service.dart | 261-287 |
| ID mapping (local ⇄ UUID) | id_mapping_service.dart | 161-295 |
| ChatMessage model + image fields | chat_message.dart | 18-19, 111-164 |
| Image upload (avatars only) | image_service.dart | 258-293 |
| Vision base64 (API only) | chat_image_preprocessor.dart | 48-70 |
| Message dedup (display-only) | message_service.dart | 86-196 |
| ConversationProvider | conversation_provider.dart | 16-166 |
| Conversation drawer | conversation_drawer.dart | 66, 259-307 |
| Chat send + persistence + realtime setup | ai_chat_screen.dart | 1066-1323, 285-313 |

## Historical recommendations (implemented in the remediation above)

1. **Confirm the image path is the blocker (Symptom 1):** verify that on the affected device `chat_messages.image_urls` is NULL while `image_paths` holds local paths.
2. **Add image upload before send (Symptom 1, upload side):** upload attached images to Supabase Storage and populate `image_urls` so `toSupabase()` carries them.
3. **Fix the renderer (Symptom 1, download side):** make `MessageMediaService.resolve()` / `initial()` also render remote HTTP `image_urls`, not only local `imagePaths`. Without this, uploaded images still won't show on another device.
4. **Probe the deletion cause (Symptom 2):** check whether any BUG D trigger holds (> 200 conversations, RLS/session visibility mismatch, actual remote deletion, stale/rebound mapping, incomplete snapshot) — this is a candidate, not yet proven.
5. **Harden the delete path:** if a BUG D trigger holds, ensure `_removeConversationsDeletedRemotely()` never removes a conversation that still owns pending/just-uploaded outbox rows, and re-confirm `isStillMappedTo` across the whole remove window.
6. **Fix realtime-watch timing:** on a new conversation, re-attempt `_setupRealtimeSync` after the UUID mapping lands, instead of silently skipping.
7. **Scope down dedup (if a real repeated turn is being hidden):** note it collapses only exact text+files+images within 90s and only in the UI — if it needs narrowing, do so on exact client_id/text match.
