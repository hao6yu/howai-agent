# HowAI Agent 🤖

A powerful AI chat app for iOS, Android, and Web powered by GPT-5.2 with built-in image generation, web search, voice synthesis, and more.

## Features

### Core Chat
- **GPT-5.2** - OpenAI's flagship model with deep research mode
- **GPT-5 Nano** - Fast, lightweight model for free-tier users
- **Conversation history** - Local SQLite storage with cloud sync
- **Multiple profiles** - Separate chat histories per profile
- **AI personalities** - Customizable AI behavior and tone

### AI Capabilities
- **Image analysis** - Analyze photos, screenshots, and documents
- **Image generation** - Built-in to GPT-5.2 (no separate model needed)
- **Web search** - Real-time internet search integrated into responses
- **Deep research mode** - High reasoning effort with comprehensive analysis
- **Voice synthesis** - Text-to-speech via ElevenLabs
- **Document analysis** - Process PDFs and files
- **Presentation generation** - Create PowerPoint slides from chat
- **Places Explorer** - Location-aware search with Google Maps & Street View

### Premium Features
- **Subscription tiers** - Free and Premium plans
- **Usage tracking** - Weekly limits for free tier
- **Cloud sync** - Supabase-powered sync across devices

### Personalization
- **17 languages** - Full localization support
- **Dark/Light mode** - System or manual theme
- **Font scaling** - Adjustable text size
- **Voice settings** - Multiple ElevenLabs voices

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Supabase** - Auth, database, and sync
- **OpenAI** - GPT-5.2 (chat, vision, image generation, web search)
- **ElevenLabs** - Text-to-speech
- **Google Maps** - Places API and Street View
- **SQLite** - Local data persistence

## Project Structure

```
lib/
├── generated/       # L10n generated files
├── l10n/           # Localization ARB files
├── models/         # Data models (Profile, Conversation, etc.)
├── providers/      # State management (Provider)
├── screens/        # UI screens
├── services/       # Business logic and APIs
├── utils/          # Helper functions
└── widgets/        # Reusable UI components

haogpt-web/         # Web deployment (Docker)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK
- API keys for: OpenAI, ElevenLabs, Google Maps, Supabase

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/hao6yu/howai-agent.git
   cd howai-agent
   ```
2. Copy `env.example` to `.env` for local build-time configuration:
   ```
   # Local development only. Do not include OpenAI keys in production mobile builds.
   OPENAI_API_KEY=
   # Production: route through the Supabase Edge Function proxy.
   OPENAI_PROXY_BASE_URL=https://your-project.supabase.co/functions/v1/openai-proxy
   ELEVENLABS_PROXY_BASE_URL=https://your-project.supabase.co/functions/v1/elevenlabs-proxy
   GOOGLE_MAPS_API_KEY=...
   SUPABASE_URL=https://...
   SUPABASE_ANON_KEY=...
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Generate localizations:
   ```bash
   flutter gen-l10n
   ```
5. Run the app:
   ```bash
   flutter run --dart-define-from-file=.env
   ```

`.env` is intentionally not bundled as a Flutter asset. Values passed with
`--dart-define` are still visible in a compiled mobile app, so only put public
client config there for production. Keep server secrets, especially
`OPENAI_API_KEY`, in Supabase secrets.

### Optional: OpenAI Proxy (Recommended for Production)

Use the included Supabase Edge Function proxy to keep OpenAI keys off-device:

1. Enable anonymous sign-ins in Supabase Dashboard:
   `Authentication` → `Sign In / Providers` → `Anonymous Sign-Ins`.
2. Deploy function:
   ```bash
   supabase functions deploy openai-proxy
   ```
3. Set function secrets:
   ```bash
   supabase secrets set OPENAI_API_KEY=sk-...
   ```
4. Configure mobile app build config:
   ```bash
   OPENAI_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/openai-proxy
   ```

Model names can now be changed server-side with Supabase secrets:

```bash
supabase secrets set \
  OPENAI_PROXY_CHAT_MODEL=gpt-5.2 \
  OPENAI_PROXY_CHAT_MINI_MODEL=gpt-5-nano
supabase functions deploy openai-proxy
```

### Optional: ElevenLabs Proxy (Recommended for Production)

Use the included Supabase Edge Function proxy to keep ElevenLabs keys off-device:

```bash
supabase db push
supabase secrets set ELEVENLABS_API_KEY=sk_...
supabase functions deploy elevenlabs-proxy
```

Configure mobile app build config:

```bash
ELEVENLABS_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/elevenlabs-proxy
```

### Building

```bash
# iOS
flutter build ios --release --dart-define-from-file=.env

# Android
flutter build apk --release --dart-define-from-file=.env

# Web (see haogpt-web/README.md)
cd haogpt-web && docker build -t haogpt-web .
```

## Screens

| Screen | Description |
|--------|-------------|
| `ai_chat_screen` | Main chat interface |
| `settings_screen` | App configuration |
| `profile_screen` | Manage user profiles |
| `ai_personality_screen` | Customize AI behavior |
| `subscription_screen` | Premium plans |
| `voice_settings_screen` | ElevenLabs voice config |
| `street_view_screen` | Google Street View |

## Configuration

Key settings in `SettingsProvider`:
- `useStreaming` - Stream responses (disable for image gen)
- `fontSize` - Text scale factor
- `selectedVoice` - ElevenLabs voice ID
- `enableHaptics` - Vibration feedback

## License

Private - All rights reserved

## Support

☕ [Buy me a coffee](https://buymeacoffee.com/hao_yu)
