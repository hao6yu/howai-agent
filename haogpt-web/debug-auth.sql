-- Debug authentication issues
-- Run these queries in Supabase SQL Editor to diagnose the problem

-- 1. Check if the trigger function exists
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name = 'handle_new_user';

-- 2. Check if the trigger exists
SELECT trigger_name, event_manipulation, event_object_table 
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- 3. Check RLS policies on profiles table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'profiles';

-- 4. Test if we can insert into profiles manually (run as authenticated user)
-- This will help identify if it's an RLS issue
-- SELECT auth.uid(); -- This should return your user ID when authenticated

-- 5. Check if there are any existing auth users
SELECT id, email, created_at 
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 5;
