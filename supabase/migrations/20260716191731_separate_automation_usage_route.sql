-- Give generated Automations an independent usage route. They still count
-- toward per-user and project-wide budgets, but no longer consume or inherit
-- the interactive Research route allowance.

alter table public.ai_usage_ledger
  drop constraint ai_usage_ledger_model_role_check;

alter table public.ai_usage_ledger
  add constraint ai_usage_ledger_model_role_check
  check (model_role in (
    'nano', 'luna', 'sol', 'research', 'automation', 'realtime'
  ));

comment on column public.ai_usage_ledger.model_role is
  'Server-selected usage budget route; Automation is isolated from interactive Research while remaining subject to user and global caps.';
