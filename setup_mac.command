#!/bin/bash
set -e
cd "$(dirname "$0")"
python3 -m pip install -r requirements.txt
mkdir -p "$HOME/Library/Application Support/LocalBridge"
DEFAULT_BACKEND="${LOCALBRIDGE_BACKEND_BASE_URL:-http://127.0.0.1:8888}"
printf "Backend URL [%s]: " "$DEFAULT_BACKEND"
read BACKEND_URL
BACKEND_URL="${BACKEND_URL:-$DEFAULT_BACKEND}"
printf "%s\n" "$BACKEND_URL" > "$HOME/Library/Application Support/LocalBridge/backend_url.txt"
echo "LocalBridge is ready."
echo "Backend: $BACKEND_URL"
echo "Open the LocalBridge website, then keep this agent window running while pairing."
python3 clients/mac/localbridge_agent.py
read -p "Press Enter to close..."
