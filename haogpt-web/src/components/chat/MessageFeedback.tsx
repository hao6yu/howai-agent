'use client'

import { useState, useEffect } from 'react'
import { ThumbsUp, ThumbsDown, MessageSquare, X, Check, AlertCircle, Copy } from 'lucide-react'

export type FeedbackType = 'helpful' | 'not_helpful' | 'too_detailed' | 'too_brief' | 'off_topic' | 'perfect'

interface MessageFeedbackProps {
  messageId: string
  darkMode?: boolean
  onCopy?: () => void
  copied?: boolean
  onFeedbackSubmit?: (feedback: FeedbackType, text?: string) => void
}

export default function MessageFeedback({ messageId, darkMode = false, onCopy, copied = false, onFeedbackSubmit }: MessageFeedbackProps) {
  const [showFeedback, setShowFeedback] = useState(false)
  const [selectedFeedback, setSelectedFeedback] = useState<FeedbackType | null>(null)
  const [feedbackText, setFeedbackText] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Check if feedback was already submitted for this message
  useEffect(() => {
    const submittedFeedbacks = JSON.parse(localStorage.getItem('submittedFeedbacks') || '{}')
    if (submittedFeedbacks[messageId]) {
      setSubmitted(true)
      setSelectedFeedback(submittedFeedbacks[messageId])
    }
  }, [messageId])

  const handleQuickFeedback = async (type: 'helpful' | 'not_helpful') => {
    if (submitted || isSubmitting) return

    setIsSubmitting(true)
    setError(null)

    try {
      const response = await fetch('/api/profile/feedback', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messageId,
          feedbackType: type,
          feedbackText: null
        })
      })

      if (!response.ok) {
        throw new Error('Failed to submit feedback')
      }

      setSelectedFeedback(type)
      setSubmitted(true)

      // Store in localStorage to persist across page refreshes
      const submittedFeedbacks = JSON.parse(localStorage.getItem('submittedFeedbacks') || '{}')
      submittedFeedbacks[messageId] = type
      localStorage.setItem('submittedFeedbacks', JSON.stringify(submittedFeedbacks))

      if (onFeedbackSubmit) {
        onFeedbackSubmit(type)
      }

      // Hide feedback after 2 seconds
      setTimeout(() => {
        setShowFeedback(false)
      }, 2000)
    } catch (err) {
      setError('Failed to submit feedback. Please try again.')
      console.error('Feedback submission error:', err)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleDetailedFeedback = async () => {
    if (!selectedFeedback || isSubmitting) return

    setIsSubmitting(true)
    setError(null)

    try {
      const response = await fetch('/api/profile/feedback', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messageId,
          feedbackType: selectedFeedback,
          feedbackText: feedbackText || null
        })
      })

      if (!response.ok) {
        throw new Error('Failed to submit feedback')
      }

      setSubmitted(true)

      // Store in localStorage
      const submittedFeedbacks = JSON.parse(localStorage.getItem('submittedFeedbacks') || '{}')
      submittedFeedbacks[messageId] = selectedFeedback
      localStorage.setItem('submittedFeedbacks', JSON.stringify(submittedFeedbacks))

      if (onFeedbackSubmit) {
        onFeedbackSubmit(selectedFeedback, feedbackText)
      }

      // Reset and hide
      setTimeout(() => {
        setShowFeedback(false)
        setFeedbackText('')
      }, 2000)
    } catch (err) {
      setError('Failed to submit feedback. Please try again.')
      console.error('Feedback submission error:', err)
    } finally {
      setIsSubmitting(false)
    }
  }

  const feedbackOptions: { value: FeedbackType; label: string; description: string }[] = [
    { value: 'perfect', label: 'Perfect', description: 'Exactly what I needed' },
    { value: 'helpful', label: 'Helpful', description: 'Good response' },
    { value: 'not_helpful', label: 'Not Helpful', description: 'Didn\'t address my needs' },
    { value: 'too_detailed', label: 'Too Detailed', description: 'Response was too verbose' },
    { value: 'too_brief', label: 'Too Brief', description: 'Need more detail' },
    { value: 'off_topic', label: 'Off Topic', description: 'Missed the point' }
  ]

  return (
    <div className="flex items-center gap-2 mt-2">
      {/* Action buttons: Copy, Helpful, Not Helpful */}
      {!submitted && (
        <div className="flex items-center gap-1 opacity-60 group-hover:opacity-100 transition-opacity">
          {/* Copy button */}
          {onCopy && (
            <button
              onClick={onCopy}
              disabled={isSubmitting}
              className={`p-1.5 rounded-md transition-colors ${
                copied
                  ? 'bg-green-500 text-white'
                  : darkMode
                    ? 'hover:bg-gray-700 text-gray-400 hover:text-gray-200'
                    : 'hover:bg-gray-100 text-gray-500 hover:text-gray-700'
              } ${isSubmitting ? 'opacity-50 cursor-not-allowed' : ''}`}
              title={copied ? 'Copied!' : 'Copy text'}
            >
              {copied ? <Check size={14} /> : <Copy size={14} />}
            </button>
          )}

          {/* Helpful button */}
          <button
            onClick={() => handleQuickFeedback('helpful')}
            disabled={isSubmitting}
            className={`p-1.5 rounded-md transition-colors ${
              darkMode
                ? 'hover:bg-gray-700 text-gray-400 hover:text-gray-200'
                : 'hover:bg-gray-100 text-gray-500 hover:text-gray-700'
            } ${isSubmitting ? 'opacity-50 cursor-not-allowed' : ''}`}
            title="Helpful"
          >
            <ThumbsUp size={14} />
          </button>

          {/* Not helpful button */}
          <button
            onClick={() => handleQuickFeedback('not_helpful')}
            disabled={isSubmitting}
            className={`p-1.5 rounded-md transition-colors ${
              darkMode
                ? 'hover:bg-gray-700 text-gray-400 hover:text-gray-200'
                : 'hover:bg-gray-100 text-gray-500 hover:text-gray-700'
            } ${isSubmitting ? 'opacity-50 cursor-not-allowed' : ''}`}
            title="Not helpful"
          >
            <ThumbsDown size={14} />
          </button>
        </div>
      )}

      {/* Submitted indicator */}
      {submitted && !showFeedback && (
        <div className={`flex items-center gap-1 text-xs ${
          darkMode ? 'text-green-400' : 'text-green-600'
        }`}>
          <Check size={14} />
          <span>Feedback received</span>
        </div>
      )}

      {/* Detailed feedback modal */}
      {showFeedback && !submitted && (
        <div className={`absolute left-0 right-0 top-full mt-2 p-4 rounded-lg shadow-lg z-10 ${
          darkMode ? 'bg-gray-800 border border-gray-700' : 'bg-white border border-gray-200'
        }`}>
          <div className="flex justify-between items-start mb-3">
            <h4 className={`font-medium ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>
              How was this response?
            </h4>
            <button
              onClick={() => {
                setShowFeedback(false)
                setSelectedFeedback(null)
                setFeedbackText('')
                setError(null)
              }}
              className={`p-1 rounded-md transition-colors ${
                darkMode
                  ? 'hover:bg-gray-700 text-gray-400'
                  : 'hover:bg-gray-100 text-gray-600'
              }`}
            >
              <X size={16} />
            </button>
          </div>

          {/* Feedback options */}
          <div className="grid grid-cols-2 gap-2 mb-3">
            {feedbackOptions.map((option) => (
              <button
                key={option.value}
                onClick={() => setSelectedFeedback(option.value)}
                disabled={isSubmitting}
                className={`p-2 rounded-md text-left transition-colors ${
                  selectedFeedback === option.value
                    ? darkMode
                      ? 'bg-blue-600 text-white'
                      : 'bg-blue-500 text-white'
                    : darkMode
                      ? 'bg-gray-700 text-gray-200 hover:bg-gray-600'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                } ${isSubmitting ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <div className="text-sm font-medium">{option.label}</div>
                <div className="text-xs opacity-80">{option.description}</div>
              </button>
            ))}
          </div>

          {/* Optional text feedback */}
          <textarea
            value={feedbackText}
            onChange={(e) => setFeedbackText(e.target.value)}
            placeholder="Additional comments (optional)"
            disabled={isSubmitting}
            className={`w-full p-2 rounded-md text-sm resize-none ${
              darkMode
                ? 'bg-gray-700 text-gray-100 border-gray-600 placeholder-gray-400'
                : 'bg-gray-50 text-gray-900 border-gray-300 placeholder-gray-500'
            } border focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              isSubmitting ? 'opacity-50 cursor-not-allowed' : ''
            }`}
            rows={2}
          />

          {/* Error message */}
          {error && (
            <div className={`mt-2 p-2 rounded-md flex items-center gap-2 text-sm ${
              darkMode ? 'bg-red-900/50 text-red-300' : 'bg-red-50 text-red-600'
            }`}>
              <AlertCircle size={14} />
              <span>{error}</span>
            </div>
          )}

          {/* Submit button */}
          <button
            onClick={handleDetailedFeedback}
            disabled={!selectedFeedback || isSubmitting}
            className={`mt-3 w-full py-2 px-4 rounded-md font-medium transition-colors ${
              selectedFeedback && !isSubmitting
                ? 'bg-blue-500 text-white hover:bg-blue-600'
                : darkMode
                  ? 'bg-gray-700 text-gray-400 cursor-not-allowed'
                  : 'bg-gray-200 text-gray-400 cursor-not-allowed'
            }`}
          >
            {isSubmitting ? 'Submitting...' : 'Submit Feedback'}
          </button>
        </div>
      )}
    </div>
  )
}