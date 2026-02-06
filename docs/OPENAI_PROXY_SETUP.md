# OpenAI Proxy Setup (Supabase Edge Function)

This guide explains how to run OpenAI requests through your Supabase Edge Function instead of calling OpenAI directly from the mobile app.

## Why this exists

- Keeps the real `OPENAI_API_KEY` on the server side.
- Prevents shipping OpenAI keys inside the mobile app.
- Gives you a central place to add limits, logging, and policy checks.

## Architecture

1. App sends request to:
   - `https://<project-ref>.supabase.co/functions/v1/openai-proxy/v1/responses`
   - `https://<project-ref>.supabase.co/functions/v1/openai-proxy/v1/audio/transcriptions`
2. App includes:
   - `X-HowAI-Proxy-Token` (shared token)
   - `X-HowAI-Timestamp` (request time)
3. Edge Function verifies token/time, then forwards request to OpenAI with server-side key.
4. Response returns back to app.

## One-time prerequisites

- Supabase CLI installed and logged in.
- Access to your Supabase project.

## 1) Set Supabase function secrets

Run in your repo root:

```bash
supabase secrets set OPENAI_API_KEY=sk-... PROXY_SHARED_TOKEN=your-long-random-token
```

Notes:
- `OPENAI_API_KEY` is your real OpenAI key (server only).
- `PROXY_SHARED_TOKEN` is a random app-to-proxy token. Use a long random string (32+ chars).

## 2) Deploy edge function

```bash
supabase functions deploy openai-proxy
```

After deploy, your function base URL is:

```text
https://<project-ref>.supabase.co/functions/v1/openai-proxy
```

## 3) Configure app `.env`

Set these in your local app `.env`:

```env
OPENAI_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/openai-proxy
OPENAI_PROXY_TOKEN=your-long-random-token
```

## 4) Validate with curl

```bash
curl -i \
  -X POST "https://<project-ref>.supabase.co/functions/v1/openai-proxy/v1/responses" \
  -H "Content-Type: application/json" \
  -H "X-HowAI-Proxy-Token: your-long-random-token" \
  -H "X-HowAI-Timestamp: $(date +%s)" \
  -d '{"model":"gpt-5-nano","input":[{"role":"user","content":"Say hi"}]}'
```

Expected:
- `HTTP/1.1 200 OK` with OpenAI-style response JSON.

## 5) App-level verification

- Start app.
- Send a normal chat message.
- Confirm responses work as before.

## Troubleshooting

### 401 Invalid proxy token
- `OPENAI_PROXY_TOKEN` in app does not match `PROXY_SHARED_TOKEN` in Supabase secrets.

### 401 Invalid or missing timestamp
- Ensure app/proxy request includes `X-HowAI-Timestamp`.
- Ensure your local clock is roughly correct.

### 500 OPENAI_API_KEY is not configured on proxy
- `OPENAI_API_KEY` secret was not set or was set in wrong project.

### 404 Unsupported endpoint
- Use exact paths:
  - `/v1/responses`
  - `/v1/audio/transcriptions`

### 413 Payload too large
- Request body exceeded proxy limit.

## Production recommendation

- In production mobile builds, do not include direct `OPENAI_API_KEY`.
- Use proxy mode only (`OPENAI_PROXY_BASE_URL` + `OPENAI_PROXY_TOKEN`).

