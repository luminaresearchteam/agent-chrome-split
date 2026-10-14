# AGENTS.md — install agent-chrome-split for your user

You are an AI agent. Follow these steps to give **yourself** a dedicated Chrome on your user's computer. Explain each step to your user in plain words; ask before anything you are unsure about.

## 0. Ground rules

- Use **only your own port**. Never connect to, close, or modify any other Chrome (especially the user's everyday browser).
- Never bind the debug port to `0.0.0.0` or expose it publicly. Never copy or upload the profile folder or cookies.
- Work in **background tabs**; do not steal focus from the user.
- **Stop before irreversible or externally visible actions** (sending, posting, purchasing, deleting, submitting forms) and get the human's explicit approval.

## 1. Detect the OS

```bash
uname -s   # Darwin = macOS, Linux = Linux
```

Windows is not covered by the scripts; adapt the flags manually if needed.

## 2. Choose a free port

Start at 9333 and go up until nothing answers:

```bash
for p in $(seq 9333 9399); do curl -s -m 1 http://127.0.0.1:$p/json/version >/dev/null || { echo $p; break; }; done
```

Also make sure nothing else listens there (`lsof -iTCP:$p -sTCP:LISTEN` on macOS/Linux).

## 3. Pick a name, color, profile and download folder

- NAME: short, e.g. your agent name (`agent-a`).
- COLOR: a distinct color, e.g. `#10b981`.
- PROFILE_DIR: `~/AgentChrome-<NAME>` (new, empty folder; never reuse the user's profile).
- DOWNLOAD_DIR: `~/Downloads/<NAME>`.

## 4. Launch

```bash
NAME=agent-a PORT=9333 COLOR="#10b981" \
PROFILE_DIR="$HOME/AgentChrome-agent-a" DOWNLOAD_DIR="$HOME/Downloads/agent-a" \
scripts/launch-agent-chrome.sh
```

The script skips if the port already answers, writes download prefs (`prompt_for_download: false`) only while that profile is not running, launches with `--user-data-dir`, `--remote-debugging-port`, `--no-first-run`, and opens a colored label tab.

On macOS, offer a double-clickable launcher:

```bash
scripts/make-launcher.sh agent-a 9333 "#10b981"
```

## 5. Verify

```bash
curl -s http://127.0.0.1:9333/json/version
```

You should see `Browser` and `webSocketDebuggerUrl`. Confirm the label tab is visible to the user.

## 6. Let the user log in

Ask the user to log in by hand, in this Chrome, to the sites you need. Do not ask for passwords.

## 7. Connect via CDP

- Read `webSocketDebuggerUrl` from `/json/version` and connect.
- Newer Chrome rejects WebSocket connections that send an `Origin` header. Either connect without an Origin (Python `websocket-client`: `create_connection(url, suppress_origin=True)`), or launch Chrome with `--remote-allow-origins=http://127.0.0.1:<PORT>` (avoid `*`).
- Open work tabs with `Target.createTarget` and `"background": true`; attach with `Target.attachToTarget` (`flatten: true`).
- Before acting on any site, verify you are logged in as the expected account.
- Downloads for a running instance: `python3 scripts/set-download-dir.py <PORT> <DIR>`.

## 8. Hand-off

When the task reaches a consequential step, stop, leave the result visible in your window (you may bring that tab to the front), and ask the human to review and approve.

## Cloud agents

If you run in the cloud, do not ask the user to expose the port. Ask them to set up a private network + SSH and use `ssh -N -L <PORT>:127.0.0.1:<PORT> <user>@<private-host>`; see `docs/ssh-tunnel.md`.
