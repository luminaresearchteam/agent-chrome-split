#!/usr/bin/env bash
# Launch a dedicated Chrome instance for one AI agent (macOS + Linux).
# Usage: NAME=agent-a PORT=9333 COLOR=#10b981 ./launch-agent-chrome.sh
#    or: ./launch-agent-chrome.sh <NAME> <PORT> [COLOR] [PROFILE_DIR] [DOWNLOAD_DIR]
set -euo pipefail

NAME="${1:-${NAME:-agent}}"
PORT="${2:-${PORT:-9333}}"
COLOR="${3:-${COLOR:-#10b981}}"
PROFILE_DIR="${4:-${PROFILE_DIR:-$HOME/AgentChrome-$NAME}}"
DOWNLOAD_DIR="${5:-${DOWNLOAD_DIR:-$HOME/Downloads/$NAME}}"

case "$PORT" in ''|*[!0-9]*) echo "PORT must be a number" >&2; exit 1;; esac

if curl -s -m 2 "http://127.0.0.1:$PORT/json/version" >/dev/null 2>&1; then
  echo "Port $PORT already responds; $NAME Chrome seems to be running. Nothing to do."
  exit 0
fi

mkdir -p "$PROFILE_DIR/Default" "$DOWNLOAD_DIR"

# Write download prefs (only safe while this profile is not running).
PREFS="$PROFILE_DIR/Default/Preferences"
python3 - "$PREFS" "$DOWNLOAD_DIR" <<'PY'
import json, os, sys
path, ddir = sys.argv[1], sys.argv[2]
try:
    with open(path) as f: p = json.load(f)
except Exception:
    p = {}
d = p.setdefault("download", {})
d["default_directory"] = ddir
d["prompt_for_download"] = False
d["directory_upgrade"] = True
p.setdefault("savefile", {})["default_directory"] = ddir
with open(path, "w") as f: json.dump(p, f)
PY

# Generate a colored label page so humans can tell windows apart.
LABEL="$PROFILE_DIR/agent-label.html"
cat > "$LABEL" <<HTML
<!doctype html><meta charset="utf-8"><title>● $NAME · :$PORT</title>
<body style="margin:0;height:100vh;display:flex;align-items:center;justify-content:center;background:$COLOR;color:#fff;font:700 42px -apple-system,Segoe UI,sans-serif;text-align:center">
<div>● $NAME<br><span style="font-size:24px;font-weight:500">Dedicated agent Chrome · debug port $PORT · please keep this tab</span></div>
HTML

ARGS=(--user-data-dir="$PROFILE_DIR" --remote-debugging-port="$PORT" --no-first-run --no-default-browser-check "file://$LABEL")

case "$(uname -s)" in
  Darwin)
    open -na "Google Chrome" --args "${ARGS[@]}" ;;
  Linux)
    BIN="$(command -v google-chrome || command -v google-chrome-stable || command -v chromium || command -v chromium-browser || true)"
    [ -n "$BIN" ] || { echo "Chrome/Chromium not found" >&2; exit 1; }
    nohup "$BIN" "${ARGS[@]}" >/dev/null 2>&1 & ;;
  *) echo "Unsupported OS" >&2; exit 1 ;;
esac

for _ in $(seq 1 30); do
  if curl -s -m 2 "http://127.0.0.1:$PORT/json/version" >/dev/null 2>&1; then
    echo "$NAME Chrome is up on 127.0.0.1:$PORT (profile: $PROFILE_DIR, downloads: $DOWNLOAD_DIR)"
    exit 0
  fi
  sleep 1
done
echo "Chrome did not open port $PORT within 30s" >&2
exit 1
