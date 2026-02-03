'use client'

import { useAuth } from '@/hooks/useAuth'
import AuthForm from '@/components/auth/AuthForm'
import ChatInterface from '@/components/chat/ChatInterface'

export default function Home() {
  const { user, loading } = useAuth()

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-lg">Loading...</div>
      </div>
    )
  }

  if (!user) {
    return <AuthForm />
  }

  return (
    <div className="h-screen bg-gray-50">
      <ChatInterface />
    </div>
  )
}
