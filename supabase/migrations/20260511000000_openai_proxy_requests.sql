create table if not exists public.openai_proxy_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  endpoint text not null,
  model text,
  status_code integer not null,
  request_bytes integer not null default 0,
  response_id text,
  input_tokens integer,
  output_tokens integer,
  total_tokens integer,
  error text,
  created_at timestamptz not null default now()
);

create index if not exists openai_proxy_requests_user_created_idx
  on public.openai_proxy_requests(user_id, created_at desc);

create index if not exists openai_proxy_requests_created_idx
  on public.openai_proxy_requests(created_at desc);

alter table public.openai_proxy_requests enable row level security;

drop policy if exists "Users can view their own OpenAI proxy logs"
  on public.openai_proxy_requests;

create policy "Users can view their own OpenAI proxy logs"
  on public.openai_proxy_requests
  for select
  to authenticated
  using (auth.uid() = user_id);
