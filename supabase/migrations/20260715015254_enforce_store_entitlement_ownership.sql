create unique index app_entitlements_store_reference_unique_idx
  on public.app_entitlements (source, source_reference)
  where source in ('app_store', 'play_store')
    and source_reference is not null;

comment on index public.app_entitlements_store_reference_unique_idx is
  'Prevents one verified store subscription from being linked to multiple HowAI accounts.';
