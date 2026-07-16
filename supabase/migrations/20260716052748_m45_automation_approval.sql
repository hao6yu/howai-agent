-- M4.5 approved Automation creation. The Edge Function validates and
-- normalizes arguments; this service-only RPC atomically consumes the proposal
-- and creates the approved template.

alter table public.automations
  add column start_local timestamp without time zone not null;

create function public.execute_automation_action(
  p_action_run_id uuid,
  p_user_id uuid,
  p_execution jsonb
)
returns table (resource_type text, resource_id uuid)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_run public.agent_action_runs%rowtype;
  v_automation_id uuid;
  v_paid boolean;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;
  if p_execution is null or jsonb_typeof(p_execution) <> 'object' then
    raise exception 'invalid automation execution' using errcode = '22023';
  end if;

  select *
  into v_run
  from public.agent_action_runs
  where id = p_action_run_id
    and user_id = p_user_id
  for update;

  if not found then
    raise exception 'automation action not found' using errcode = '55000';
  end if;
  if v_run.status = 'succeeded' and v_run.resource_type = 'automation' then
    return query select 'automation'::text, v_run.resource_id;
    return;
  end if;
  if v_run.status <> 'proposed' or v_run.action_type <> 'automations_create' then
    raise exception 'automation action is not executable' using errcode = '55000';
  end if;
  if v_run.arguments <> p_execution then
    raise exception 'automation execution differs from approved proposal'
      using errcode = '55000';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_user_id::text || ':active_automations', 0)
  );

  select exists (
    select 1
    from public.app_entitlements e
    where e.user_id = p_user_id
      and e.tier = 'paid'
      and (e.expires_at is null or e.expires_at > pg_catalog.now())
  ) into v_paid;
  if not v_paid then
    raise exception 'paid entitlement required' using errcode = '42501';
  end if;

  if (
    select count(*)
    from public.automations a
    where a.user_id = p_user_id
      and a.status = 'active'
  ) >= 2 then
    raise exception 'active automation limit reached' using errcode = '54000';
  end if;

  insert into public.automations (
    user_id,
    conversation_id,
    action_run_id,
    kind,
    title,
    timezone,
    start_local,
    schedule_rule,
    next_run_at,
    config,
    source_policy,
    delivery_preferences
  ) values (
    p_user_id,
    v_run.conversation_id,
    v_run.id,
    p_execution ->> 'kind',
    p_execution ->> 'title',
    p_execution ->> 'timezone',
    (p_execution ->> 'start_local')::timestamp without time zone,
    p_execution -> 'schedule_rule',
    (p_execution ->> 'next_run_at')::timestamptz,
    p_execution -> 'config',
    p_execution -> 'source_policy',
    p_execution -> 'delivery_preferences'
  )
  returning id into v_automation_id;

  update public.agent_action_runs
  set
    status = 'succeeded',
    approved_at = pg_catalog.now(),
    completed_at = pg_catalog.now(),
    resource_type = 'automation',
    resource_id = v_automation_id,
    result = jsonb_build_object(
      'automation_id', v_automation_id,
      'kind', p_execution ->> 'kind',
      'status', 'active'
    )
  where id = v_run.id;

  return query select 'automation'::text, v_automation_id;
end;
$$;

revoke all on function public.execute_automation_action(uuid,uuid,jsonb)
  from public, anon, authenticated;
grant execute on function public.execute_automation_action(uuid,uuid,jsonb)
  to service_role;
