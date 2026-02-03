import { createClient } from '@/lib/supabase-server'
import OpenAI from 'openai'

interface UserProfile {
  id?: string
  user_id: string
  preferred_language: string
  detected_languages: string[]
  communication_style: {
    formality?: 'formal' | 'casual' | 'mixed'
    detail_level?: 'concise' | 'detailed' | 'balanced'
    humor?: boolean
    technical_level?: 'beginner' | 'intermediate' | 'advanced'
  }
  topic_interests: Record<string, number>
  characteristics: {
    profession?: string
    expertise?: string[]
    learning_goals?: string[]
    personality_traits?: string[]
  }
  behavioral_patterns: {
    avg_message_length?: number
    question_types?: Record<string, number>
    interaction_times?: Record<string, number>
    response_preferences?: string[]
  }
  preferences: {
    prefers_examples?: boolean
    likes_detailed_explanations?: boolean
    wants_sources?: boolean
    prefers_visual_content?: boolean
    code_style?: string
  }
  profile_summary?: string
  last_summary_update?: string | Date
  message_count: number
  last_analyzed_at?: string | Date
}

interface ProfileInsights {
  new_interests?: string[]
  style_changes?: Record<string, any>
  learned_facts?: string[]
  sentiment_trend?: string
  engagement_level?: number
}

export class UserProfileService {
  private static readonly EVALUATION_INTERVAL = 5 // Evaluate every N messages
  private static readonly MIN_MESSAGES_FOR_EVALUATION = 3

  /**
   * Get or create user profile
   */
  static async getOrCreateProfile(userId: string): Promise<UserProfile> {
    const supabase = createClient()

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', userId)
      .single()

    if (profile) {
      return profile
    }

    // Create new profile
    const newProfile: Partial<UserProfile> = {
      user_id: userId,
      preferred_language: 'en',
      detected_languages: [],
      communication_style: {},
      topic_interests: {},
      characteristics: {},
      behavioral_patterns: {},
      preferences: {},
      message_count: 0
    }

    const { data: created, error } = await supabase
      .from('user_profiles')
      .insert(newProfile)
      .select()
      .single()

    if (error) {
      console.error('Error creating user profile:', error)
      return newProfile as UserProfile
    }

    return created
  }

  /**
   * Check if profile evaluation is needed
   */
  static async shouldEvaluateProfile(userId: string, messageCount: number): Promise<boolean> {
    const profile = await this.getOrCreateProfile(userId)

    // Check if enough messages have passed since last evaluation
    const messagesSinceLastEvaluation = messageCount - (profile.message_count || 0)

    return messagesSinceLastEvaluation >= this.EVALUATION_INTERVAL &&
           messagesSinceLastEvaluation >= this.MIN_MESSAGES_FOR_EVALUATION
  }

  /**
   * Evaluate and update user profile based on conversation history
   */
  static async evaluateAndUpdateProfile(
    userId: string,
    conversationId: string,
    recentMessages: Array<{ content: string; is_ai: boolean; created_at: string }>
  ): Promise<ProfileInsights | null> {
    if (!process.env.OPENAI_API_KEY) {
      console.error('OpenAI API key not configured')
      return null
    }

    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
    const supabase = createClient()

    try {
      // Get current profile
      const profile = await this.getOrCreateProfile(userId)

      // Prepare messages for analysis
      const userMessages = recentMessages
        .filter(msg => !msg.is_ai)
        .map(msg => msg.content)
        .join('\n---\n')

      // Analyze user characteristics and preferences
      const analysisPrompt = `Analyze the following user messages to extract profile characteristics and preferences.

Current Profile Summary: ${profile.profile_summary || 'New user, no prior summary'}

User Messages:
${userMessages}

Extract and return a JSON object with the following structure:
{
  "language": "detected primary language code (e.g., 'en', 'es', 'zh')",
  "communication_style": {
    "formality": "formal|casual|mixed",
    "detail_level": "concise|detailed|balanced",
    "humor": true|false,
    "technical_level": "beginner|intermediate|advanced"
  },
  "topics": ["array of topics discussed with relevance 0-1"],
  "characteristics": {
    "profession": "inferred profession if mentioned",
    "expertise": ["areas of expertise"],
    "learning_goals": ["what they want to learn"],
    "personality_traits": ["observed traits"]
  },
  "preferences": {
    "prefers_examples": true|false,
    "likes_detailed_explanations": true|false,
    "wants_sources": true|false,
    "prefers_visual_content": true|false
  },
  "behavioral_patterns": {
    "question_types": "technical|creative|informational|mixed",
    "engagement_level": 0-10
  },
  "summary": "A 2-3 sentence summary of the user's profile and how to best assist them"
}

Be concise and only include characteristics you're confident about based on the messages.`

      const completion = await openai.chat.completions.create({
        model: process.env.OPENAI_PROFILE_MODEL || 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'You are a user profile analyzer. Extract user characteristics from their messages.' },
          { role: 'user', content: analysisPrompt }
        ],
        response_format: { type: 'json_object' },
        max_tokens: 800
      })

      const analysis = JSON.parse(completion.choices[0]?.message?.content || '{}')

      // Calculate topic interest scores (decay old interests, boost new ones)
      const updatedTopicInterests = { ...profile.topic_interests }

      // Decay existing interests
      Object.keys(updatedTopicInterests).forEach(topic => {
        updatedTopicInterests[topic] *= 0.9
      })

      // Boost current topics
      if (analysis.topics) {
        analysis.topics.forEach((topic: string) => {
          if (!updatedTopicInterests[topic]) {
            updatedTopicInterests[topic] = 0
          }
          updatedTopicInterests[topic] = Math.min(1, updatedTopicInterests[topic] + 0.2)
        })
      }

      // Update message count
      const newMessageCount = profile.message_count + recentMessages.filter(m => !m.is_ai).length

      // Merge with existing profile
      const updatedProfile: Partial<UserProfile> = {
        preferred_language: analysis.language || profile.preferred_language,
        detected_languages: Array.from(new Set([
          ...(profile.detected_languages || []),
          analysis.language
        ].filter(Boolean))),
        communication_style: {
          ...profile.communication_style,
          ...analysis.communication_style
        },
        topic_interests: updatedTopicInterests,
        characteristics: {
          ...profile.characteristics,
          ...analysis.characteristics
        },
        preferences: {
          ...profile.preferences,
          ...analysis.preferences
        },
        behavioral_patterns: {
          ...profile.behavioral_patterns,
          avg_message_length: userMessages.length / recentMessages.filter(m => !m.is_ai).length,
          question_types: analysis.behavioral_patterns?.question_types
        },
        profile_summary: analysis.summary || profile.profile_summary,
        last_summary_update: new Date().toISOString(),
        message_count: newMessageCount,
        last_analyzed_at: new Date().toISOString()
      }

      // Update profile in database
      const { error: updateError } = await supabase
        .from('user_profiles')
        .update(updatedProfile)
        .eq('user_id', userId)

      if (updateError) {
        console.error('Error updating user profile:', updateError)
      }

      // Log evaluation
      const insights: ProfileInsights = {
        new_interests: analysis.topics || [],
        style_changes: analysis.communication_style,
        learned_facts: analysis.characteristics?.expertise || [],
        engagement_level: analysis.behavioral_patterns?.engagement_level
      }

      await supabase
        .from('profile_evaluations')
        .insert({
          user_id: userId,
          conversation_id: conversationId,
          messages_analyzed: recentMessages.length,
          evaluation_type: 'periodic',
          insights,
          profile_changes: updatedProfile
        })

      console.log(`[Profile Service] Updated profile for user ${userId}`)
      return insights

    } catch (error) {
      console.error('Error evaluating user profile:', error)
      return null
    }
  }

  /**
   * Get profile summary for AI context
   */
  static async getProfileContext(userId: string): Promise<string> {
    const profile = await this.getOrCreateProfile(userId)

    if (!profile.profile_summary && profile.message_count < 5) {
      return ''
    }

    const context: string[] = []

    // Add profile summary
    if (profile.profile_summary) {
      context.push(`User Profile: ${profile.profile_summary}`)
    }

    // Add language preference
    if (profile.preferred_language && profile.preferred_language !== 'en') {
      context.push(`Preferred Language: ${profile.preferred_language}`)
    }

    // Add communication style
    if (profile.communication_style?.formality) {
      context.push(`Communication Style: ${profile.communication_style.formality} tone, ${profile.communication_style.detail_level || 'balanced'} detail`)
    }

    // Add top interests
    const topInterests = Object.entries(profile.topic_interests || {})
      .filter(([_, score]) => score > 0.5)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([topic]) => topic)

    if (topInterests.length > 0) {
      context.push(`Main Interests: ${topInterests.join(', ')}`)
    }

    // Add preferences
    const prefs: string[] = []
    if (profile.preferences?.prefers_examples) prefs.push('provide examples')
    if (profile.preferences?.likes_detailed_explanations) prefs.push('detailed explanations')
    if (profile.preferences?.wants_sources) prefs.push('include sources')
    if (profile.preferences?.prefers_visual_content) prefs.push('visual content when possible')

    if (prefs.length > 0) {
      context.push(`Preferences: ${prefs.join(', ')}`)
    }

    return context.join('\n')
  }

  /**
   * Format profile characteristics for AI personality service
   */
  static formatCharacteristicsForAI(profile: UserProfile): string {
    const parts: string[] = []

    if (profile.characteristics?.profession) {
      parts.push(`Works as: ${profile.characteristics.profession}`)
    }

    if (profile.characteristics?.expertise && profile.characteristics.expertise.length > 0) {
      parts.push(`Expert in: ${profile.characteristics.expertise.join(', ')}`)
    }

    if (profile.communication_style?.technical_level) {
      parts.push(`Technical level: ${profile.communication_style.technical_level}`)
    }

    if (profile.profile_summary) {
      parts.push(profile.profile_summary)
    }

    return parts.join('. ')
  }
}