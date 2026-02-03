import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const { query } = await request.json()

    if (!query) {
      return NextResponse.json(
        { error: 'Search query is required' },
        { status: 400 }
      )
    }

    const googleApiKey = process.env.GOOGLE_API_KEY
    const googleCseId = process.env.GOOGLE_CSE_ID

    if (!googleApiKey || !googleCseId) {
      console.warn('Google API key or CSE ID not configured')
      return NextResponse.json({
        results: [
          {
            title: 'Web Search Configuration Error',
            link: '',
            snippet: 'Web search is not properly configured. Google API credentials are missing. Please check your environment variables for GOOGLE_API_KEY and GOOGLE_CSE_ID.',
          }
        ]
      })
    }

    try {
      const searchUrl = `https://www.googleapis.com/customsearch/v1?key=${googleApiKey}&cx=${googleCseId}&q=${encodeURIComponent(query)}&num=5`
      
      console.log(`[WebSearch] Searching for: ${query}`)
      
      const response = await fetch(searchUrl)
      
      console.log(`[WebSearch] Response status: ${response.status}`)

      if (response.ok) {
        const data = await response.json()
        const results: Array<{ title: string; link: string; snippet: string }> = []

        // Extract search results
        if (data.items && Array.isArray(data.items)) {
          console.log(`[WebSearch] Found ${data.items.length} search results`)
          
          for (const item of data.items) {
            results.push({
              title: item.title || '',
              link: item.link || '',
              snippet: item.snippet || '',
            })
          }
        } else {
          console.log('[WebSearch] No items found in response')
        }

        console.log(`[WebSearch] Returning ${results.length} results`)
        return NextResponse.json({ results })
      } else {
        console.error(`[WebSearch] Request failed: ${response.status}`)
        const errorText = await response.text()
        console.error(`[WebSearch] Error response: ${errorText}`)
        
        return NextResponse.json({
          results: [
            {
              title: 'Google Search API Error',
              link: '',
              snippet: `Google Search API returned error ${response.status}. Please check your API configuration.`,
            }
          ]
        })
      }
    } catch (searchError) {
      console.error('[WebSearch] Search request failed:', searchError)
      return NextResponse.json({
        results: [
          {
            title: 'Google Search Network Error',
            link: '',
            snippet: `Network error occurred while searching: ${searchError}`,
          }
        ]
      })
    }

  } catch (error) {
    console.error('Web search API error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
