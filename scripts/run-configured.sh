#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$PROJECT_ROOT/scripts/with-public-mobile-config.sh" flutter run "$@"
