-- Master AI Personality Template System for HaoGPT Web (FIXED VERSION)
-- This schema adds a master/default personality that all user personalities are based on

-- First, add new columns if they don't exist
ALTER TABLE ai_personalities
ADD COLUMN IF NOT EXISTS is_master BOOLEAN DEFAULT false;

-- Drop existing constraints temporarily
ALTER TABLE ai_personalities DROP CONSTRAINT IF EXISTS ai_personalities_user_id_key;
ALTER TABLE ai_personalities DROP CONSTRAINT IF EXISTS unique_master;
ALTER TABLE ai_personalities DROP CONSTRAINT IF EXISTS user_or_master;

-- Modify user_id column to allow NULL
ALTER TABLE ai_personalities
ALTER COLUMN user_id DROP NOT NULL;

-- Create partial unique index for master (PostgreSQL way)
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_master
ON ai_personalities (is_master)
WHERE is_master = true;

-- Add check constraint for user_or_master logic
ALTER TABLE ai_personalities
ADD CONSTRAINT user_or_master CHECK (
  (user_id IS NOT NULL AND is_master = false) OR
  (user_id IS NULL AND is_master = true)
);

-- Create the master/default AI personality if it doesn't exist
INSERT INTO ai_personalities (
  user_id,
  is_master,
  ai_name,
  personality,
  humor_level,
  communication_style,
  response_length,
  expertise,
  interests,
  background_story,
  custom_settings
)
SELECT
  NULL, -- No user_id for master
  true, -- This is the master template
  'HowAI',
  'friendly',
  'dry',
  'tech-savvy',
  'moderate',
  'general',
  'Technology, AI, Programming, Science, Arts, Business, Health, Education',
  'I am HowAI, your intelligent assistant powered by advanced AI. I''m here to help with a wide range of topics, from technical questions to creative projects. I combine friendly conversation with deep knowledge to provide you with the best assistance possible.',
  '{"temperature": 0.7, "creativity": "balanced", "formality": 0.5}'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM ai_personalities WHERE is_master = true);

-- Function to create user personality from master template
CREATE OR REPLACE FUNCTION create_user_personality_from_master(p_user_id UUID)
RETURNS ai_personalities AS $$
DECLARE
  v_master RECORD;
  v_new_personality ai_personalities;
BEGIN
  -- Get the master template
  SELECT * INTO v_master
  FROM ai_personalities
  WHERE is_master = true;

  -- If no master exists, create with defaults
  IF v_master IS NULL THEN
    INSERT INTO ai_personalities (
      user_id, is_master, ai_name, personality, humor_level,
      communication_style, response_length, expertise
    ) VALUES (
      p_user_id, false, 'HowAI', 'friendly', 'dry',
      'tech-savvy', 'moderate', 'general'
    ) RETURNING * INTO v_new_personality;
  ELSE
    -- Copy from master template
    INSERT INTO ai_personalities (
      user_id,
      is_master,
      ai_name,
      personality,
      humor_level,
      communication_style,
      response_length,
      expertise,
      interests,
      background_story,
      custom_settings
    ) VALUES (
      p_user_id,
      false, -- User personality, not master
      v_master.ai_name,
      v_master.personality,
      v_master.humor_level,
      v_master.communication_style,
      v_master.response_length,
      v_master.expertise,
      v_master.interests,
      v_master.background_story,
      v_master.custom_settings
    ) RETURNING * INTO v_new_personality;
  END IF;

  RETURN v_new_personality;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to reset user personality to master defaults
CREATE OR REPLACE FUNCTION reset_user_personality_to_master(p_user_id UUID)
RETURNS ai_personalities AS $$
DECLARE
  v_master RECORD;
  v_updated_personality ai_personalities;
BEGIN
  -- Get the master template
  SELECT * INTO v_master
  FROM ai_personalities
  WHERE is_master = true;

  IF v_master IS NULL THEN
    RAISE EXCEPTION 'No master personality template found';
  END IF;

  -- Update user's personality to match master
  UPDATE ai_personalities
  SET
    ai_name = v_master.ai_name,
    personality = v_master.personality,
    humor_level = v_master.humor_level,
    communication_style = v_master.communication_style,
    response_length = v_master.response_length,
    expertise = v_master.expertise,
    interests = v_master.interests,
    background_story = v_master.background_story,
    custom_settings = v_master.custom_settings,
    updated_at = NOW()
  WHERE user_id = p_user_id AND is_master = false
  RETURNING * INTO v_updated_personality;

  RETURN v_updated_personality;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update RLS policies to exclude master from user queries
DROP POLICY IF EXISTS "Users can view own AI personality" ON ai_personalities;
CREATE POLICY "Users can view own AI personality" ON ai_personalities
  FOR SELECT USING (auth.uid() = user_id AND is_master = false);

DROP POLICY IF EXISTS "Users can update own AI personality" ON ai_personalities;
CREATE POLICY "Users can update own AI personality" ON ai_personalities
  FOR UPDATE USING (auth.uid() = user_id AND is_master = false);

DROP POLICY IF EXISTS "Users can create own AI personality" ON ai_personalities;
CREATE POLICY "Users can create own AI personality" ON ai_personalities
  FOR INSERT WITH CHECK (auth.uid() = user_id AND is_master = false);

-- Allow authenticated users to view master template
CREATE POLICY "All users can view master personality" ON ai_personalities
  FOR SELECT USING (is_master = true);

-- Migration: Create personalities for existing users based on master template
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Loop through all users without AI personality
  FOR v_user_id IN
    SELECT id FROM profiles
    WHERE id NOT IN (
      SELECT user_id FROM ai_personalities
      WHERE user_id IS NOT NULL
    )
  LOOP
    -- Create personality from master template
    PERFORM create_user_personality_from_master(v_user_id);
  END LOOP;
END $$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION create_user_personality_from_master TO authenticated;
GRANT EXECUTE ON FUNCTION reset_user_personality_to_master TO authenticated;

-- View to easily see user personalities with master comparison
CREATE OR REPLACE VIEW user_personality_status AS
SELECT
  p.id as user_id,
  p.email,
  ap.ai_name,
  ap.personality,
  ap.humor_level,
  ap.communication_style,
  ap.updated_at,
  CASE
    WHEN ap.id IS NULL THEN 'No personality'
    WHEN ap.updated_at > COALESCE(m.updated_at, '1970-01-01'::timestamptz) THEN 'Customized'
    ELSE 'Using defaults'
  END as status
FROM profiles p
LEFT JOIN ai_personalities ap ON p.id = ap.user_id AND ap.is_master = false
LEFT JOIN ai_personalities m ON m.is_master = true;

-- Verify the setup
SELECT
  'Master personality created' as status,
  ai_name,
  personality,
  humor_level
FROM ai_personalities
WHERE is_master = true;