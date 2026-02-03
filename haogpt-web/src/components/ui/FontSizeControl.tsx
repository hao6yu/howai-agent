'use client'

import { Type, Minus, Plus } from 'lucide-react'
import { useFontSize, fontSizeMap } from '@/context/FontSizeContext'

interface FontSizeControlProps {
  darkMode: boolean
  compact?: boolean
  inline?: boolean
}

export default function FontSizeControl({ darkMode, compact = false, inline = false }: FontSizeControlProps) {
  const { fontSize, increaseFontSize, decreaseFontSize } = useFontSize()

  // Inline version for header
  if (inline) {
    return (
      <div className={`flex items-center space-x-1`}>
        <button
          onClick={decreaseFontSize}
          disabled={fontSize === 'xs'}
          className={`p-2 rounded-lg transition-colors ${
            fontSize === 'xs'
              ? darkMode ? 'text-gray-600 cursor-not-allowed' : 'text-gray-300 cursor-not-allowed'
              : darkMode ? 'text-white hover:bg-gray-700 hover:text-gray-200' : 'text-gray-600 hover:bg-gray-100 hover:text-gray-800'
          }`}
          title="Decrease font size"
        >
          <Minus className="w-4 h-4" />
        </button>

        <button
          className={`p-2 rounded-lg transition-colors ${
            darkMode ? 'text-white hover:bg-gray-700' : 'text-gray-600 hover:bg-gray-100'
          }`}
          title={`Font size: ${fontSizeMap[fontSize].label}`}
        >
          <Type className="w-4 h-4" />
        </button>

        <button
          onClick={increaseFontSize}
          disabled={fontSize === 'xl'}
          className={`p-2 rounded-lg transition-colors ${
            fontSize === 'xl'
              ? darkMode ? 'text-gray-600 cursor-not-allowed' : 'text-gray-300 cursor-not-allowed'
              : darkMode ? 'text-white hover:bg-gray-700 hover:text-gray-200' : 'text-gray-600 hover:bg-gray-100 hover:text-gray-800'
          }`}
          title="Increase font size"
        >
          <Plus className="w-4 h-4" />
        </button>
      </div>
    )
  }

  if (compact) {
    // Compact floating version (no longer used, but kept for compatibility)
    return (
      <div className={`fixed bottom-24 right-6 z-40 flex items-center space-x-1 p-2 rounded-full shadow-lg ${
        darkMode ? 'bg-gray-800 border border-gray-700' : 'bg-white border border-gray-200'
      }`}>
        <button
          onClick={decreaseFontSize}
          disabled={fontSize === 'xs'}
          className={`p-1.5 rounded-full transition-colors ${
            fontSize === 'xs'
              ? darkMode ? 'text-gray-600 cursor-not-allowed' : 'text-gray-300 cursor-not-allowed'
              : darkMode ? 'text-gray-400 hover:text-white hover:bg-gray-700' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
          }`}
          title="Decrease font size"
        >
          <Minus className="w-4 h-4" />
        </button>

        <div className={`px-2 flex items-center space-x-1 ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>
          <Type className="w-4 h-4" />
          <span className="text-xs font-medium">{fontSizeMap[fontSize].label}</span>
        </div>

        <button
          onClick={increaseFontSize}
          disabled={fontSize === 'xl'}
          className={`p-1.5 rounded-full transition-colors ${
            fontSize === 'xl'
              ? darkMode ? 'text-gray-600 cursor-not-allowed' : 'text-gray-300 cursor-not-allowed'
              : darkMode ? 'text-gray-400 hover:text-white hover:bg-gray-700' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
          }`}
          title="Increase font size"
        >
          <Plus className="w-4 h-4" />
        </button>
      </div>
    )
  }

  // Full version for settings
  return (
    <div className={`flex items-center justify-between p-4 rounded-lg ${
      darkMode ? 'bg-gray-700/50' : 'bg-gray-50'
    }`}>
      <div className="flex items-center space-x-2">
        <Type className={`w-5 h-5 ${darkMode ? 'text-blue-400' : 'text-blue-600'}`} />
        <div>
          <div className={`font-medium ${darkMode ? 'text-white' : 'text-gray-900'}`}>Font Size</div>
          <div className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
            {fontSizeMap[fontSize].label}
          </div>
        </div>
      </div>

      <div className="flex items-center space-x-2">
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
    </div>
  )
}