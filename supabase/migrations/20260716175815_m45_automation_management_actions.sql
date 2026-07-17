-- M4.5 generated Automation management. All mutations continue to flow
-- through an approved agent_action_runs proposal and this service-only RPC.

create or replace function public.execute_automation_action(
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
  v_automation public.automations%rowtype;
  v_automation_id uuid;
  v_automation_version integer;
  v_expected_version integer;
  v_paid boolean;
  v_manual_run_at timestamptz;
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
  if v_run.status <> 'proposed'
    or v_run.action_type not in (
      'automations_create',
      'automations_update',
      'automations_pause',
      'automations_resume',
      'automations_run_now',
      'automations_delete'
    ) then
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

  update public.agent_action_runs
  set status = 'executing', approved_at = pg_catalog.now()
  where id = v_run.id;

  if v_run.action_type = 'automations_create' then
    if (
      select count(*)
      from public.automations a
      where a.user_id = p_user_id and a.status = 'active'
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
    returning id, version into v_automation_id, v_automation_version;
  else
    v_automation_id := (p_execution ->> 'automation_id')::uuid;
    v_expected_version := (p_execution ->> 'expected_version')::integer;

    select * into v_automation
    from public.automations
    where id = v_automation_id
      and user_id = p_user_id
      and version = v_expected_version
    for update;

    if not found then
      raise exception 'automation changed or is no longer available'
        using errcode = '40001';
    end if;

    if v_run.action_type = 'automations_update' then
      update public.automation_runs
      set
        status = 'cancelled',
        completed_at = pg_catalog.now(),
        lease_expires_at = null,
        updated_at = pg_catalog.now(),
        error_code = 'automation_updated',
        error_message = 'The Automation was updated before this run started.'
      where automation_id = v_automation_id and status = 'queued';

      update public.automations
      set
        title = p_execution ->> 'title',
        timezone = p_execution ->> 'timezone',
        start_local = (p_execution ->> 'start_local')::timestamp without time zone,
        schedule_rule = p_execution -> 'schedule_rule',
        next_run_at = (p_execution ->> 'next_run_at')::timestamptz,
        config = p_execution -> 'config',
        source_policy = p_execution -> 'source_policy',
        delivery_preferences = p_execution -> 'delivery_preferences',
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_automation_id
        and user_id = p_user_id
        and version = v_expected_version
        and status in ('active', 'paused')
      returning version into v_automation_version;
    elsif v_run.action_type = 'automations_pause' then
      update public.automation_runs
      set
        status = 'cancelled',
        completed_at = pg_catalog.now(),
        lease_expires_at = null,
        updated_at = pg_catalog.now(),
        error_code = 'automation_paused',
        error_message = 'The Automation was paused before this run started.'
      where automation_id = v_automation_id and status = 'queued';

      update public.automations
      set
        status = 'paused',
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_automation_id
        and user_id = p_user_id
        and version = v_expected_version
        and status = 'active'
      returning version into v_automation_version;
    elsif v_run.action_type = 'automations_resume' then
      if (
        select count(*)
        from public.automations a
        where a.user_id = p_user_id and a.status = 'active'
      ) >= 2 then
        raise exception 'active automation limit reached' using errcode = '54000';
      end if;

      update public.automations
      set
        status = 'active',
        next_run_at = (p_execution ->> 'next_run_at')::timestamptz,
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_automation_id
        and user_id = p_user_id
        and version = v_expected_version
        and status = 'paused'
      returning version into v_automation_version;
    elsif v_run.action_type = 'automations_run_now' then
      if v_automation.status = 'completed' then
        raise exception 'completed automation cannot run again'
          using errcode = '40001';
      end if;
      if exists (
        select 1
        from public.automation_runs r
        where r.automation_id = v_automation_id
          and r.trigger_type = 'manual'
          and r.created_at > pg_catalog.now() - interval '10 minutes'
          and r.status in ('queued', 'running', 'verifying', 'succeeded', 'withheld')
      ) then
        raise exception 'automation manual run cooldown'
          using errcode = '54001';
      end if;
      v_manual_run_at := pg_catalog.clock_timestamp();
      insert into public.automation_runs (
        automation_id,
        user_id,
        conversation_id,
        automation_version,
        scheduled_for,
        trigger_type,
        template_snapshot
      ) values (
        v_automation.id,
        v_automation.user_id,
        v_automation.conversation_id,
        v_automation.version,
        v_manual_run_at,
        'manual',
        jsonb_build_object(
          'automation_id', v_automation.id,
          'kind', v_automation.kind,
          'title', v_automation.title,
          'timezone', v_automation.timezone,
          'start_local', v_automation.start_local,
          'schedule_rule', v_automation.schedule_rule,
          'config', v_automation.config,
          'source_policy', v_automation.source_policy,
          'delivery_preferences', v_automation.delivery_preferences
        )
      );
      v_automation_version := v_automation.version;
    elsif v_run.action_type = 'automations_delete' then
      v_automation_version := v_automation.version;
      delete from public.automations
      where id = v_automation_id
        and user_id = p_user_id
        and version = v_expected_version;
    else
      raise exception 'unsupported automation action' using errcode = '22023';
    end if;

    if not found and v_run.action_type <> 'automations_run_now' then
      raise exception 'automation changed or is no longer available'
        using errcode = '40001';
    end if;
  end if;

  update public.agent_action_runs
  set
    status = 'succeeded',
    completed_at = pg_catalog.now(),
    resource_type = 'automation',
    resource_id = v_automation_id,
    result = jsonb_build_object(
      'automation_id', v_automation_id,
      'resource_version', v_automation_version,
      'action_type', v_run.action_type
    ),
    error_code = null,
    error_message = null
  where id = v_run.id;

  return query select 'automation'::text, v_automation_id;
end;
$$;

revoke all on function public.execute_automation_action(uuid,uuid,jsonb)
  from public, anon, authenticated;
grant execute on function public.execute_automation_action(uuid,uuid,jsonb)
  to service_role;
