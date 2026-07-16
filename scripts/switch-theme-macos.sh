#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

THEME_ID=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --id) THEME_ID="${2:-}"; shift 2 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

case "$THEME_ID" in ''|*[!a-z0-9-]*) fail "Usage: switch-theme-macos.sh --id <theme-id>" ;; esac
ensure_state_root
PACK="$STATE_ROOT/themes/$THEME_ID"
[ -f "$PACK/theme.json" ] || fail "Theme not found: $THEME_ID"

/bin/mkdir -p "$THEME_DIR"
/usr/bin/find "$THEME_DIR" -maxdepth 1 -type f -delete
/bin/cp -f "$PACK/"* "$THEME_DIR/"
/bin/chmod 600 "$THEME_DIR/"*

exec "$SCRIPT_DIR/apply-theme-macos.sh" --port 9341 --prompt-restart
