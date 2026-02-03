# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HaoGPT (HowAI) is a Flutter application that provides AI-powered conversations, with support for voice chat, text-to-speech, subscription management, and various educational features. The app integrates with OpenAI API for AI conversations and ElevenLabs for text-to-speech functionality.

## Environment Setup

The application requires environment variables configured in a `.env` file:

```bash
# Required environment variables
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_CHAT_MODEL=gpt-4.1
OPENAI_CHAT_MINI_MODEL=gpt-3.5-turbo-0125
OPENAI_REALTIME_MODEL=gpt-4o-realtime-preview-2024-12-17
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

Use `env.example` as a template for creating the `.env` file.

## Common Development Commands

### Basic Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the application in development mode
flutter run

# Clean build artifacts
flutter clean

# Check for Flutter issues
flutter doctor
```

### Building and Testing
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Use the automated build script for Android releases
./build_android_release.sh

# Run tests
flutter test

# Analyze code
flutter analyze

# Update app icons
flutter pub run flutter_launcher_icons
```

### Linting
The project uses `flutter_lints` with custom rules defined in `analysis_options.yaml`. Run linting with:
```bash
flutter analyze
```

## Architecture Overview

### Core Structure
- **`lib/main.dart`**: Application entry point with provider setup and service initialization
- **`lib/providers/`**: State management using Provider pattern
  - `conversation_provider.dart`: Manages chat conversations and messages
  - `settings_provider.dart`: App settings and preferences
  - `profile_provider.dart`: User profile management
  - `ai_personality_provider.dart`: AI personality configurations
- **`lib/services/`**: Business logic and external API integrations
  - `openai_service.dart`: OpenAI API integration for chat and realtime voice
  - `elevenlabs_service.dart`: Text-to-speech functionality
  - `database_service.dart`: SQLite database operations
  - `subscription_service.dart`: In-app purchase management
  - `audio_service.dart`: Audio recording and playback
  - `location_service.dart`: GPS and Google Maps integration
- **`lib/screens/`**: UI screens for different app features
- **`lib/widgets/`**: Reusable UI components
- **`lib/models/`**: Data models and structures

### Key Services Integration
- **OpenAI Integration**: Multiple model support for chat (`gpt-4.1`), mini tasks (`gpt-3.5-turbo`), and realtime voice (`gpt-4o-realtime`)
- **ElevenLabs TTS**: Text-to-speech with voice customization
- **Google Maps**: Location services and map display
- **In-App Purchases**: Subscription management with platform-specific handling
- **SQLite Database**: Local data persistence with integrity checking
- **Internationalization**: Multi-language support via `flutter_localizations`

### State Management
The app uses the Provider pattern for state management with the following key providers:
- `ConversationProvider`: Handles chat state, messages, and conversation history
- `SettingsProvider`: Manages user preferences, themes, and app settings
- `ProfileProvider`: User profile data and configuration
- `AIPersonalityProvider`: AI behavior and personality settings

### Database Architecture
- SQLite database with automatic integrity checking and repair on startup
- Conversation and message persistence
- User profile and settings storage
- Subscription and usage tracking

## Platform-Specific Configurations

### Android
- Build configurations in `android/` directory
- Release signing requires `android/key.properties` file
- Google Play subscription handling
- Location permissions for GPS features

### iOS
- iOS-specific configurations in `ios/` directory
- Apple App Store subscription integration
- Location and microphone permissions

## Testing and Quality Assurance
- Use `flutter test` for unit and widget tests
- Test files located in `test/` directory
- Subscription testing guides available in documentation files
- Platform-specific testing checklists in `ANDROID_*` and `IOS_*` files

## Documentation
The project includes extensive documentation:
- `GOOGLE_PLAY_SUBSCRIPTION_SETUP.md`: Subscription configuration
- `ANDROID_SETUP_CHECKLIST.md`: Android deployment guide
- `GOOGLE_MAPS_SETUP.md`: Maps integration setup
- `ELEVENLABS_SETUP.md`: Text-to-speech configuration
- Various testing and platform-specific guides