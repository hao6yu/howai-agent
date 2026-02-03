# HowAI Web - Setup Guide

This guide will help you set up the HowAI web application from scratch.

## Prerequisites

- **Node.js**: Version 18.17.0 or later (your current version is 18.13.0, needs update)
- **Supabase Account**: Free tier available at [supabase.com](https://supabase.com)
- **Git**: For version control

## Step 1: Update Node.js (Required)

Your current Node.js version (18.13.0) is too old. Update to 18.17.0 or later:

### Using nvm (recommended):
```bash
# Install latest LTS
nvm install --lts
nvm use --lts
```

### Or download from nodejs.org:
Visit [nodejs.org](https://nodejs.org) and download the latest LTS version.

## Step 2: Supabase Project Setup

1. **Create a new project** at [supabase.com](https://supabase.com)
2. **Get your credentials** from Settings > API:
   - Project URL
   - Anon public key
3. **Set up the database**:
   - Go to SQL Editor in your Supabase dashboard
   - Copy and paste the entire content from `database-schema.sql`
   - Click "Run" to execute the SQL

## Step 3: Environment Configuration

1. **Copy the environment template**:
   ```bash
   cp .env.example .env.local
   ```

2. **Update `.env.local`** with your actual values:
   ```env
   # From your Supabase project settings
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here

   # From your existing Flutter app .env
   OPENAI_API_KEY=your_openai_api_key_here
   OPENAI_CHAT_MODEL=gpt-4.1
   OPENAI_CHAT_MINI_MODEL=gpt-3.5-turbo-0125
   OPENAI_REALTIME_MODEL=gpt-4o-realtime-preview-2024-12-17
   ELEVENLABS_API_KEY=your_elevenlabs_api_key_here

   # App configuration
   NEXT_PUBLIC_APP_URL=http://localhost:3000
   ```

## Step 4: Install and Run

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Step 5: Test the Application

1. **Sign up** for a new account
2. **Check your email** for confirmation (if required)
3. **Sign in** and test the chat interface
4. **Send a message** - you should see a placeholder AI response

## What Works Now

✅ **User authentication** (sign up/in/out)
✅ **Database integration** (conversations and messages saved)
✅ **Chat interface** (responsive design)
✅ **Security** (Row Level Security enabled)

## Next Steps

### Immediate (Ready to implement):
- **OpenAI API integration** - Replace placeholder AI responses
- **Voice recording** - Add Web Audio API for voice messages
- **File uploads** - Supabase Storage integration

### Future Features:
- **Real-time updates** - WebSocket/Server-Sent Events
- **PWA support** - Offline functionality and app installation
- **Image sharing** - Camera access and image uploads
- **Video calls** - WebRTC integration

## Troubleshooting

### Common Issues:

1. **Build fails**: Update Node.js to 18.17.0+
2. **Database errors**: Ensure you ran the SQL schema setup
3. **Auth not working**: Check Supabase URL and keys
4. **TypeScript errors**: Run `npx tsc --noEmit` to check

### Database Issues:

If you need to reset the database:
```sql
-- Run in Supabase SQL Editor
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
-- Then re-run database-schema.sql
```

## Production Deployment

### Vercel (Recommended):
1. Push to GitHub
2. Connect repository to Vercel
3. Add environment variables in Vercel dashboard
4. Deploy

### Environment Variables for Production:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `OPENAI_API_KEY`
- `ELEVENLABS_API_KEY`
- `NEXT_PUBLIC_APP_URL` (your production domain)

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Supabase      │    │   External APIs │
│   (Next.js)     │◄──►│   (Database +   │    │   (OpenAI +     │
│                 │    │    Auth)        │    │    ElevenLabs)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

This setup gives you a solid foundation that can scale to support all your Flutter app's features in a web environment.