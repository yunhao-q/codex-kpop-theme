#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

IMAGE=""
CONFIG=""
THEME_ID=""
APPLY="false"
SHORTCUT="false"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --image) IMAGE="${2:-}"; shift 2 ;;
    --config) CONFIG="${2:-}"; shift 2 ;;
    --id) THEME_ID="${2:-}"; shift 2 ;;
    --apply) APPLY="true"; shift ;;
    --shortcut) SHORTCUT="true"; shift ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

[ -f "$IMAGE" ] || fail "Image not found: $IMAGE"
[ -f "$CONFIG" ] || fail "Config not found: $CONFIG"
case "$THEME_ID" in ''|*[!a-z0-9-]*) fail "Theme id must use lowercase letters, digits and hyphens" ;; esac

discover_codex_app
require_macos_runtime
ensure_state_root
THEMES_ROOT="$STATE_ROOT/themes"
PACK="$THEMES_ROOT/$THEME_ID"
PREPARED="$STATE_ROOT/.${THEME_ID}.$$.jpg"
trap '/bin/rm -f "$PREPARED"' EXIT
/usr/bin/sips -s format jpeg -s formatOptions 84 -Z 3200 "$IMAGE" --out "$PREPARED" >/dev/null
[ -s "$PREPARED" ] || fail "Image preparation failed"

/bin/mkdir -p "$PACK"
"$NODE" "$SCRIPT_DIR/build-theme.mjs" --config "$CONFIG" --image "$PREPARED" --output "$PACK" >/dev/null

if [ "$SHORTCUT" = "true" ]; then
  launcher="$HOME/Desktop/K-pop Theme - ${THEME_ID}.command"
  if [ -e "$launcher" ] && ! /usr/bin/grep -q '^# KpopCodexTheme launcher$' "$launcher"; then
    fail "Refusing to overwrite unrelated Desktop file: $launcher"
  fi
  /usr/bin/printf '%s\n' '#!/bin/bash' '# KpopCodexTheme launcher' 'set -e' \
    "exec \"$SCRIPT_DIR/switch-theme-macos.sh\" --id \"$THEME_ID\"" > "$launcher"
  /bin/chmod 700 "$launcher"
fi

if [ "$APPLY" = "true" ]; then
  /bin/mkdir -p "$THEME_DIR"
  /usr/bin/find "$THEME_DIR" -maxdepth 1 -type f -delete
  /bin/cp -f "$PACK/"* "$THEME_DIR/"
  /bin/chmod 600 "$THEME_DIR/"*
  "$SCRIPT_DIR/apply-theme-macos.sh" --port 9341 --prompt-restart
fi

printf 'Installed K-pop theme %s at %s\n' "$THEME_ID" "$PACK"
