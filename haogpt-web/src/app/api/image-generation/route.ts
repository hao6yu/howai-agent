import { NextRequest, NextResponse } from 'next/server'
import OpenAI from 'openai'

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  timeout: 240000, // 4 minutes timeout for image generation (doubled)
})

// Increase timeout for image generation API
export const maxDuration = 240 // 4 minutes in seconds (doubled)

export async function POST(request: NextRequest) {
  try {
    const { prompt, size = '1024x1024', quality = 'standard' } = await request.json()

    if (!prompt) {
      return NextResponse.json({ error: 'Prompt is required' }, { status: 400 })
    }

    // Validate size parameter
    const validSizes = ['1024x1024', '1792x1024', '1024x1792']
    const validatedSize = validSizes.includes(size) ? size : '1024x1024'

    // Validate quality parameter - prioritize 'standard' for better performance
    const validatedQuality = quality === 'hd' ? 'hd' : 'standard' // Default to 'standard' for faster generation

    console.log('[Image Generation] Generating image with prompt:', prompt.substring(0, 100) + '...')
    console.log('[Image Generation] Size:', validatedSize, 'Quality:', validatedQuality)

    const response = await openai.images.generate({
      model: 'dall-e-3',
      prompt: prompt,
      n: 1,
      size: validatedSize as '1024x1024' | '1792x1024' | '1024x1792',
      quality: validatedQuality as 'standard' | 'hd',
      response_format: 'url',
      style: 'natural' // Changed from 'vivid' to 'natural' - faster generation
    })

    const imageUrl = response.data[0]?.url

    if (!imageUrl) {
      console.error('[Image Generation] No image URL returned from OpenAI')
      return NextResponse.json(
        { error: 'Failed to generate image - no URL returned' },
        { status: 500 }
      )
    }

    console.log('[Image Generation] Successfully generated image')

    return NextResponse.json({
      imageUrl,
      prompt,
      size: validatedSize,
      quality: validatedQuality,
      revised_prompt: response.data[0]?.revised_prompt
    })

  } catch (error) {
    console.error('[Image Generation] Error:', error)
    
    // Handle specific OpenAI errors
    if (error instanceof Error) {
      // Check for content policy violations
      if (error.message.includes('content_policy_violation')) {
        return NextResponse.json(
          { error: 'Image generation failed: Content policy violation. Please try a different prompt.' },
          { status: 400 }
        )
      }
      
      // Check for safety system rejections
      if (error.message.includes('safety_system')) {
        return NextResponse.json(
          { error: 'Image generation failed: Safety system rejection. Please try a different prompt.' },
          { status: 400 }
        )
      }
    }

    return NextResponse.json(
      { error: 'Failed to generate image' },
      { status: 500 }
    )
  }
}
