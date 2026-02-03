'use client'

import { useState, useEffect } from 'react'
import { X, User, Palette, Brain, Bot, Bell, Shield, Info, Save, RefreshCw, Zap, MessageCircle, Heart, TrendingUp, HelpCircle, Type, Minus, Plus } from 'lucide-react'
import { useAuth } from '@/hooks/useAuth'
import { supabase } from '@/lib/supabase'
import AIPersonalitySettings from './AIPersonalitySettings'
import { useFontSize, fontSizeMap } from '@/context/FontSizeContext'

interface UserProfile {
  id?: string
  user_id: string
  preferred_language?: string
  detected_languages?: string[]
  communication_style?: any
  topic_interests?: any
  characteristics?: any
  behavioral_patterns?: any
  preferences?: any
  profile_summary?: string
  last_summary_update?: string
  message_count?: number
  total_conversations?: number
  last_analyzed_at?: string
  created_at?: string
  updated_at?: string
}

interface SettingsModalProps {
  isOpen: boolean
  onClose: () => void
  darkMode: boolean
  onDarkModeChange: (enabled: boolean) => void
}

export default function SettingsModal({ isOpen, onClose, darkMode, onDarkModeChange }: SettingsModalProps) {
  const { user } = useAuth()
  const { fontSize, setFontSize, increaseFontSize, decreaseFontSize } = useFontSize()
  const [activeSection, setActiveSection] = useState('profile')
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null)
  const [profileLoading, setProfileLoading] = useState(false)
  const [showTooltip, setShowTooltip] = useState(false)
  const [userNickname, setUserNickname] = useState('')
  const [nicknameLoading, setNicknameLoading] = useState(false)
  const [nicknameSaving, setNicknameSaving] = useState(false)
  const [nicknameChanged, setNicknameChanged] = useState(false)
  const isPremium = true // All web users are premium

  // Load user profile and nickname
  useEffect(() => {
    if (user && isOpen) {
      loadUserProfile()
      loadUserNickname()
    }
  }, [user, isOpen])

  const loadUserProfile = async () => {
    if (!user) return

    setProfileLoading(true)
    try {
      const { data, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', user.id)
        .single()

      if (data) {
        setUserProfile(data)
      }
    } catch (error) {
      console.error('Error loading user profile:', error)
    } finally {
      setProfileLoading(false)
    }
  }

  const loadUserNickname = async () => {
    if (!user) return

    setNicknameLoading(true)
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('name')
        .eq('id', user.id)
        .single()

      if (data && data.name) {
        setUserNickname(data.name)
      } else {
        // Fallback to email prefix if no name set
        const emailPrefix = user.email?.split('@')[0] || ''
        setUserNickname(emailPrefix)
      }
    } catch (error) {
      console.error('Error loading user nickname:', error)
      // Fallback to email prefix
      const emailPrefix = user.email?.split('@')[0] || ''
      setUserNickname(emailPrefix)
    } finally {
      setNicknameLoading(false)
    }
  }

  const saveUserNickname = async () => {
    if (!user || !nicknameChanged) return

    setNicknameSaving(true)
    try {
      const { error } = await supabase
        .from('profiles')
        .update({ name: userNickname.trim() })
        .eq('id', user.id)

      if (error) {
        throw error
      }

      setNicknameChanged(false)
      // Show success feedback (you could add a toast here)
      console.log('Nickname saved successfully')
    } catch (error) {
      console.error('Error saving nickname:', error)
      // You could show an error toast here
    } finally {
      setNicknameSaving(false)
    }
  }

  if (!isOpen) return null

  const sections = [
    { id: 'profile', label: 'Profile', icon: User, description: 'Account information' },
    { id: 'ai-personality', label: 'AI Assistant', icon: Bot, description: 'Customize your AI companion' },
    { id: 'preferences', label: 'Preferences', icon: Palette, description: 'App appearance & behavior' },
    { id: 'about', label: 'About & Privacy', icon: Info, description: 'App info & security' }
  ]

  const renderProfileSection = () => (
    <div className="space-y-6">
      <div>
        <h3 className={`text-lg font-semibold mb-4 ${darkMode ? 'text-white' : 'text-gray-900'}`}>
          Profile Information
        </h3>
        <div className="space-y-4">
          {/* User Nickname Field */}
          <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
            <label className={`block text-sm font-medium mb-2 ${darkMode ? 'text-gray-200' : 'text-gray-700'}`}>
              Display Name
            </label>
            <div className="flex items-center gap-3">
              <input
                type="text"
                value={userNickname}
                onChange={(e) => {
                  setUserNickname(e.target.value)
                  setNicknameChanged(true)
                }}
                disabled={nicknameLoading || nicknameSaving}
                className={`flex-1 px-3 py-2 rounded-lg border ${
                  darkMode
                    ? 'bg-gray-700 border-gray-600 text-white placeholder-gray-400'
                    : 'bg-white border-gray-300 text-gray-900 placeholder-gray-500'
                } focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                  nicknameLoading || nicknameSaving ? 'opacity-50 cursor-not-allowed' : ''
                }`}
                placeholder="Enter your display name"
              />
              <button
                onClick={saveUserNickname}
                disabled={!nicknameChanged || nicknameSaving || nicknameLoading}
                className={`px-4 py-2 rounded-lg flex items-center gap-2 transition-colors ${
                  nicknameChanged && !nicknameSaving && !nicknameLoading
                    ? 'bg-blue-500 text-white hover:bg-blue-600'
                    : darkMode
                      ? 'bg-gray-700 text-gray-400 cursor-not-allowed'
                      : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                }`}
              >
                <Save size={16} />
                {nicknameSaving ? 'Saving...' : 'Save'}
              </button>
            </div>
            <p className={`text-xs mt-2 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
              This name will be used by the AI to address you in conversations
            </p>
          </div>

          {/* Email Display */}
          <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
            <div className={`text-sm font-medium mb-1 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>Email</div>
            <div className={`text-base ${darkMode ? 'text-white' : 'text-gray-900'}`}>{user?.email}</div>
          </div>

        </div>
      </div>

      {/* AI Learning Profile Section */}
      <div>
        <div className="mb-4">
          <div className="flex items-center justify-between mb-1">
            <h3 className={`text-lg font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>
              AI Insights
            </h3>
            <div className="relative">
              <button
                onMouseEnter={() => setShowTooltip(true)}
                onMouseLeave={() => setShowTooltip(false)}
                className={`p-2 rounded-full transition-colors ${darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'}`}
              >
                <HelpCircle className={`w-5 h-5 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`} />
              </button>

              {showTooltip && (
                <div className={`absolute right-0 top-full mt-2 w-80 p-4 rounded-lg shadow-lg border z-10 ${darkMode ? 'bg-gray-800 border-gray-600' : 'bg-white border-gray-200'}`}>
                  <div className="flex items-start space-x-3">
                    <div className="p-2 rounded-full bg-gradient-to-r from-purple-500 to-pink-500">
                      <Brain className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <h4 className={`font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>
                        🧠 Your AI Gets Smarter Every Chat!
                      </h4>
                      <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        The more you chat, the better I understand your unique style, preferences, and needs.
                        Every conversation helps me learn your communication patterns, favorite topics, and personality traits
                        to provide increasingly personalized and helpful responses.
                        <span className="font-medium text-purple-500"> Keep chatting to unlock my full potential! ✨</span>
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
          <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>
            How AI understands you
          </p>
        </div>

        {profileLoading ? (
          <div className="flex items-center justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          </div>
        ) : userProfile ? (
          <div className="space-y-4">
            {/* Profile Summary */}
            {userProfile.profile_summary && (
              <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                <div className="flex items-center mb-3">
                  <User className={`w-5 h-5 mr-2 ${darkMode ? 'text-blue-400' : 'text-blue-600'}`} />
                  <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Profile Summary</span>
                </div>
                <p className={`text-sm leading-relaxed ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                  {userProfile.profile_summary}
                </p>
              </div>
            )}

            {/* Communication Style */}
            {userProfile.communication_style && Object.keys(userProfile.communication_style).length > 0 && (
              <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                <div className="flex items-center mb-3">
                  <MessageCircle className={`w-5 h-5 mr-2 ${darkMode ? 'text-blue-400' : 'text-blue-600'}`} />
                  <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Communication Style</span>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  {Object.entries(userProfile.communication_style).map(([key, value]) => (
                    <div key={key} className={`flex justify-between items-center py-2 px-3 rounded ${darkMode ? 'bg-gray-600/50' : 'bg-gray-100'}`}>
                      <span className={`text-xs font-medium capitalize ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        {key.replace('_', ' ')}
                      </span>
                      <span className={`text-xs font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>
                        {typeof value === 'boolean' ? (value ? 'Yes' : 'No') : String(value)}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Topic Interests */}
            {userProfile.topic_interests && Object.keys(userProfile.topic_interests).length > 0 && (
              <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                <div className="flex items-center mb-3">
                  <TrendingUp className={`w-5 h-5 mr-2 ${darkMode ? 'text-pink-400' : 'text-pink-600'}`} />
                  <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Topic Interests</span>
                </div>
                <div className="space-y-2">
                  {(() => {
                    const entries = Object.entries(userProfile.topic_interests);
                    const validEntries = entries.filter(([topic, score]) => {
                      // Skip malformed entries where topic is "[object Object]"
                      const isValidTopic = typeof topic === 'string' && topic !== '' && topic !== '[object Object]';
                      const isValidScore = typeof score === 'number' && !isNaN(score);
                      return isValidTopic && isValidScore;
                    });

                    if (validEntries.length === 0) {
                      return (
                        <div className={`p-3 rounded ${darkMode ? 'bg-gray-600/50' : 'bg-gray-100'}`}>
                          <div className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                            No topic interests recorded yet. Chat more with the AI to build your interest profile!
                          </div>
                        </div>
                      );
                    }

                    return validEntries
                      .sort(([,a], [,b]) => (b as number) - (a as number))
                      .map(([topic, score]) => (
                        <div key={topic} className={`flex justify-between items-center py-2 px-3 rounded ${darkMode ? 'bg-gray-600/50' : 'bg-gray-100'}`}>
                          <span className={`text-sm font-medium capitalize ${darkMode ? 'text-gray-200' : 'text-gray-800'}`}>
                            {topic.toLowerCase().replace(/[_-]/g, ' ')}
                          </span>
                          <div className="flex items-center space-x-2">
                            <div className={`w-12 h-2 rounded-full ${darkMode ? 'bg-gray-600' : 'bg-gray-200'}`}>
                              <div
                                className="h-2 rounded-full bg-pink-500"
                                style={{ width: `${Math.min(Math.max((score as number) * 100, 0), 100)}%` }}
                              />
                            </div>
                            <span className={`text-xs ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                              {Math.round((score as number) * 100)}%
                            </span>
                          </div>
                        </div>
                      ));
                  })()}
                </div>
              </div>
            )}

            {/* Characteristics */}
            {userProfile.characteristics && Object.keys(userProfile.characteristics).length > 0 && (
              <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                <div className="flex items-center mb-3">
                  <User className={`w-5 h-5 mr-2 ${darkMode ? 'text-green-400' : 'text-green-600'}`} />
                  <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>User Characteristics</span>
                </div>
                <div className="space-y-2">
                  {Object.entries(userProfile.characteristics).map(([key, value]) => (
                    <div key={key} className={`py-2 px-3 rounded ${darkMode ? 'bg-gray-600/50' : 'bg-gray-100'}`}>
                      <div className={`text-xs font-medium capitalize mb-1 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        {key.replace('_', ' ')}
                      </div>
                      <div className={`text-sm ${darkMode ? 'text-white' : 'text-gray-900'}`}>
                        {Array.isArray(value) ? value.join(', ') : String(value)}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Behavioral Patterns */}
            {userProfile.behavioral_patterns && Object.keys(userProfile.behavioral_patterns).length > 0 && (
              <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                <div className="flex items-center mb-3">
                  <Brain className={`w-5 h-5 mr-2 ${darkMode ? 'text-purple-400' : 'text-purple-600'}`} />
                  <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Behavioral Patterns</span>
                </div>
                <div className="space-y-2">
                  {Object.entries(userProfile.behavioral_patterns)
                    .filter(([key]) => key !== 'avg_message_length')
                    .map(([key, value]) => (
                    <div key={key} className={`py-2 px-3 rounded ${darkMode ? 'bg-gray-600/50' : 'bg-gray-100'}`}>
                      <div className={`text-xs font-medium capitalize mb-1 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        {key.replace('_', ' ')}
                      </div>
                      <div className={`text-sm ${darkMode ? 'text-white' : 'text-gray-900'}`}>
                        {typeof value === 'object' ? JSON.stringify(value, null, 2) : String(value)}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* User Preferences */}
            {userProfile.preferences && Object.keys(userProfile.preferences).length > 0 && (
              <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                <div className="flex items-center mb-3">
                  <Info className={`w-5 h-5 mr-2 ${darkMode ? 'text-yellow-400' : 'text-yellow-600'}`} />
                  <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>User Preferences</span>
                </div>
                <div className="grid grid-cols-1 gap-2">
                  {Object.entries(userProfile.preferences).map(([key, value]) => (
                    <div key={key} className={`flex justify-between items-center py-2 px-3 rounded ${darkMode ? 'bg-gray-600/50' : 'bg-gray-100'}`}>
                      <span className={`text-xs font-medium ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        {key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                      </span>
                      <span className={`text-xs font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>
                        {typeof value === 'boolean' ? (value ? 'Yes' : 'No') : String(value)}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Language & Stats */}
            <div className="grid grid-cols-2 gap-4">
              {/* Language Info */}
              {userProfile.preferred_language && (
                <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                  <div className="flex items-center mb-2">
                    <span className="text-lg mr-2">🌍</span>
                    <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Preferred Language</span>
                  </div>
                  <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    {userProfile.preferred_language.toUpperCase()}
                  </p>
                </div>
              )}

              {/* Stats */}
              <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
                <div className="flex items-center mb-2">
                  <span className="text-lg mr-2">📊</span>
                  <span className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Activity</span>
                </div>
                <div className="space-y-1">
                  <p className={`text-xs ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    {userProfile.message_count || 0} messages
                  </p>
                  <p className={`text-xs ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    {userProfile.total_conversations || 0} conversations
                  </p>
                </div>
              </div>
            </div>

            {userProfile.updated_at && (
              <div className={`text-xs text-center pt-2 ${darkMode ? 'text-gray-500' : 'text-gray-400'}`}>
                Profile last updated: {new Date(userProfile.updated_at).toLocaleDateString()}
              </div>
            )}
          </div>
        ) : (
          <div className={`text-center py-8 ${darkMode ? 'bg-gray-700/30' : 'bg-gray-50'} rounded-lg`}>
            <Brain className={`w-12 h-12 mx-auto mb-3 ${darkMode ? 'text-gray-500' : 'text-gray-400'}`} />
            <h4 className={`font-medium mb-2 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
              Start Building Your AI Profile
            </h4>
            <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
              Chat with me more to help me learn your preferences and communication style!
            </p>
          </div>
        )}
      </div>
    </div>
  )

  const renderPreferencesSection = () => (
    <div className="space-y-6">
      <div>
        <h3 className={`text-lg font-semibold mb-4 ${darkMode ? 'text-white' : 'text-gray-900'}`}>
          App Preferences
        </h3>
        <div className="space-y-4">
          {/* Font Size Control */}
          <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
            <div className="mb-4">
              <div className="flex items-center mb-2">
                <Type className={`w-5 h-5 mr-2 ${darkMode ? 'text-blue-400' : 'text-blue-600'}`} />
                <div className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Font Size</div>
              </div>
              <div className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                Adjust the text size across the entire app
              </div>
            </div>

            <div className="flex items-center justify-between">
              <button
                onClick={decreaseFontSize}
                disabled={fontSize === 'xs'}
                className={`p-2 rounded-lg transition-colors ${
                  fontSize === 'xs'
                    ? darkMode ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                    : darkMode ? 'bg-gray-600 text-white hover:bg-gray-500' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
                title="Decrease font size"
              >
                <Minus className="w-4 h-4" />
              </button>

              <div className="flex items-center space-x-3 px-4">
                <div className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                  {fontSizeMap[fontSize].label}
                </div>
                <div className="flex space-x-1">
                  {Object.keys(fontSizeMap).map((size) => (
                    <button
                      key={size}
                      onClick={() => setFontSize(size as keyof typeof fontSizeMap)}
                      className={`w-2 h-2 rounded-full transition-colors ${
                        fontSize === size
                          ? 'bg-blue-500'
                          : darkMode ? 'bg-gray-600' : 'bg-gray-300'
                      }`}
                      title={fontSizeMap[size as keyof typeof fontSizeMap].label}
                    />
                  ))}
                </div>
              </div>

              <button
                onClick={increaseFontSize}
                disabled={fontSize === 'xl'}
                className={`p-2 rounded-lg transition-colors ${
                  fontSize === 'xl'
                    ? darkMode ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                    : darkMode ? 'bg-gray-600 text-white hover:bg-gray-500' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
                title="Increase font size"
              >
                <Plus className="w-4 h-4" />
              </button>
            </div>

            <div className={`mt-3 text-xs ${darkMode ? 'text-gray-400' : 'text-gray-500'} text-center`}>
              Preview: The quick brown fox jumps over the lazy dog
            </div>
          </div>

          {/* Dark Mode Toggle */}
          <div className={`flex items-center justify-between p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
            <div>
              <div className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Dark Mode</div>
              <div className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>Switch between light and dark themes</div>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={darkMode}
                onChange={(e) => onDarkModeChange(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>

        </div>
      </div>
    </div>
  )

  const renderAboutSection = () => (
    <div className="space-y-6">
      <div>
        <h3 className={`text-lg font-semibold mb-4 ${darkMode ? 'text-white' : 'text-gray-900'}`}>
          About HowAI
        </h3>
        <div className="space-y-4">
          <div className="text-center mb-6">
            <div className="w-20 h-20 mx-auto mb-4">
              <img
                src="/howai-icon.png"
                alt="HowAI"
                className="w-20 h-20 rounded-2xl"
              />
            </div>
            <h4 className={`text-xl font-bold ${darkMode ? 'text-white' : 'text-gray-900'}`}>HowAI</h4>
            <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>Your Intelligent AI Assistant</p>
          </div>

          <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
            <div className={`text-sm space-y-2 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
              <div><span className="font-medium">Version:</span> 1.0.0</div>
              <div><span className="font-medium">Platform:</span> Web</div>
            </div>
          </div>

          <div className={`p-4 rounded-lg ${darkMode ? 'bg-gray-700/50' : 'bg-gray-50'}`}>
            <div className="flex items-center justify-between mb-3">
              <div className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Data Storage</div>
              <span className={`text-sm px-2 py-1 rounded ${darkMode ? 'bg-green-900 text-green-300' : 'bg-green-100 text-green-800'}`}>
                Secure
              </span>
            </div>
            <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
              Your conversations are stored securely and encrypted. Only you can access your data.
            </p>
          </div>
        </div>
      </div>
    </div>
  )

  const renderSectionContent = () => {
    switch (activeSection) {
      case 'profile':
        return renderProfileSection()
      case 'ai-personality':
        return <AIPersonalitySettings isPremium={isPremium} darkMode={darkMode} />
      case 'preferences':
        return renderPreferencesSection()
      case 'about':
        return renderAboutSection()
      default:
        return renderProfileSection()
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className={`rounded-xl shadow-2xl max-w-5xl w-full max-h-[90vh] overflow-hidden ${darkMode ? 'bg-gray-800' : 'bg-white'}`}>
        {/* Header */}
        <div className={`flex items-center justify-between p-6 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
          <div>
            <h2 className={`text-2xl font-bold ${darkMode ? 'text-white' : 'text-gray-900'}`}>Settings</h2>
            <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>Customize your HowAI experience</p>
          </div>
          <button
            onClick={onClose}
            className={`p-2 rounded-lg transition-colors ${darkMode ? 'text-gray-400 hover:text-gray-200 hover:bg-gray-700' : 'text-gray-400 hover:text-gray-600 hover:bg-gray-100'}`}
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="flex h-[calc(90vh-80px)]">
          {/* Sidebar */}
          <div className={`w-64 border-r overflow-y-auto ${darkMode ? 'border-gray-700 bg-gray-800/50' : 'border-gray-200 bg-gray-50'}`}>
            <div className="p-4">
              <nav className="space-y-1">
                {sections.map((section) => {
                  const Icon = section.icon
                  const isActive = activeSection === section.id

                  return (
                    <button
                      key={section.id}
                      onClick={() => setActiveSection(section.id)}
                      className={`w-full flex items-center px-3 py-3 text-left rounded-lg transition-colors group ${
                        isActive
                          ? darkMode
                            ? 'bg-blue-900 text-blue-300'
                            : 'bg-blue-50 text-blue-700'
                          : darkMode
                            ? 'text-gray-300 hover:bg-gray-700'
                            : 'text-gray-700 hover:bg-gray-100'
                      }`}
                    >
                      <Icon className={`w-5 h-5 mr-3 ${isActive ? (darkMode ? 'text-blue-300' : 'text-blue-700') : (darkMode ? 'text-gray-400' : 'text-gray-500')}`} />
                      <div className="flex-1 min-w-0">
                        <span className="font-medium truncate">{section.label}</span>
                        <p className={`text-xs truncate ${darkMode ? 'text-gray-500' : 'text-gray-500'}`}>
                          {section.description}
                        </p>
                      </div>
                    </button>
                  )
                })}
              </nav>
            </div>
          </div>

          {/* Main Content */}
          <div className="flex-1 overflow-y-auto">
            <div className="p-6">
              {renderSectionContent()}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}