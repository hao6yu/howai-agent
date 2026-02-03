-- AI Personality Configuration for HaoGPT Web
-- This schema adds manual AI personality customization per user

-- AI personality settings table (one per user)
CREATE TABLE IF NOT EXISTS ai_personalities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE UNIQUE, -- One personality per user

  -- Basic settings
  ai_name TEXT DEFAULT 'HowAI',
  avatar_url TEXT,

  -- Personality configuration
  personality TEXT CHECK (personality IN ('friendly', 'professional', 'witty', 'caring', 'energetic')) DEFAULT 'friendly',
  humor_level TEXT CHECK (humor_level IN ('none', 'light', 'dry', 'moderate', 'heavy')) DEFAULT 'dry',
  communication_style TEXT CHECK (communication_style IN ('casual', 'formal', 'tech-savvy', 'supportive')) DEFAULT 'tech-savvy',
  response_length TEXT CHECK (response_length IN ('concise', 'moderate', 'detailed')) DEFAULT 'moderate',
  expertise TEXT CHECK (expertise IN ('general', 'technology', 'business', 'creative', 'academic')) DEFAULT 'general',

  -- Extended configuration
  interests TEXT, -- User-defined interests and hobbies
  background_story TEXT, -- Optional background story for the AI

  -- Custom parameters (JSON for flexibility)
  custom_settings JSONB DEFAULT '{}',
  -- Can store additional settings like: {"temperature": 0.7, "creativity": "high", "formality": 0.5}

  -- Metadata
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for quick user lookup
CREATE INDEX IF NOT EXISTS idx_ai_personalities_user_id ON ai_personalities(user_id);

-- Update trigger for updated_at
CREATE TRIGGER update_ai_personalities_updated_at
  BEFORE UPDATE ON ai_personalities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE ai_personalities ENABLE ROW LEVEL SECURITY;

-- Users can only view their own AI personality
CREATE POLICY "Users can view own AI personality" ON ai_personalities
  FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own AI personality
CREATE POLICY "Users can create own AI personality" ON ai_personalities
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own AI personality
CREATE POLICY "Users can update own AI personality" ON ai_personalities
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own AI personality
CREATE POLICY "Users can delete own AI personality" ON ai_personalities
  FOR DELETE USING (auth.uid() = user_id);

-- Function to merge AI personality with learned profile
CREATE OR REPLACE FUNCTION get_merged_ai_context(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
  v_personality RECORD;
  v_profile RECORD;
  v_context TEXT;
BEGIN
  -- Get manual AI personality settings
  SELECT * INTO v_personality
  FROM ai_personalities
  WHERE user_id = p_user_id AND is_active = true;

  -- Get learned user profile
  SELECT * INTO v_profile
  FROM user_profiles
  WHERE user_id = p_user_id;

  v_context := '';

  -- Add AI name if customized
  IF v_personality.ai_name IS NOT NULL AND v_personality.ai_name != 'HaoGPT Assistant' THEN
    v_context := v_context || 'Your name is: ' || v_personality.ai_name || E'\n';
  END IF;

  -- Add personality traits
  IF v_personality IS NOT NULL THEN
    v_context := v_context || 'Personality Configuration:' || E'\n';
    v_context := v_context || '- Personality: ' || v_personality.personality || E'\n';
    v_context := v_context || '- Humor Level: ' || v_personality.humor_level || E'\n';
    v_context := v_context || '- Communication: ' || v_personality.communication_style || E'\n';
    v_context := v_context || '- Response Length: ' || v_personality.response_length || E'\n';
    v_context := v_context || '- Expertise: ' || v_personality.expertise || E'\n';

    IF v_personality.interests IS NOT NULL AND v_personality.interests != '' THEN
      v_context := v_context || '- Interests: ' || v_personality.interests || E'\n';
    END IF;

    IF v_personality.background_story IS NOT NULL AND v_personality.background_story != '' THEN
      v_context := v_context || '- Background: ' || v_personality.background_story || E'\n';
    END IF;
  END IF;

  -- Add learned profile context if exists
  IF v_profile IS NOT NULL AND v_profile.profile_summary IS NOT NULL THEN
    v_context := v_context || E'\nLearned User Preferences:' || E'\n';
    v_context := v_context || v_profile.profile_summary || E'\n';

    -- Merge topic interests from learned profile
    IF v_profile.topic_interests IS NOT NULL AND v_profile.topic_interests != '{}' THEN
      v_context := v_context || 'User Interests: ' || v_profile.topic_interests::TEXT || E'\n';
    END IF;
  END IF;

  RETURN v_context;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_merged_ai_context TO authenticated;

-- Sample data for testing (optional)
-- INSERT INTO ai_personalities (user_id, ai_name, personality, humor_level, communication_style, expertise, interests)
-- VALUES
-- ('user-uuid-here', 'Tech Buddy', 'witty', 'dry', 'tech-savvy', 'technology', 'Programming, AI, Gaming, Science Fiction');