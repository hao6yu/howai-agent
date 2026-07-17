-- Supabase may apply default authenticated-table grants at creation time.
-- Extraction summaries are service-authored audit records, so clients may
-- only read and delete their own rows through RLS.
revoke all on table public.memory_session_summaries from authenticated;
grant select, delete on table public.memory_session_summaries to authenticated;
