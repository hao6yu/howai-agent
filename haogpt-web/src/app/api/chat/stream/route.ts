import { NextRequest } from 'next/server'
import OpenAI from 'openai'
import { createClient } from '@/lib/supabase-server'
import { AIPersonalityService } from '@/services/aiPersonalityService'
import { UserProfileService } from '@/services/userProfileService'
import { AIPersonalityConfigService } from '@/services/aiPersonalityConfigService'

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
})

export async function POST(request: NextRequest) {
  try {
    const { message, conversationId, deepResearch, attachments = [] } = await request.json()

    if ((!message && attachments.length === 0) || !conversationId) {
      return new Response('Message or attachments and conversation ID are required', { status: 400 })
    }

    const supabase = createClient()

    // Get the authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response('Unauthorized', { status: 401 })
    }

    // Verify user owns the conversation
    const { data: conversation, error: convError } = await supabase
      .from('conversations')
      .select('id')
      .eq('id', conversationId)
      .eq('user_id', user.id)
      .single()

    if (convError || !conversation) {
      return new Response('Conversation not found or unauthorized', { status: 404 })
    }

    // Get conversation history for context
    const { data: messages } = await supabase
      .from('messages')
      .select('content, is_ai, created_at')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true })
      .limit(20)

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

    // Use GPT-5 for all conversations with appropriate reasoning levels
    const modelToUse = 'gpt-5'
    const reasoningLevel = deepResearch ? 'high' : 'low' // High for deep research, low for regular chat

    // Generate comprehensive system prompt with current date, AI personality, and user profile
    let systemPrompt = AIPersonalityService.generateConciseSystemPrompt({
      userName: userName, // Use display name from profiles table
      aiName: aiPersonality?.ai_name, // Use custom AI name
      characteristicsSummary: characteristicsSummary,
      generateTitle: false, // Streaming doesn't generate titles
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
      systemPrompt += '\n\n🧠 GPT-5 DEEP REASONING MODE: You are using OpenAI\'s advanced GPT-5 model with high reasoning effort. Provide deep, step-by-step logical analysis with comprehensive insights, multiple perspectives, and thorough explanations. Break down complex problems, consider pros and cons, and provide detailed reasoning for your conclusions. Focus on educational value and helping users understand not just the "what" but the "why" behind your answers.'
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

    // Configure parameters based on reasoning level

    const streamParams: any = {
      model: modelToUse,
      messages: openaiMessages,
      stream: true,
    }

    // GPT-5 streaming parameters with configurable reasoning effort
    streamParams.max_completion_tokens = deepResearch ? 8000 : 4000
    streamParams.reasoning_effort = reasoningLevel // 'low' for regular chat, 'high' for deep research

    if (deepResearch) {
      streamParams.verbosity = 'medium'
      streamParams.temperature = 0.3 // Lower temperature for focused analysis
    } else {
      streamParams.verbosity = 'low'
      streamParams.temperature = 0.7 // Higher temperature for natural conversation
    }

    // Create streaming response
    const stream = await openai.chat.completions.create({
      ...streamParams,
      stream: true
    }) as any

    let fullResponse = ''

    // Create a readable stream
    const encoder = new TextEncoder()
    const readable = new ReadableStream({
      async start(controller) {
        try {
          for await (const chunk of stream) {
            const content = chunk.choices[0]?.delta?.content || ''
            if (content) {
              fullResponse += content
              controller.enqueue(encoder.encode(`data: ${JSON.stringify({ content })}\n\n`))
            }
          }

          // Save the complete response to the database
          if (fullResponse) {
            // Clean up the response before saving (remove image URLs but preserve contextual links)
            let cleanedResponse = fullResponse

            // Simple URL cleanup - convert contextual image URLs to links, remove standalone ones
            const imageUrlPattern = /https?:\/\/oaidalleapiprodscus\.blob\.core\.windows\.net\/[^\s\)]+/gi
            const contextWords = ['image\\s+link', 'link', 'url', 'view', 'download', 'here', 'source']

            // Find all image URLs in the response
            const imageUrls = fullResponse.match(imageUrlPattern) || []

            imageUrls.forEach(imageUrl => {
              const escapedUrl = imageUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

              // Remove contextual mentions like "Image link: [URL]", "Here's the link: [URL]", etc.
              for (const contextWord of contextWords) {
                // Remove the entire context phrase + URL
                cleanedResponse = cleanedResponse.replace(
                  new RegExp(`(${contextWord})\\s*:?\\s*${escapedUrl}`, 'gi'),
                  ''
                )
              }

              // Remove any remaining standalone URLs
              cleanedResponse = cleanedResponse.replace(new RegExp(`\\b${escapedUrl}\\b`, 'g'), '')
            })

            await supabase
              .from('messages')
              .insert({
                conversation_id: conversationId,
                content: cleanedResponse,
                is_ai: true
              })

            // Update conversation timestamp
            await supabase
              .from('conversations')
              .update({ updated_at: new Date().toISOString() })
              .eq('id', conversationId)
          }

          controller.enqueue(encoder.encode('data: [DONE]\n\n'))
          controller.close()
        } catch (error) {
          console.error('Streaming error:', error)
          controller.error(error)
        }
      }
    })

    return new Response(readable, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    })

  } catch (error) {
    console.error('Chat streaming error:', error)
    return new Response('Internal server error', { status: 500 })
  }
}