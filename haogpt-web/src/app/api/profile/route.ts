import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase-server'
import { UserProfileService } from '@/services/userProfileService'

/**
 * GET /api/profile - Get current user's profile
 */
export async function GET() {
  try {
    const supabase = createClient()

    // Get authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    // Get user profile
    const profile = await UserProfileService.getOrCreateProfile(user.id)

    return NextResponse.json({
      profile,
      profileContext: await UserProfileService.getProfileContext(user.id)
    })

  } catch (error) {
    console.error('Profile API error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

/**
 * POST /api/profile/evaluate - Manually trigger profile evaluation
 */
export async function POST(request: NextRequest) {
  try {
    const { conversationId } = await request.json()

    const supabase = createClient()

    // Get authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    // Get recent messages from conversation
    const { data: messages } = await supabase
      .from('messages')
      .select('content, is_ai, created_at')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: false })
      .limit(20)

    if (!messages || messages.length === 0) {
      return NextResponse.json(
        { error: 'No messages found in conversation' },
        { status: 400 }
      )
    }

    // Evaluate and update profile
    const insights = await UserProfileService.evaluateAndUpdateProfile(
      user.id,
      conversationId,
      messages.reverse() // Reverse to get chronological order
    )

    // Get updated profile
    const updatedProfile = await UserProfileService.getOrCreateProfile(user.id)

    return NextResponse.json({
      success: true,
      insights,
      profile: updatedProfile
    })

  } catch (error) {
    console.error('Profile evaluation API error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}