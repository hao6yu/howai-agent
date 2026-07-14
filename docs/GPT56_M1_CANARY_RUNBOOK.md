# GPT-5.6 M1 evaluation and canary runbook

This runbook upgrades primary text chat by role without changing the Realtime
voice or persistent Research model paths. GPT-5.6 Sol is the paid primary-chat
candidate, Luna is the metered free smart-answer candidate, and nano remains
the background/lightweight and free fallback model.

The rollout is dormant until the environment gate, database flag, and user
cohort all select the request. No client build is required to start or stop the
canary.

## Active model inventory

| Workload | Client alias/intent | Legacy source | Candidate role |
|---|---|---|---|
| Primary chat | `howai-chat`, `primary_chat` | `OPENAI_PROXY_CHAT_MODEL` (fallback `gpt-5.2`) | Paid: `gpt-5.6-sol`; signed-in free: budgeted `gpt-5.6-luna` then nano |
| Quick/background chat | `howai-chat-mini`, `lightweight` | `OPENAI_PROXY_CHAT_MINI_MODEL` | `gpt-5-nano` |
| Title generation | `title` | Existing alias route | `gpt-5-nano` |
| Synchronous legacy research | `research` | Existing Responses route | `gpt-5-nano` during the M1 policy; persistent Research is a later workstream |
| Voice transcription | `/v1/audio/transcriptions` | `whisper-1` | Unchanged in M1 |
| Realtime voice | Separate ElevenLabs/current voice path | Separate integration | OpenAI Realtime workstream, not GPT-5.6 text routing |

The effective legacy model must be recorded from `response.model` and proxy
telemetry before comparison. Do not infer it from the source fallback if a
hosted secret overrides `OPENAI_PROXY_CHAT_MODEL`.

Production inventory on 2026-07-14 confirmed that the hosted primary route is
currently `gpt-5.2`, not GPT-5.5. The previous 30 days contained 155 logged
GPT-5.2 requests and 98 nano requests. Treat GPT-5.2 as the M1 baseline unless
a later configuration change is separately recorded.

## 1. Preflight

1. Confirm all migrations are applied and the database advisors are clean.
2. Confirm the hosted proxy has the existing Supabase-managed
   `OPENAI_API_KEY`. Never copy it locally.
3. Confirm `model_policy_v2.enabled = false`, its payload mode is `off`, and
   all other HowAI 2.0 flags remain disabled.
4. Capture the current alias-to-model result and at least one week of aggregate
   latency, error, token, and cost telemetry where available.
5. Run the synthetic suite against the legacy route and save the JSON as the
   immutable baseline artifact.

The evaluator requires an internal Supabase user access token and the project's
publishable/anon key, not an OpenAI API key:

```bash
OPENAI_PROXY_BASE_URL=https://<project-ref>.supabase.co/functions/v1/openai-proxy \
HOWAI_EVAL_ACCESS_TOKEN=<internal-user-access-token> \
SUPABASE_ANON_KEY=<publishable-key> \
node scripts/run-gpt56-evals.mjs --label legacy-baseline
```

Only synthetic fixtures are automated. Web search, PPTX continuation,
multi-turn state, and multimodal detail stay manual because they require
separate tool gates, app continuation handling, or local synthetic assets.

## 2. Deploy dormant controls

Apply the additive database migration, deploy the proxy, and leave all three
gates inert:

- `OPENAI_PROXY_POLICY_ENABLED` absent or `false`.
- `model_policy_v2.enabled = false`.
- payload `mode = off`, `rollout_percent = 0`.

Verify legacy chat, title generation, transcription, and OPTIONS health before
changing any gate.

## 3. Mark an internal account privately

Use the authenticated user's UUID. The marker is stored in the service-only
entitlement table and is never placed in the client-readable feature flag:

```sql
insert into public.app_entitlements (
  user_id,
  tier,
  source,
  verified_at,
  model_policy_canary
)
values ('<internal-user-uuid>', 'free', 'admin', now(), true)
on conflict (user_id) do update
set model_policy_canary = true,
    updated_at = now();
```

This statement does not downgrade or otherwise replace an existing paid
entitlement on conflict.

## 4. Internal canary

Set the environment gate to true, deploy the function with explicit candidate
model secrets, then enable only the private internal cohort:

```sql
update public.feature_flags
set enabled = true,
    payload = payload || jsonb_build_object(
      'mode', 'internal',
      'rollout_percent', 0,
      'rollout_salt', 'gpt56-m1-v1'
    ),
    updated_at = now()
where key = 'model_policy_v2';
```

Run `gpt56-m1-v1` with `--label candidate-internal`. Confirm that:

- the marked paid account resolves primary chat to explicit `gpt-5.6-sol`;
- the marked free account receives only the budgeted Luna allowance and then
  nano;
- title and lightweight intents remain nano;
- client attempts to select Sol, Pro mode, priority service, background mode,
  larger output, or explicit cache controls cannot override the proxy;
- tool schemas and continuations remain compatible;
- telemetry contains no prompt or response content.

## 5. Percentage rollout

After the internal gates pass, move through 5%, 25%, 50%, and 100%. Keep the
same rollout salt:

```sql
update public.feature_flags
set payload = payload || jsonb_build_object(
      'mode', 'percentage',
      'rollout_percent', 5
    ),
    updated_at = now()
where key = 'model_policy_v2';
```

Compare cohorts using aggregate telemetry only:

```sql
select
  rollout_cohort,
  model,
  count(*) as requests,
  round(avg(latency_ms)) as average_latency_ms,
  round(avg(time_to_first_token_ms)) as average_ttft_ms,
  sum(coalesce(input_tokens, 0)) as input_tokens,
  sum(coalesce(output_tokens, 0)) as output_tokens,
  sum(coalesce(actual_cost_microusd, 0)) as cost_microusd,
  count(*) filter (where error_category is not null) as errors
from public.openai_proxy_requests
where created_at >= now() - interval '24 hours'
group by rollout_cohort, model
order by rollout_cohort, model;
```

Hold or roll back when task success regresses, schema/tool continuations fail,
approval boundaries fail, cost exceeds the approved budget, or error/latency
crosses the release threshold.

## 6. Instant rollback

The strongest rollback is the master database flag:

```sql
update public.feature_flags
set enabled = false,
    payload = payload || jsonb_build_object(
      'mode', 'off',
      'rollout_percent', 0
    ),
    updated_at = now()
where key = 'model_policy_v2';
```

Then verify new requests record `rollout_cohort = legacy` and resolve to the
legacy alias target. The environment gate can remain deployed while the
database flag is off. For defense in depth after an incident, also set the
environment gate to false and redeploy.

## Exit gates

- Automated and manual fixtures pass against the candidate at no worse than
  the accepted baseline.
- Paid primary chat resolves to Sol; free Luna and nano fallback budgets are
  enforced atomically.
- Reminder/action proposals never execute without approval.
- PPTX, web, multimodal, multilingual, multi-turn, refusal, and privacy cases
  are accepted.
- Requested alias, resolved model, cohort, reasoning, latency, usage, cost,
  eval version, and error category are complete enough for comparison.
- Internal, percentage, zero-percent, flag-off, and environment-off paths have
  all been verified.
