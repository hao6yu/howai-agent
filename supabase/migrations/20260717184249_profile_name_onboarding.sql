alter table public.profiles
  add column if not exists name_status text,
  add column if not exists name_source text,
  add column if not exists name_prompted_at timestamptz;

with classified as (
  select
    profile.id,
    case
      when profile.name is null
        or btrim(profile.name) = ''
        or lower(btrim(profile.name)) = 'user'
        or (
          profile.email is not null
          and lower(btrim(profile.name)) =
            lower(split_part(profile.email, '@', 1))
        )
        then 'User'
      else left(regexp_replace(btrim(profile.name), '\s+', ' ', 'g'), 80)
    end as normalized_name,
    case
      when profile.name is null
        or btrim(profile.name) = ''
        or lower(btrim(profile.name)) = 'user'
        or (
          profile.email is not null
          and lower(btrim(profile.name)) =
            lower(split_part(profile.email, '@', 1))
        )
        then 'unknown'
      else 'known'
    end as normalized_status,
    case
      when profile.name is null
        or btrim(profile.name) = ''
        or lower(btrim(profile.name)) = 'user'
        or (
          profile.email is not null
          and lower(btrim(profile.name)) =
            lower(split_part(profile.email, '@', 1))
        )
        then 'default'
      when nullif(
        btrim(coalesce(
          auth_user.raw_user_meta_data->>'name',
          auth_user.raw_user_meta_data->>'full_name',
          auth_user.raw_user_meta_data->>'given_name',
          ''
        )),
        ''
      ) is not null
        then 'auth'
      else 'user'
    end as normalized_source
  from public.profiles as profile
  left join auth.users as auth_user on auth_user.id = profile.id
)
update public.profiles as profile
set
  name = classified.normalized_name,
  name_status = classified.normalized_status,
  name_source = classified.normalized_source
from classified
where classified.id = profile.id;

alter table public.profiles
  alter column name set default 'User',
  alter column name set not null,
  alter column name_status set default 'unknown',
  alter column name_status set not null,
  alter column name_source set default 'default',
  alter column name_source set not null;

alter table public.profiles
  drop constraint if exists profiles_name_length_check,
  add constraint profiles_name_length_check
    check (char_length(btrim(name)) between 1 and 80),
  drop constraint if exists profiles_name_status_check,
  add constraint profiles_name_status_check
    check (name_status in ('unknown', 'prompted', 'known', 'declined')),
  drop constraint if exists profiles_name_source_check,
  add constraint profiles_name_source_check
    check (name_source in ('default', 'auth', 'user', 'assistant'));

comment on column public.profiles.name_status is
  'Preferred-name onboarding state. Unknown may be claimed once for a conversational prompt.';
comment on column public.profiles.name_source is
  'Origin of the current app display name; never use this field for authorization.';
comment on column public.profiles.name_prompted_at is
  'When HowAI first asked what the user would like to be called.';

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  candidate_name text;
  resolved_name text;
  resolved_status text;
  resolved_source text;
begin
  candidate_name := nullif(
    regexp_replace(
      btrim(coalesce(
        new.raw_user_meta_data->>'name',
        new.raw_user_meta_data->>'full_name',
        new.raw_user_meta_data->>'given_name',
        ''
      )),
      '\s+',
      ' ',
      'g'
    ),
    ''
  );

  if candidate_name is null
    or lower(candidate_name) = 'user'
    or (
      new.email is not null
      and lower(candidate_name) = lower(split_part(new.email, '@', 1))
    )
  then
    resolved_name := 'User';
    resolved_status := 'unknown';
    resolved_source := 'default';
  else
    resolved_name := left(candidate_name, 80);
    resolved_status := 'known';
    resolved_source := 'auth';
  end if;

  insert into public.profiles (
    id,
    email,
    name,
    name_status,
    name_source
  )
  values (
    new.id,
    new.email,
    resolved_name,
    resolved_status,
    resolved_source
  );
  return new;
exception
  when others then
    raise warning 'Failed to create profile for user %: %', new.id, sqlerrm;
    return new;
end;
$function$;

revoke all on function public.handle_new_user() from public, anon, authenticated;
