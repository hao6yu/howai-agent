'use client'

import React, { createContext, useContext, useState, useEffect } from 'react'

export type FontSize = 'xs' | 'sm' | 'base' | 'lg' | 'xl'

interface FontSizeContextType {
  fontSize: FontSize
  setFontSize: (size: FontSize) => void
  increaseFontSize: () => void
  decreaseFontSize: () => void
}

const fontSizeMap = {
  xs: { scale: 0.85, label: 'Extra Small' },
  sm: { scale: 0.9, label: 'Small' },
  base: { scale: 1, label: 'Default' },
  lg: { scale: 1.1, label: 'Large' },
  xl: { scale: 1.2, label: 'Extra Large' }
}

const fontSizeOrder: FontSize[] = ['xs', 'sm', 'base', 'lg', 'xl']

const FontSizeContext = createContext<FontSizeContextType | undefined>(undefined)

export function FontSizeProvider({ children }: { children: React.ReactNode }) {
  const [fontSize, setFontSizeState] = useState<FontSize>('base')
  const [isInitialized, setIsInitialized] = useState(false)

  // Load font size from localStorage on mount
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const savedFontSize = localStorage.getItem('fontSize') as FontSize
      if (savedFontSize && fontSizeOrder.includes(savedFontSize)) {
        setFontSizeState(savedFontSize)
        applyFontSize(savedFontSize)
      }
      setIsInitialized(true)
    }
  }, [])

  const applyFontSize = (size: FontSize) => {
    const scale = fontSizeMap[size].scale

    // Apply to root element for global scaling
    if (typeof window !== 'undefined') {
      const root = document.documentElement

      // Set CSS variables for different text sizes
      root.style.setProperty('--font-scale', scale.toString())
      root.style.setProperty('--text-xs', `${0.75 * scale}rem`)
      root.style.setProperty('--text-sm', `${0.875 * scale}rem`)
      root.style.setProperty('--text-base', `${1 * scale}rem`)
      root.style.setProperty('--text-lg', `${1.125 * scale}rem`)
      root.style.setProperty('--text-xl', `${1.25 * scale}rem`)
      root.style.setProperty('--text-2xl', `${1.5 * scale}rem`)
      root.style.setProperty('--text-3xl', `${1.875 * scale}rem`)

      // Apply a base font size class to body
      document.body.setAttribute('data-font-size', size)
    }
  }

  const setFontSize = (size: FontSize) => {
    setFontSizeState(size)
    applyFontSize(size)

    // Save to localStorage
    if (typeof window !== 'undefined') {
      localStorage.setItem('fontSize', size)
    }
  }

  const increaseFontSize = () => {
    const currentIndex = fontSizeOrder.indexOf(fontSize)
    if (currentIndex < fontSizeOrder.length - 1) {
      setFontSize(fontSizeOrder[currentIndex + 1])
    }
  }

  const decreaseFontSize = () => {
    const currentIndex = fontSizeOrder.indexOf(fontSize)
    if (currentIndex > 0) {
      setFontSize(fontSizeOrder[currentIndex - 1])
    }
  }

  // Don't render children until we've loaded the saved font size
  if (!isInitialized) {
    return null
  }

  return (
    <FontSizeContext.Provider value={{ fontSize, setFontSize, increaseFontSize, decreaseFontSize }}>
      {children}
    </FontSizeContext.Provider>
  )
}

export function useFontSize() {
  const context = useContext(FontSizeContext)
  if (context === undefined) {
    throw new Error('useFontSize must be used within a FontSizeProvider')
  }
  return context
}

export { fontSizeMap }