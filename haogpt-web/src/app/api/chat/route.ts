import { NextRequest, NextResponse } from 'next/server'
import OpenAI from 'openai'
import { createClient } from '@/lib/supabase-server'
import { AIPersonalityService } from '@/services/aiPersonalityService'
import { UserProfileService } from '@/services/userProfileService'
import { AIPersonalityConfigService } from '@/services/aiPersonalityConfigService'

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  timeout: 240000, // 4 minutes timeout for image generation (doubled)
})

// Increase timeout for this API route (especially for image generation)
export const maxDuration = 240 // 4 minutes in seconds (doubled)

export async function POST(request: NextRequest) {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  try {
    const { message, conversationId, deepResearch, attachments = [], generateTitle = false, allowWebSearch = false, enableAIWebSearchDetection = true } = await request.json()

    console.log('[Chat API] Request parameters:', {
      hasMessage: !!message,
      conversationId,
      generateTitle,
      deepResearch,
      attachmentsCount: attachments.length
    })

    // Initialize image URLs array for storing generated images
    const imageUrls: string[] = []

    if ((!message && attachments.length === 0) || !conversationId) {
      return NextResponse.json(
        { error: 'Message or attachments and conversation ID are required' },
        { status: 400 }
      )
    }

    const supabase = createClient()

    // Get the authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    // Verify user owns the conversation
    const { data: conversation, error: convError } = await supabase
      .from('conversations')
      .select('id')
      .eq('id', conversationId)
      .eq('user_id', user.id)
      .single()

    if (convError || !conversation) {
      return NextResponse.json(
        { error: 'Conversation not found or unauthorized' },
        { status: 404 }
      )
    }

    // Get conversation history for context
    const { data: messages } = await supabase
      .from('messages')
      .select('content, is_ai, created_at, image_urls')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true })
      .limit(20) // Limit to last 20 messages for context

    // Check if we should evaluate user profile
    const totalMessageCount = (messages?.length || 0) + 1 // +1 for current message
    const shouldEvaluate = await UserProfileService.shouldEvaluateProfile(user.id, totalMessageCount)

    // Get user display name from profiles table
    const { data: userProfileData } = await supabase
      .from('profiles')
      .select('name')
      .eq('id', user.id)
      .single()

    const userName = userProfileData?.name || user?.email?.split('@')[0] || 'User'

    // Get user profile context for AI (learned preferences)
    const userProfile = await UserProfileService.getOrCreateProfile(user.id)
    const profileContext = await UserProfileService.getProfileContext(user.id)
    const characteristicsSummary = UserProfileService.formatCharacteristicsForAI(userProfile)

    // Get manual AI personality configuration
    const aiPersonality = await AIPersonalityConfigService.getOrCreatePersonality(user.id)
    const personalityPrompt = AIPersonalityConfigService.generatePersonalityPrompt(aiPersonality)

    // Get merged context (manual config + learned profile)
    const mergedContext = await AIPersonalityConfigService.getMergedContext(user.id)

    // Auto-detect if we need to generate a title (for new conversations)
    const isNewConversation = !messages || messages.length === 0
    const shouldGenerateTitle = generateTitle || isNewConversation

    console.log('[Chat API] Title generation logic:', {
      generateTitle,
      isNewConversation,
      shouldGenerateTitle,
      messageCount: messages?.length || 0
    })

    // Use GPT-5 for all conversations with appropriate reasoning levels
    const modelToUse = 'gpt-5'
    const reasoningLevel = deepResearch ? 'high' : 'low' // High for deep research, low for regular chat

    // All using GPT-5 now

    // Generate comprehensive system prompt with current date, AI personality, and user profile
    let systemPrompt = AIPersonalityService.generateConciseSystemPrompt({
      userName: userName, // Use display name from profiles table
      aiName: aiPersonality?.ai_name, // Use custom AI name
      characteristicsSummary: characteristicsSummary,
      generateTitle: shouldGenerateTitle,
      isPremiumUser: true, // TODO: Implement subscription checking
      userWantsPresentations: false, // TODO: Implement presentation intent detection
    })

    // Add merged context (manual personality + learned profile)
    if (mergedContext) {
      systemPrompt += '\n\n**AI Configuration & User Context:**\n' + mergedContext
    } else if (profileContext) {
      // Fallback to just profile context if merged not available
      systemPrompt += '\n\n**User Context:**\n' + profileContext
    }

    // Add manual personality configuration if available
    if (personalityPrompt) {
      systemPrompt += '\n\n**Personality Settings:**\n' + personalityPrompt
    }

    // Add reasoning mode instructions based on reasoning level
    if (deepResearch) {
      systemPrompt += '\n\n🧠 GPT-5 DEEP REASONING MODE: You are using OpenAI\'s advanced GPT-5 model with high reasoning effort. Provide deep, step-by-step logical analysis with comprehensive insights, multiple perspectives, and thorough explanations. You have access to web search for current information, image generation, and other tools - use them strategically to enhance your reasoning and provide the most accurate, up-to-date analysis possible. For stock or financial questions, prioritize using web search to get current market data.'
    } else {
      systemPrompt += '\n\n⚡ GPT-5 FAST MODE: You are using OpenAI\'s GPT-5 model optimized for quick, efficient responses while maintaining high quality. Be helpful, accurate, and concise.'
    }

    // Build OpenAI messages array
    const openaiMessages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [
      {
        role: 'system',
        content: systemPrompt
      }
    ]

    // Add conversation history
    if (messages) {
      messages.forEach((msg) => {
        openaiMessages.push({
          role: msg.is_ai ? 'assistant' : 'user',
          content: msg.content
        })
      })
    }

    // Build the user message content
    const userContent: any[] = []

    // Add text message if present
    if (message) {
      userContent.push({
        type: 'text',
        text: message
      })
    }

    // Add image attachments
    attachments.forEach((attachment: any) => {
      if (attachment.type === 'image') {
        userContent.push({
          type: 'image_url',
          image_url: {
            url: `data:${attachment.mimeType};base64,${attachment.data}`,
            detail: deepResearch ? 'high' : 'auto'
          }
        })
      } else if (attachment.type === 'document') {
        // For documents, add as text content
        userContent.push({
          type: 'text',
          text: `Document "${attachment.name}" content:\n\n${attachment.content}`
        })
      }
    })

    // Add the new message
    openaiMessages.push({
      role: 'user',
      content: userContent.length === 1 && userContent[0].type === 'text'
        ? userContent[0].text
        : userContent
    })

    // Handle title generation separately if needed
    let conversationTitle: string | null = null
    if (shouldGenerateTitle) {
      try {
        const titleModel = process.env.OPENAI_TTITLE_GEN_MODEL || 'gpt-4o-mini'
        console.log('[Chat API] Generating conversation title using model:', titleModel)
        const titleResponse = await openai.chat.completions.create({
          model: titleModel,
          messages: [
            {
              role: 'system',
              content: 'Generate a brief 3-5 word title for this conversation based on the user\'s message. Respond with ONLY the title text, no quotes, no extra formatting.'
            },
            {
              role: 'user',
              content: message
            }
          ],
          max_completion_tokens: 20
        })

        const title = titleResponse.choices[0]?.message?.content?.trim()
        console.log('[Chat API] Title generation response:', {
          choices: titleResponse.choices?.length,
          content: title,
          contentLength: title?.length
        })
        if (title && title.length > 0 && title.length < 50) {
          conversationTitle = title
          console.log('[Chat API] Generated title:', conversationTitle)
        } else {
          console.log('[Chat API] Title generation failed - invalid title:', { title, length: title?.length })
        }
      } catch (titleError) {
        console.error('[Chat API] Error generating title:', titleError)
        // Continue without title if generation fails
      }
    }

    // Determine if web search should be enabled
    let shouldEnableWebSearch = allowWebSearch
    
    // If AI detection is enabled and web search is not forced, check if web search is needed
    if (enableAIWebSearchDetection && !allowWebSearch) {
      shouldEnableWebSearch = await detectWebSearchIntent(message, messages || [])
      console.log('[Chat API] AI web search detection result:', shouldEnableWebSearch)
    }

    // Build tools array
    const tools: any[] = []
    
    // Add image generation tool (always available)
    tools.push({
      type: 'function',
      function: {
        name: 'image_generation',
        description: 'Generate an image ONLY when the user explicitly requests visual content like "draw", "create an image", "show me a picture", "generate artwork", etc. Do NOT use for data, news, or informational queries. Images are optimized for fast generation with standard quality.',
        parameters: {
          type: 'object',
          properties: {
            prompt: {
              type: 'string',
              description: 'The detailed image prompt describing what to generate. Images will be generated in square format with standard quality for optimal performance.'
            }
          },
          required: ['prompt']
        }
      }
    })
    
    // Add web search tool if enabled (either forced or AI-detected)
    if (shouldEnableWebSearch) {
      tools.push({
        type: 'function',
        function: {
          name: 'web_search',
          description: `Search the internet for current information including: stock market data (especially when users ask about "today's" prices), currency exchange rates, forex rates, news, restaurant reviews and rankings, business information, current events, prices, weather, or any real-time data that may have changed recently. CRITICAL: When users ask about "today's Tesla stock price" or similar time-specific queries for ${new Date().toISOString().split('T')[0]}, you MUST use this tool to get current data. For currency exchange rates (like JPY to USD, EUR to USD, etc.), you MUST use this tool to get the current live exchange rate. NEVER use outdated training data for time-sensitive information.`,
          parameters: {
            type: 'object',
            properties: {
              query: { 
                type: 'string', 
                description: 'The search query to find relevant information' 
              }
            },
            required: ['query']
          }
        }
      })
    }

    const completionParams: any = {
      model: modelToUse,
      messages: openaiMessages,
    }

    // Add tools if available
    if (tools.length > 0) {
      completionParams.tools = tools
      completionParams.tool_choice = 'auto'
    }

    // GPT-5 parameters with configurable reasoning effort
    completionParams.max_completion_tokens = deepResearch ? 8000 : 4000
    completionParams.reasoning_effort = reasoningLevel // 'low' for regular chat, 'high' for deep research

    if (deepResearch) {
      completionParams.verbosity = 'high' // Detailed responses for deep research
    } else {
      completionParams.verbosity = 'low' // Concise responses for regular chat
    }

    // Get AI response
    console.log('[Chat API] Sending request to OpenAI with model:', modelToUse)
    console.log('[Chat API] GPT-5 configuration:', {
      model: modelToUse,
      reasoning_effort: reasoningLevel,
      verbosity: deepResearch ? 'high' : 'low',
      max_completion_tokens: completionParams.max_completion_tokens,
      deepResearch
    })
    console.log('[Chat API] Tools enabled:', tools.length > 0 ? tools.map(t => t.function.name) : 'none')
    
    let completion
    try {
      completion = await openai.chat.completions.create(completionParams)
      console.log('[Chat API] OpenAI response received successfully')
    } catch (openaiError) {
      console.error('[Chat API] OpenAI API error:', openaiError)
      return NextResponse.json(
        { error: `OpenAI API error: ${openaiError instanceof Error ? openaiError.message : 'Unknown error'}` },
        { status: 500 }
      )
    }
    
    console.log('[Chat API] Choices length:', completion.choices?.length || 0)

    let aiResponse = completion.choices[0]?.message?.content
    const choice = completion.choices[0]
    
    console.log('[Chat API] Initial AI response length:', aiResponse?.length || 0)
    console.log('[Chat API] Has tool calls:', choice?.message?.tool_calls?.length || 0)

    // Handle tool calls if present first (before checking aiResponse)
    if (choice?.message?.tool_calls && choice.message.tool_calls.length > 0) {
      console.log(`[Chat API] AI made ${choice.message.tool_calls.length} tool calls`)
      
      // Process tool calls
      const toolResults = []
      
      for (const toolCall of choice.message.tool_calls) {
        if (toolCall.type === 'function' && toolCall.function) {
          const functionName = toolCall.function.name
          
          if (functionName === 'web_search') {
            try {
              const args = JSON.parse(toolCall.function.arguments)
              const query = args.query
              
              if (query) {
                console.log(`[Chat API] Performing web search: "${query}"`)
                
                // Call our internal search API
                const searchResponse = await fetch(`${process.env.NEXTAUTH_URL || 'http://localhost:3000'}/api/search`, {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: JSON.stringify({ query }),
                })
                
                const searchData = await searchResponse.json()
                console.log(`[Chat API] Web search returned ${searchData.results?.length || 0} results`)

                // Smart token management: if search results are too large, prioritize first few results
                let searchResults = searchData.results || []
                const searchResultsText = JSON.stringify(searchResults)

                // Rough token estimation: ~4 chars per token
                const estimatedTokens = searchResultsText.length / 4
                console.log(`[Chat API] Search results estimated tokens: ${estimatedTokens}`)

                // If estimated tokens > 6000, reduce number of results instead of truncating content
                if (estimatedTokens > 6000 && searchResults.length > 3) {
                  searchResults = searchResults.slice(0, 3)
                  console.log(`[Chat API] Reduced search results to ${searchResults.length} due to token limit`)
                } else if (estimatedTokens > 8000 && searchResults.length > 2) {
                  searchResults = searchResults.slice(0, 2)
                  console.log(`[Chat API] Reduced search results to ${searchResults.length} due to token limit`)
                }

                toolResults.push({
                  role: 'tool' as const,
                  tool_call_id: toolCall.id,
                  content: JSON.stringify({
                    search_results: searchResults
                  }),
                })
              }
            } catch (error) {
              console.error('[Chat API] Error processing web search:', error)
              toolResults.push({
                role: 'tool' as const,
                tool_call_id: toolCall.id,
                content: JSON.stringify({
                  error: 'Failed to perform web search'
                }),
              })
            }
          } else if (functionName === 'image_generation') {
            try {
              const args = JSON.parse(toolCall.function.arguments)
              // Force performance optimizations regardless of AI's choice
              const { prompt } = args
              const size = '1024x1024' // Always use square format for fastest generation
              const quality = 'standard' // Always use standard quality for speed
              
              if (prompt) {
                console.log(`[Chat API] Generating image with prompt: "${prompt.substring(0, 100)}..."`)
                console.log(`[Chat API] FORCED settings - Size: ${size}, Quality: ${quality} (optimized for performance)`)

                // Call our internal image generation API
                const imageResponse = await fetch(`${process.env.NEXTAUTH_URL || 'http://localhost:3000'}/api/image-generation`, {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: JSON.stringify({ prompt, size, quality }),
                })
                
                const imageData = await imageResponse.json()
                
                if (imageResponse.ok && imageData.imageUrl) {
                  console.log('[Chat API] Image generated successfully')
                  // Add to image URLs array for database storage
                  imageUrls.push(imageData.imageUrl)
                  
                  toolResults.push({
                    role: 'tool' as const,
                    tool_call_id: toolCall.id,
                    content: JSON.stringify({
                      imageUrl: imageData.imageUrl,
                      prompt: imageData.prompt,
                      size: imageData.size,
                      quality: imageData.quality,
                      revised_prompt: imageData.revised_prompt
                    }),
                  })
                } else {
                  console.error('[Chat API] Image generation failed:', imageData.error)
                  toolResults.push({
                    role: 'tool' as const,
                    tool_call_id: toolCall.id,
                    content: JSON.stringify({
                      error: imageData.error || 'Failed to generate image'
                    }),
                  })
                }
              }
            } catch (error) {
              console.error('[Chat API] Error processing image generation:', error)
              toolResults.push({
                role: 'tool' as const,
                tool_call_id: toolCall.id,
                content: JSON.stringify({
                  error: 'Failed to generate image'
                }),
              })
            }
          }
        }
      }
      
      // If we have tool results, send a follow-up request
      if (toolResults.length > 0) {
        const followupMessages = [...openaiMessages]
        followupMessages.push({
          role: 'assistant',
          content: choice.message.content || '',
          tool_calls: choice.message.tool_calls,
        })
        followupMessages.push(...toolResults)

        
        const followupParams: any = {
          model: modelToUse,
          messages: followupMessages,
        }

        // GPT-5 follow-up parameters
        followupParams.max_completion_tokens = 6000
        followupParams.reasoning_effort = 'low' // Use low effort for follow-ups for speed
        followupParams.verbosity = 'low' // Concise follow-up responses

        console.log('[Chat API] Sending follow-up request with tool results')
        console.log('[Chat API] Follow-up params:', JSON.stringify({
          model: followupParams.model,
          messagesCount: followupParams.messages.length,
          max_completion_tokens: followupParams.max_completion_tokens,
          reasoning_effort: followupParams.reasoning_effort,
          verbosity: followupParams.verbosity
        }))

        // Debug: Log the last few messages to see if title instruction is there
        if (shouldGenerateTitle) {
          console.log('[Chat API] Last 2 follow-up messages:')
          const lastMessages = followupParams.messages.slice(-2)
          lastMessages.forEach((msg: any, idx: number) => {
            console.log(`[Chat API] Message ${idx}:`, { role: msg.role, content: msg.content?.substring(0, 150) + '...' })
          })
        }

        let followupCompletion
        try {
          followupCompletion = await openai.chat.completions.create(followupParams)
          console.log('[Chat API] Follow-up completion received successfully')
        } catch (followupError) {
          console.error('[Chat API] Follow-up completion error:', followupError)
          // If follow-up fails, we'll still return the original response
          console.log('[Chat API] Using original response due to follow-up error')
          followupCompletion = null
        }

        // Use the follow-up response and clean it
        if (followupCompletion) {
          aiResponse = followupCompletion.choices[0]?.message?.content || aiResponse
          console.log('[Chat API] Follow-up response length:', aiResponse?.length || 0)
        }

        // Clean the response for final display
        if (aiResponse) {
          aiResponse = cleanGPT5ReasoningArtifacts(aiResponse)
        }

        console.log('[Chat API] Successfully processed tool calls and got follow-up response')
      }
    }


    // Check if we have a valid response after tool processing
    if (!aiResponse) {
      console.error('[Chat API] No valid AI response after processing')
      return NextResponse.json(
        { error: 'No response from AI' },
        { status: 500 }
      )
    }

    console.log('[Chat API] Final AI response length:', aiResponse.length)

    // Clean up AI response by removing ONLY image URLs if images are being displayed separately
    if (imageUrls.length > 0 && aiResponse) {
      // Remove markdown image syntax with URLs
      aiResponse = aiResponse.replace(/!\[.*?\]\(https?:\/\/[^\s\)]+\)/g, '')

      // Handle image URLs: remove them completely since images are displayed separately
      imageUrls.forEach(imageUrl => {
        const escapedUrl = imageUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

        // Remove contextual mentions like "Image link: [URL]", "Here's the link: [URL]", etc.
        const contextWords = ['image\\s+link', 'link', 'url', 'view', 'download', 'here', 'source']

        for (const contextWord of contextWords) {
          // Remove the entire context phrase + URL
          aiResponse = aiResponse!.replace(
            new RegExp(`(${contextWord})\\s*:?\\s*${escapedUrl}`, 'gi'),
            ''
          )
        }

        // Remove any remaining standalone URLs
        aiResponse = aiResponse!.replace(new RegExp(`\\b${escapedUrl}\\b`, 'g'), '')
      })

      // Remove any remaining standalone DALL-E URLs (but preserve other URLs)
      aiResponse = aiResponse.replace(/https?:\/\/oaidalleapiprodscus\.blob\.core\.windows\.net\/[^\s\)]+/gi, '')

      // Remove any remaining standalone image URLs that are likely generated (not in markdown links)
      aiResponse = aiResponse.replace(/(?<!\]\()\bhttps?:\/\/[^\s]+\.(png|jpg|jpeg|gif|webp)(?:\?[^\s]*)?(?!\))/gi, '')

      // Remove lines that ONLY contain image URLs (but preserve lines with text + URLs)
      aiResponse = aiResponse.replace(/^\s*https?:\/\/[^\s]*\.(png|jpg|jpeg|gif|webp)(?:\?[^\s]*)?\s*$/gm, '')

      // Clean up extra whitespace, newlines, and empty lines
      aiResponse = aiResponse
        .replace(/\n\s*\n\s*\n/g, '\n\n')
        .replace(/^\s*\n+/g, '')
        .replace(/\n+\s*$/g, '')
        .trim()
    }

    // Convert standalone URLs to user-friendly links (for non-image URLs)
    if (aiResponse) {
      // Replace standalone URLs that aren't already in markdown links with "Click here" links
      aiResponse = aiResponse.replace(
        /(?<!\]\(|\[.*?\]\()\b(https?:\/\/(?!oaidalleapiprodscus\.blob\.core\.windows\.net)[^\s\)]+)(?!\))/gi,
        (_match, url) => {
          // Make the link text more contextual based on the domain
          const domain = url.match(/https?:\/\/(?:www\.)?([^\/]+)/i)?.[1] || ''

          if (domain.includes('github.com')) return `[View on GitHub](${url})`
          if (domain.includes('stackoverflow.com')) return `[View on Stack Overflow](${url})`
          if (domain.includes('youtube.com') || domain.includes('youtu.be')) return `[Watch on YouTube](${url})`
          if (domain.includes('docs.')) return `[View documentation](${url})`
          if (domain.includes('wikipedia.org')) return `[Read on Wikipedia](${url})`

          return `[Visit link](${url})`
        }
      )
    }

    // Clean the response
    if (aiResponse) {
      aiResponse = cleanGPT5ReasoningArtifacts(aiResponse)
    }

    // Now save the clean response to database (without title JSON)
    const { data: aiMessage, error: saveError } = await supabase
      .from('messages')
      .insert({
        conversation_id: conversationId,
        content: aiResponse,
        is_ai: true,
        image_urls: imageUrls.length > 0 ? imageUrls : null
      })
      .select()
      .single()

    if (saveError) {
      console.error('Error saving AI message:', saveError)
      return NextResponse.json(
        { error: 'Failed to save AI response' },
        { status: 500 }
      )
    }

    // Update conversation with title if generated (blocking to ensure frontend gets updated data)
    if (conversationTitle) {
      console.log('[Chat API] Updating conversation title in database:', conversationTitle)
      console.log('[Chat API] Conversation ID:', conversationId)
      try {
        const { data, error } = await supabase
          .from('conversations')
          .update({
            title: conversationTitle,
            updated_at: new Date().toISOString()
          })
          .eq('id', conversationId)

        if (error) {
          console.error('[Chat API] Error updating conversation title:', error)
        } else {
          console.log('[Chat API] Conversation title updated successfully')
          console.log('[Chat API] Update result:', { data, updatedTitle: conversationTitle })
        }
      } catch (titleUpdateError) {
        console.error('[Chat API] Exception updating conversation title:', titleUpdateError)
      }
    } else {
      console.log('[Chat API] No conversation title to update')
      // Still update the timestamp even without title
      try {
        const { error } = await supabase
          .from('conversations')
          .update({ updated_at: new Date().toISOString() })
          .eq('id', conversationId)

        if (error) {
          console.error('[Chat API] Error updating conversation timestamp:', error)
        } else {
          console.log('[Chat API] Conversation timestamp updated')
        }
      } catch (timestampError) {
        console.error('[Chat API] Exception updating conversation timestamp:', timestampError)
      }
    }

    // Evaluate user profile in the background if needed
    if (shouldEvaluate && messages && messages.length > 0) {
      // Run profile evaluation asynchronously (non-blocking)
      UserProfileService.evaluateAndUpdateProfile(
        user.id,
        conversationId,
        messages
      ).catch(error => {
        console.error('[Chat API] Error evaluating user profile:', error)
      })
    }

    console.log('[Chat API] Returning response:', {
      hasMessage: !!aiMessage,
      title: conversationTitle,
      hasUsage: !!completion.usage,
      profileEvaluated: shouldEvaluate
    })

    return NextResponse.json({
      message: {
        ...aiMessage,
        image_urls: imageUrls.length > 0 ? imageUrls : undefined
      },
      title: conversationTitle,
      usage: completion.usage,
      // Include simple tool usage metadata for thinking indicators
      thinking: choice?.message?.tool_calls && choice.message.tool_calls.length > 0 ? {
        toolsUsed: choice.message.tool_calls
          .filter(call => call.type === 'function')
          .map(call => call.function.name)
          .filter(Boolean),
        status: 'completed'
      } : undefined,
      profileUpdated: shouldEvaluate // Let frontend know if profile was updated
    })

  } catch (error) {
    console.error('Chat API error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// Helper function to detect if web search is needed using AI
async function detectWebSearchIntent(currentMessage: string, recentMessages: any[]): Promise<boolean> {
  try {
    // Take the last 5 messages for context
    const contextMessages = recentMessages.slice(-5).map(msg => ({
      role: msg.is_ai ? 'assistant' : 'user',
      content: msg.content
    }))

    const intentDetectionPrompt = `You are an intent analyzer. Analyze the user's message to determine if web search is needed for current, real-time information.

DETECT "YES" for these SPECIFIC cases:
- Weather queries for ANY location (e.g., "weather in Houston", "how's the weather", "temperature today")
- Stock prices, market data, financial information with "today", "current", "latest"
- Currency/forex exchange rates
- Current news, events, developments
- Sports scores, schedules, recent results
- Restaurant reviews, business ratings, hours
- Real-time data that changes daily
- Any query with words: "today", "current", "latest", "now", "recent", "this week/month/year"

DETECT "NO" for:
- General knowledge, historical facts
- Programming help, code explanations
- Math calculations, concept explanations
- Creative writing, personal advice
- Greetings without specific information requests

EXAMPLES:
"weather in Houston today" → YES
"how's the weather" → YES
"what's the temperature" → YES
"today's Tesla stock price" → YES
"current exchange rate" → YES
"what's up" → NO
"explain programming" → NO
"tell me a story" → NO

Answer ONLY "YES" or "NO" - nothing else.`

    const messages = [
      { role: 'system' as const, content: intentDetectionPrompt },
      ...contextMessages.map(msg => ({ role: msg.role as 'user' | 'assistant', content: msg.content })),
      { role: 'user' as const, content: currentMessage },
      { role: 'user' as const, content: 'Based on the conversation context and my latest message, do I need web search to get current, accurate information?' }
    ]

    console.log('[Chat API] Intent detection for message:', currentMessage)

    // Use a more reliable model for intent detection
    const completion = await openai.chat.completions.create({
      model: process.env.OPENAI_INTENT_MODEL || 'gpt-5-nano',
      messages: messages,
      max_completion_tokens: 10, // Very short response needed
    })

    const response = completion.choices[0]?.message?.content?.trim().toLowerCase()
    console.log('[Chat API] Intent detection response:', response)

    // Check for web search keywords as fallback if AI detection fails
    const weatherKeywords = ['weather', 'temperature', 'temp', 'forecast', 'rain', 'sunny', 'cloudy', 'storm']
    const stockKeywords = ['stock', 'price', 'tesla', 'tsla', 'share', 'market', 'close', 'closing', 'nasdaq', 'nyse']
    const timeKeywords = ['today', 'current', 'now', 'latest', 'recent', 'this week', 'this month', 'last week', 'yesterday']
    const locationKeywords = ['houston', 'dallas', 'austin', 'in ', 'city', 'town']

    const messageWords = currentMessage.toLowerCase().split(/\s+/)
    const hasWeatherKeyword = weatherKeywords.some(keyword => messageWords.some(word => word.includes(keyword)))
    const hasStockKeyword = stockKeywords.some(keyword => messageWords.some(word => word.includes(keyword)))
    const hasTimeKeyword = timeKeywords.some(keyword => currentMessage.toLowerCase().includes(keyword))
    const hasLocationKeyword = locationKeywords.some(keyword => currentMessage.toLowerCase().includes(keyword))

    // Auto-detect weather queries with location/time context
    const isWeatherQuery = hasWeatherKeyword && (hasTimeKeyword || hasLocationKeyword)

    // Auto-detect stock queries with time context
    const isStockQuery = hasStockKeyword && hasTimeKeyword

    const needsWebSearch = response?.includes('yes') || isWeatherQuery || isStockQuery

    console.log('[Chat API] Keyword analysis:', {
      hasWeatherKeyword,
      hasStockKeyword,
      hasTimeKeyword,
      hasLocationKeyword,
      isWeatherQuery,
      isStockQuery
    })
    console.log('[Chat API] Needs web search:', needsWebSearch)

    return needsWebSearch

  } catch (error) {
    console.error('[Chat API] Error in web search intent detection:', error)
    // Default to false if detection fails
    return false
  }
}

// Helper function to clean GPT-5 reasoning artifacts from responses
function cleanGPT5ReasoningArtifacts(response: string): string {
  if (!response) return response

  // Remove ONLY specific search result artifacts, not legitimate JSON content
  const searchArtifactPatterns = [
    // Remove individual query objects with various patterns
    /\{"query"\s*:\s*"[^"]*"[^}]*\}\s*/gi,

    // Remove search_results arrays that are clearly from web search tools
    /\{"search_results"\s*:\s*\[[^\]]*\]\s*\}/gi,

    // Remove specific web search result patterns
    /\{"title"\s*:\s*"[^"]*",\s*"link"\s*:\s*"https?:\/\/[^"]*"[^}]*\}/gi,

    // Remove sequences of multiple query objects
    /(?:\{"query"\s*:\s*"[^"]*"[^}]*\}\s*)+/gi,

    // Remove query objects with source and top fields (common in search results)
    /\{"query"\s*:\s*"[^"]*",\s*"top"\s*:\s*\d+,\s*"source"\s*:\s*"[^"]*"\}\s*/gi,

    // Remove lines that are just JSON artifacts from search
    /^\s*\{"[^"]*"\s*:\s*"[^"]*"[^}]*\}\s*$/gm,
  ]

  // Remove common GPT-5 reasoning patterns
  const reasoningPatterns = [
    // Remove "I'll..." statements at the beginning
    /^I'll\s+[^.]*\.\s*/i,

    // Remove "Searching for..." statements
    /Searching for[^.]*\.\s*/gi,

    // Remove "Performing..." statements
    /Performing[^.]*\.\s*/gi,

    // Remove "Pulling..." statements
    /Pulling[^.]*\.\s*/gi,

    // Remove "Querying..." statements
    /Querying[^.]*\.\s*/gi,

    // Remove "Fetching..." statements
    /Fetching[^.]*\.\s*/gi,

    // Remove "Almost done..." statements
    /Almost done[^.]*\.\s*/gi,

    // Remove "Compiling..." statements
    /Compiling[^.]*\.\s*/gi,

    // Remove "Providing..." statements at beginning of sentences
    /Providing[^.]*\.\s*/gi,

    // Remove standalone reasoning statements
    /^Let me[^.]*\.\s*/gmi,
    /^I'm[^.]*\.\s*/gmi,
    /^I need to[^.]*\.\s*/gmi,
  ]

  let cleanedResponse = response

  // First remove search artifacts (but preserve legitimate JSON/code)
  searchArtifactPatterns.forEach(pattern => {
    cleanedResponse = cleanedResponse.replace(pattern, '')
  })

  // Additional cleanup for complex search artifact blocks
  // Remove entire blocks that start with search queries
  cleanedResponse = cleanedResponse.replace(
    /^\s*\{"query"[\s\S]*?(?=\n\n|\n[A-Z]|$)/gm,
    ''
  )

  // Remove remaining standalone JSON lines that look like search artifacts
  cleanedResponse = cleanedResponse.replace(
    /^\s*\{[^{}]*(?:"query"|"top"|"source")[^{}]*\}\s*$/gm,
    ''
  )

  // Then remove reasoning patterns
  reasoningPatterns.forEach(pattern => {
    cleanedResponse = cleanedResponse.replace(pattern, '')
  })

  // Clean up any remaining artifacts
  cleanedResponse = cleanedResponse
    // Remove extra whitespace and newlines
    .replace(/\n\s*\n\s*\n/g, '\n\n')
    .replace(/^\s*\n+/g, '')
    .replace(/\n+\s*$/g, '')
    .trim()

  // Remove title JSON if it still exists in the response (safety cleanup)
  cleanedResponse = cleanedResponse.replace(/^\s*\{\s*"title"\s*:\s*"[^"]+"\s*\}\s*/, '').trim()

  return cleanedResponse
}