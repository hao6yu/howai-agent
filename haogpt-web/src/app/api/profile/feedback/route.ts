import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase-server'

// Valid feedback types
const VALID_FEEDBACK_TYPES = ['helpful', 'not_helpful', 'too_detailed', 'too_brief', 'off_topic', 'perfect']

// Rate limiting: Track feedback submissions per user
const feedbackRateLimit = new Map<string, { count: number; resetTime: number }>()

/**
 * POST /api/profile/feedback - Submit feedback for a message
 */
export async function POST(request: NextRequest) {
  try {
    const { messageId, feedbackType, feedbackText } = await request.json()

    // Validate input
    if (!messageId || !feedbackType) {
      return NextResponse.json(
        { error: 'Message ID and feedback type are required' },
        { status: 400 }
      )
    }

    // Validate feedback type
    if (!VALID_FEEDBACK_TYPES.includes(feedbackType)) {
      return NextResponse.json(
        { error: 'Invalid feedback type' },
        { status: 400 }
      )
    }

    // Validate feedback text length if provided
    if (feedbackText && feedbackText.length > 500) {
      return NextResponse.json(
        { error: 'Feedback text must be less than 500 characters' },
        { status: 400 }
      )
    }

    const supabase = createClient()

    // Get authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    // Rate limiting: 10 feedbacks per 5 minutes per user
    const now = Date.now()
    const userRateLimit = feedbackRateLimit.get(user.id)

    if (userRateLimit) {
      if (now < userRateLimit.resetTime) {
        if (userRateLimit.count >= 10) {
          return NextResponse.json(
            { error: 'Too many feedback submissions. Please try again later.' },
            { status: 429 }
          )
        }
        userRateLimit.count++
      } else {
        // Reset the rate limit window
        feedbackRateLimit.set(user.id, { count: 1, resetTime: now + 5 * 60 * 1000 })
      }
    } else {
      // First feedback from this user
      feedbackRateLimit.set(user.id, { count: 1, resetTime: now + 5 * 60 * 1000 })
    }

    // Verify user owns the message via conversation
    const { data: message } = await supabase
      .from('messages')
      .select('conversation_id')
      .eq('id', messageId)
      .single()

    if (!message) {
      return NextResponse.json(
        { error: 'Message not found' },
        { status: 404 }
      )
    }

    // Verify user owns the conversation
    const { data: conversation } = await supabase
      .from('conversations')
      .select('id')
      .eq('id', message.conversation_id)
      .eq('user_id', user.id)
      .single()

    if (!conversation) {
      return NextResponse.json(
        { error: 'Unauthorized to provide feedback for this message' },
        { status: 403 }
      )
    }

    // Check if feedback already exists
    const { data: existingFeedback } = await supabase
      .from('message_feedback')
      .select('id')
      .eq('message_id', messageId)
      .eq('user_id', user.id)
      .single()

    let result
    if (existingFeedback) {
      // Update existing feedback
      result = await supabase
        .from('message_feedback')
        .update({
          feedback_type: feedbackType,
          feedback_text: feedbackText
        })
        .eq('id', existingFeedback.id)
        .select()
        .single()
    } else {
      // Insert new feedback
      result = await supabase
        .from('message_feedback')
        .insert({
          message_id: messageId,
          user_id: user.id,
          feedback_type: feedbackType,
          feedback_text: feedbackText
        })
        .select()
        .single()
    }

    if (result.error) {
      throw result.error
    }

    // Update user profile preferences based on feedback
    if (feedbackType === 'too_detailed' || feedbackType === 'too_brief') {
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('preferences')
        .eq('user_id', user.id)
        .single()

      if (profile) {
        const preferences = profile.preferences || {}

        if (feedbackType === 'too_detailed') {
          preferences.likes_detailed_explanations = false
        } else if (feedbackType === 'too_brief') {
          preferences.likes_detailed_explanations = true
        }

        await supabase
          .from('user_profiles')
          .update({ preferences })
          .eq('user_id', user.id)
      }
    }

    return NextResponse.json({
      success: true,
      feedback: result.data
    })

  } catch (error) {
    console.error('Feedback API error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}