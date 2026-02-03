-- User Profile Enhancement for HaoGPT Web
-- This schema adds user profiling and preference tracking capabilities

-- User profile preferences and characteristics
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,

  -- Language preferences
  preferred_language TEXT DEFAULT 'en',
  detected_languages TEXT[],

  -- Communication style (JSON object)
  communication_style JSONB DEFAULT '{}',
  -- Structure: {"formality": "casual|formal|mixed", "detail_level": "concise|detailed|balanced", "humor": boolean, "technical_level": "beginner|intermediate|advanced"}

  -- Topic interests (weighted by frequency and recency, scores 0-1)
  topic_interests JSONB DEFAULT '{}',
  -- Example: {"technology": 0.8, "finance": 0.6, "health": 0.3, "ai": 0.9}

  -- User characteristics (JSON object)
  characteristics JSONB DEFAULT '{}',
  -- Structure: {"profession": "developer", "expertise": ["python", "react", "ai"], "learning_goals": ["machine learning", "cloud"], "personality_traits": ["curious", "analytical"]}

  -- Behavioral patterns (JSON object)
  behavioral_patterns JSONB DEFAULT '{}',
  -- Structure: {"avg_message_length": 45, "question_types": {"technical": 0.6, "creative": 0.2, "informational": 0.2}, "interaction_times": {"morning": 0.3, "afternoon": 0.5, "evening": 0.2}}

  -- User preferences (JSON object)
  preferences JSONB DEFAULT '{}',
  -- Structure: {"prefers_examples": true, "likes_detailed_explanations": false, "wants_sources": true, "prefers_visual_content": true, "code_style": "verbose"}

  -- AI-generated profile summary (2-3 sentences about the user)
  profile_summary TEXT,
  last_summary_update TIMESTAMPTZ,

  -- Statistics and metadata
  message_count INTEGER DEFAULT 0,
  total_conversations INTEGER DEFAULT 0,
  last_analyzed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Profile evaluation logs (tracks when and how profiles are updated)
CREATE TABLE IF NOT EXISTS profile_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,

  -- Evaluation metadata
  messages_analyzed INTEGER,
  evaluation_type TEXT CHECK (evaluation_type IN ('periodic', 'conversation_end', 'manual', 'initial')),

  -- Extracted insights (JSON object)
  insights JSONB,
  -- Structure: {"new_interests": ["cloud computing", "docker"], "style_changes": {"formality": "more casual"}, "learned_facts": ["uses Python", "interested in ML"], "sentiment_trend": "positive", "engagement_level": 8}

  -- Changes applied to profile (JSON object showing before/after values)
  profile_changes JSONB,

  -- Performance metrics
  processing_time_ms INTEGER,
  model_used TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User feedback on AI responses (helps improve personalization)
CREATE TABLE IF NOT EXISTS message_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Feedback type
  feedback_type TEXT CHECK (feedback_type IN ('helpful', 'not_helpful', 'too_detailed', 'too_brief', 'off_topic', 'perfect')),

  -- Optional feedback text
  feedback_text TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_updated_at ON user_profiles(updated_at);
CREATE INDEX IF NOT EXISTS idx_profile_evaluations_user_id ON profile_evaluations(user_id);
CREATE INDEX IF NOT EXISTS idx_profile_evaluations_conversation_id ON profile_evaluations(conversation_id);
CREATE INDEX IF NOT EXISTS idx_profile_evaluations_created_at ON profile_evaluations(created_at);
CREATE INDEX IF NOT EXISTS idx_message_feedback_message_id ON message_feedback(message_id);
CREATE INDEX IF NOT EXISTS idx_message_feedback_user_id ON message_feedback(user_id);

-- Update trigger for user_profiles
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security for new tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_feedback ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view own user profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own user profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Profile evaluations policies
CREATE POLICY "Users can view own evaluations" ON profile_evaluations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert evaluations" ON profile_evaluations
  FOR INSERT WITH CHECK (true);

-- Message feedback policies
CREATE POLICY "Users can view own feedback" ON message_feedback
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own feedback" ON message_feedback
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own feedback" ON message_feedback
  FOR UPDATE USING (auth.uid() = user_id);

-- Function to initialize user profile after first message
CREATE OR REPLACE FUNCTION initialize_user_profile()
RETURNS TRIGGER AS $$
DECLARE
  v_user_id UUID;
  v_profile_exists BOOLEAN;
BEGIN
  -- Get the user_id from the conversation
  SELECT user_id INTO v_user_id
  FROM conversations
  WHERE id = NEW.conversation_id;

  -- Check if profile already exists
  SELECT EXISTS(
    SELECT 1 FROM user_profiles WHERE user_id = v_user_id
  ) INTO v_profile_exists;

  -- Create profile if it doesn't exist
  IF NOT v_profile_exists AND NOT NEW.is_ai THEN
    INSERT INTO user_profiles (user_id, message_count, total_conversations)
    VALUES (v_user_id, 1, 1)
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on first message
CREATE TRIGGER on_first_message_create_profile
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION initialize_user_profile();

-- Function to get user profile context for AI
CREATE OR REPLACE FUNCTION get_user_profile_context(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
  v_profile RECORD;
  v_context TEXT;
BEGIN
  SELECT * INTO v_profile
  FROM user_profiles
  WHERE user_id = p_user_id;

  IF v_profile IS NULL THEN
    RETURN '';
  END IF;

  v_context := '';

  -- Add profile summary if exists
  IF v_profile.profile_summary IS NOT NULL THEN
    v_context := v_context || 'User Profile: ' || v_profile.profile_summary || E'\n';
  END IF;

  -- Add language preference
  IF v_profile.preferred_language IS NOT NULL AND v_profile.preferred_language != 'en' THEN
    v_context := v_context || 'Preferred Language: ' || v_profile.preferred_language || E'\n';
  END IF;

  -- Add communication style
  IF v_profile.communication_style IS NOT NULL AND v_profile.communication_style != '{}' THEN
    v_context := v_context || 'Communication Style: ' || v_profile.communication_style::TEXT || E'\n';
  END IF;

  -- Add top interests
  IF v_profile.topic_interests IS NOT NULL AND v_profile.topic_interests != '{}' THEN
    v_context := v_context || 'Interests: ' || v_profile.topic_interests::TEXT || E'\n';
  END IF;

  RETURN v_context;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_profile_context TO authenticated;