insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'chat-attachments',
  'chat-attachments',
  false,
  10485760,
  array[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif'
  ]::text[]
)
on conflict (id) do nothing;

create policy "users can read own chat attachments"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
);

create policy "users can upload own chat attachments"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
);

create policy "users can update own chat attachments"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
)
with check (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
);

create policy "users can delete own chat attachments"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
);
