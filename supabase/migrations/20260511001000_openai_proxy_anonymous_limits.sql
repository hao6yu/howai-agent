alter table public.openai_proxy_requests
  add column if not exists is_anonymous boolean not null default false;

create index if not exists openai_proxy_requests_anonymous_created_idx
  on public.openai_proxy_requests(user_id, is_anonymous, created_at desc);
