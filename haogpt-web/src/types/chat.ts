export interface Message {
  id: string
  conversation_id: string
  content: string
  is_ai: boolean
  created_at: string
  image_urls?: string[]
}

export interface Conversation {
  id: string
  user_id: string
  title: string | null
  is_pinned: boolean
  created_at: string
  updated_at: string
  messages?: Message[]
}