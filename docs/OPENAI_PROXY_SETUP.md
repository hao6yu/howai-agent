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
   - `Authorization: Bearer <supabase-access-token>`
   - `apikey: <supabase-anon-key>`
3. Edge Function verifies the Supabase user, applies request limits, logs usage, then forwards request to OpenAI with the server-side key.
4. Response returns back to app.

## One-time prerequisites

- Supabase CLI installed and logged in.
- Access to your Supabase project.
- Anonymous sign-ins enabled in Supabase Dashboard:
  - Authentication → Sign In / Providers → Anonymous Sign-Ins.

## 1) Set Supabase function secrets

Run in your repo root:

```bash
supabase secrets set OPENAI_API_KEY=sk-...
```

Notes:
- `OPENAI_API_KEY` is your real OpenAI key (server only).
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are available automatically to hosted Supabase Edge Functions.
- Optional tuning secrets: `OPENAI_PROXY_CHAT_MODEL`, `OPENAI_PROXY_CHAT_MINI_MODEL`, `OPENAI_PROXY_MAX_REQUESTS_PER_HOUR`, `OPENAI_PROXY_ANON_MAX_REQUESTS_PER_DAY`, `OPENAI_PROXY_MAX_OUTPUT_TOKENS`, and `OPENAI_PROXY_ALLOWED_MODELS`.

The proxy always allows the two server-configured alias targets. Set
`OPENAI_PROXY_ALLOWED_MODELS` only when you intentionally want to allow extra
real model names from the client.

## 2) Apply database migration and deploy edge function

```bash
supabase db push
supabase functions deploy openai-proxy
```

After deploy, your function base URL is:

```text
https://<project-ref>.supabase.co/functions/v1/openai-proxy
```

## 3) Configure app build values

Set these in your local `.env`. Build and run through
`scripts/with-public-mobile-config.sh` or `scripts/run-configured.sh`, which
exclude provider credentials from the compiled app:

```env
OPENAI_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/openai-proxy
OPENAI_CHAT_MODEL=howai-chat
OPENAI_CHAT_MINI_MODEL=howai-chat-mini
```

`.env` is not bundled as a Flutter asset. Do not pass `OPENAI_API_KEY` or other
server secrets into production mobile builds; keep them in Supabase secrets.

`howai-chat` and `howai-chat-mini` are model aliases resolved by the proxy. To
change models later without rebuilding the app:

```bash
supabase secrets set \
  OPENAI_PROXY_CHAT_MODEL=gpt-5.2 \
  OPENAI_PROXY_CHAT_MINI_MODEL=gpt-5-nano
supabase functions deploy openai-proxy
```

## 4) Validate with curl

```bash
curl -i \
  -X POST "https://<project-ref>.supabase.co/functions/v1/openai-proxy/v1/responses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <supabase-access-token>" \
  -H "apikey: <supabase-anon-key>" \
  -d '{"model":"gpt-5-nano","input":[{"role":"user","content":"Say hi"}]}'
```

Expected:
- `HTTP/1.1 200 OK` with OpenAI-style response JSON.

## 5) App-level verification

- Start app.
- Send a normal chat message.
- Confirm responses work as before.

## Troubleshooting

### 401 Authentication required
- User is not signed in, or the app did not send a valid Supabase access token.

### 500 OPENAI_API_KEY is not configured on proxy
- `OPENAI_API_KEY` secret was not set or was set in wrong project.

### 500 Supabase proxy auth/logging secrets are not configured
- The function is not running in the expected Supabase project environment, or service role secrets are unavailable.

### 404 Unsupported endpoint
- Use exact paths:
  - `/v1/responses`
  - `/v1/audio/transcriptions`

### 413 Payload too large
- Request body exceeded proxy limit.

### 429 Hourly request limit exceeded
- User exceeded `OPENAI_PROXY_MAX_REQUESTS_PER_HOUR`, or an anonymous/local-mode user exceeded `OPENAI_PROXY_ANON_MAX_REQUESTS_PER_DAY`.

## Production recommendation

- In production mobile builds, do not include direct `OPENAI_API_KEY`.
- Use proxy mode only (`OPENAI_PROXY_BASE_URL`) with authenticated Supabase users.
- "Continue without account" uses a Supabase anonymous session. This is still local-only in the app: cloud sync stays disabled until the user signs in with email, Google, or Apple.
