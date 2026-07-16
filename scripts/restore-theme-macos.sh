#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

discover_codex_app
require_macos_runtime
ensure_state_root

PORT=9341
if [ -f "$STATE_PATH" ]; then
  saved_port="$(state_field port 2>/dev/null || true)"
  [ -n "$saved_port" ] && PORT="$saved_port"
fi

"$NODE" "$INJECTOR" --remove --port "$PORT" --timeout-ms 15000
stop_recorded_injector
/bin/rm -f "$STATE_PATH"
printf 'Removed K-pop Codex Theme from the live renderer. Saved theme packs were preserved.\n'
