# HaoGPT (HowAI) 🤖

A powerful AI chat app for iOS, Android, and Web with advanced features like image generation, voice synthesis, and location-aware search.

## Features

### Core Chat
- **Multi-model AI** - GPT-4, GPT-4 Vision, and more
- **Conversation history** - Local SQLite storage with cloud sync
- **Multiple profiles** - Separate chat histories per profile
- **AI personalities** - Customizable AI behavior and tone

### AI Capabilities
- **Image analysis** - Analyze photos and screenshots
- **Image generation** - Create images with DALL-E
- **Voice synthesis** - Text-to-speech via ElevenLabs
- **Document analysis** - Process PDFs and files
- **Places Explorer** - Location-aware search with Google Maps

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
- **OpenAI** - GPT models and DALL-E
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

1. Clone the repository
2. Copy `env.example` to `.env` and fill in API keys:
   ```
   OPENAI_API_KEY=sk-...
   # Optional in production: route through your backend proxy
   OPENAI_PROXY_BASE_URL=https://your-proxy.example.com
   OPENAI_PROXY_TOKEN=...
   ELEVENLABS_API_KEY=...
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
   flutter run
   ```

### Optional: OpenAI Proxy (Recommended for Production)

Use the included Supabase Edge Function proxy to keep OpenAI keys off-device:

1. Deploy function:
   ```bash
   supabase functions deploy openai-proxy
   ```
2. Set function secrets:
   ```bash
   supabase secrets set OPENAI_API_KEY=sk-... PROXY_SHARED_TOKEN=your-shared-token
   ```
3. Configure mobile app `.env`:
   ```bash
   OPENAI_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/openai-proxy
   OPENAI_PROXY_TOKEN=your-shared-token
   ```

### Building

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release

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
