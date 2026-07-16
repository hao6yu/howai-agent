# HowAI

Release runbooks:

- [M3 Actions beta](M3_ACTIONS_BETA_RUNBOOK.md)
- [M4 Notification beta](M4_NOTIFICATION_BETA_RUNBOOK.md)

## Environment Variables

This app uses build-time variables for public client configuration. Create a
local `.env` file in the root directory and pass it with
`--dart-define-from-file=.env`.

```
# OpenAI proxy
OPENAI_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/openai-proxy
OPENAI_CHAT_MODEL=howai-chat
OPENAI_CHAT_MINI_MODEL=howai-chat-mini

# ElevenLabs proxy
ELEVENLABS_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/elevenlabs-proxy
```

### Description of variables:

- `OPENAI_PROXY_BASE_URL`: Supabase Edge Function URL for OpenAI requests.
- `OPENAI_CHAT_MODEL`: Proxy model alias for premium chat.
- `OPENAI_CHAT_MINI_MODEL`: Proxy model alias for lighter chat.
- `ELEVENLABS_PROXY_BASE_URL`: Supabase Edge Function URL for ElevenLabs requests.

Do not put `OPENAI_API_KEY` or `ELEVENLABS_API_KEY` in production mobile
builds. Keep those values in Supabase secrets.

You can refer to the `env.example` file in the root directory for a template.

## Features

- Talk with AI: Child-friendly AI conversations

## Getting Started

1. Clone this repository
2. Create `.env` file with the configuration above
3. Run `flutter pub get` to install dependencies
4. Run `scripts/run-configured.sh` to start the app
