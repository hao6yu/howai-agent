-- Supabase Schema Updates for Flutter Integration
-- Run these SQL commands in your Supabase SQL Editor

-- 1. Add gender and age fields to ai_personalities table
ALTER TABLE ai_personalities 
ADD COLUMN IF NOT EXISTS gender TEXT DEFAULT 'neutral',
ADD COLUMN IF NOT EXISTS age INTEGER DEFAULT 25;

-- 2. Remove user_id UNIQUE constraint from ai_personalities
-- (Allows multiple AI personalities per user)
ALTER TABLE ai_personalities 
DROP CONSTRAINT IF EXISTS ai_personalities_user_id_key;

-- 3. Create subscription_status table for tracking IAP across devices
CREATE TABLE IF NOT EXISTS subscription_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  platform TEXT NOT NULL, -- 'ios', 'android', 'web'
  subscription_type TEXT NOT NULL, -- 'premium', 'pro', etc.
  is_active BOOLEAN DEFAULT FALSE,
  purchase_token TEXT, -- Platform-specific purchase token
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, platform)
);

-- 4. Create usage_statistics table for tracking feature usage limits
CREATE TABLE IF NOT EXISTS usage_statistics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  feature_name TEXT NOT NULL, -- 'image_generation', 'voice_chat', etc.
  usage_count INTEGER DEFAULT 0,
  last_reset_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, feature_name)
);

-- 5. Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_subscription_status_user_id ON subscription_status(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_status_active ON subscription_status(is_active);
CREATE INDEX IF NOT EXISTS idx_usage_statistics_user_id ON usage_statistics(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_personalities_user_id ON ai_personalities(user_id);

-- 6. Add RLS (Row Level Security) policies for new tables
ALTER TABLE subscription_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_statistics ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own subscription status
CREATE POLICY "Users can view own subscription status"
  ON subscription_status FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can update their own subscription status
CREATE POLICY "Users can update own subscription status"
  ON subscription_status FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own subscription status
CREATE POLICY "Users can insert own subscription status"
  ON subscription_status FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only read their own usage statistics
CREATE POLICY "Users can view own usage statistics"
  ON usage_statistics FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can update their own usage statistics
CREATE POLICY "Users can update own usage statistics"
  ON usage_statistics FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own usage statistics
CREATE POLICY "Users can insert own usage statistics"
  ON usage_statistics FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 7. Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Add triggers for automatic timestamp updates
CREATE TRIGGER update_subscription_status_updated_at
  BEFORE UPDATE ON subscription_status
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_usage_statistics_updated_at
  BEFORE UPDATE ON usage_statistics
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Success message
SELECT 'Supabase schema migration completed successfully!' AS status;

