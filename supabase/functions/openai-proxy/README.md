# openai-proxy (Supabase Edge Function)

Secure proxy for OpenAI APIs used by mobile app:
- `POST /v1/responses`
- `POST /v1/audio/transcriptions`

This prevents exposing `OPENAI_API_KEY` in the client app.

## Required secrets

Set in Supabase project secrets:

```bash
supabase secrets set OPENAI_API_KEY=sk-... PROXY_SHARED_TOKEN=your-shared-token
```

## Deploy

```bash
supabase functions deploy openai-proxy
```

## Base URL for mobile app

Use this as `OPENAI_PROXY_BASE_URL` in app `.env`:

```text
https://<project-ref>.supabase.co/functions/v1/openai-proxy
```

Set `OPENAI_PROXY_TOKEN` in app `.env` to the same `PROXY_SHARED_TOKEN` value.

When token auth is enabled, requests must also include `X-HowAI-Timestamp` (unix seconds, +/- 5 minutes).

## Local test

```bash
curl -i \
  -X POST "https://<project-ref>.supabase.co/functions/v1/openai-proxy/v1/responses" \
  -H "Content-Type: application/json" \
  -H "X-HowAI-Proxy-Token: your-shared-token" \
  -H "X-HowAI-Timestamp: $(date +%s)" \
  -d '{"model":"gpt-5-nano","input":[{"role":"user","content":"Say hi"}]}'
```
