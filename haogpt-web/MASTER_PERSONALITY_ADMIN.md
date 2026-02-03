# Master AI Personality Template Management

## Overview

The system now uses a **master/default AI personality template** that all new user personalities are based on. This allows you to:

1. **Centrally manage defaults** - Update the master template to change defaults for new users
2. **Consistent experience** - All new users start with the same personality
3. **Easy updates** - Change the master template without affecting existing customized users

## Database Structure

### Master Template
- Stored in `ai_personalities` table with `is_master = true` and `user_id = NULL`
- Only one master template can exist (enforced by unique constraint)
- All authenticated users can read the master template
- Only database admins can modify it (through SQL)

### User Personalities
- Each user has their own personality record with `is_master = false`
- Created automatically by copying from master template
- Users can customize their own personality

## Managing the Master Template

### View Current Master Template
```sql
SELECT * FROM ai_personalities WHERE is_master = true;
```

### Update Master Template
```sql
UPDATE ai_personalities
SET
  ai_name = 'HowAI',
  personality = 'friendly',
  humor_level = 'dry',
  communication_style = 'tech-savvy',
  response_length = 'moderate',
  expertise = 'general',
  interests = 'Technology, AI, Programming, Science, Arts, Business',
  background_story = 'Your new background story here...',
  updated_at = NOW()
WHERE is_master = true;
```

### Reset All Users to Master (Optional - Use Carefully!)
```sql
-- This will reset ALL user personalities to master defaults
-- Only use if you want to force reset everyone
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  FOR v_user_id IN SELECT user_id FROM ai_personalities WHERE is_master = false
  LOOP
    PERFORM reset_user_personality_to_master(v_user_id);
  END LOOP;
END $$;
```

## How It Works

### New User Flow
1. User sends first message or opens settings
2. System checks for existing personality → Not found
3. System fetches master template
4. Creates new user personality by copying master values
5. User can then customize their personality

### Existing User Flow
- Existing users keep their current personalities
- They can reset to master defaults using the "Reset" button
- Their customizations are preserved unless they explicitly reset

## Migration for Existing Database

Run the migration SQL to set up the master template system:

```bash
# In Supabase SQL editor
1. Run: ai-personality-master-schema.sql
```

This will:
1. Modify the table structure to support master template
2. Create the master personality record
3. Create helper functions
4. Update RLS policies
5. Automatically create personalities for existing users

## Benefits

1. **Consistency** - All users start with the same high-quality defaults
2. **Maintainability** - Update defaults in one place
3. **Flexibility** - Users can still customize their personality
4. **Scalability** - New users automatically get the latest defaults
5. **Control** - Admin can update master template as AI capabilities evolve

## Admin Interface (Future Enhancement)

You could create an admin interface to manage the master template:

```typescript
// Example admin component
import { useState } from 'react'

export function MasterPersonalityAdmin() {
  const [master, setMaster] = useState<AIPersonalityConfig>()

  const loadMaster = async () => {
    const { data } = await supabase
      .from('ai_personalities')
      .select('*')
      .eq('is_master', true)
      .single()
    setMaster(data)
  }

  const updateMaster = async () => {
    // Note: This requires special admin privileges
    const { error } = await supabase
      .from('ai_personalities')
      .update(master)
      .eq('is_master', true)
  }

  // Admin UI here...
}
```

## Best Practices

1. **Test changes** - Always test master template changes with a test user first
2. **Document changes** - Keep a changelog of master template updates
3. **Gradual rollout** - Consider feature flags for major personality changes
4. **User communication** - Notify users when significant defaults change
5. **Backup** - Always backup the master template before major changes

## Monitoring

Track how users customize from defaults:

```sql
-- See how many users have customized their personality
SELECT
  COUNT(*) FILTER (WHERE ap.updated_at > m.updated_at) as customized_count,
  COUNT(*) FILTER (WHERE ap.updated_at <= m.updated_at) as using_defaults,
  COUNT(*) FILTER (WHERE ap.id IS NULL) as no_personality
FROM profiles p
LEFT JOIN ai_personalities ap ON p.id = ap.user_id AND ap.is_master = false
LEFT JOIN ai_personalities m ON m.is_master = true;
```

## Troubleshooting

### If master template is missing:
```sql
-- Recreate master template
INSERT INTO ai_personalities (
  user_id, is_master, ai_name, personality, humor_level,
  communication_style, response_length, expertise
) VALUES (
  NULL, true, 'HowAI', 'friendly', 'dry',
  'tech-savvy', 'moderate', 'general'
) ON CONFLICT (is_master) WHERE is_master = true DO NOTHING;
```

### Check user personality status:
```sql
-- View user personality status
SELECT * FROM user_personality_status WHERE email = 'user@example.com';
```