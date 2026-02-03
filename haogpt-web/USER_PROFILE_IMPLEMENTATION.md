# User Profile & Preference Tracking Implementation

## Overview
This implementation adds intelligent user profiling and preference tracking to HaoGPT Web, automatically learning from conversations to personalize AI responses.

## Features Implemented

### 1. **Automatic Profile Learning**
- Evaluates user preferences every 10 messages
- Analyzes communication style, topics of interest, and behavioral patterns
- Updates profile without user intervention

### 2. **Profile Components Tracked**
- **Language**: Preferred language and detected languages
- **Communication Style**: Formality level, detail preference, humor, technical expertise
- **Topic Interests**: Weighted interests with decay over time
- **User Characteristics**: Profession, expertise areas, learning goals
- **Behavioral Patterns**: Message length, question types, interaction times
- **Preferences**: Examples, detail level, sources, visual content

### 3. **Contextual AI Responses**
- AI receives user profile context with each request
- Responses adapt to user's communication style
- Topic expertise adjusts based on user's technical level

### 4. **Feedback System**
- Users can provide feedback on AI responses
- Feedback automatically adjusts profile preferences
- Options: helpful, not_helpful, too_detailed, too_brief, off_topic, perfect

## Database Schema

### New Tables Created:
1. **user_profiles** - Stores comprehensive user profile data
2. **profile_evaluations** - Logs profile evaluation history
3. **message_feedback** - Captures user feedback on messages

Run the SQL schema:
```bash
# Execute in Supabase SQL editor
cat user-profile-schema.sql
```

## API Endpoints

### Profile Management
- `GET /api/profile` - Get current user's profile
- `POST /api/profile/evaluate` - Manually trigger profile evaluation
- `POST /api/profile/feedback` - Submit message feedback

## Implementation Details

### Profile Evaluation Trigger Points:
1. **Automatic**: Every 10 messages in a conversation
2. **Manual**: Via API endpoint
3. **Conversation End**: Optional trigger on conversation completion

### Profile Context Integration:
The AI receives user context in this format:
```
User Profile: [2-3 sentence summary]
Preferred Language: [if not English]
Communication Style: [formality, detail level]
Main Interests: [top 3 topics]
Preferences: [examples, explanations, sources]
```

### Adaptive Behavior:
- **For Technical Users**: More detailed technical explanations, code examples
- **For Casual Users**: Simpler language, more analogies
- **For Visual Learners**: Prioritizes image generation when appropriate
- **For Research-Oriented**: Includes more sources and references

## Configuration

### Environment Variables:
```env
OPENAI_PROFILE_MODEL=gpt-4o-mini  # Model for profile analysis
OPENAI_TITLE_GEN_MODEL=gpt-4o-mini  # Model for title generation
```

## Usage Example

### Profile Evaluation Flow:
1. User sends messages in conversation
2. System counts messages since last evaluation
3. At 10-message threshold, triggers background evaluation
4. Profile updates with new insights
5. Next AI response uses updated profile context

### Frontend Integration (Optional):
```typescript
// Show when profile was updated
if (response.profileUpdated) {
  showNotification('Your preferences have been updated')
}

// Display user interests
const profile = await fetch('/api/profile')
displayUserInterests(profile.topic_interests)
```

## Privacy & Security

- All profile data is user-specific with RLS policies
- Users can only access their own profiles
- Profile evaluation runs server-side only
- No profile data is shared between users

## Testing the Implementation

1. **Start a new conversation** - Profile will be created automatically
2. **Send 10+ messages** - Profile evaluation will trigger
3. **Check profile context** - View how AI adapts to your style
4. **Provide feedback** - Use feedback API to refine preferences

## Future Enhancements

### Potential Improvements:
- Export/import user profiles
- Profile versioning and rollback
- Cross-conversation learning
- Sentiment analysis integration
- Time-of-day preference tracking
- Multi-language profile summaries
- Profile sharing between devices
- Advanced personality insights

## Monitoring

### Key Metrics to Track:
- Profile evaluation frequency
- Feedback submission rates
- Profile accuracy (via user feedback)
- Response personalization effectiveness

## Troubleshooting

### Common Issues:
1. **Profile not updating**: Check message count threshold
2. **Context not applied**: Verify profile exists in database
3. **Evaluation failing**: Check OpenAI API key and model availability

## Benefits

1. **Personalized Experience**: Each user gets tailored responses
2. **Improved Relevance**: AI understands user's expertise level
3. **Better Engagement**: Responses match communication preferences
4. **Learning System**: Continuously improves with usage
5. **Reduced Friction**: No manual preference configuration needed