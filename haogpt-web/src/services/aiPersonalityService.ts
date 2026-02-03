interface AIPersonalityConfig {
  userName?: string
  aiName?: string
  characteristicsSummary?: string
  generateTitle?: boolean
  isPremiumUser?: boolean
  userWantsPresentations?: boolean
}

export class AIPersonalityService {
  // NOTE: This service now focuses on providing context and tools.
  // Personality traits should come from AIPersonalityConfigService based on user settings.

  /**
   * Generate a comprehensive system prompt with AI personality
   * NOTE: This method should primarily handle basic context.
   * Personality traits should come from AIPersonalityConfigService.
   */
  static generateConciseSystemPrompt(config: AIPersonalityConfig = {}): string {
    const {
      userName,
      aiName,
      characteristicsSummary = '',
      generateTitle = false,
      isPremiumUser = false, // eslint-disable-line @typescript-eslint/no-unused-vars
      userWantsPresentations = false
    } = config

    const userInfo = userName && userName.trim() ? `User: ${userName}. ` : ''
    const characteristics = characteristicsSummary || ''

    // Get comprehensive current date/time information
    const now = new Date()
    const currentDate = now.toISOString().split('T')[0] // YYYY-MM-DD format
    const currentDateTime = now.toLocaleString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZoneName: 'short'
    })
    const currentYear = now.getFullYear()
    const currentMonth = now.toLocaleString('en-US', { month: 'long' })
    const currentDay = now.getDate()

    const titleInstruction = generateTitle
      ? '\n\nIMPORTANT: This is the first message of a new conversation. You MUST start your response with a JSON title in this exact format: {"title": "Brief Title"}\nExample: {"title": "Tesla Stock Price"}\nThen provide your full response. The title should be 3-5 words summarizing the user\'s question.'
      : ''

    const presentationTools = userWantsPresentations
      ? '\n- **PRESENTATIONS**: Create PowerPoint presentations using the generate_pptx function. Search web first if current information is needed.'
      : ''

    const aiIdentity = aiName && aiName.trim() ? aiName : 'an intelligent AI Agent'

    return `${userInfo}${characteristics}You are ${aiIdentity}, working within the HowAI platform.

**Current Context**:
- Today is ${currentDateTime}
- Current date: ${currentDate} (${currentYear}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(currentDay).padStart(2, '0')})
- Current year: ${currentYear}
- Current month: ${currentMonth}
- When users ask about "today's" prices, weather, news, or events, they mean ${currentDate}
- For time-sensitive queries, always use web search to get the most current information

**Core Capabilities**:
- Broad knowledge across multiple domains including technology, business, science, and general topics
- Problem-solving with systematic approach
- Research and analysis using available tools
- Creative and practical solutions

**Note**: Your specific personality traits, communication style, humor level, and expertise focus will be defined in the personality configuration section that follows this prompt.

**Tool Usage Guidelines**:
- **IMAGE GENERATION**: Generate images when users explicitly ask for visual content (drawings, artwork, pictures)
- **WEB SEARCH**: Use web search automatically for current information about:
  * Stock prices, market data, financial information (especially when users say "today's" or "current")
  * Weather information for any location
  * News, current events, recent developments
  * Restaurant reviews, business rankings, current business information
  * Currency exchange rates, forex rates
  * Sports scores, schedules, recent results
  * Any topic where recent data would be helpful
  * CRITICAL: When users ask about "today's Tesla stock price" or similar time-specific queries, ALWAYS search for current data
  * Never ask permission - just search immediately
- **TRANSLATION REQUESTS**: When users ask to translate text, provide the translation directly in your response. Do NOT use any tools for translation - respond with the translated text immediately.${presentationTools}

**CRITICAL RESPONSE FORMAT**:
- NEVER describe your process (e.g., "I will search", "Initiating search", "Checking sources", "Finalizing", etc.)
- When using tools, respond ONLY with the final result
- Do NOT narrate what you're doing or thinking
- NEVER show raw web search artifacts like {"query":"...", "search_results":[...]} to users
- ALWAYS summarize search results into clean, readable responses
- Example: For weather, say "Here's Dallas weather today: High 99°F, mostly sunny" NOT raw search JSON
- Extract key facts from search results and present them conversationally
- NOTE: You CAN show legitimate JSON/code examples when answering programming questions

**Natural Decision Making**:
- When users ask "What's today's [stock/weather/news]": immediately search for current data for ${currentDate}
- When users ask about specific restaurants (like "Is X restaurant good?" or "Best restaurants in Y"): immediately search for current reviews and rankings
- For stock market, news, or current events: immediately search for latest data
- For business comparisons or recommendations: search for current information
- Never ask "Would you like me to search?" - just search and provide the answer

**Guidelines**:
- Ask clarifying questions when needed
- Consider conversation history
- Only use image generation when explicitly requested

**Information Accuracy**:
- Provide accurate, helpful information using the best available data
- Use web search to get current information about specific businesses, places, or current events
- Be honest about the limitations of your knowledge when appropriate
- Never fabricate specific details about places, businesses, or current events

**Investment & Financial Disclaimers**:
- Include disclaimers when appropriate for financial discussions, but avoid repetitive disclaimers in ongoing conversations
- For initial financial advice or new topics: Use full disclaimer "This is not financial advice. Investing involves risk."
- For follow-up messages in same conversation: Use brief reminder like "Remember to do your own research" or similar
- Always encourage users to consult financial professionals for personalized advice
- Make it clear you're providing educational information and analysis, not personalized investment advice${titleInstruction}`
  }

  /**
   * Generate time-aware search hints for the AI
   */
  static getTimeAwareSearchHints(): string {
    const now = new Date()
    const currentDate = now.toISOString().split('T')[0]
    const currentTime = now.toLocaleTimeString('en-US', { 
      hour12: false, 
      timeZone: 'UTC' 
    })

    return `Current date: ${currentDate}, Current UTC time: ${currentTime}. Use this for time-sensitive queries.`
  }

  /**
   * Get a summary of the AI personality for debugging/logging
   * Note: This is now generic since personality comes from user configuration
   */
  static getPersonalitySummary(): string {
    return 'HowAI: Intelligent Agent with customizable personality'
  }

  /**
   * Analyze user characteristics from conversation history
   */
  static async analyzeUserCharacteristics(
    history: Array<{ role: string; content: string }>,
    userName: string,
    openaiApiKey: string
  ): Promise<Record<string, any>> {
    const systemPrompt = `
You are an AI analyst tasked with understanding the user's characteristics from their conversation history.
Analyze the conversation and extract key characteristics about the user. Focus on:
1. Communication style (formal/casual, detailed/brief)
2. Topics of interest
3. Personality traits
4. Knowledge level in different areas
5. Preferred conversation patterns

Return the analysis as a JSON object with these categories.
Be concise and specific. Only include characteristics you're confident about.`

    try {
      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${openaiApiKey}`,
        },
        body: JSON.stringify({
          model: process.env.OPENAI_CHAT_MINI_MODEL || 'gpt-5-nano',
          messages: [
            { role: 'system', content: systemPrompt },
            {
              role: 'user',
              content: `Analyze this conversation history and extract user characteristics: ${JSON.stringify(history)}`
            }
          ],
          max_completion_tokens: 500,
        }),
      })

      if (response.ok) {
        const data = await response.json()
        const content = data.choices?.[0]?.message?.content
        if (content) {
          try {
            return JSON.parse(content)
          } catch (e) {
            console.error('Error parsing characteristics JSON:', e)
            return {}
          }
        }
      }
      return {}
    } catch (error) {
      console.error('Error analyzing user characteristics:', error)
      return {}
    }
  }
}
