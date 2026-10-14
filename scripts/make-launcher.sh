#!/usr/bin/env bash
# Create a double-clickable macOS launcher: ~/Desktop/Start_<NAME>_Chrome.command
# Usage: ./make-launcher.sh <NAME> <PORT> [COLOR] [PROFILE_DIR] [DOWNLOAD_DIR]
set -euo pipefail
NAME="${1:?NAME required}"; PORT="${2:?PORT required}"
COLOR="${3:-#10b981}"
PROFILE_DIR="${4:-$HOME/AgentChrome-$NAME}"
DOWNLOAD_DIR="${5:-$HOME/Downloads/$NAME}"
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HOME/Desktop/Start_${NAME}_Chrome.command"
cat > "$OUT" <<CMD
#!/usr/bin/env bash
"$HERE/launch-agent-chrome.sh" "$NAME" "$PORT" "$COLOR" "$PROFILE_DIR" "$DOWNLOAD_DIR"
CMD
chmod +x "$OUT"
echo "Created $OUT"
