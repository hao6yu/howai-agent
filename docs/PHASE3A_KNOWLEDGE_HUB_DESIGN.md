# Phase 3A: Personal Knowledge Hub (Foundation)

## Goal
Create a profile-scoped memory layer so HowAI can remember user-specific facts and preferences across chats, with clear user control.
This is a **Premium-only** capability in Phase 3A.

## Non-goals (3A)
- No recurring jobs/automation engine (that is Phase 3B).
- No large vector/RAG infrastructure yet.
- No aggressive fully-automatic memory extraction without user visibility.

## User Experience
1. Save memory from chat message:
- Action on AI/user message: `Save to Knowledge Hub`.
- Optional quick fields: type, tags.

2. Knowledge Hub screen:
- List memories by newest, filter by type/tag.
- Edit, pin/unpin, delete.
- Toggle `Use in AI context` per item.

3. Runtime behavior:
- When user sends new prompt, app fetches top relevant memories and injects concise context.
- If none are relevant, no memory context is injected.

## Premium Gating (required)
1. Feature availability:
- Knowledge Hub entry points are visible only to Premium users.
- Non-Premium users see an upgrade paywall CTA instead of functional controls.

2. Write operations:
- Save/edit/delete/pin/toggle actions must verify Premium entitlement before execution.
- If entitlement fails, operation is blocked and upgrade UI is shown.

3. Read/retrieval operations:
- Memory retrieval/injection into prompt is disabled for non-Premium users.
- Existing knowledge records (if any) are ignored until user is Premium again.

4. Defense in depth:
- Gate in UI (`SubscriptionService` via Provider) and in service layer (`KnowledgeHubService` entitlement guard).
- Never rely on UI-only checks.

## Data Model (initial)
Use local DB first (existing app DB), synced later via existing sync path.

### Table: `knowledge_items`
- `id` INTEGER PK
- `profile_id` INTEGER NOT NULL
- `conversation_id` INTEGER NULL
- `source_message_id` INTEGER NULL
- `title` TEXT NOT NULL
- `content` TEXT NOT NULL
- `memory_type` TEXT NOT NULL  // `preference`, `fact`, `goal`, `constraint`, `other`
- `tags_json` TEXT NULL         // JSON array of strings
- `is_pinned` INTEGER NOT NULL DEFAULT 0
- `is_active` INTEGER NOT NULL DEFAULT 1
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

### Table: `knowledge_item_usage` (optional in 3A, can defer)
- `id` INTEGER PK
- `knowledge_item_id` INTEGER NOT NULL
- `conversation_id` INTEGER NOT NULL
- `used_at` TEXT NOT NULL

## Retrieval Strategy (3A simple + reliable)
Scoring for each active knowledge item:
- +3 if pinned
- +2 if prompt contains one of its tags
- +2 if prompt contains keyword from title/content
- +1 if recent (`updated_at` within 14 days)

Take top N (default 5), render as compact system context block:
- `User memory context (do not repeat unless relevant): ...`

## Safety & Privacy
- Memory is profile-scoped.
- User can delete individual memory or clear all profile memories.
- No hidden extraction in 3A; saved items come from explicit user action.
- Respect `is_active=0` to keep history without runtime usage.

## Implementation Plan (small PR slices)
1. DB + model + service
- Migration for `knowledge_items`.
- `KnowledgeItem` model + CRUD service.
- Add service-level premium guard for all Knowledge Hub operations.

2. Save action from chat messages
- Add `Save to Knowledge Hub` action.
- Minimal modal for title/type/tags.
- Show upgrade prompt for non-Premium users.

3. Knowledge Hub screen
- New screen route and list UI.
- Edit/delete/pin/toggle active.
- Screen gated behind Premium; non-Premium sees paywall CTA.

4. Prompt integration
- Retrieve top memories before API call.
- Inject compact memory context into prompt builder.
- Retrieval path runs only when Premium entitlement is active.

5. QA + polish
- Verify no regressions in existing chat flows.
- Add guardrails for empty/duplicate memory save.

## Success Criteria
- User can save, view, edit, and delete memories.
- AI responses reflect relevant saved preferences/facts.
- Existing chat, translation, PDF, and voice flows remain functional.
- Non-Premium users cannot use Knowledge Hub or memory injection paths.
