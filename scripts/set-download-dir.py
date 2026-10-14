#!/usr/bin/env python3
"""Set the download folder of a RUNNING agent Chrome via CDP Browser.setDownloadBehavior.
Usage: python3 set-download-dir.py <PORT> <DOWNLOAD_DIR>
Requires: pip install websocket-client"""
import json, os, sys, urllib.request
import websocket  # websocket-client

port, ddir = sys.argv[1], os.path.abspath(os.path.expanduser(sys.argv[2]))
os.makedirs(ddir, exist_ok=True)
ver = json.load(urllib.request.urlopen(f"http://127.0.0.1:{port}/json/version", timeout=5))
# suppress_origin avoids "403 Rejected an incoming WebSocket connection" on newer Chrome
ws = websocket.create_connection(ver["webSocketDebuggerUrl"], timeout=10, suppress_origin=True)
ws.send(json.dumps({"id": 1, "method": "Browser.setDownloadBehavior",
                    "params": {"behavior": "allow", "downloadPath": ddir, "eventsEnabled": False}}))
while True:
    r = json.loads(ws.recv())
    if r.get("id") == 1:
        break
ws.close()
if "error" in r:
    sys.exit(f"Failed: {r['error']}")
print(f"Downloads for :{port} now go to {ddir} (until this Chrome restarts)")
