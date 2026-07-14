# openai-proxy (Supabase Edge Function)

Secure proxy for OpenAI APIs used by mobile app:
- `POST /v1/responses`
- `POST /v1/audio/transcriptions`

This prevents exposing `OPENAI_API_KEY` in the client app and requires a
Supabase Auth user session before forwarding requests.

## Required secrets

Set in Supabase project secrets:

```bash
supabase secrets set OPENAI_API_KEY=sk-...
```

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are
available automatically in hosted Supabase Edge Functions.

Optional tuning secrets:

```bash
supabase secrets set \
  OPENAI_PROXY_MAX_REQUESTS_PER_HOUR=120 \
  OPENAI_PROXY_ANON_MAX_REQUESTS_PER_DAY=300 \
  OPENAI_PROXY_MAX_OUTPUT_TOKENS=3000 \
  OPENAI_PROXY_CHAT_MODEL=gpt-5.2 \
  OPENAI_PROXY_CHAT_MINI_MODEL=gpt-5-nano
```

`OPENAI_PROXY_ALLOWED_MODELS` is optional. Use it only if the app needs to send
additional real model names besides the two aliases.

## Deploy

```bash
supabase db push
supabase functions deploy openai-proxy
```

## Base URL for mobile app

Use this as `OPENAI_PROXY_BASE_URL` in app `.env`:

```text
https://<project-ref>.supabase.co/functions/v1/openai-proxy
```

The mobile app sends the current Supabase session access token as:

```text
Authorization: Bearer <supabase-access-token>
```

The app can send `howai-chat` or `howai-chat-mini` as model aliases. The proxy
resolves those aliases from `OPENAI_PROXY_CHAT_MODEL` and
`OPENAI_PROXY_CHAT_MINI_MODEL`, so model changes do not require an app rebuild.

## Local test

```bash
curl -i \
  -X POST "https://<project-ref>.supabase.co/functions/v1/openai-proxy/v1/responses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <supabase-access-token>" \
  -H "apikey: <supabase-anon-key>" \
  -d '{"model":"howai-chat-mini","input":[{"role":"user","content":"Say hi"}]}'
```
