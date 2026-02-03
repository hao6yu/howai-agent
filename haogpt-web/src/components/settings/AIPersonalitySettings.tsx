'use client'

import { useState, useEffect } from 'react'
import { Camera, RefreshCw, Save, Lock, CheckCircle, XCircle } from 'lucide-react'
import { useAuth } from '@/hooks/useAuth'
import { supabase } from '@/lib/supabase'

interface AIPersonalityConfig {
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
  created_at?: string
  updated_at?: string
}

interface AIPersonalitySettingsProps {
  isPremium?: boolean
  darkMode?: boolean
}

export default function AIPersonalitySettings({ isPremium = false, darkMode = false }: AIPersonalitySettingsProps) {
  const { user } = useAuth()
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [hasChanges, setHasChanges] = useState(false)
  const [saveMessage, setSaveMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null)
  const [personality, setPersonality] = useState<AIPersonalityConfig>({
    user_id: '',
    ai_name: 'HowAI',
    personality: 'friendly',
    humor_level: 'dry',
    communication_style: 'tech-savvy',
    response_length: 'moderate',
    expertise: 'general',
    interests: '',
    background_story: ''
  })

  // Load existing personality settings
  useEffect(() => {
    if (user) {
      loadPersonality()
    }
  }, [user])

  const loadPersonality = async () => {
    if (!user) return

    setLoading(true)
    try {
      const { data, error } = await supabase
        .from('ai_personalities')
        .select('*')
        .eq('user_id', user.id)
        .single()

      if (data) {
        setPersonality(data)
      } else {
        // Set default with user_id
        setPersonality(prev => ({ ...prev, user_id: user.id }))
      }
    } catch (error) {
      console.error('Error loading AI personality:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    if (!user || !isPremium) return

    setSaving(true)
    try {
      const dataToSave = {
        ...personality,
        user_id: user.id,
        updated_at: new Date().toISOString()
      }

      if (personality.id) {
        // Update existing
        const { error } = await supabase
          .from('ai_personalities')
          .update(dataToSave)
          .eq('id', personality.id)

        if (error) throw error
      } else {
        // Create new
        const { data, error } = await supabase
          .from('ai_personalities')
          .insert({
            ...dataToSave,
            created_at: new Date().toISOString()
          })
          .select()
          .single()

        if (error) throw error
        if (data) setPersonality(data)
      }

      setHasChanges(false)
      // Show success message
      setSaveMessage({ type: 'success', text: 'AI personality saved successfully!' })
      setTimeout(() => setSaveMessage(null), 3000)
    } catch (error) {
      console.error('Error saving AI personality:', error)
      setSaveMessage({ type: 'error', text: 'Failed to save AI personality. Please try again.' })
    } finally {
      setSaving(false)
    }
  }

  const handleReset = async () => {
    if (!confirm('Reset AI personality to default settings?')) return

    if (!user) return

    try {
      // Get master personality template from database
      const { data: masterData, error: masterError } = await supabase
        .from('ai_personalities')
        .select('*')
        .eq('is_master', true)
        .single()

      if (masterError || !masterData) {
        // Fallback to hardcoded defaults if master not found
        setPersonality({
          user_id: user.id,
          ai_name: 'HowAI',
          personality: 'friendly',
          humor_level: 'dry',
          communication_style: 'tech-savvy',
          response_length: 'moderate',
          expertise: 'general',
          interests: '',
          background_story: ''
        })
      } else {
        // Use master template values
        setPersonality(prev => ({
          ...prev,
          ai_name: masterData.ai_name,
          personality: masterData.personality,
          humor_level: masterData.humor_level,
          communication_style: masterData.communication_style,
          response_length: masterData.response_length,
          expertise: masterData.expertise,
          interests: masterData.interests || '',
          background_story: masterData.background_story || ''
        }))
      }

      setHasChanges(true)
    } catch (error) {
      console.error('Error resetting to defaults:', error)
      setSaveMessage({ type: 'error', text: 'Failed to reset to defaults. Please try again.' })
    }
  }

  const handleChange = (field: keyof AIPersonalityConfig, value: any) => {
    setPersonality(prev => ({ ...prev, [field]: value }))
    setHasChanges(true)
    // Clear any existing messages when user starts making changes
    if (saveMessage) {
      setSaveMessage(null)
    }
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
      </div>
    )
  }

  if (!isPremium) {
    return (
      <div className={`p-6 rounded-lg ${darkMode ? 'bg-gray-800' : 'bg-gray-50'}`}>
        <div className="flex items-center justify-between mb-4">
          <h3 className={`text-lg font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>
            AI Personality Customization
          </h3>
          <Lock className="text-gray-400" size={20} />
        </div>
        <p className={`mb-4 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
          Customize your AI assistant's personality, communication style, and expertise areas.
        </p>
        <button className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
          Upgrade to Premium
        </button>
      </div>
    )
  }

  return (
    <div className={`p-6 rounded-lg ${darkMode ? 'bg-gray-800' : 'bg-white'} shadow-sm`}>
      <div className="flex items-center justify-between mb-6">
        <h3 className={`text-xl font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>
          AI Personality Settings
        </h3>
        <div className="flex gap-2">
          <button
            onClick={handleReset}
            className={`p-2 rounded-lg transition-colors ${
              darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'
            }`}
            title="Reset to default"
          >
            <RefreshCw size={18} />
          </button>
          <button
            onClick={handleSave}
            disabled={!hasChanges || saving}
            className={`px-4 py-2 rounded-lg flex items-center gap-2 transition-colors ${
              hasChanges && !saving
                ? 'bg-blue-500 text-white hover:bg-blue-600'
                : darkMode
                  ? 'bg-gray-700 text-gray-400 cursor-not-allowed'
                  : 'bg-gray-200 text-gray-400 cursor-not-allowed'
            }`}
          >
            <Save size={16} />
            {saving ? 'Saving...' : 'Save'}
          </button>
        </div>
      </div>

      {/* Success/Error Message */}
      {saveMessage && (
        <div className={`mb-4 p-3 rounded-lg flex items-center gap-3 ${
          saveMessage.type === 'success'
            ? darkMode ? 'bg-green-900/30 text-green-300 border border-green-800' : 'bg-green-50 text-green-700 border border-green-200'
            : darkMode ? 'bg-red-900/30 text-red-300 border border-red-800' : 'bg-red-50 text-red-700 border border-red-200'
        }`}>
          {saveMessage.type === 'success' ? (
            <CheckCircle size={20} className="flex-shrink-0" />
          ) : (
            <XCircle size={20} className="flex-shrink-0" />
          )}
          <span className="text-sm font-medium">{saveMessage.text}</span>
        </div>
      )}

      <div className="space-y-6">
        {/* AI Name and Avatar */}
        <div>
          <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
            AI Assistant Name
          </label>
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-2xl overflow-hidden flex items-center justify-center">
              <img
                src="/howai-icon.png"
                alt="HowAI"
                className="w-16 h-16 rounded-2xl object-cover"
              />
            </div>
            <input
              type="text"
              value={personality.ai_name}
              onChange={(e) => handleChange('ai_name', e.target.value)}
              className={`flex-1 px-3 py-2 rounded-lg border ${
                darkMode
                  ? 'bg-gray-700 border-gray-600 text-white'
                  : 'bg-white border-gray-300 text-gray-900'
              }`}
              placeholder="e.g., Assistant, Helper, Alex"
            />
          </div>
        </div>

        {/* Personality Traits Grid */}
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
              Personality
            </label>
            <select
              value={personality.personality}
              onChange={(e) => handleChange('personality', e.target.value)}
              className={`w-full px-3 py-2 rounded-lg border ${
                darkMode
                  ? 'bg-gray-700 border-gray-600 text-white'
                  : 'bg-white border-gray-300 text-gray-900'
              }`}
            >
              <option value="friendly">Friendly & Approachable</option>
              <option value="professional">Professional & Rigorous</option>
              <option value="witty">Witty & Humorous</option>
              <option value="caring">Caring & Compassionate</option>
              <option value="energetic">Energetic & Vibrant</option>
            </select>
          </div>

          <div>
            <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
              Humor Level
            </label>
            <select
              value={personality.humor_level}
              onChange={(e) => handleChange('humor_level', e.target.value)}
              className={`w-full px-3 py-2 rounded-lg border ${
                darkMode
                  ? 'bg-gray-700 border-gray-600 text-white'
                  : 'bg-white border-gray-300 text-gray-900'
              }`}
            >
              <option value="none">Serious & Professional</option>
              <option value="light">Occasionally Humorous</option>
              <option value="dry">Dry & Witty</option>
              <option value="moderate">Moderately Humorous</option>
              <option value="heavy">Frequently Humorous</option>
            </select>
          </div>

          <div>
            <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
              Communication Style
            </label>
            <select
              value={personality.communication_style}
              onChange={(e) => handleChange('communication_style', e.target.value)}
              className={`w-full px-3 py-2 rounded-lg border ${
                darkMode
                  ? 'bg-gray-700 border-gray-600 text-white'
                  : 'bg-white border-gray-300 text-gray-900'
              }`}
            >
              <option value="casual">Casual & Relaxed</option>
              <option value="formal">Formal & Structured</option>
              <option value="tech-savvy">Tech-Oriented</option>
              <option value="supportive">Supportive & Encouraging</option>
            </select>
          </div>

          <div>
            <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
              Response Length
            </label>
            <select
              value={personality.response_length}
              onChange={(e) => handleChange('response_length', e.target.value)}
              className={`w-full px-3 py-2 rounded-lg border ${
                darkMode
                  ? 'bg-gray-700 border-gray-600 text-white'
                  : 'bg-white border-gray-300 text-gray-900'
              }`}
            >
              <option value="concise">Concise & Brief</option>
              <option value="moderate">Moderate Detail</option>
              <option value="detailed">Detailed & Comprehensive</option>
            </select>
          </div>
        </div>

        {/* Expertise Area */}
        <div>
          <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
            Expertise Area
          </label>
          <select
            value={personality.expertise}
            onChange={(e) => handleChange('expertise', e.target.value)}
            className={`w-full px-3 py-2 rounded-lg border ${
              darkMode
                ? 'bg-gray-700 border-gray-600 text-white'
                : 'bg-white border-gray-300 text-gray-900'
            }`}
          >
            <option value="general">General Knowledge</option>
            <option value="technology">Technology Expert</option>
            <option value="business">Business Analysis</option>
            <option value="creative">Creative Design</option>
            <option value="academic">Academic Research</option>
          </select>
        </div>

        {/* Interests */}
        <div>
          <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
            Interests & Hobbies
          </label>
          <textarea
            value={personality.interests || ''}
            onChange={(e) => handleChange('interests', e.target.value)}
            rows={3}
            className={`w-full px-3 py-2 rounded-lg border resize-none ${
              darkMode
                ? 'bg-gray-700 border-gray-600 text-white'
                : 'bg-white border-gray-300 text-gray-900'
            }`}
            placeholder="e.g., Programming, Music, Photography, Travel, Reading, Gaming, Art, Sports, Cooking..."
          />
        </div>

        {/* Background Story */}
        <div>
          <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
            Background Story (Optional)
          </label>
          <textarea
            value={personality.background_story || ''}
            onChange={(e) => handleChange('background_story', e.target.value)}
            rows={4}
            className={`w-full px-3 py-2 rounded-lg border resize-none ${
              darkMode
                ? 'bg-gray-700 border-gray-600 text-white'
                : 'bg-white border-gray-300 text-gray-900'
            }`}
            placeholder="Describe your AI's background story, experience, expertise areas, or personality traits to make conversations more personal and engaging..."
          />
        </div>
      </div>

      {/* Info Box */}
      <div className={`mt-6 p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-blue-50'}`}>
        <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-blue-700'}`}>
          💡 <strong>Tip:</strong> Your AI personality settings work alongside automatic learning.
          The AI will combine your manual preferences with insights learned from your conversations for the best experience.
        </p>
      </div>
    </div>
  )
}