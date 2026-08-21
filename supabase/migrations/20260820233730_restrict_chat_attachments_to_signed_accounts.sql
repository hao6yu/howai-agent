-- Supabase anonymous sessions also use the authenticated Postgres role.
-- Keep synced chat photos limited to recoverable signed-in accounts, matching
-- the application's cloud-sync boundary.

alter policy "users can read own chat attachments"
on storage.objects
using (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
);

alter policy "users can upload own chat attachments"
on storage.objects
with check (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
);

alter policy "users can update own chat attachments"
on storage.objects
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

alter policy "users can delete own chat attachments"
on storage.objects
using (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  ) = false
);
