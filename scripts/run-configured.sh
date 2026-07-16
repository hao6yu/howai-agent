#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${HOWAI_ENV_FILE:-$PROJECT_ROOT/.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "HowAI build configuration not found: $ENV_FILE" >&2
  echo "Copy .env.example to .env and add the public client configuration." >&2
  exit 1
fi

cd "$PROJECT_ROOT"
exec flutter run --dart-define-from-file="$ENV_FILE" "$@"
