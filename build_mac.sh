#!/bin/bash
set -e
BACKEND_URL="${LOCALBRIDGE_BACKEND_BASE_URL:-http://127.0.0.1:8888}"
printf "%s\n" "$BACKEND_URL" > localbridge_backend_url.txt
python3 -m pip install --upgrade pip pyinstaller
python3 -m pip install -r requirements.txt
python3 -m PyInstaller --noconfirm --clean --onedir --windowed --name LocalBridge-Mac \
  --add-data "mac:mac" \
  --add-data "packages:packages" \
  --add-data "localbridge_backend_url.txt:." \
  clients/mac/localbridge_agent.py
echo "Built dist/LocalBridge-Mac.app with backend $BACKEND_URL"
