-- Quick check to see what tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check if profiles table exists specifically
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name = 'profiles'
) as profiles_exists;

-- Check if the trigger function exists
SELECT EXISTS (
   SELECT FROM information_schema.routines 
   WHERE routine_schema = 'public' 
   AND routine_name = 'handle_new_user'
) as trigger_function_exists;
