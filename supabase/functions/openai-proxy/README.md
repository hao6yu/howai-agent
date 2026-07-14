# openai-proxy (Supabase Edge Function)

Secure proxy for OpenAI APIs used by mobile app:
- `POST /v1/responses`
- `POST /v1/audio/transcriptions`

This prevents exposing `OPENAI_API_KEY` in the client app and requires a
Supabase Auth user session before forwarding requests.

## Required secret

`OPENAI_API_KEY` must remain in Supabase project secrets. Reuse the existing
managed secret; never copy it into Flutter or any other client-side environment,
the repository, logs, or local documentation.

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are
available automatically in hosted Supabase Edge Functions.

Optional tuning secrets:

```bash
supabase secrets set \
  OPENAI_PROXY_MAX_REQUESTS_PER_HOUR=120 \
  OPENAI_PROXY_ANON_MAX_REQUESTS_PER_DAY=300 \
  OPENAI_PROXY_MAX_OUTPUT_TOKENS=3000 \
  OPENAI_PROXY_CHAT_MODEL=gpt-5.2 \
  OPENAI_PROXY_CHAT_MINI_MODEL=gpt-5-nano \
  OPENAI_PROXY_MODEL_NANO=gpt-5-nano \
  OPENAI_PROXY_MODEL_LUNA=gpt-5.6-luna \
  OPENAI_PROXY_MODEL_SOL=gpt-5.6-sol
```

`OPENAI_PROXY_ALLOWED_MODELS` is optional. Use it only if the app needs to send
additional real model names besides the two aliases.

## GPT-5.6 policy rollout

The HowAI 2.0 model policy is fail-safe and double-gated. It activates only
when both of these are true:

1. `OPENAI_PROXY_POLICY_ENABLED=true` is present in Supabase secrets.
2. The `model_policy_v2` row in `public.feature_flags` is enabled.

Keep both gates off until migrations are deployed, verified paid entitlements
are backfilled into `app_entitlements`, streaming telemetry is visible, and the
canary cohort is approved. The legacy client-written `subscription_status`
table is not authoritative for Sol access.

Optional policy limits:

```text
OPENAI_PROXY_FREE_LUNA_ANSWERS_PER_DAY=3
OPENAI_PROXY_FREE_LUNA_DAILY_BUDGET_MICROUSD=30000
OPENAI_PROXY_FREE_LUNA_MONTHLY_BUDGET_MICROUSD=300000
OPENAI_PROXY_ANON_ANSWER_LIMIT=5
OPENAI_PROXY_POLICY_WEB_SEARCH_ENABLED=false
OPENAI_PROXY_POLICY_IMAGE_GENERATION_ENABLED=false
```

Web search and image generation remain separately disabled in the policy path
until their own ledgers and quotas are ready. Allowed function tools continue
to pass through the existing allowlist.

## Deploy

```bash
supabase db push
supabase functions deploy openai-proxy
```

Apply and verify database migrations before deploying the function. Enabling a
feature flag is a separate release action after both deployments succeed.

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
