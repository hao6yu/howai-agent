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
  OPENAI_PROXY_MODEL_SOL=gpt-5.6-sol \
  OPENAI_PROXY_RESEARCH_MODEL=gpt-5.2 \
  OPENAI_PROXY_GLOBAL_DAILY_BUDGET_MICROUSD=10000000 \
  OPENAI_PROXY_GLOBAL_MONTHLY_BUDGET_MICROUSD=150000000 \
  OPENAI_PROXY_EVAL_VERSION=gpt56-m1-v1
```

`OPENAI_PROXY_ALLOWED_MODELS` is optional. Use it only if the app needs to send
additional real model names besides the two aliases.

## GPT-5.6 policy rollout

The HowAI 2.0 model policy is fail-safe and triple-gated. It activates for a
request only when all of these are true:

1. `OPENAI_PROXY_POLICY_ENABLED=true` is present in Supabase secrets.
2. The `model_policy_v2` row in `public.feature_flags` is enabled.
3. The request's user is selected by the flag payload's rollout mode.

The supported payload is:

```json
{
  "mode": "off",
  "rollout_percent": 0,
  "rollout_salt": "gpt56-m1-v1"
}
```

- `off` routes everyone through the legacy model path.
- `internal` routes only users marked by the private
  `app_entitlements.model_policy_canary` column.
- `percentage` uses a deterministic 0–9,999 user bucket and the integer
  percentage in `rollout_percent`.

The payload never contains user IDs. Keep `rollout_salt` stable throughout a
percentage canary so users do not move between cohorts. For instant rollback,
disable the feature flag or set `mode` to `off`; `percentage` with `0` is also
an inert route.

Keep both gates off until migrations are deployed, verified paid entitlements
are backfilled into `app_entitlements`, streaming telemetry is visible, and the
canary cohort is approved. The legacy client-written `subscription_status`
table is not authoritative for Sol access. When the environment gate is on, a
feature-flag lookup failure returns a temporary error instead of bypassing the
policy.

Every Responses request records the requested alias, resolved model, actual
upstream model, deterministic rollout cohort/bucket, reasoning effort, latency,
usage, cost, eval version, and bounded error category/code/parameter fields.
User prompts, responses, and upstream error messages are not written to proxy
telemetry.

Optional policy limits:

```text
OPENAI_PROXY_FREE_LUNA_ANSWERS_PER_DAY=3
OPENAI_PROXY_FREE_LUNA_DAILY_BUDGET_MICROUSD=30000
OPENAI_PROXY_FREE_LUNA_MONTHLY_BUDGET_MICROUSD=300000
OPENAI_PROXY_FREE_NANO_DAILY_BUDGET_MICROUSD=20000
OPENAI_PROXY_FREE_NANO_MONTHLY_BUDGET_MICROUSD=500000
OPENAI_PROXY_FREE_USER_DAILY_BUDGET_MICROUSD=50000
OPENAI_PROXY_FREE_USER_MONTHLY_BUDGET_MICROUSD=1000000
OPENAI_PROXY_FREE_MAX_ESTIMATED_INPUT_TOKENS=20000
OPENAI_PROXY_ANON_MAX_ESTIMATED_INPUT_TOKENS=8000
OPENAI_PROXY_PAID_SOL_DAILY_BUDGET_MICROUSD=2000000
OPENAI_PROXY_PAID_SOL_MONTHLY_BUDGET_MICROUSD=30000000
OPENAI_PROXY_PAID_USER_DAILY_BUDGET_MICROUSD=3000000
OPENAI_PROXY_PAID_USER_MONTHLY_BUDGET_MICROUSD=40000000
OPENAI_PROXY_RESEARCH_DAILY_BUDGET_MICROUSD=1000000
OPENAI_PROXY_RESEARCH_MONTHLY_BUDGET_MICROUSD=10000000
OPENAI_PROXY_RESEARCH_RESERVATION_MICROUSD=250000
OPENAI_PROXY_GLOBAL_DAILY_BUDGET_MICROUSD=10000000
OPENAI_PROXY_GLOBAL_MONTHLY_BUDGET_MICROUSD=150000000
OPENAI_PROXY_ANON_ANSWER_LIMIT=5
OPENAI_PROXY_POLICY_WEB_SEARCH_ENABLED=false
OPENAI_PROXY_POLICY_IMAGE_GENERATION_ENABLED=true
OPENAI_PROXY_FREE_IMAGE_GENERATION_ENABLED=true
OPENAI_PROXY_ANON_IMAGE_GENERATION_ENABLED=true
OPENAI_PROXY_FREE_IMAGE_GENERATIONS_PER_WEEK=10
OPENAI_PROXY_ANON_IMAGE_GENERATIONS_PER_WEEK=5
OPENAI_PROXY_TRIAL_IMAGE_RESERVATION_MICROUSD=10000
OPENAI_PROXY_TRIAL_IMAGE_GLOBAL_DAILY_BUDGET_MICROUSD=10000000
OPENAI_PROXY_TRIAL_IMAGE_GLOBAL_MONTHLY_BUDGET_MICROUSD=150000000
OPENAI_PROXY_FREE_WEB_SEARCH_ENABLED=false
OPENAI_PROXY_FREE_WEB_SEARCH_ANSWERS_PER_DAY=2
OPENAI_PROXY_FREE_WEB_SEARCH_ANSWERS_PER_MONTH=20
OPENAI_PROXY_FREE_WEB_SEARCH_RESERVATION_MICROUSD=40000
OPENAI_PROXY_FREE_WEB_SEARCH_GLOBAL_DAILY_BUDGET_MICROUSD=1000000
OPENAI_PROXY_FREE_WEB_SEARCH_GLOBAL_MONTHLY_BUDGET_MICROUSD=10000000
```

Paid web search and image generation remain controlled by their existing
separate environment gates. Anonymous and signed-in Free image generation is
also gated and server-quantized to one low-quality 1024x1024 result per request:
five per rolling week for anonymous users and ten per rolling week for Free
users. Trial image spend is reconciled in its dedicated ledger and excluded
from the general text-chat ledger so one image cannot lock an anonymous user
out of ordinary chat. Limited Free automatic search is triple-gated: the
model policy must select an eligible signed-in Free Luna request,
`OPENAI_PROXY_FREE_WEB_SEARCH_ENABLED` must be `true`, and the disabled-by-default
`free_web_search` database flag must be in `internal` or `on` mode. The proxy
reserves the 2-per-day/20-per-30-days allowance and conservative four-cent cost
headroom before the OpenAI call, releases it when the model does not search,
clamps Free responses to one built-in tool call, and reconciles the complete
searched-response estimate. Provider spend is retained without consuming a
user's allowance when a searched response fails or lacks citations.

Allowed function tools continue to pass through the existing allowlist. The
policy fixes ordinary chat reasoning to `low`, the standard service tier, and
the plan-specific output cap. Client-supplied Pro mode, background execution,
priority processing, and explicit prompt-cache controls are ignored. Verified
paid synchronous Deep Research stays on the legacy hosted chat model with
`high` reasoning until the persistent Research workstream replaces it.

Anonymous and signed-in Free users can analyze photo attachments within the
app's existing 15-per-week allowance. The proxy routes those requests through
Nano and still enforces the cohort's input-token, answer, and daily/monthly
spend ceilings.

## Deploy

```bash
supabase db push
supabase functions deploy openai-proxy
```

Apply and verify database migrations before deploying the function. Enabling a
feature flag is a separate release action after both deployments succeed.

For Free web search, deploy in this order:

1. Apply `free_web_search_quota` and run the database security/advisor checks.
2. Deploy `openai-proxy` while both Free-search gates remain off.
3. Set the environment gate, then use database mode `internal` for physical
   testing. Move directly to `on` only after the internal cost/citation checks
   pass.

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

## GPT-5.6 evaluation

The versioned synthetic fixture set lives in
`supabase/functions/evals/gpt56-m1-v1/fixtures.json`. Run the automated subset
through this proxy with:

```bash
OPENAI_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/openai-proxy \
HOWAI_EVAL_ACCESS_TOKEN=<internal-user-access-token> \
SUPABASE_ANON_KEY=<publishable-key> \
node scripts/run-gpt56-evals.mjs --label baseline
```

The runner never needs or reads `OPENAI_API_KEY`; OpenAI access stays inside
the Supabase-managed proxy. See `docs/GPT56_M1_CANARY_RUNBOOK.md` for the
baseline, internal-canary, percentage-rollout, and rollback sequence.
