# Phase 3B: Knowledge Hub Document Grounding (Design)

## Why
Users should be able to:
1. Attach a document to memory.
2. Have AI use extracted document content when relevant.
3. Open the original file later for verification.

This design keeps local-first behavior and is shaped for future Supabase sync.

## Scope
- In scope:
  - Store original file metadata + local path.
  - Extract document text and persist it.
  - Chunk extracted text for retrieval.
  - Ground AI responses with retrieved chunks and citations.
  - Premium gating for all document-memory actions.
- Out of scope:
  - Full vector DB in 3B (start with deterministic keyword scoring, optional embeddings later).
  - OCR for scanned/image-only PDFs (can be added in 3C).

## Data Model (Local SQLite)

### Table: `knowledge_sources`
Represents an uploaded/linked source document.
- `id` INTEGER PK
- `profile_id` INTEGER NOT NULL
- `knowledge_item_id` INTEGER NULL
- `source_type` TEXT NOT NULL   // `file`, `chat_message`
- `display_name` TEXT NOT NULL
- `mime_type` TEXT NULL
- `file_extension` TEXT NULL
- `file_size_bytes` INTEGER NULL
- `local_uri` TEXT NULL         // local app file path/uri
- `storage_key` TEXT NULL       // future Supabase storage object key
- `sha256` TEXT NULL            // dedupe + integrity
- `extraction_status` TEXT NOT NULL DEFAULT `pending` // pending, ready, failed
- `extraction_error` TEXT NULL
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Indexes:
- `(profile_id, updated_at DESC)`
- `(knowledge_item_id)`
- `(sha256)`

### Table: `knowledge_source_chunks`
Chunked extracted text used at retrieval time.
- `id` INTEGER PK
- `source_id` INTEGER NOT NULL
- `profile_id` INTEGER NOT NULL
- `chunk_index` INTEGER NOT NULL
- `content` TEXT NOT NULL
- `content_hash` TEXT NULL
- `token_estimate` INTEGER NULL
- `metadata_json` TEXT NULL     // heading/page hints, offsets
- `created_at` TEXT NOT NULL

Indexes:
- `(source_id, chunk_index)`
- `(profile_id, created_at DESC)`

### Table: `knowledge_item_sources` (optional now, recommended)
Many-to-many relation between memory items and sources.
- `id` INTEGER PK
- `knowledge_item_id` INTEGER NOT NULL
- `source_id` INTEGER NOT NULL
- `created_at` TEXT NOT NULL

Unique index:
- `(knowledge_item_id, source_id)`

## Supabase Target Model (Future Sync)
- `knowledge_items` (already planned)
- `knowledge_sources` (UUID PK, user_id, profile_uuid, knowledge_item_uuid nullable)
- `knowledge_source_chunks` (UUID PK, source_uuid FK, profile_uuid FK)
- Storage bucket: `knowledge-files` (private)
  - object path: `user_id/profile_uuid/source_uuid/original_filename`

RLS:
- Users can only access rows/files where `user_id = auth.uid()`.
- Storage objects are private; access only via signed URL.

## Ingestion Pipeline
1. User attaches file in Knowledge Hub item editor.
2. App copies file to app-managed folder and records `knowledge_sources` row.
3. Extract text using existing file extraction capabilities in `FileService`.
4. Normalize text:
   - collapse excess whitespace
   - remove obviously empty lines
   - keep section boundaries where possible
5. Chunk text (e.g., 800-1200 chars with 120 char overlap).
6. Save chunks into `knowledge_source_chunks`.
7. Mark source `ready` or `failed`.

## Retrieval and Grounding
When sending user prompt:
1. Keep current memory retrieval (`knowledge_items`) scoring.
2. Also score document chunks:
   - lexical overlap against prompt terms
   - boost chunks from pinned/active memory-linked sources
   - optional recency boost
3. Select top K chunks (e.g., 4-8) with total token budget cap.
4. Inject compact grounded context:
   - include source label and chunk id
   - instruction: answer from these chunks only when relevant
5. Ask model to cite source labels in final answer when grounded content is used.

Fallback behavior:
- No relevant chunks: proceed with normal memory-only context.

## UX Changes
### Knowledge Hub Item Editor
- Add section: `Sources`
  - `Attach File`
  - list attached sources with status (`Processing`, `Ready`, `Failed`)
  - open/remove actions

### Message Actions
- Keep `Add to Memory` / `Review & Save`.
- In `Review & Save`, show optional source linking.

### Transparency
- In AI message footer or expand panel:
  - `Grounded by: <source name>, <source name>`
  - tap to open Knowledge Hub item/source.

## Premium Gating
- Non-premium users can see educational UI only.
- Attach/extract/retrieve document chunks blocked by entitlement check in:
  - UI layer
  - service layer

## Sync Strategy
Local-first writes:
1. Save metadata + chunks locally immediately.
2. Queue sync records for:
   - source metadata rows
   - source chunk rows
   - file upload to Supabase storage
3. On upload success, set `storage_key` and sync status.

Conflict policy:
- `updated_at` last-write-wins for metadata.
- Chunk rows are immutable per `source_id + chunk_index`; re-extraction replaces all chunks for that source.

ID mapping:
- Extend `IDMappingService` to include:
  - source local id <-> source uuid
  - chunk local id <-> chunk uuid (optional if using deterministic upsert keys)

## Security & Privacy
- Never embed local file paths in prompts.
- Prompts only include extracted chunk text and source display names.
- Source files remain private in app sandbox / Supabase private bucket.
- Add retention controls:
  - remove source file and chunks when source deleted.

## Rollout Plan
1. **3B-1 schema + services**
   - DB migration for source/chunk tables.
   - CRUD methods + entitlement guards.
2. **3B-2 ingestion UI**
   - attach/remove/open source in Knowledge Hub editor.
   - extraction worker + status updates.
3. **3B-3 retrieval grounding**
   - chunk scoring + prompt injection + source labels in responses.
4. **3B-4 sync to Supabase**
   - metadata/chunks/file upload pipeline + retries.
5. **3B-5 hardening**
   - error UX, dedupe, performance and token budget tuning.

## Acceptance Criteria
- User can attach a supported file and see extraction status.
- AI can answer using extracted content and surface source labels.
- User can open original file from Knowledge Hub.
- Non-premium cannot perform doc-memory operations.
- Existing chat/translation/pdf/voice behaviors remain intact.
