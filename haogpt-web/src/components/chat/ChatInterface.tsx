'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import { Send, Brain, Plus, Paperclip, X, Pin, PinOff, MessageSquare, Settings, Trash2, Search, Menu, XCircle, LogOut, User, Palette, Bell, Shield, Moon, Sun, MessageSquarePlus, Globe, SearchCheck, FileText, ChevronUp, ChevronDown } from 'lucide-react'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/hooks/useAuth'
import { Message, Conversation } from '@/types/chat'
import ChatMessage from './ChatMessage'
import SettingsModal from '../settings/SettingsModal'
import FontSizeControl from '../ui/FontSizeControl'
import { getTimeAgo, formatDate } from '@/utils/timeHelpers'

export default function ChatInterface() {
  const { user } = useAuth()
  const [messages, setMessages] = useState<Message[]>([])
  const [currentMessage, setCurrentMessage] = useState('')
  const [loading, setLoading] = useState(false)
  const [currentConversation, setCurrentConversation] = useState<Conversation | null>(null)
  const [conversations, setConversations] = useState<Conversation[]>([])
  const [pinnedConversations, setPinnedConversations] = useState<Conversation[]>([])
  const [deepResearchMode, setDeepResearchMode] = useState(false)
  const [webSearchEnabled, setWebSearchEnabled] = useState(false)
  const [attachedFiles, setAttachedFiles] = useState<File[]>([])
  const [previewUrls, setPreviewUrls] = useState<string[]>([])
  const [showAttachmentMenu, setShowAttachmentMenu] = useState(false)
  const [isDragging, setIsDragging] = useState(false)
  const [dragCounter, setDragCounter] = useState(0)
  const [searchQuery, setSearchQuery] = useState('')
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [settingsOpen, setSettingsOpen] = useState(false)
  const [darkMode, setDarkMode] = useState(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('darkMode')
      return saved ? JSON.parse(saved) : false
    }
    return false
  })
  const [showPdfConverter, setShowPdfConverter] = useState(false)
  const [pdfImages, setPdfImages] = useState<File[]>([])
  const [pdfPreviewUrls, setPdfPreviewUrls] = useState<string[]>([])
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const imageInputRef = useRef<HTMLInputElement>(null)
  const pdfImageInputRef = useRef<HTMLInputElement>(null)
  const attachmentMenuRef = useRef<HTMLDivElement>(null)
  const requestControllerRef = useRef<AbortController | null>(null)
  const thinkingDelayRef = useRef<NodeJS.Timeout | null>(null)
  const isProcessingRef = useRef<boolean>(false)
  const dropZoneRef = useRef<HTMLDivElement>(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  // Save dark mode preference to localStorage
  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('darkMode', JSON.stringify(darkMode))
    }
  }, [darkMode])

  // Helper function to convert HEIC files to JPEG
  const convertHeicToJpeg = async (file: File): Promise<File> => {
    try {
      // Dynamically import heic2any to avoid SSR issues
      const heic2any = (await import('heic2any')).default
      
      const convertedBlob = await heic2any({
        blob: file,
        toType: 'image/jpeg',
        quality: 0.8
      }) as Blob

      // Create a new File object with the converted blob
      const convertedFile = new File(
        [convertedBlob], 
        file.name.replace(/\.heic$/i, '.jpg'), 
        { type: 'image/jpeg' }
      )
      
      return convertedFile
    } catch (error) {
      console.error('Error converting HEIC file:', error)
      throw new Error(`Failed to convert HEIC file: ${file.name}`)
    }
  }

  // File upload handlers
  const handleFileUpload = async (files: FileList | null) => {
    if (!files) return

    const newFiles = Array.from(files)
    const processedFiles: File[] = []
    
    for (const file of newFiles) {
      // Support common file types for both Windows and Mac
      const allowedTypes = [
        // Images
        'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/heic', 'image/heif',
        // Documents
        'application/pdf', 'text/plain', 'text/csv',
        'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        // Code files
        'text/javascript', 'text/html', 'text/css', 'application/json'
      ]

      // Different size limits for different file types
      const imageMaxSize = 5 * 1024 * 1024 // 5MB limit for images (will be compressed)
      const docMaxSize = 10 * 1024 * 1024 // 10MB limit for documents

      // Check if file type is supported (including HEIC files by extension)
      const isHeicFile = file.name.match(/\.(heic|heif)$/i)
      const isAllowedType = allowedTypes.includes(file.type) || isHeicFile
      const isAllowedExtension = file.name.match(/\.(txt|md|js|ts|py|java|cpp|c|h)$/i)

      if (!isAllowedType && !isAllowedExtension) {
        alert(`File type not supported: ${file.name}`)
        continue
      }

      // Check file size based on type
      const isImage = file.type.startsWith('image/') || isHeicFile
      const maxSize = isImage ? imageMaxSize : docMaxSize
      const maxSizeText = isImage ? '5MB' : '10MB'

      if (file.size > maxSize) {
        alert(`File too large: ${file.name} (max ${maxSizeText})`)
        continue
      }

      try {
        // Convert HEIC files to JPEG
        if (isHeicFile) {
          const convertedFile = await convertHeicToJpeg(file)
          processedFiles.push(convertedFile)
        } else {
          processedFiles.push(file)
        }
      } catch (error) {
        console.error('Error processing file:', error)
        alert(`Error processing file: ${file.name}`)
        continue
      }
    }

    if (processedFiles.length > 0) {
      setAttachedFiles(prev => [...prev, ...processedFiles])

      // Create preview URLs for images
      processedFiles.forEach(file => {
        if (file.type.startsWith('image/')) {
          const url = URL.createObjectURL(file)
          setPreviewUrls(prev => [...prev, url])
        } else {
          setPreviewUrls(prev => [...prev, ''])
        }
      })
    }
  }

  const removeFile = (index: number) => {
    const fileToRemove = attachedFiles[index]
    const urlToRevoke = previewUrls[index]

    if (urlToRevoke && fileToRemove.type.startsWith('image/')) {
      URL.revokeObjectURL(urlToRevoke)
    }

    setAttachedFiles(prev => prev.filter((_, i) => i !== index))
    setPreviewUrls(prev => prev.filter((_, i) => i !== index))
  }

  const handleImageClick = () => {
    imageInputRef.current?.click()
    setShowAttachmentMenu(false)
  }

  const handleFileClick = () => {
    fileInputRef.current?.click()
    setShowAttachmentMenu(false)
  }

  const handlePdfConverterClick = () => {
    setShowPdfConverter(true)
    setShowAttachmentMenu(false)
  }

  const toggleAttachmentMenu = () => {
    setShowAttachmentMenu(!showAttachmentMenu)
  }

  // Drag and drop handlers
  const handleDragEnter = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setDragCounter(prev => prev + 1)

    if (e.dataTransfer.items && e.dataTransfer.items.length > 0) {
      setIsDragging(true)
    }
  }

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setDragCounter(prev => prev - 1)

    if (dragCounter <= 1) {
      setIsDragging(false)
    }
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setIsDragging(false)
    setDragCounter(0)

    const files = e.dataTransfer.files
    if (files && files.length > 0) {
      handleFileUpload(files)
    }
  }

  // Compress and convert image to base64 for API
  const compressAndConvertImage = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      const img = new Image()

      img.onload = () => {
        // Calculate new dimensions (max 1024px on longest side)
        let { width, height } = img
        const maxSize = 1024

        if (width > maxSize || height > maxSize) {
          if (width > height) {
            height = (height * maxSize) / width
            width = maxSize
          } else {
            width = (width * maxSize) / height
            height = maxSize
          }
        }

        canvas.width = width
        canvas.height = height

        // Draw and compress
        ctx?.drawImage(img, 0, 0, width, height)

        // Convert to base64 with compression (0.8 quality for JPEG)
        const quality = file.type === 'image/png' ? 1.0 : 0.8
        const compressedDataUrl = canvas.toDataURL('image/jpeg', quality)

        // Remove data:image/jpeg;base64, prefix
        resolve(compressedDataUrl.split(',')[1])
      }

      img.onerror = () => reject(new Error('Failed to load image'))
      img.src = URL.createObjectURL(file)
    })
  }

  // Convert file to base64 for API (with compression for images)
  const fileToBase64 = (file: File): Promise<string> => {
    // For images, use compression
    if (file.type.startsWith('image/')) {
      return compressAndConvertImage(file)
    }

    // For non-images, use original method
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.readAsDataURL(file)
      reader.onload = () => {
        const result = reader.result as string
        resolve(result.split(',')[1]) // Remove data:image/jpeg;base64, prefix
      }
      reader.onerror = error => reject(error)
    })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  // Close attachment menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (attachmentMenuRef.current && !attachmentMenuRef.current.contains(event.target as Node)) {
        setShowAttachmentMenu(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [])

  // Prevent default drag behaviors globally and add global paste handler
  useEffect(() => {
    const preventDefaults = (e: Event) => {
      e.preventDefault()
      e.stopPropagation()
    }

    const events = ['dragenter', 'dragover', 'dragleave', 'drop']

    events.forEach(eventName => {
      document.addEventListener(eventName, preventDefaults, false)
    })

    // Global paste handler for images
    const handleGlobalPaste = async (e: ClipboardEvent) => {
      const items = e.clipboardData?.items
      if (!items) return

      const files: File[] = []

      for (let i = 0; i < items.length; i++) {
        const item = items[i]
        if (item.type.startsWith('image/')) {
          const file = item.getAsFile()
          if (file) {
            files.push(file)
          }
        }
      }

      // Only handle if there are actually images to paste
      if (files.length > 0) {
        e.preventDefault()
        const fileList = new DataTransfer()
        files.forEach(file => fileList.items.add(file))
        await handleFileUpload(fileList.files)
      }
    }

    document.addEventListener('paste', handleGlobalPaste)

    return () => {
      events.forEach(eventName => {
        document.removeEventListener(eventName, preventDefaults, false)
      })
      document.removeEventListener('paste', handleGlobalPaste)
    }
  }, [handleFileUpload])

  // PDF converter functions
  const handlePdfImageUpload = async (files: FileList | null) => {
    if (!files) return

    const newFiles = Array.from(files)
    const processedFiles: File[] = []

    for (const file of newFiles) {
      const isHeicFile = file.name.match(/\.(heic|heif)$/i)
      const isImage = file.type.startsWith('image/') || isHeicFile

      if (!isImage) {
        alert(`Please select only image files: ${file.name}`)
        continue
      }

      const maxSize = 5 * 1024 * 1024 // 5MB limit
      if (file.size > maxSize) {
        alert(`Image too large: ${file.name} (max 5MB)`)
        continue
      }

      try {
        if (isHeicFile) {
          const convertedFile = await convertHeicToJpeg(file)
          processedFiles.push(convertedFile)
        } else {
          processedFiles.push(file)
        }
      } catch (error) {
        console.error('Error processing file:', error)
        alert(`Error processing file: ${file.name}`)
        continue
      }
    }

    if (processedFiles.length > 0) {
      setPdfImages(prev => [...prev, ...processedFiles])

      processedFiles.forEach(file => {
        const url = URL.createObjectURL(file)
        setPdfPreviewUrls(prev => [...prev, url])
      })
    }
  }

  const removePdfImage = (index: number) => {
    const urlToRevoke = pdfPreviewUrls[index]
    URL.revokeObjectURL(urlToRevoke)

    setPdfImages(prev => prev.filter((_, i) => i !== index))
    setPdfPreviewUrls(prev => prev.filter((_, i) => i !== index))
  }

  const movePdfImage = (fromIndex: number, toIndex: number) => {
    if (toIndex < 0 || toIndex >= pdfImages.length) return

    const newImages = [...pdfImages]
    const newUrls = [...pdfPreviewUrls]

    const [movedImage] = newImages.splice(fromIndex, 1)
    const [movedUrl] = newUrls.splice(fromIndex, 1)

    newImages.splice(toIndex, 0, movedImage)
    newUrls.splice(toIndex, 0, movedUrl)

    setPdfImages(newImages)
    setPdfPreviewUrls(newUrls)
  }

  const generatePDF = async () => {
    if (pdfImages.length === 0) {
      alert('Please select at least one image to convert to PDF')
      return
    }

    try {
      // Dynamically import jsPDF to avoid SSR issues
      const { jsPDF } = await import('jspdf')

      const pdf = new jsPDF()
      let isFirstPage = true

      for (let i = 0; i < pdfImages.length; i++) {
        const file = pdfImages[i]
        const base64 = await compressAndConvertImage(file)

        if (!isFirstPage) {
          pdf.addPage()
        }

        // Calculate image dimensions to fit page while maintaining aspect ratio
        const img = new Image()
        img.src = pdfPreviewUrls[i]

        await new Promise((resolve) => {
          img.onload = () => {
            const pageWidth = pdf.internal.pageSize.getWidth()
            const pageHeight = pdf.internal.pageSize.getHeight()
            const margin = 20
            const maxWidth = pageWidth - (2 * margin)
            const maxHeight = pageHeight - (2 * margin)

            let imgWidth = img.width
            let imgHeight = img.height

            // Scale to fit page while maintaining aspect ratio
            const widthRatio = maxWidth / imgWidth
            const heightRatio = maxHeight / imgHeight
            const ratio = Math.min(widthRatio, heightRatio)

            imgWidth *= ratio
            imgHeight *= ratio

            // Center the image on the page
            const x = (pageWidth - imgWidth) / 2
            const y = (pageHeight - imgHeight) / 2

            pdf.addImage(`data:image/jpeg;base64,${base64}`, 'JPEG', x, y, imgWidth, imgHeight)
            resolve(void 0)
          }
        })

        isFirstPage = false
      }

      // Generate filename with timestamp
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
      const filename = `images-to-pdf-${timestamp}.pdf`

      // Get PDF as blob for download link
      const pdfBlob = pdf.output('blob')
      const pdfUrl = URL.createObjectURL(pdfBlob)

      // Don't auto-download, just prepare for user-initiated download
      // pdf.save(filename) - removed auto-download

      // Simulate AI response with PDF
      await simulateAIPdfResponse(filename, pdfImages.length, pdfUrl)

      // Clean up
      pdfPreviewUrls.forEach(url => URL.revokeObjectURL(url))
      setPdfImages([])
      setPdfPreviewUrls([])
      setShowPdfConverter(false)

    } catch (error) {
      console.error('Error generating PDF:', error)
      alert('Failed to generate PDF. Please try again.')
    }
  }

  const simulateAIPdfResponse = async (filename: string, imageCount: number, pdfUrl: string) => {
    let conversationToUse = currentConversation
    let isFirstMessage = false

    if (!user || !conversationToUse) {
      // Create a new conversation if none exists
      conversationToUse = await createNewConversation()
      if (conversationToUse) {
        setCurrentConversation(conversationToUse)
        isFirstMessage = true
      }
    } else {
      // Check if this is the first message in existing conversation
      isFirstMessage = messages.length === 0
    }

    if (!conversationToUse) return

    const responseContent = `I've successfully converted ${imageCount} image${imageCount > 1 ? 's' : ''} into a PDF document for you! Your PDF is ready for download.

📄 **PDF Details:**
- Images converted: ${imageCount}
- Format: PDF with high-quality JPEG compression
- Layout: Each image centered on its own page
- File name: ${filename}

✅ Click the download button below to save your PDF file.`

    // Add AI response to database
    const { data: aiMessage } = await supabase
      .from('messages')
      .insert({
        conversation_id: conversationToUse.id,
        content: responseContent,
        is_ai: true
      })
      .select()
      .single()

    if (aiMessage) {
      // Add the PDF download function to the message object for custom handling
      const enhancedMessage = {
        ...aiMessage,
        pdfDownload: {
          url: pdfUrl,
          filename,
          type: 'pdf_conversion'
        }
      }
      setMessages(prev => [...prev, enhancedMessage])
    }

    // Generate conversation title if this is the first message
    if (isFirstMessage) {
      const newTitle = `PDF: ${imageCount} Image${imageCount > 1 ? 's' : ''} Converted`

      // Update conversation title in database
      const { error } = await supabase
        .from('conversations')
        .update({ title: newTitle })
        .eq('id', conversationToUse.id)

      if (!error) {
        // Update local state
        setCurrentConversation(prev => prev ? { ...prev, title: newTitle } : null)

        // Update conversations in sidebar
        setPinnedConversations(prev =>
          prev.map(conv =>
            conv.id === conversationToUse.id
              ? { ...conv, title: newTitle, updated_at: new Date().toISOString() }
              : conv
          )
        )
        setConversations(prev =>
          prev.map(conv =>
            conv.id === conversationToUse.id
              ? { ...conv, title: newTitle, updated_at: new Date().toISOString() }
              : conv
          )
        )

        // Refresh from database
        await loadConversations()
      }
    }
  }

  // Load all conversations for sidebar
  const loadConversations = useCallback(async () => {
    if (!user) return

    try {
      const { data: allConversations, error } = await supabase
        .from('conversations')
        .select('*')
        .eq('user_id', user.id)
        .order('updated_at', { ascending: false })

      if (error) {
        console.error('Error fetching conversations:', error)
        return
      }

      if (allConversations) {
        const pinned = allConversations
          .filter(conv => conv.is_pinned)
          .sort((a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime())
        
        const regular = allConversations
          .filter(conv => !conv.is_pinned)
          .sort((a, b) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime())

        setPinnedConversations(pinned)
        setConversations(regular)
      }
    } catch (error) {
      console.error('Error loading conversations:', error)
    }
  }, [user])

  const loadOrCreateConversation = useCallback(async () => {
    if (!user) return

    try {
      // First, ensure user profile exists
      const { data: _profile, error: profileError } = await supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .single()

      if (profileError && profileError.code === 'PGRST116') {
        // Profile doesn't exist, create it
        console.log('Creating user profile...')
        const { error: createProfileError } = await supabase
          .from('profiles')
          .insert({
            id: user.id,
            email: user.email,
            name: user.user_metadata?.name || user.email?.split('@')[0]
          })

        if (createProfileError) {
          console.error('Error creating profile:', createProfileError)
          return
        }
      }

      // Load all conversations for the sidebar
      await loadConversations()

      // Don't auto-load any conversation - stay on landing page
      console.log('User profile ready, staying on landing page')
    } catch (error) {
      console.error('Error in loadOrCreateConversation:', error)
    }
  }, [user, loadConversations])

  // Create new conversation
  const createNewConversation = async () => {
    if (!user) return null

    try {
      const { data: newConversation, error } = await supabase
        .from('conversations')
        .insert({
          user_id: user.id,
          title: 'New Chat'
        })
        .select()
        .single()

      if (error) {
        console.error('Error creating conversation:', error)
        return null
      }

      // Refresh conversations list
      await loadConversations()
      return newConversation
    } catch (error) {
      console.error('Error creating new conversation:', error)
      return null
    }
  }

  // Switch to a conversation
  const switchToConversation = async (conversation: Conversation) => {
    setCurrentConversation(conversation)
    loadMessages(conversation.id)
  }

  // Pin/unpin conversation
  const togglePin = async (conversation: Conversation) => {
    try {
      const { error } = await supabase
        .from('conversations')
        .update({ is_pinned: !conversation.is_pinned })
        .eq('id', conversation.id)

      if (error) {
        console.error('Error toggling pin:', error)
        return
      }

      // Refresh conversations
      await loadConversations()
    } catch (error) {
      console.error('Error toggling pin:', error)
    }
  }

  // Delete conversation
  const deleteConversation = async (conversation: Conversation) => {
    try {
      const { error } = await supabase
        .from('conversations')
        .delete()
        .eq('id', conversation.id)

      if (error) {
        console.error('Error deleting conversation:', error)
        return
      }

      // If this was the current conversation, create a new one
      if (currentConversation?.id === conversation.id) {
        const newConv = await createNewConversation()
        if (newConv) {
          setCurrentConversation(newConv)
          setMessages([])
        }
      }

      // Refresh conversations
      await loadConversations()
    } catch (error) {
      console.error('Error deleting conversation:', error)
    }
  }

  // Load or create conversation
  useEffect(() => {
    if (user) {
      loadOrCreateConversation()
    }
  }, [user, loadOrCreateConversation])

  const loadMessages = async (conversationId: string) => {
    const { data: messages } = await supabase
      .from('messages')
      .select('*')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true })

    if (messages) {
      setMessages(messages)
    }
  }

  const sendMessage = async () => {
    console.log('Send message clicked', {
      hasMessage: !!currentMessage.trim(),
      hasConversation: !!currentConversation,
      hasUser: !!user,
      attachedFiles: attachedFiles.length
    })

    if ((!currentMessage.trim() && attachedFiles.length === 0) || !user) {
      console.log('Send message aborted - missing requirements')
      return
    }

    // If no current conversation, create a new one
    let conversationToUse = currentConversation
    if (!conversationToUse) {
      console.log('No current conversation, creating new one...')
      conversationToUse = await createNewConversation()
      if (!conversationToUse) {
        console.error('Failed to create new conversation')
        return
      }
      setCurrentConversation(conversationToUse)
    }

    // Prevent duplicate processing
    if (isProcessingRef.current) {
      console.log('[Chat] Already processing a request, ignoring duplicate')
      return
    }
    isProcessingRef.current = true

    // Add a realistic delay before showing "AI is thinking" - makes conversation feel more natural
    thinkingDelayRef.current = setTimeout(() => {
      if (isProcessingRef.current) { // Only show if still processing
        setLoading(true)
      }
      thinkingDelayRef.current = null
    }, 800) // 0.8 second delay for natural conversation flow

    try {
      // Check if this is the first message in the conversation BEFORE adding it
      const isFirstMessage = messages.length === 0

      // Prepare attachments for API
      const attachments = []
      for (let i = 0; i < attachedFiles.length; i++) {
        const file = attachedFiles[i]
        if (file.type.startsWith('image/')) {
          const base64 = await fileToBase64(file)
          attachments.push({
            type: 'image',
            name: file.name,
            mimeType: file.type,
            data: base64
          })
        } else {
          // For non-image files, read as text or send file info
          const text = await file.text()
          attachments.push({
            type: 'document',
            name: file.name,
            mimeType: file.type,
            content: text.substring(0, 10000) // Limit to 10k chars
          })
        }
      }

      // Create image URLs for attached images
      const attachedImageUrls: string[] = []
      for (let i = 0; i < attachedFiles.length; i++) {
        const file = attachedFiles[i]
        if (file.type.startsWith('image/')) {
          // Create object URL for immediate display
          const objectUrl = URL.createObjectURL(file)
          attachedImageUrls.push(objectUrl)
        }
      }

      // Create display content for user message (without file list for now)
      let displayContent = currentMessage

      // Store the message and attachments for API call
      const messageToSend = currentMessage
      const attachmentsToSend = [...attachments]

      // Add user message to database
      const { data: userMessage } = await supabase
        .from('messages')
        .insert({
          conversation_id: conversationToUse.id,
          content: displayContent || '📎 Attached files',
          is_ai: false,
          image_urls: attachedImageUrls.length > 0 ? attachedImageUrls : null
        })
        .select()
        .single()

      if (userMessage) {
        setMessages(prev => [...prev, userMessage])
      }

      // Clear input and attachments
      setCurrentMessage('')
      setAttachedFiles([])
      setPreviewUrls([])

      // Call OpenAI API
      try {
        const requestBody = {
          message: messageToSend,
          conversationId: conversationToUse.id,
          deepResearch: deepResearchMode,
          attachments: attachmentsToSend,
          generateTitle: isFirstMessage,
          allowWebSearch: webSearchEnabled, // Use the toggle state
          enableAIWebSearchDetection: !webSearchEnabled, // Enable AI detection when toggle is off
        }

        console.log('Sending API request:', {
          messageLength: messageToSend?.length,
          generateTitle: isFirstMessage,
          conversationId: conversationToUse.id,
          attachmentsCount: attachmentsToSend.length
        })

        // Create AbortController for timeout handling (use persistent ref)
        if (requestControllerRef.current) {
          requestControllerRef.current.abort() // Cancel any previous request
        }
        requestControllerRef.current = new AbortController()

        const timeoutId = setTimeout(() => {
          console.log('[Chat] Request timeout - aborting after 4 minutes')
          requestControllerRef.current?.abort()
        }, 240000) // 4 minute timeout (doubled)

        let response: Response
        try {
          response = await fetch('/api/chat', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestBody),
            signal: requestControllerRef.current.signal,
          })
          clearTimeout(timeoutId)
          requestControllerRef.current = null // Clear successful request
          console.log('[Chat] Request completed successfully')
        } catch (fetchError) {
          clearTimeout(timeoutId)

          console.log('[Chat] Fetch error occurred:', {
            name: fetchError instanceof Error ? fetchError.name : 'Unknown',
            message: fetchError instanceof Error ? fetchError.message : 'Unknown error',
            type: typeof fetchError,
            constructor: fetchError instanceof Error ? fetchError.constructor.name : 'Unknown'
          })

          // Handle abort specifically
          if (fetchError instanceof Error && fetchError.name === 'AbortError') {
            console.log('[Chat] AbortError detected - but backend might still be processing')

            // Don't show error immediately - the request might have completed on backend
            // Show a different message and check for completion
            const checkMessage = {
              id: `checking-${Date.now()}`,
              conversation_id: conversationToUse.id,
              content: 'Processing your request... This may take a moment for image generation.',
              is_ai: true,
              created_at: new Date().toISOString()
            }
            setMessages(prev => [...prev, checkMessage])

            // Check if the request completed on the backend after a delay
            setTimeout(async () => {
              console.log('[Chat] Checking if message was saved despite abort...')
              await loadConversations()

              // Remove the checking message
              setMessages(prev => prev.filter(msg => msg.id !== checkMessage.id))
            }, 3000)

            return // Don't throw error, let the check handle it
          }

          // For non-abort errors, still check if backend completed
          console.log('[Chat] Non-abort error - backend might still be processing')

          // Wait a bit and check if the request completed on backend
          setTimeout(async () => {
            console.log('[Chat] Checking if request completed despite frontend error...')
            await loadConversations()
          }, 2000)

          throw fetchError
        }

        if (!response.ok) {
          throw new Error('Failed to get AI response')
        }

        const data = await response.json()

        console.log('API Response:', { hasMessage: !!data.message, title: data.title, isFirstMessage })

        if (data.message) {
          setMessages(prev => [...prev, data.message])
        }

        // Update conversation title if generated
        if (data.title && conversationToUse) {
          console.log('Updating conversation title to:', data.title)
          setCurrentConversation(prev => prev ? { ...prev, title: data.title } : null)

          // Update the conversation in both pinned and regular lists
          setPinnedConversations(prev =>
            prev.map(conv =>
              conv.id === conversationToUse.id
                ? { ...conv, title: data.title, updated_at: new Date().toISOString() }
                : conv
            )
          )
          setConversations(prev =>
            prev.map(conv =>
              conv.id === conversationToUse.id
                ? { ...conv, title: data.title, updated_at: new Date().toISOString() }
                : conv
            )
          )

          // Also refresh from database to ensure consistency
          await loadConversations()
        }
      } catch (apiError) {
        console.error('Error calling chat API:', apiError)
        console.error('Error details:', {
          name: apiError instanceof Error ? apiError.name : 'Unknown',
          message: apiError instanceof Error ? apiError.message : 'Unknown error',
          stack: apiError instanceof Error ? apiError.stack : 'No stack trace'
        })

        // Determine error message based on error type
        let errorContent = 'Sorry, I encountered an error processing your message. Please try again.'

        if (apiError instanceof Error) {
          if (apiError.name === 'AbortError') {
            console.log('[Chat] Request aborted - this was likely a timeout or user navigation')
            errorContent = 'Request timed out after 4 minutes. This can happen with complex image generation - please try again.'
          } else if (apiError.message.includes('timeout')) {
            console.log('[Chat] Timeout error detected')
            errorContent = 'Request took too long to complete. Please try again.'
          } else if (apiError.message.includes('Failed to fetch')) {
            console.log('[Chat] Network error detected')
            errorContent = 'Network error. Please check your connection and try again.'
          } else {
            console.log('[Chat] Unknown error type:', apiError.message)
          }
        }

        // Add error message to chat
        const errorMessage = {
          id: `error-${Date.now()}`,
          conversation_id: conversationToUse.id,
          content: errorContent,
          is_ai: true,
          created_at: new Date().toISOString()
        }
        setMessages(prev => [...prev, errorMessage])
      } finally {
        // Clear the thinking delay if still pending and set loading to false
        if (thinkingDelayRef.current) {
          clearTimeout(thinkingDelayRef.current)
          thinkingDelayRef.current = null
        }
        setLoading(false)
        isProcessingRef.current = false // Clear processing flag
        console.log('[Chat] Processing completed, flag cleared')
      }

    } catch (error) {
      console.error('Error sending message:', error)
      // Clear the thinking delay if still pending
      if (thinkingDelayRef.current) {
        clearTimeout(thinkingDelayRef.current)
        thinkingDelayRef.current = null
      }
      setLoading(false)
      isProcessingRef.current = false // Clear processing flag
      console.log('[Chat] Error occurred, processing flag cleared')
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  const logout = async () => {
    await supabase.auth.signOut()
  }

  if (!user) {
    return <div>Please sign in to use the chat.</div>
  }

  // Get current conversation ID for sidebar
  const currentConversationId = currentConversation?.id

  // Filter conversations based on search query
  const filteredPinnedConversations = pinnedConversations.filter((conv) => {
    if (!searchQuery.trim()) return true
    return conv.title?.toLowerCase().includes(searchQuery.toLowerCase()) || false
  })

  const filteredUnpinnedConversations = conversations.filter((conv) => {
    if (!searchQuery.trim()) return true
    return conv.title?.toLowerCase().includes(searchQuery.toLowerCase()) || false
  })

  // Total filtered conversations for "no results" message
  const totalFilteredConversations = filteredPinnedConversations.length + filteredUnpinnedConversations.length

  return (
    <div className={`flex h-screen transition-colors duration-200 ${darkMode ? 'bg-gray-900' : 'bg-gray-50'}`}>
      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Left Sidebar */}
      <div className={`
        fixed lg:relative lg:translate-x-0
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
        w-80 ${darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'} border-r flex flex-col flex-shrink-0
        transition-all duration-300 ease-in-out z-50 lg:z-auto
        h-full lg:flex
      `}>
        {/* Sidebar Header */}
        <div className={`p-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-3">
              <div className="w-8 h-8 flex items-center justify-center">
                <img
                  src="/howai-icon.png"
                  alt="HowAI"
                  className="w-8 h-8 rounded-lg"
                />
              </div>
              <h1 className={`text-lg font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>HowAI</h1>
            </div>
            <div className="flex items-center space-x-2">
              <button
                onClick={() => {
                  setCurrentConversation(null)
                  setMessages([])
                }}
                className={`p-2 rounded-md transition-colors ${darkMode ? 'text-gray-400 hover:text-white hover:bg-gray-700' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'}`}
                title="New conversation"
              >
                <MessageSquarePlus className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search conversations..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className={`w-full pl-10 pr-10 py-2 text-sm rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent ${darkMode ? 'bg-gray-700 border-gray-600 text-white placeholder-gray-400' : 'bg-gray-50 border-gray-200 text-gray-900 placeholder-gray-500'}`}
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className={`absolute right-3 top-1/2 transform -translate-y-1/2 transition-colors ${darkMode ? 'text-gray-500 hover:text-gray-300' : 'text-gray-400 hover:text-gray-600'}`}
                title="Clear search"
              >
                <XCircle className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>

        {/* Conversations List */}
        <div className="flex-1 overflow-y-auto">
          {/* Pinned Conversations */}
          {filteredPinnedConversations.length > 0 && (
            <div className="p-3">
              <h3 className={`text-xs font-medium uppercase tracking-wider mb-2 px-2 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                Pinned
              </h3>
              <div className="space-y-1">
                {filteredPinnedConversations.map((conv) => (
                  <div
                    key={conv.id}
                    className={`group px-3 py-2 text-sm rounded-md cursor-pointer transition-colors ${
                      currentConversationId === conv.id
                        ? darkMode ? 'bg-blue-900 text-blue-300' : 'bg-blue-50 text-blue-700'
                        : darkMode ? 'text-gray-300 hover:bg-gray-700' : 'text-gray-700 hover:bg-gray-50'
                    }`}
                    onClick={() => switchToConversation(conv)}
                    title={`Created ${formatDate(conv.created_at)}`}
                  >
                    <div className="flex items-center">
                      <Pin className="w-4 h-4 mr-2 text-yellow-500 flex-shrink-0" />
                      <div className="flex-1 min-w-0">
                        <div className="truncate">{conv.title}</div>
                        <div className={`text-xs mt-0.5 ${darkMode ? 'text-gray-500' : 'text-gray-400'}`}>
                          {getTimeAgo(conv.created_at)}
                        </div>
                      </div>
                      <div className="flex items-center space-x-1 opacity-0 group-hover:opacity-100 transition-opacity ml-2">
                        <button
                          onClick={(e) => {
                            e.stopPropagation()
                            togglePin(conv)
                          }}
                          className={`p-1 rounded ${darkMode ? 'text-gray-500 hover:text-gray-300' : 'text-gray-400 hover:text-gray-600'}`}
                          title="Unpin"
                        >
                          <PinOff className="w-3 h-3" />
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation()
                            deleteConversation(conv)
                          }}
                          className="p-1 text-gray-400 hover:text-red-500 rounded"
                          title="Delete"
                        >
                          <Trash2 className="w-3 h-3" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Regular Conversations */}
          <div className="p-3">
            {filteredPinnedConversations.length > 0 && (
              <h3 className={`text-xs font-medium uppercase tracking-wider mb-2 px-2 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                Recent
              </h3>
            )}
            <div className="space-y-1">
              {filteredUnpinnedConversations.map((conv) => (
                <div
                  key={conv.id}
                  className={`group px-3 py-2 text-sm rounded-md cursor-pointer transition-colors ${
                    currentConversationId === conv.id
                      ? darkMode ? 'bg-blue-900 text-blue-300' : 'bg-blue-50 text-blue-700'
                      : darkMode ? 'text-gray-300 hover:bg-gray-700' : 'text-gray-700 hover:bg-gray-50'
                  }`}
                  onClick={() => switchToConversation(conv)}
                  title={`Created ${formatDate(conv.created_at)}`}
                >
                  <div className="flex items-center">
                    <MessageSquare className="w-4 h-4 mr-2 text-gray-400 flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <div className="truncate">{conv.title}</div>
                      <div className={`text-xs mt-0.5 ${darkMode ? 'text-gray-500' : 'text-gray-400'}`}>
                        {getTimeAgo(conv.created_at)}
                      </div>
                    </div>
                    <div className="flex items-center space-x-1 opacity-0 group-hover:opacity-100 transition-opacity ml-2">
                      <button
                        onClick={(e) => {
                          e.stopPropagation()
                          togglePin(conv)
                        }}
                        className="p-1 text-gray-400 hover:text-yellow-500 rounded"
                        title="Pin"
                      >
                        <Pin className="w-3 h-3" />
                      </button>
                      <button
                        onClick={(e) => {
                          e.stopPropagation()
                          deleteConversation(conv)
                        }}
                        className="p-1 text-gray-400 hover:text-red-500 rounded"
                        title="Delete"
                      >
                        <Trash2 className="w-3 h-3" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* No results message */}
            {searchQuery.trim() && totalFilteredConversations === 0 && (
              <div className={`text-center py-8 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                <Search className={`w-8 h-8 mx-auto mb-2 ${darkMode ? 'text-gray-500' : 'text-gray-400'}`} />
                <p className="text-sm">No conversations found</p>
                <p className={`text-xs ${darkMode ? 'text-gray-500' : 'text-gray-400'}`}>Try a different search term</p>
              </div>
            )}
          </div>
        </div>

        {/* Settings Panel */}
        <div className={`p-3 border-t ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
          <div className={`text-xs mb-3 px-3 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>
            {user?.email}
          </div>

          <button
            onClick={() => setSettingsOpen(true)}
            className={`w-full flex items-center px-3 py-2 text-sm rounded-md transition-colors ${darkMode ? 'text-gray-300 hover:bg-gray-700' : 'text-gray-700 hover:bg-gray-50'}`}
          >
            <Settings className="w-4 h-4 mr-2" />
            Settings
          </button>
          <button
            onClick={logout}
            className={`w-full flex items-center px-3 py-2 text-sm rounded-md transition-colors mt-1 ${darkMode ? 'text-gray-300 hover:bg-gray-700' : 'text-gray-700 hover:bg-gray-50'}`}
          >
            <span className="w-4 h-4 mr-2">↗</span>
            Logout
          </button>
        </div>
      </div>

      {/* Main Chat Area */}
      <div
        className="flex-1 flex flex-col relative"
        ref={dropZoneRef}
        onDragEnter={handleDragEnter}
        onDragLeave={handleDragLeave}
        onDragOver={handleDragOver}
        onDrop={handleDrop}
      >
        {/* Header */}
        <div className={`border-b px-2 sm:px-4 lg:px-6 py-3 sm:py-4 ${darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'}`}>
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2 sm:space-x-3">
              {/* Mobile Menu Button */}
              <button
                onClick={() => setSidebarOpen(true)}
                className={`p-2 rounded-md lg:hidden ${darkMode ? 'text-gray-400 hover:text-white hover:bg-gray-700' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'}`}
              >
                <Menu className="w-5 h-5" />
              </button>
              {/* Mobile App Icon */}
              <div className="w-8 h-8 flex items-center justify-center lg:hidden">
                <img
                  src="/howai-icon.png"
                  alt="HowAI"
                  className="w-8 h-8 rounded-lg"
                />
              </div>
              <div>
                <h2 className={`text-lg font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>
                  {currentConversation?.title || 'HowAI'}
                </h2>
              </div>
            </div>
            <div className="flex items-center space-x-2 sm:space-x-4">
              {deepResearchMode && (
                <div className={`flex items-center space-x-2 px-3 py-1 rounded-full ${darkMode ? 'bg-purple-900 text-purple-300' : 'bg-purple-50 text-purple-700'}`}>
                  <SearchCheck size={16} />
                  <span className="text-sm font-medium hidden sm:inline">Deep Research</span>
                </div>
              )}
              {webSearchEnabled && (
                <div className={`flex items-center space-x-2 px-3 py-1 rounded-full ${darkMode ? 'bg-blue-900 text-blue-300' : 'bg-blue-50 text-blue-700'}`}>
                  <Globe size={16} />
                  <span className="text-sm font-medium hidden sm:inline">Web Search</span>
                </div>
              )}

              {/* Font Size Controls */}
              <FontSizeControl darkMode={darkMode} inline={true} />

              {/* Dark Mode Toggle */}
              <button
                onClick={() => setDarkMode(!darkMode)}
                className={`p-2 rounded-lg transition-colors ${
                  darkMode
                    ? 'text-white hover:bg-gray-700 hover:text-gray-200'
                    : 'text-gray-600 hover:bg-gray-100 hover:text-gray-800'
                }`}
                title={darkMode ? 'Switch to light mode' : 'Switch to dark mode'}
              >
                {darkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
              </button>
            </div>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto">
          <div className="w-full px-2 sm:px-4 lg:px-6">
            {messages.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-full text-center px-2 sm:px-6">
                  <div className="w-20 h-20 flex items-center justify-center mb-6">
                    <img
                      src="/howai-icon.png"
                      alt="HowAI"
                      className="w-20 h-20 rounded-3xl"
                    />
                  </div>
                  <h2 className={`text-2xl sm:text-3xl font-bold mb-3 ${darkMode ? 'text-white' : 'text-gray-900'}`}>Welcome to HowAI</h2>
                  <p className={`text-base sm:text-lg mb-8 max-w-2xl leading-relaxed ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    Your intelligent AI assistant with powerful capabilities. I can chat, research, analyze, create, and help you accomplish any task.
                  </p>

                  {/* Feature Grid */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 w-full max-w-4xl mb-8">
                    <div className={`p-5 rounded-xl border ${darkMode ? 'bg-gray-800 border-gray-600' : 'bg-white border-gray-200'}`}>
                      <div className="text-2xl mb-3">💬</div>
                      <h3 className={`font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>Smart Conversations</h3>
                      <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>Ask me anything - from complex questions to casual chat</p>
                    </div>

                    <div className={`p-5 rounded-xl border ${darkMode ? 'bg-gray-800 border-gray-600' : 'bg-white border-gray-200'}`}>
                      <div className="text-2xl mb-3">🧠</div>
                      <h3 className={`font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>Deep Research</h3>
                      <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>Comprehensive analysis and in-depth research on any topic</p>
                    </div>

                    <div className={`p-5 rounded-xl border ${darkMode ? 'bg-gray-800 border-gray-600' : 'bg-white border-gray-200'}`}>
                      <div className="text-2xl mb-3">🌐</div>
                      <h3 className={`font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>Web Search</h3>
                      <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>Get real-time information from across the internet</p>
                    </div>

                    <div className={`p-5 rounded-xl border ${darkMode ? 'bg-gray-800 border-gray-600' : 'bg-white border-gray-200'}`}>
                      <div className="text-2xl mb-3">📷</div>
                      <h3 className={`font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>Photo Analysis</h3>
                      <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>Understand and analyze images, photos, and visual content</p>
                    </div>

                    <div className={`p-5 rounded-xl border ${darkMode ? 'bg-gray-800 border-gray-600' : 'bg-white border-gray-200'}`}>
                      <div className="text-2xl mb-3">🎨</div>
                      <h3 className={`font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>AI Artwork</h3>
                      <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>Create stunning images and artwork from your descriptions</p>
                    </div>

                    <div className={`p-5 rounded-xl border ${darkMode ? 'bg-gray-800 border-gray-600' : 'bg-white border-gray-200'}`}>
                      <div className="text-2xl mb-3">📄</div>
                      <h3 className={`font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>Document Work</h3>
                      <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-600'}`}>Analyze, summarize, and work with your documents and files</p>
                    </div>
                  </div>

                  {/* Quick Start Tips */}
                  <div className={`rounded-xl p-6 max-w-3xl ${darkMode ? 'bg-gray-800/50 border border-gray-700' : 'bg-gray-50 border border-gray-200'}`}>
                    <h3 className={`font-semibold mb-3 ${darkMode ? 'text-white' : 'text-gray-900'}`}>💡 Quick Tips</h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm">
                      <div className={`flex items-center ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        <span className="mr-2">📎</span>
                        <span>Drag & drop files or paste images directly</span>
                      </div>
                      <div className={`flex items-center ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        <span className="mr-2">🔍</span>
                        <span>Toggle web search for current info</span>
                      </div>
                      <div className={`flex items-center ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        <span className="mr-2">🧠</span>
                        <span>Enable deep research for complex topics</span>
                      </div>
                      <div className={`flex items-center ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                        <span className="mr-2">🎯</span>
                        <span>Ask me to "draw" or "create" for artwork</span>
                      </div>
                    </div>
                  </div>
                </div>
            ) : (
              <div className="py-3 sm:py-6">
                {messages.map((message) => (
                  <ChatMessage key={message.id} message={message} darkMode={darkMode} />
                ))}
                {loading && (
                  <div className="py-2 sm:py-4 w-full">
                    <div className="w-full">
                      <div className={`rounded-lg sm:rounded-2xl px-3 py-2 sm:py-3 shadow-sm max-w-[90%] sm:max-w-[80%] lg:max-w-3xl ${darkMode ? 'bg-gray-800' : 'bg-white'}`}>
                        <div className="flex items-center space-x-2">
                          <div className="flex space-x-1">
                            <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                            <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.1s'}}></div>
                            <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{animationDelay: '0.2s'}}></div>
                          </div>
                          <span className={`text-sm ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>Thinking...</span>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
                <div ref={messagesEndRef} />
              </div>
            )}
          </div>
        </div>

        {/* Input */}
        <div className={`px-2 sm:px-4 lg:px-6 py-2 sm:py-4 border-t flex-shrink-0 ${darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'}`}>
          <div className="w-full">
            <div className={`rounded-2xl p-2 sm:p-3 ${darkMode ? 'bg-gray-700' : 'bg-gray-100'}`}>
            {/* File attachments preview */}
            {attachedFiles.length > 0 && (
              <div className="mb-3 flex flex-wrap gap-2">
                {attachedFiles.map((file, index) => (
                  <div key={index} className={`relative rounded-lg p-2 flex items-center space-x-2 max-w-full sm:max-w-xs ${darkMode ? 'bg-gray-600' : 'bg-white'}`}>
                    {file.type.startsWith('image/') && previewUrls[index] ? (
                      <img
                        src={previewUrls[index]}
                        alt={file.name}
                        className="w-8 h-8 object-cover rounded"
                      />
                    ) : (
                      <div className={`w-8 h-8 rounded flex items-center justify-center ${darkMode ? 'bg-gray-500' : 'bg-gray-200'}`}>
                        <Paperclip size={16} className={darkMode ? 'text-gray-300' : 'text-gray-600'} />
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <p className={`text-sm font-medium truncate ${darkMode ? 'text-white' : 'text-gray-900'}`}>{file.name}</p>
                      <p className={`text-xs ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>{(file.size / 1024).toFixed(1)} KB</p>
                    </div>
                    <button
                      onClick={() => removeFile(index)}
                      className={`p-1 rounded-full ${darkMode ? 'text-gray-400 hover:text-gray-200 hover:bg-gray-500' : 'text-gray-400 hover:text-gray-600 hover:bg-gray-100'}`}
                    >
                      <X size={14} />
                    </button>
                  </div>
                ))}
              </div>
            )}

            {/* Top row - Text input */}
            <div className="mb-3">
              <textarea
                value={currentMessage}
                onChange={(e) => setCurrentMessage(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Ask anything... paste images (Ctrl+V), attach files, or ask me to create artwork!"
                className={`w-full bg-transparent resize-none focus:outline-none text-base leading-6 ${darkMode ? 'text-white placeholder-gray-400' : 'text-gray-900 placeholder-gray-500'}`}
                rows={1}
                disabled={loading}
                style={{minHeight: '24px', maxHeight: '200px'}}
                onInput={(e) => {
                  const target = e.target as HTMLTextAreaElement;
                  target.style.height = '24px';
                  target.style.height = Math.min(target.scrollHeight, 200) + 'px';
                }}
              />
            </div>

            {/* Bottom row - Action buttons */}
            <div className="flex items-center justify-between">
              {/* Left side - Attachment and options */}
              <div className="flex items-center space-x-1 sm:space-x-2">
                {/* Attachment dropdown */}
                <div className="relative" ref={attachmentMenuRef}>
                  <button
                    onClick={toggleAttachmentMenu}
                    className={`p-3 sm:p-2 rounded-lg transition-colors flex items-center justify-center min-w-[44px] min-h-[44px] sm:min-w-[auto] sm:min-h-[auto] ${darkMode ? 'text-gray-400 hover:text-white hover:bg-gray-600' : 'text-gray-600 hover:text-gray-800 hover:bg-gray-200'}`}
                    title="Add attachments"
                  >
                    <Plus size={18} />
                  </button>

                  {showAttachmentMenu && (
                    <div className={`absolute bottom-full left-0 mb-2 rounded-lg shadow-lg border py-1 min-w-48 ${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-200'}`}>
                      <button
                        onClick={handleImageClick}
                        className={`w-full px-4 py-3 text-left text-sm transition-colors ${darkMode ? 'text-gray-300 hover:bg-gray-600' : 'text-gray-700 hover:bg-gray-50'}`}
                      >
                        📷 Upload photo
                      </button>
                      <button
                        onClick={handleFileClick}
                        className={`w-full px-4 py-3 text-left text-sm transition-colors ${darkMode ? 'text-gray-300 hover:bg-gray-600' : 'text-gray-700 hover:bg-gray-50'}`}
                      >
                        📄 Upload file
                      </button>
                      <button
                        onClick={handlePdfConverterClick}
                        className={`w-full px-4 py-3 text-left text-sm transition-colors ${darkMode ? 'text-gray-300 hover:bg-gray-600' : 'text-gray-700 hover:bg-gray-50'}`}
                      >
                        📄 Convert to PDF
                      </button>
                    </div>
                  )}
                </div>

                {/* Web Search toggle */}
                <button
                  onClick={() => setWebSearchEnabled(!webSearchEnabled)}
                  className={`p-3 sm:p-2 rounded-lg transition-colors flex items-center justify-center min-w-[44px] min-h-[44px] sm:min-w-[auto] sm:min-h-[auto] ${
                    webSearchEnabled
                      ? darkMode ? 'bg-blue-800 text-blue-300 hover:bg-blue-700' : 'bg-blue-200 text-blue-700 hover:bg-blue-300'
                      : darkMode ? 'text-gray-400 hover:text-blue-400 hover:bg-blue-900' : 'text-gray-600 hover:text-blue-600 hover:bg-blue-100'
                  }`}
                  title={webSearchEnabled ? 'Disable Web Search' : 'Enable Web Search'}
                >
                  <Globe size={18} />
                </button>

                {/* Deep Research toggle */}
                <button
                  onClick={() => setDeepResearchMode(!deepResearchMode)}
                  className={`p-3 sm:p-2 rounded-lg transition-colors flex items-center justify-center min-w-[44px] min-h-[44px] sm:min-w-[auto] sm:min-h-[auto] ${
                    deepResearchMode
                      ? darkMode ? 'bg-purple-800 text-purple-300 hover:bg-purple-700' : 'bg-purple-200 text-purple-700 hover:bg-purple-300'
                      : darkMode ? 'text-gray-400 hover:text-purple-400 hover:bg-purple-900' : 'text-gray-600 hover:text-purple-600 hover:bg-purple-100'
                  }`}
                  title={deepResearchMode ? 'Disable Deep Research Mode' : 'Enable Deep Research Mode'}
                >
                  <SearchCheck size={18} />
                </button>
              </div>

              {/* Right side - Send button */}
              <div className="flex items-center">
                <button
                  onClick={sendMessage}
                  disabled={loading || (!currentMessage.trim() && attachedFiles.length === 0)}
                  className={`px-4 py-3 sm:py-2 rounded-lg font-medium transition-colors flex items-center space-x-2 min-h-[44px] ${
                    (currentMessage.trim() || attachedFiles.length > 0) && !loading
                      ? 'bg-blue-500 text-white hover:bg-blue-600'
                      : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                  }`}
                >
                  <Send size={16} />
                  <span className="hidden sm:inline">Send</span>
                </button>
              </div>
            </div>
            </div>
          </div>

          {/* Hidden file inputs */}
          <input
            ref={fileInputRef}
            type="file"
            multiple
            accept=".pdf,.txt,.csv,.doc,.docx,.xls,.xlsx,.js,.ts,.py,.java,.cpp,.c,.h,.md,.json,.html,.css"
            onChange={(e) => handleFileUpload(e.target.files)}
            className="hidden"
          />
          <input
            ref={imageInputRef}
            type="file"
            multiple
            accept="image/*,.heic,.heif"
            onChange={(e) => handleFileUpload(e.target.files)}
            className="hidden"
          />
          <input
            ref={pdfImageInputRef}
            type="file"
            multiple
            accept="image/*,.heic,.heif"
            onChange={(e) => handlePdfImageUpload(e.target.files)}
            className="hidden"
          />

          {/* Drag and drop overlay */}
          {isDragging && (
            <div className="fixed inset-0 bg-blue-500 bg-opacity-20 flex items-center justify-center z-50 pointer-events-none">
              <div className={`rounded-2xl p-8 shadow-2xl border-2 border-dashed border-blue-500 max-w-md mx-4 ${darkMode ? 'bg-gray-800' : 'bg-white'}`}>
                <div className="text-center">
                  <div className="w-16 h-16 mx-auto mb-4 bg-blue-100 rounded-full flex items-center justify-center">
                    <svg
                      className="w-8 h-8 text-blue-500"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                      />
                    </svg>
                  </div>
                  <h3 className={`text-lg font-semibold mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>
                    Drop files to upload
                  </h3>
                  <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    Drop your photos or documents here to attach them to your message
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* PDF Converter Modal */}
      {showPdfConverter && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className={`w-full max-w-4xl max-h-[90vh] rounded-2xl shadow-2xl overflow-hidden ${darkMode ? 'bg-gray-800' : 'bg-white'}`}>
            {/* Header */}
            <div className={`px-6 py-4 border-b ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
              <div className="flex items-center justify-between">
                <div>
                  <h2 className={`text-xl font-semibold ${darkMode ? 'text-white' : 'text-gray-900'}`}>Convert Images to PDF</h2>
                  <p className={`text-sm mt-1 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>Select multiple images to combine into a single PDF document</p>
                </div>
                <button
                  onClick={() => {
                    setShowPdfConverter(false)
                    // Clean up preview URLs
                    pdfPreviewUrls.forEach(url => URL.revokeObjectURL(url))
                    setPdfImages([])
                    setPdfPreviewUrls([])
                  }}
                  className={`p-2 rounded-lg transition-colors ${darkMode ? 'text-gray-400 hover:text-white hover:bg-gray-700' : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'}`}
                >
                  <X size={20} />
                </button>
              </div>
            </div>

            {/* Content */}
            <div className="p-6 max-h-96 overflow-y-auto">
              {pdfImages.length === 0 ? (
                <div className="text-center py-12">
                  <div className={`w-16 h-16 mx-auto mb-4 rounded-full flex items-center justify-center ${darkMode ? 'bg-gray-700' : 'bg-gray-100'}`}>
                    <FileText className={`w-8 h-8 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`} />
                  </div>
                  <h3 className={`text-lg font-medium mb-2 ${darkMode ? 'text-white' : 'text-gray-900'}`}>No images selected</h3>
                  <p className={`text-sm mb-6 ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>Choose images to convert into a PDF document</p>
                  <button
                    onClick={() => pdfImageInputRef.current?.click()}
                    className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors"
                  >
                    Select Images
                  </button>
                </div>
              ) : (
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                      {pdfImages.length} image{pdfImages.length > 1 ? 's' : ''} selected
                    </p>
                    <button
                      onClick={() => pdfImageInputRef.current?.click()}
                      className={`text-sm px-3 py-1 rounded-md transition-colors ${darkMode ? 'text-blue-400 hover:bg-blue-900' : 'text-blue-600 hover:bg-blue-100'}`}
                    >
                      Add more images
                    </button>
                  </div>

                  <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                    {pdfImages.map((file, index) => (
                      <div key={index} className={`relative rounded-lg overflow-hidden ${darkMode ? 'bg-gray-700' : 'bg-gray-100'}`}>
                        <img
                          src={pdfPreviewUrls[index]}
                          alt={file.name}
                          className="w-full h-32 object-cover"
                        />
                        <div className="absolute inset-0 bg-black bg-opacity-0 hover:bg-opacity-20 transition-opacity flex items-start justify-end p-2">
                          <div className="flex space-x-1">
                            {index > 0 && (
                              <button
                                onClick={() => movePdfImage(index, index - 1)}
                                className="bg-black bg-opacity-50 text-white p-1 rounded hover:bg-opacity-70 transition-opacity"
                                title="Move up"
                              >
                                <ChevronUp size={12} />
                              </button>
                            )}
                            {index < pdfImages.length - 1 && (
                              <button
                                onClick={() => movePdfImage(index, index + 1)}
                                className="bg-black bg-opacity-50 text-white p-1 rounded hover:bg-opacity-70 transition-opacity"
                                title="Move down"
                              >
                                <ChevronDown size={12} />
                              </button>
                            )}
                            <button
                              onClick={() => removePdfImage(index)}
                              className="bg-red-500 bg-opacity-80 text-white p-1 rounded hover:bg-opacity-100 transition-opacity"
                              title="Remove"
                            >
                              <X size={12} />
                            </button>
                          </div>
                        </div>
                        <div className={`absolute bottom-0 left-0 right-0 p-2 ${darkMode ? 'bg-gray-800' : 'bg-white'} bg-opacity-90`}>
                          <p className={`text-xs truncate ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>{file.name}</p>
                          <p className={`text-xs ${darkMode ? 'text-gray-400' : 'text-gray-500'}`}>Page {index + 1}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Footer */}
            {pdfImages.length > 0 && (
              <div className={`px-6 py-4 border-t ${darkMode ? 'border-gray-700 bg-gray-700' : 'border-gray-200 bg-gray-50'}`}>
                <div className="flex items-center justify-between">
                  <div className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    📄 Images will be arranged in the order shown above
                  </div>
                  <div className="flex space-x-3">
                    <button
                      onClick={() => {
                        setShowPdfConverter(false)
                        pdfPreviewUrls.forEach(url => URL.revokeObjectURL(url))
                        setPdfImages([])
                        setPdfPreviewUrls([])
                      }}
                      className={`px-4 py-2 rounded-lg transition-colors ${darkMode ? 'text-gray-300 hover:bg-gray-600' : 'text-gray-600 hover:bg-gray-200'}`}
                    >
                      Cancel
                    </button>
                    <button
                      onClick={generatePDF}
                      className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600 transition-colors"
                    >
                      Generate PDF
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Settings Modal */}
      <SettingsModal
        isOpen={settingsOpen}
        onClose={() => setSettingsOpen(false)}
        darkMode={darkMode}
        onDarkModeChange={setDarkMode}
      />
    </div>
  )
}