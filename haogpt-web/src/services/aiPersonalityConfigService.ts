import { createClient } from '@/lib/supabase-server'

export interface AIPersonalityConfig {
  id?: string
  user_id: string
  ai_name: string
  avatar_url?: string
  personality: 'friendly' | 'professional' | 'witty' | 'caring' | 'energetic'
  humor_level: 'none' | 'light' | 'dry' | 'moderate' | 'heavy'
  communication_style: 'casual' | 'formal' | 'tech-savvy' | 'supportive'
  response_length: 'concise' | 'moderate' | 'detailed'
  expertise: 'general' | 'technology' | 'business' | 'creative' | 'academic'
  interests?: string
  background_story?: string
  custom_settings?: Record<string, any>
  is_active?: boolean
}

export class AIPersonalityConfigService {
  /**
   * Get or create AI personality configuration for a user
   */
  static async getOrCreatePersonality(userId: string): Promise<AIPersonalityConfig> {
    const supabase = createClient()

    // Try to get existing personality
    const { data: personality } = await supabase
      .from('ai_personalities')
      .select('*')
      .eq('user_id', userId)
      .eq('is_active', true)
      .single()

    if (personality) {
      return personality
    }

    // Get master template to copy from
    const { data: masterPersonality } = await supabase
      .from('ai_personalities')
      .select('*')
      .eq('is_master', true)
      .single()

    if (masterPersonality) {
      // Create from master template
      const newPersonality: Partial<AIPersonalityConfig> = {
        user_id: userId,
        ai_name: masterPersonality.ai_name,
        personality: masterPersonality.personality,
        humor_level: masterPersonality.humor_level,
        communication_style: masterPersonality.communication_style,
        response_length: masterPersonality.response_length,
        expertise: masterPersonality.expertise,
        interests: masterPersonality.interests,
        background_story: masterPersonality.background_story,
        custom_settings: masterPersonality.custom_settings || {},
        is_active: true
      }

      const { data: created, error } = await supabase
        .from('ai_personalities')
        .insert(newPersonality)
        .select()
        .single()

      if (error) {
        console.error('Error creating AI personality from master:', error)
        // Fallback to hardcoded defaults if database fails
        return {
          ...newPersonality,
          ai_name: 'HowAI',
          personality: 'friendly',
          humor_level: 'dry',
          communication_style: 'tech-savvy',
          response_length: 'moderate',
          expertise: 'general'
        } as AIPersonalityConfig
      }

      return created
    } else {
      // Fallback: Create with hardcoded defaults if no master exists
      const defaultPersonality: Partial<AIPersonalityConfig> = {
        user_id: userId,
        ai_name: 'HowAI',
        personality: 'friendly',
        humor_level: 'dry',
        communication_style: 'tech-savvy',
        response_length: 'moderate',
        expertise: 'general',
        interests: '',
        background_story: '',
        custom_settings: {},
        is_active: true
      }

      const { data: created, error } = await supabase
        .from('ai_personalities')
        .insert(defaultPersonality)
        .select()
        .single()

      if (error) {
        console.error('Error creating AI personality:', error)
        return defaultPersonality as AIPersonalityConfig
      }

      return created
    }
  }

  /**
   * Generate system prompt additions based on personality config
   */
  static generatePersonalityPrompt(config: AIPersonalityConfig): string {
    const prompts: string[] = []

    // AI Name - Always include so the AI knows its name
    if (config.ai_name && config.ai_name.trim()) {
      prompts.push(`Your name is ${config.ai_name}.`)
    }

    // Personality traits
    switch (config.personality) {
      case 'friendly':
        prompts.push('Be friendly, warm, and approachable in your responses.')
        break
      case 'professional':
        prompts.push('Maintain a professional, rigorous, and formal tone.')
        break
      case 'witty':
        prompts.push('Be witty and clever, using wordplay and intelligent humor when appropriate.')
        break
      case 'caring':
        prompts.push('Show genuine care and compassion, being supportive and understanding.')
        break
      case 'energetic':
        prompts.push('Be energetic, enthusiastic, and vibrant in your communication.')
        break
    }

    // Humor level
    switch (config.humor_level) {
      case 'none':
        prompts.push('Keep responses serious and professional without humor.')
        break
      case 'light':
        prompts.push('Include occasional light humor to keep things pleasant.')
        break
      case 'dry':
        prompts.push('Use dry wit and subtle humor, like a seasoned developer would.')
        break
      case 'moderate':
        prompts.push('Balance informative content with moderate amounts of humor.')
        break
      case 'heavy':
        prompts.push('Be frequently humorous and entertaining while remaining helpful.')
        break
    }

    // Communication style
    switch (config.communication_style) {
      case 'casual':
        prompts.push('Use a casual, relaxed, conversational tone.')
        break
      case 'formal':
        prompts.push('Maintain formal, structured communication.')
        break
      case 'tech-savvy':
        prompts.push('Use technical terminology and programming analogies when relevant.')
        break
      case 'supportive':
        prompts.push('Be encouraging and supportive, helping build user confidence.')
        break
    }

    // Response length
    switch (config.response_length) {
      case 'concise':
        prompts.push('Keep responses brief and to the point. Avoid unnecessary elaboration.')
        break
      case 'moderate':
        prompts.push('Provide balanced responses with appropriate detail.')
        break
      case 'detailed':
        prompts.push('Give comprehensive, detailed explanations with examples when helpful.')
        break
    }

    // Expertise
    switch (config.expertise) {
      case 'technology':
        prompts.push('Emphasize technical expertise, especially in programming, software architecture, and emerging tech.')
        break
      case 'business':
        prompts.push('Focus on business analysis, strategy, and professional insights.')
        break
      case 'creative':
        prompts.push('Emphasize creative thinking, design principles, and artistic perspectives.')
        break
      case 'academic':
        prompts.push('Provide scholarly, research-oriented responses with academic rigor.')
        break
      // 'general' doesn't need special instruction
    }

    // Interests
    if (config.interests) {
      prompts.push(`You have interests in: ${config.interests}. Reference these when relevant to make conversations more engaging.`)
    }

    // Background story
    if (config.background_story) {
      prompts.push(`Your background: ${config.background_story}`)
    }

    return prompts.join('\n')
  }

  /**
   * Merge manual personality config with learned profile
   */
  static async getMergedContext(userId: string): Promise<string> {
    const supabase = createClient()

    // Get both personality config and learned profile
    const [personalityResult, profileResult] = await Promise.all([
      supabase
        .from('ai_personalities')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true)
        .single(),
      supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', userId)
        .single()
    ])

    const contexts: string[] = []

    // Add manual personality configuration
    if (personalityResult.data) {
      const personalityPrompt = this.generatePersonalityPrompt(personalityResult.data)
      if (personalityPrompt) {
        contexts.push('**Manual Configuration:**\n' + personalityPrompt)
      }
    }

    // Add learned profile context
    if (profileResult.data && profileResult.data.profile_summary) {
      contexts.push('**Learned Preferences:**\n' + profileResult.data.profile_summary)

      // Add specific learned preferences that might override manual settings
      if (profileResult.data.preferences?.likes_detailed_explanations !== undefined) {
        const prefersDetail = profileResult.data.preferences.likes_detailed_explanations
        contexts.push(`User feedback indicates they prefer ${prefersDetail ? 'detailed' : 'concise'} responses.`)
      }
    }

    return contexts.join('\n\n')
  }

  /**
   * Reset user's personality to master template defaults
   */
  static async resetToMasterDefaults(userId: string): Promise<AIPersonalityConfig | null> {
    const supabase = createClient()

    try {
      // Get master template
      const { data: masterPersonality } = await supabase
        .from('ai_personalities')
        .select('*')
        .eq('is_master', true)
        .single()

      if (!masterPersonality) {
        console.error('No master personality template found')
        return null
      }

      // Update user's personality to match master
      const { data: updated, error } = await supabase
        .from('ai_personalities')
        .update({
          ai_name: masterPersonality.ai_name,
          personality: masterPersonality.personality,
          humor_level: masterPersonality.humor_level,
          communication_style: masterPersonality.communication_style,
          response_length: masterPersonality.response_length,
          expertise: masterPersonality.expertise,
          interests: masterPersonality.interests,
          background_story: masterPersonality.background_story,
          custom_settings: masterPersonality.custom_settings,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId)
        .select()
        .single()

      if (error) {
        console.error('Error resetting to master defaults:', error)
        return null
      }

      return updated
    } catch (error) {
      console.error('Error in resetToMasterDefaults:', error)
      return null
    }
  }

  /**
   * Get the master personality template
   */
  static async getMasterPersonality(): Promise<AIPersonalityConfig | null> {
    const supabase = createClient()

    const { data: masterPersonality } = await supabase
      .from('ai_personalities')
      .select('*')
      .eq('is_master', true)
      .single()

    return masterPersonality
  }

  /**
   * Check if user has premium features for personality customization
   */
  static async canCustomizePersonality(userId: string): Promise<boolean> {
    // TODO: Implement subscription checking
    // For now, return true for all users or check a subscription table
    return true
  }
}