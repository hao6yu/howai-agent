-- Keep push-device audit timestamps on the database clock. Edge runtimes can
-- be a few milliseconds behind Postgres, which made a new row's supplied
-- updated_at precede its database-generated created_at.

create function public.set_push_device_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = pg_catalog.now();
  return new;
end;
$$;

revoke all on function public.set_push_device_updated_at() from public;

create trigger set_push_device_updated_at
before insert or update on public.push_devices
for each row execute function public.set_push_device_updated_at();
