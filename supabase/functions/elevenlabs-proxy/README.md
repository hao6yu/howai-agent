# ElevenLabs Proxy

Supabase Edge Function that keeps `ELEVENLABS_API_KEY` off mobile devices.

Supported endpoints:

- `GET /v1/voices`
- `GET /v1/convai/conversation/get-signed-url?agent_id=...`
- `POST /v1/text-to-speech/:voice_id`
- `POST /v1/text-to-speech/:voice_id/with-timestamps`

Required request headers from the app:

```text
Authorization: Bearer <supabase-access-token>
apikey: <supabase-anon-key>
```

Deploy:

```bash
supabase db push
supabase secrets set \
  ELEVENLABS_API_KEY=... \
  ELEVENLABS_PROXY_ALLOWED_AGENT_IDS=agent_... \
  ELEVENLABS_PROXY_ALLOWED_VOICE_IDS=9BWtsMINqrJLrRacOk9x,N2lVS1w4EtoT3dr4eOWO \
  ELEVENLABS_PROXY_MAX_REQUESTS_PER_HOUR=120 \
  ELEVENLABS_PROXY_PAID_MAX_REQUESTS_PER_DAY=1000 \
  ELEVENLABS_PROXY_FREE_MAX_REQUESTS_PER_HOUR=30 \
  ELEVENLABS_PROXY_FREE_MAX_REQUESTS_PER_DAY=60 \
  ELEVENLABS_PROXY_ANON_MAX_REQUESTS_PER_HOUR=10 \
  ELEVENLABS_PROXY_ANON_MAX_REQUESTS_PER_DAY=20
supabase functions deploy elevenlabs-proxy
```

`ELEVENLABS_PROXY_ALLOWED_AGENT_IDS` and `ELEVENLABS_PROXY_ALLOWED_VOICE_IDS`
are required allowlists. If either is missing, that request type fails closed.

The function derives the free/paid cohort from the server-owned
`app_entitlements` table and atomically reserves each request through
`reserve_elevenlabs_proxy_request`. The reservation function is executable only
by `service_role`, so mobile clients cannot choose their own quota or race a
count-before-insert check.

Use this as `ELEVENLABS_PROXY_BASE_URL` in the app build config:

```text
https://<project-ref>.supabase.co/functions/v1/elevenlabs-proxy
```
