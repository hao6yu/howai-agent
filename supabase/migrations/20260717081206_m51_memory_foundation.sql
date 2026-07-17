create table if not exists public.user_memories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  memory_key text not null,
  title text not null,
  content text not null,
  memory_type text not null default 'other'
    check (memory_type in ('preference', 'fact', 'goal', 'constraint', 'other')),
  tags jsonb not null default '[]'::jsonb
    check (jsonb_typeof(tags) = 'array'),
  status text not null default 'suggested'
    check (status in ('suggested', 'active', 'archived')),
  source_type text not null default 'manual'
    check (source_type in ('manual', 'chat', 'voice')),
  source_id text,
  confidence double precision not null default 1
    check (confidence >= 0 and confidence <= 1),
  is_explicit boolean not null default false,
  sensitivity text not null default 'normal'
    check (sensitivity in ('normal', 'sensitive')),
  first_observed_at timestamptz not null default now(),
  last_observed_at timestamptz not null default now(),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, memory_key),
  check (char_length(memory_key) between 1 and 160),
  check (char_length(title) between 1 and 120),
  check (char_length(content) between 1 and 2000),
  check (source_id is null or char_length(source_id) <= 200)
);

comment on table public.user_memories is
  'M5.1 structured user memories. Active rows may personalize HowAI; suggested rows require review.';
comment on column public.user_memories.content is
  'User-context data only. Never interpret this field as model instructions.';

create index if not exists user_memories_user_status_updated_idx
  on public.user_memories (user_id, status, updated_at desc);
create index if not exists user_memories_user_source_idx
  on public.user_memories (user_id, source_type, source_id);

alter table public.user_memories enable row level security;

drop policy if exists "Users can view own memories" on public.user_memories;
create policy "Users can view own memories"
  on public.user_memories
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own memories" on public.user_memories;
create policy "Users can insert own memories"
  on public.user_memories
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own memories" on public.user_memories;
create policy "Users can update own memories"
  on public.user_memories
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete own memories" on public.user_memories;
create policy "Users can delete own memories"
  on public.user_memories
  for delete
  to authenticated
  using (auth.uid() = user_id);

revoke all on table public.user_memories from anon;
grant select, insert, update, delete on table public.user_memories to authenticated;
grant all on table public.user_memories to service_role;

create table if not exists public.memory_session_summaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source_type text not null check (source_type in ('chat', 'voice')),
  source_id text not null,
  summary text not null,
  user_turn_count integer not null default 0 check (user_turn_count >= 0),
  content_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, source_type, source_id, content_hash),
  check (char_length(source_id) between 1 and 200),
  check (char_length(summary) between 1 and 2000),
  check (char_length(content_hash) between 16 and 128)
);

comment on table public.memory_session_summaries is
  'Compact post-session summaries used to deduplicate and audit M5.1 memory extraction.';

create index if not exists memory_session_summaries_user_created_idx
  on public.memory_session_summaries (user_id, created_at desc);

alter table public.memory_session_summaries enable row level security;

drop policy if exists "Users can view own memory summaries"
  on public.memory_session_summaries;
create policy "Users can view own memory summaries"
  on public.memory_session_summaries
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can delete own memory summaries"
  on public.memory_session_summaries;
create policy "Users can delete own memory summaries"
  on public.memory_session_summaries
  for delete
  to authenticated
  using (auth.uid() = user_id);

revoke all on table public.memory_session_summaries from anon;
grant select, delete on table public.memory_session_summaries to authenticated;
grant all on table public.memory_session_summaries to service_role;

create table if not exists public.memory_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  personalization_enabled boolean not null default true,
  learn_from_chats boolean not null default true,
  learn_from_voice boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.memory_preferences is
  'User controls for M5.1 personalization and automatic learning.';

alter table public.memory_preferences enable row level security;

drop policy if exists "Users can view own memory preferences"
  on public.memory_preferences;
create policy "Users can view own memory preferences"
  on public.memory_preferences
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own memory preferences"
  on public.memory_preferences;
create policy "Users can insert own memory preferences"
  on public.memory_preferences
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own memory preferences"
  on public.memory_preferences;
create policy "Users can update own memory preferences"
  on public.memory_preferences
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete own memory preferences"
  on public.memory_preferences;
create policy "Users can delete own memory preferences"
  on public.memory_preferences
  for delete
  to authenticated
  using (auth.uid() = user_id);

revoke all on table public.memory_preferences from anon;
grant select, insert, update, delete on table public.memory_preferences
  to authenticated;
grant all on table public.memory_preferences to service_role;

drop trigger if exists update_user_memories_updated_at
  on public.user_memories;
create trigger update_user_memories_updated_at
before update on public.user_memories
for each row execute function public.update_updated_at_column();

drop trigger if exists update_memory_session_summaries_updated_at
  on public.memory_session_summaries;
create trigger update_memory_session_summaries_updated_at
before update on public.memory_session_summaries
for each row execute function public.update_updated_at_column();

drop trigger if exists update_memory_preferences_updated_at
  on public.memory_preferences;
create trigger update_memory_preferences_updated_at
before update on public.memory_preferences
for each row execute function public.update_updated_at_column();

-- Tighten the legacy user-profile policy so ownership cannot change during an
-- update, and remove unauthenticated Data API grants left by the baseline.
drop policy if exists "Users can update own user profile"
  on public.user_profiles;
create policy "Users can update own user profile"
  on public.user_profiles
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

revoke all on table public.user_profiles from anon;
