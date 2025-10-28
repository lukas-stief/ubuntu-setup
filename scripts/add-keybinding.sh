#!/usr/bin/env bash
# add_keybinding.sh
# Usage: ./add_keybinding.sh "Launch Chrome" "google-chrome" "<Super>c"
# Notes:
#  - Works on Ubuntu with GNOME (22.04, 24.04+).
#  - Idempotent: if a binding with the same accelerator exists, it updates the name/command.

set -euo pipefail

NAME="${1:-}"
CMD="${2:-}"
ACCEL="${3:-}"

if [[ -z "$NAME" || -z "$CMD" || -z "$ACCEL" ]]; then
  echo "Usage: $0 \"Name\" \"command\" \"<Super>c\""
  exit 1
fi

SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
BIND_KW="custom-keybinding"
BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# Read current list (e.g., "['/.../custom0/', '/.../custom1/']")
current_list="$(gsettings get "$SCHEMA" custom-keybindings)"

# Helper to read a key in a custom path
read_key () {
  local path="$1" key="$2"
  gsettings get "$SCHEMA.$BIND_KW:$BASE_PATH/$path/" "$key" 2>/dev/null || true
}

# Normalize list into lines like: custom0 custom1 ...
mapfile -t paths < <(python3 - <<'PY'
import ast,sys
lst=sys.stdin.read().strip()
try:
    arr=ast.literal_eval(lst)
except Exception:
    arr=[]
for p in arr:
    # p looks like '/org/.../customN/'
    if isinstance(p,str) and p.rstrip('/').endswith('custom'):
        # unlikely, but ignore malformed
        continue
    if isinstance(p,str):
        # extract 'customN'
        seg=p.strip('/').split('/')[-1]
        print(seg)
PY
<<<"$current_list")

# 1) If any existing entry already uses this accelerator, update it (idempotent).
for seg in "${paths[@]:-}"; do
  existing="$(read_key "$seg" binding)"
  if [[ "$existing" == "'$ACCEL'" ]]; then
    # update name + command (no list change)
    gsettings set "$SCHEMA.$BIND_KW:$BASE_PATH/$seg/" name "$NAME"
    gsettings set "$SCHEMA.$BIND_KW:$BASE_PATH/$seg/" command "$CMD"
    echo "Updated existing binding $seg -> $ACCEL ($NAME: $CMD)"
    exit 0
  fi
done

# 2) Otherwise, create a new slot (find first free customN)
i=0
while :; do
  candidate="custom${i}"
  if ! printf '%s\0' "${paths[@]:-}" | grep -qxz -- "$candidate"; then
    new_seg="$candidate"
    break
  fi
  ((i++))
done

# Write the binding data
gsettings set "$SCHEMA.$BIND_KW:$BASE_PATH/$new_seg/" name "$NAME"
gsettings set "$SCHEMA.$BIND_KW:$BASE_PATH/$new_seg/" command "$CMD"
gsettings set "$SCHEMA.$BIND_KW:$BASE_PATH/$new_seg/" binding "$ACCEL"

# Append path to the list
python3 - "$SCHEMA" "$BASE_PATH" "$current_list" "$new_seg" <<'PY'
import ast, sys, subprocess, json
schema, base, cur, seg = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
try:
    arr = ast.literal_eval(cur)
except Exception:
    arr = []
full = f"{base}/{seg}/"
if full not in arr:
    arr.append(full)
value = "[" + ", ".join(repr(x) for x in arr) + "]"
subprocess.check_call(["gsettings","set",schema,"custom-keybindings", value])
PY

echo "Added new keybinding: $ACCEL → $NAME ($CMD)"
