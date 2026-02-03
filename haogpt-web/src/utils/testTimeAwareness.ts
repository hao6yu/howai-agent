// Test utility to demonstrate time-aware AI functionality
export function testTimeAwarenessQueries() {
  const currentDate = new Date().toISOString().split('T')[0]
  const currentDateTime = new Date().toLocaleString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })

  console.log('🕒 Time-Aware AI Test Queries')
  console.log('============================')
  console.log(`Current Date: ${currentDate}`)
  console.log(`Current DateTime: ${currentDateTime}`)
  console.log('')
  
  const testQueries = [
    "What's today's Tesla stock price?",
    "What's the current weather in Tokyo?",
    "What's today's news?",
    "What's the latest Bitcoin price?",
    "What happened in the stock market today?",
    "Current USD to JPY exchange rate",
    "Today's weather forecast for New York",
    "Recent news about Apple Inc",
    "What's the current price of gold?",
    "Today's sports scores"
  ]

  console.log('Test Queries (should trigger web search):')
  testQueries.forEach((query, index) => {
    console.log(`${index + 1}. ${query}`)
  })
  
  console.log('')
  console.log('Expected Behavior:')
  console.log('- AI should know today is', currentDate)
  console.log('- AI should automatically use web search for these queries')
  console.log('- AI should provide current, accurate information')
  console.log('- AI should reference the specific date in responses')
  
  return {
    currentDate,
    currentDateTime,
    testQueries
  }
}

// Export for use in components or testing
export const timeAwarenessInfo = {
  getCurrentDateInfo: () => {
    const now = new Date()
    return {
      date: now.toISOString().split('T')[0],
      dateTime: now.toLocaleString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        timeZoneName: 'short'
      }),
      year: now.getFullYear(),
      month: now.toLocaleString('en-US', { month: 'long' }),
      day: now.getDate()
    }
  }
}
