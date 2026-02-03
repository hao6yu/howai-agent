'use client'

import { useState } from 'react'
import { Copy, Check, Download } from 'lucide-react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeRaw from 'rehype-raw'
import rehypeSanitize from 'rehype-sanitize'
import { Message } from '@/types/chat'
import MessageFeedback from './MessageFeedback'

interface ChatMessageProps {
  message: Message & { pdfDownload?: { url: string; filename: string; type: string } }
  darkMode?: boolean
}

export default function ChatMessage({ message, darkMode = false }: ChatMessageProps) {
  const [copiedText, setCopiedText] = useState(false)

  const copyTextToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(message.content)
      setCopiedText(true)
      setTimeout(() => setCopiedText(false), 2000)
    } catch (error) {
      console.error('Failed to copy text:', error)
    }
  }

  if (message.is_ai) {
    return (
      <div className="py-2 sm:py-4 w-full">
        <div className="w-full group">
          <div className={`rounded-lg sm:rounded-2xl px-3 py-2 sm:py-3 shadow-sm max-w-[90%] sm:max-w-[80%] lg:max-w-3xl ${darkMode ? 'bg-gray-800' : 'bg-white'}`}>
            <div className={`text-sm sm:text-base leading-relaxed markdown-content ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>
              <ReactMarkdown
                remarkPlugins={[remarkGfm]}
                rehypePlugins={[rehypeRaw, rehypeSanitize]}
                components={{
                  // Style headings
                  h1: ({ children }) => <h1 className={`text-lg sm:text-xl font-bold mt-4 mb-2 first:mt-0 ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>{children}</h1>,
                  h2: ({ children }) => <h2 className={`text-base sm:text-lg font-bold mt-3 mb-2 first:mt-0 ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>{children}</h2>,
                  h3: ({ children }) => <h3 className={`text-sm sm:text-base font-bold mt-3 mb-1 first:mt-0 ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>{children}</h3>,

                  // Style lists
                  ul: ({ children }) => <ul className="list-disc ml-4 my-2 space-y-1">{children}</ul>,
                  ol: ({ children }) => <ol className="list-decimal ml-4 my-2 space-y-1">{children}</ol>,
                  li: ({ children }) => <li className={`text-sm sm:text-base ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>{children}</li>,

                  // Style paragraphs
                  p: ({ children }) => <p className={`mb-2 last:mb-0 text-sm sm:text-base ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>{children}</p>,

                  // Style emphasis
                  strong: ({ children }) => <strong className={`font-semibold ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>{children}</strong>,
                  em: ({ children }) => <em className={`italic ${darkMode ? 'text-gray-100' : 'text-gray-900'}`}>{children}</em>,

                  // Style code
                  code: ({ children, className }) => {
                    const isInline = !className?.includes('language-')
                    return isInline ? (
                      <code className={`px-1.5 py-0.5 rounded text-xs sm:text-sm font-mono ${darkMode ? 'bg-gray-700 text-gray-200' : 'bg-gray-100 text-gray-900'}`}>{children}</code>
                    ) : (
                      <code className={`block p-3 rounded-lg overflow-x-auto text-xs sm:text-sm font-mono my-2 ${darkMode ? 'bg-gray-700 text-gray-200' : 'bg-gray-100 text-gray-900'}`}>{children}</code>
                    )
                  },

                  // Style links
                  a: ({ href, children }) => (
                    <a href={href} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800 underline">
                      {children}
                    </a>
                  ),

                  // Style blockquotes
                  blockquote: ({ children }) => (
                    <blockquote className={`border-l-4 pl-4 italic my-2 ${darkMode ? 'border-gray-600 text-gray-300' : 'border-gray-300 text-gray-700'}`}>
                      {children}
                    </blockquote>
                  ),
                }}
              >
                {message.content}
              </ReactMarkdown>
            </div>

            
            {/* Display images if they exist - without copy functionality */}
            {message.image_urls && message.image_urls.length > 0 && (
              <div className="mt-3 space-y-2">
                {message.image_urls.map((imageUrl, index) => (
                  <div key={index}>
                    <img
                      src={imageUrl}
                      alt={`Generated image ${index + 1}`}
                      className="max-w-full h-auto rounded-lg shadow-sm cursor-pointer hover:shadow-md transition-shadow"
                      onClick={() => window.open(imageUrl, '_blank')}
                      onError={(e) => {
                        console.error('Failed to load image:', imageUrl)
                        e.currentTarget.style.display = 'none'
                      }}
                    />
                  </div>
                ))}
              </div>
            )}

            {/* PDF Download Button */}
            {(message as any).pdfDownload && (
              <div className="mt-3">
                <button
                  onClick={() => {
                    const link = document.createElement('a')
                    link.href = (message as any).pdfDownload.url
                    link.download = (message as any).pdfDownload.filename
                    document.body.appendChild(link)
                    link.click()
                    document.body.removeChild(link)
                  }}
                  className={`inline-flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
                    darkMode
                      ? 'bg-blue-600 hover:bg-blue-700 text-white'
                      : 'bg-blue-500 hover:bg-blue-600 text-white'
                  }`}
                >
                  <Download size={16} />
                  <span>Download PDF</span>
                </button>
              </div>
            )}
          </div>

          {/* Action buttons - positioned at bottom-left */}
          <div className="mt-2">
            <MessageFeedback
              messageId={message.id}
              darkMode={darkMode}
              onCopy={copyTextToClipboard}
              copied={copiedText}
              onFeedbackSubmit={(type, text) => {
                console.log(`Feedback submitted for message ${message.id}:`, type, text)
              }}
            />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="py-2 sm:py-4 w-full">
      <div className="w-full flex justify-end">
        <div className="max-w-[90%] sm:max-w-[75%] lg:max-w-3xl">
          <div className={`rounded-lg sm:rounded-2xl px-3 py-2 sm:py-3 shadow-sm ${darkMode ? 'bg-gray-700 text-gray-100' : 'bg-gray-100 text-gray-900'}`}>
            {message.content && (
              <p className="text-sm sm:text-base leading-relaxed whitespace-pre-wrap break-words">
                {message.content}
              </p>
            )}

            {/* Display user attached images */}
            {message.image_urls && message.image_urls.length > 0 && (
              <div className={`${message.content ? 'mt-2' : ''} space-y-2`}>
                {message.image_urls.map((imageUrl, index) => (
                  <div key={index} className="relative">
                    <img
                      src={imageUrl}
                      alt={`User attached image ${index + 1}`}
                      className="max-w-full h-auto rounded-lg shadow-sm cursor-pointer hover:opacity-90 transition-opacity max-h-48 object-cover"
                      onClick={() => window.open(imageUrl, '_blank')}
                      onError={(e) => {
                        console.error('Failed to load user image:', imageUrl)
                        e.currentTarget.style.display = 'none'
                      }}
                    />
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
      <div className="w-full flex justify-end">
        <p className="text-xs text-gray-500 mt-1 sm:mt-2 mr-1">
          {new Date(message.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </p>
      </div>
    </div>
  )
}