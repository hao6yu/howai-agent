# HowAI

## Environment Variables

This app uses environment variables to configure various services including OpenAI API. Create a `.env` file in the root directory with the following variables:

```
# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here

# OpenAI Models
OPENAI_CHAT_MODEL=gpt-4.1
OPENAI_CHAT_MINI_MODEL=gpt-3.5-turbo-0125
OPENAI_REALTIME_MODEL=gpt-4o-realtime-preview-2024-12-17

# ElevenLabs API Key
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
```

### Description of variables:

- `OPENAI_API_KEY`: Your OpenAI API key
- `OPENAI_CHAT_MODEL`: Model used for generating stories and longer content (default: gpt-4.1)
- `OPENAI_CHAT_MINI_MODEL`: Model used for chat and shorter generation tasks (default: gpt-3.5-turbo-0125)
- `OPENAI_REALTIME_MODEL`: Model used for realtime voice conversations (default: gpt-4o-realtime-preview-2024-12-17)
- `ELEVENLABS_API_KEY`: Your ElevenLabs API key for text-to-speech

You can refer to the `env.example` file in the root directory for a template.

## Features

- Talk with AI: Child-friendly AI conversations

## Getting Started

1. Clone this repository
2. Create `.env` file with the configuration above
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app
