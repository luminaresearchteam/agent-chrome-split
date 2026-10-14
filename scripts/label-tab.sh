#!/usr/bin/env bash
# Add a colored label tab to an already running agent Chrome via /json/new.
# Usage: ./label-tab.sh <NAME> <PORT> [COLOR]
set -euo pipefail
NAME="${1:?NAME}"; PORT="${2:?PORT}"; COLOR="${3:-#10b981}"
DIR="${TMPDIR:-/tmp}/agent-labels"; mkdir -p "$DIR"
F="$DIR/$NAME-$PORT.html"
cat > "$F" <<HTML
<!doctype html><meta charset="utf-8"><title>● $NAME · :$PORT</title>
<body style="margin:0;height:100vh;display:flex;align-items:center;justify-content:center;background:$COLOR;color:#fff;font:700 42px -apple-system,Segoe UI,sans-serif">● $NAME · port $PORT
HTML
# Newer Chrome requires PUT for /json/new
curl -s -m 5 -X PUT "http://127.0.0.1:$PORT/json/new?file://$F" >/dev/null && echo "Label tab opened on :$PORT"
