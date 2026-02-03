import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase-server'

export async function GET() {
  try {
    const supabase = createClient()

    // Check if tables exist by trying to query them
    const checks = []

    // Check profiles table
    const { error: profilesError } = await supabase
      .from('profiles')
      .select('id')
      .limit(1)

    checks.push({
      table: 'profiles',
      exists: !profilesError,
      error: profilesError?.message
    })

    // Check conversations table
    const { error: conversationsError } = await supabase
      .from('conversations')
      .select('id, is_pinned')
      .limit(1)

    checks.push({
      table: 'conversations',
      exists: !conversationsError,
      error: conversationsError?.message,
      has_is_pinned: !conversationsError
    })

    // Check messages table
    const { error: messagesError } = await supabase
      .from('messages')
      .select('id')
      .limit(1)

    checks.push({
      table: 'messages',
      exists: !messagesError,
      error: messagesError?.message
    })

    const allTablesExist = checks.every(check => check.exists)

    return NextResponse.json({
      status: allTablesExist ? 'ready' : 'needs_setup',
      checks,
      message: allTablesExist
        ? 'Database is ready for use'
        : 'Database tables need to be created. Please run the database-schema.sql in your Supabase SQL editor.'
    })

  } catch (error) {
    console.error('Database check error:', error)
    return NextResponse.json(
      {
        status: 'error',
        error: 'Failed to check database status',
        message: 'Please ensure your Supabase connection is working'
      },
      { status: 500 }
    )
  }
}

export async function POST() {
  return NextResponse.json({
    status: 'info',
    message: 'Please run the updated database-schema.sql in your Supabase SQL editor to add the is_pinned column to conversations table.'
  })
}