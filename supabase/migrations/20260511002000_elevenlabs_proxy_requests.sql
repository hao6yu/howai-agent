create table if not exists public.elevenlabs_proxy_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  is_anonymous boolean not null default false,
  endpoint text not null,
  voice_id text,
  agent_id text,
  status_code integer not null,
  request_bytes integer not null default 0,
  response_bytes integer,
  error text,
  created_at timestamptz not null default now()
);

alter table public.elevenlabs_proxy_requests enable row level security;

create policy "Users can view their own ElevenLabs proxy logs"
on public.elevenlabs_proxy_requests
for select
to authenticated
using (auth.uid() = user_id);

create index if not exists elevenlabs_proxy_requests_user_created_idx
on public.elevenlabs_proxy_requests (user_id, created_at desc);

create index if not exists elevenlabs_proxy_requests_user_anon_created_idx
on public.elevenlabs_proxy_requests (user_id, is_anonymous, created_at desc);
