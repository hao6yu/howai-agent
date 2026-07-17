alter table public.automations
  drop constraint automations_schedule_frequency;

alter table public.automations
  add constraint automations_schedule_frequency
  check (
    schedule_rule ->> 'frequency' in ('once', 'daily', 'weekly', 'market_days')
  );

alter table public.automations
  drop constraint automations_status_check;

alter table public.automations
  add constraint automations_status_check
  check (status in ('active', 'paused', 'completed'));

create or replace function public.finish_automation_run(
  p_run_id uuid,
  p_status text,
  p_message_content text,
  p_report jsonb,
  p_preview text,
  p_claims jsonb,
  p_sources jsonb,
  p_verification jsonb,
  p_generation_response_id text,
  p_verification_response_id text,
  p_generation_usage_ledger_id uuid,
  p_verification_usage_ledger_id uuid,
  p_next_run_at timestamptz,
  p_create_delivery boolean,
  p_error_code text default null,
  p_error_message text default null
)
returns table (
  conversation_id uuid,
  message_id uuid,
  delivery_id uuid
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_run public.automation_runs%rowtype;
  v_automation public.automations%rowtype;
  v_conversation_id uuid;
  v_message_id uuid;
  v_delivery_id uuid;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;
  if p_status not in ('succeeded', 'withheld', 'failed')
    or p_report is null or jsonb_typeof(p_report) <> 'object'
    or p_claims is null or jsonb_typeof(p_claims) <> 'array'
    or p_sources is null or jsonb_typeof(p_sources) <> 'array'
    or p_verification is null or jsonb_typeof(p_verification) <> 'object'
    or (p_preview is not null and char_length(p_preview) > 500)
    or (p_error_code is not null and char_length(p_error_code) > 100)
    or (p_error_message is not null and char_length(p_error_message) > 500)
    or (
      p_status in ('succeeded', 'withheld')
      and (p_message_content is null or char_length(btrim(p_message_content)) = 0)
    )
    or (
      p_create_delivery
      and (
        p_status not in ('succeeded', 'withheld')
        or p_preview is null
        or char_length(btrim(p_preview)) = 0
      )
    ) then
    raise exception 'invalid Automation completion values'
      using errcode = '22023';
  end if;

  select * into v_run
  from public.automation_runs
  where id = p_run_id
  for update;

  if not found then return; end if;
  if v_run.status in ('succeeded', 'withheld', 'failed', 'cancelled') then
    select d.id into v_delivery_id
    from public.automation_run_deliveries d
    where d.automation_run_id = v_run.id;
    return query select v_run.conversation_id, v_run.conversation_message_id, v_delivery_id;
    return;
  end if;
  if v_run.status not in ('running', 'verifying') then return; end if;

  select * into v_automation
  from public.automations
  where id = v_run.automation_id and user_id = v_run.user_id
  for update;
  if not found then
    raise exception 'Automation no longer exists' using errcode = '55000';
  end if;

  v_conversation_id := coalesce(v_run.conversation_id, v_automation.conversation_id);
  if p_status in ('succeeded', 'withheld') and v_conversation_id is null then
    insert into public.conversations (user_id, title, created_at, updated_at, is_pinned)
    values (
      v_run.user_id,
      'Automation: ' || v_automation.title,
      pg_catalog.now(),
      pg_catalog.now(),
      false
    )
    returning id into v_conversation_id;

    update public.automations
    set conversation_id = v_conversation_id, updated_at = pg_catalog.now()
    where id = v_automation.id;
  end if;

  if p_status in ('succeeded', 'withheld') then
    insert into public.messages (conversation_id, content, is_ai, created_at)
    values (v_conversation_id, p_message_content, true, pg_catalog.now())
    returning id into v_message_id;

    update public.conversations
    set updated_at = pg_catalog.now(), archived_at = null
    where id = v_conversation_id and user_id = v_run.user_id;
  end if;

  update public.automation_runs
  set
    conversation_id = v_conversation_id,
    conversation_message_id = v_message_id,
    status = p_status,
    report = p_report,
    preview = p_preview,
    claims = p_claims,
    sources = p_sources,
    verification = p_verification,
    generation_response_id = p_generation_response_id,
    verification_response_id = p_verification_response_id,
    generation_usage_ledger_id = p_generation_usage_ledger_id,
    verification_usage_ledger_id = p_verification_usage_ledger_id,
    error_code = p_error_code,
    error_message = p_error_message,
    completed_at = pg_catalog.now(),
    lease_expires_at = null,
    updated_at = pg_catalog.now()
  where id = v_run.id;

  if v_automation.status = 'active'
    and v_automation.next_run_at = v_run.scheduled_for then
    update public.automations
    set
      status = case
        when p_next_run_at is null and schedule_rule ->> 'frequency' = 'once'
          then 'completed'
        when p_next_run_at is null then 'paused'
        else status
      end,
      next_run_at = coalesce(p_next_run_at, next_run_at),
      last_run_at = v_run.scheduled_for,
      version = version + 1,
      updated_at = pg_catalog.now()
    where id = v_automation.id;
  end if;

  if p_create_delivery and v_message_id is not null then
    insert into public.automation_run_deliveries (
      automation_run_id, user_id, conversation_id, message_id, title, preview
    ) values (
      v_run.id, v_run.user_id, v_conversation_id, v_message_id,
      v_automation.title, p_preview
    )
    on conflict (automation_run_id) do update
    set updated_at = pg_catalog.now()
    returning id into v_delivery_id;
  end if;

  return query select v_conversation_id, v_message_id, v_delivery_id;
end;
$$;

revoke all on function public.finish_automation_run(
  uuid,text,text,jsonb,text,jsonb,jsonb,jsonb,text,text,uuid,uuid,timestamptz,boolean,text,text
) from public, anon, authenticated;

grant execute on function public.finish_automation_run(
  uuid,text,text,jsonb,text,jsonb,jsonb,jsonb,text,text,uuid,uuid,timestamptz,boolean,text,text
) to service_role;
