# HowAI Web

A Next.js web application for HowAI - AI-powered conversations for everyone. This is the web companion to the Flutter mobile app.

## Features

- 🔐 **User Authentication** - Sign up/in with Supabase Auth
- 💬 **Real-time Chat** - Instant messaging with AI
- 🔍 **Web Search** - AI can search the internet for current information
- 📎 **File Attachments** - Upload images and documents (including HEIC support)
- 🧠 **Deep Research Mode** - Enhanced AI analysis with reasoning models
- 📌 **Conversation Pinning** - Pin important conversations to the top
- 🏷️ **Auto-Generated Titles** - Conversations get smart titles automatically
- 🗄️ **PostgreSQL Database** - Persistent conversation history
- 📱 **Responsive Design** - Works on desktop and mobile
- 🎨 **Tailwind CSS** - Modern, clean UI
- 🔒 **Row Level Security** - Secure data access

## Tech Stack

- **Frontend**: Next.js 14, TypeScript, Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **AI**: OpenAI API integration (coming soon)
- **Icons**: Lucide React

## Getting Started

### Prerequisites

- Node.js 18.17.0 or later
- npm or yarn
- Supabase account

### 1. Clone and Install

```bash
# Navigate to the web app directory
cd haogpt-web

# Install dependencies
npm install
```

### 2. Environment Setup

Copy the environment template:
```bash
cp .env.example .env.local
```

Update `.env.local` with your Supabase credentials:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Database Setup

1. Go to your Supabase dashboard
2. Navigate to SQL Editor
3. Copy and run the SQL from `database-schema.sql`
4. This will create all necessary tables and security policies

### 4. Run the Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser.

## Project Structure

```
src/
├── app/                 # Next.js app directory
│   ├── globals.css     # Global styles
│   ├── layout.tsx      # Root layout
│   └── page.tsx        # Home page
├── components/         # React components
│   ├── auth/          # Authentication components
│   └── chat/          # Chat interface components
├── hooks/             # Custom React hooks
├── lib/               # Utility libraries
│   ├── supabase.ts    # Supabase client (browser)
│   └── supabase-server.ts # Supabase client (server)
└── types/             # TypeScript type definitions
    ├── chat.ts        # Chat-related types
    └── database.ts    # Database schema types
```

## Web Search Configuration

To enable the web search feature, you need to set up Google Custom Search:

### 1. Get Google API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create a new project or select existing one
3. Enable the "Custom Search API"
4. Create credentials (API Key)
5. Copy the API key

### 2. Create Custom Search Engine
1. Go to [Programmable Search Engine](https://programmablesearchengine.google.com/)
2. Click "Add" to create a new search engine
3. Enter `*` as the site to search (for searching the entire web)
4. Create the search engine
5. Copy the Search Engine ID

### 3. Add to Environment Variables
```bash
GOOGLE_API_KEY=your_google_api_key_here
GOOGLE_CSE_ID=your_custom_search_engine_id_here
```

**Note**: Google Custom Search provides 100 free searches per day. For higher usage, you'll need to enable billing.

## Development Commands

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Run production build
npm start

# Run linting
npm run lint

# Type checking
npx tsc --noEmit
```

## Database Schema

The application uses three main tables:

- **profiles**: User profile information (extends Supabase auth.users)
- **conversations**: Chat conversations belonging to users
- **messages**: Individual messages within conversations

All tables have Row Level Security (RLS) enabled to ensure users can only access their own data.

## Features Roadmap

- [x] Basic authentication
- [x] Chat interface
- [x] Database integration
- [ ] OpenAI API integration
- [ ] Voice recording/playback
- [ ] File uploads
- [ ] Image sharing
- [ ] Real-time updates
- [ ] PWA support
- [ ] Mobile optimizations

## Deployment

### Vercel (Recommended)

1. Push your code to GitHub
2. Connect your repository to Vercel
3. Add environment variables in Vercel dashboard
4. Deploy automatically on push

### Other Platforms

The app can be deployed to any platform that supports Next.js:
- Netlify
- Railway
- DigitalOcean App Platform
- AWS Amplify

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the HowAI application suite.
