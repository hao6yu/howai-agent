#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${HOWAI_ENV_FILE:-$PROJECT_ROOT/.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "HowAI build configuration not found: $ENV_FILE" >&2
  echo "Copy .env.example to .env and add the public client configuration." >&2
  exit 1
fi

if [[ "$#" -eq 0 ]]; then
  echo "Usage: scripts/with-public-mobile-config.sh <flutter command...>" >&2
  exit 1
fi

PUBLIC_ENV_FILE="$(mktemp "${TMPDIR:-/tmp}/howai-mobile-env.XXXXXX")"
trap 'rm -f "$PUBLIC_ENV_FILE"' EXIT

# Keep this allowlist limited to values that are safe to inspect in a compiled
# mobile app. Provider credentials remain in Supabase Edge Function secrets.
awk -F= '
  /^(SUPABASE_URL|SUPABASE_ANON_KEY|OPENAI_PROXY_BASE_URL|OPENAI_CHAT_MODEL|OPENAI_CHAT_MINI_MODEL|ELEVENLABS_PROXY_BASE_URL|ELEVENLABS_AGENT_ID|ELEVENLABS_AGENT_ID_MALE|ELEVENLABS_AGENT_ID_FEMALE|GOOGLE_API_KEY|GOOGLE_CSE_ID|GOOGLE_MAPS_API_KEY|GOOGLE_PLACES_API_KEY)=/ {
    print
  }
' "$ENV_FILE" > "$PUBLIC_ENV_FILE"

if grep -Eq '^(OPENAI_API_KEY|ELEVENLABS_API_KEY|XI_API_KEY)=.+' "$ENV_FILE"; then
  echo "Ignoring provider API keys in $ENV_FILE; mobile builds use Supabase proxies." >&2
fi

cd "$PROJECT_ROOT"
"$@" --dart-define-from-file="$PUBLIC_ENV_FILE"
