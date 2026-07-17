alter table if exists public.conversations
  add column if not exists archived_at timestamp with time zone;

create index if not exists conversations_user_active_updated_idx
  on public.conversations (user_id, updated_at desc)
  where archived_at is null;

create index if not exists conversations_user_archived_at_idx
  on public.conversations (user_id, archived_at desc)
  where archived_at is not null;
