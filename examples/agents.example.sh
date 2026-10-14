#!/usr/bin/env bash
# Example: three agents, three Chromes, three ports, three colors.
cd "$(dirname "$0")/../scripts" || exit 1
NAME=agent-a PORT=9333 COLOR="#10b981" ./launch-agent-chrome.sh   # green
NAME=agent-b PORT=9334 COLOR="#3b82f6" ./launch-agent-chrome.sh   # blue
NAME=agent-c PORT=9335 COLOR="#8b5cf6" ./launch-agent-chrome.sh   # purple
