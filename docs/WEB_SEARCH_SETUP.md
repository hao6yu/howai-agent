# 🌐 Web Search Setup Guide

HowAI now supports **real-time web search** capabilities! The AI can automatically search the internet for current information, news, prices, and more.

## 🔧 Setup Instructions

### 1. Get Google API Credentials (FREE!)
**Step 1: Get API Key**
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new project or select existing one
3. Click "Create Credentials" → "API Key"
4. Copy your API key

**Step 2: Enable Custom Search API**
1. Go to [Google Cloud Console APIs](https://console.cloud.google.com/apis/library)
2. Search for "Custom Search API"
3. Click on it and press "Enable"

**Step 3: Create Search Engine**
1. Go to [Programmable Search Engine](https://programmablesearchengine.google.com/)
2. Click "Add" to create a new search engine
3. Enter `*` in "Sites to search" (to search the entire web)
4. Give it a name like "HowAI Web Search"
5. Click "Create"
6. Copy your Search Engine ID

### 2. Add to Environment
Add your credentials to your `.env` file:
```
GOOGLE_API_KEY=your_google_api_key_here
GOOGLE_CSE_ID=your_custom_search_engine_id_here
```

### 3. Test It Out!
Try asking questions like:
- "What's the current weather in New York?"
- "What are the latest news about AI?"
- "What's the current price of Bitcoin?"
- "Who won the latest NBA game?"

## 🎯 How It Works

1. **Smart Detection**: The AI automatically detects when you need current information
2. **Web Search**: It searches Google using the Custom Search API to get the latest results
3. **Intelligent Response**: The AI analyzes the search results and provides you with a comprehensive answer
4. **Source Links**: Responses include links to the original sources

## 💡 Example Conversations

**User**: "What's happening in the stock market today?"
**HowAI**: *[Searches web]* Based on the latest market data, here's what's happening today... [includes current prices and trends with source links]

**User**: "What's the weather like in Tokyo right now?"
**HowAI**: *[Searches web]* The current weather in Tokyo is... [provides real-time weather data]

## 🔒 Privacy & Costs

- **FREE**: 100 searches per day (no cost!)
- **Paid Plans**: $5 per 1,000 additional queries (very affordable)
- **Privacy**: Search queries are processed through Google but not stored by HowAI

## 🚀 Why Google Custom Search?

✅ **FREE**: 100 searches per day at no cost
✅ **Reliable**: Powered by Google's search infrastructure  
✅ **Fast**: Direct API access with quick responses
✅ **Accurate**: High-quality search results from Google
✅ **Simple**: Easy setup with just 2 credentials

---

**Note**: Web search is automatically triggered when the AI detects you need current information. You don't need to explicitly ask it to search - just ask your question naturally! 