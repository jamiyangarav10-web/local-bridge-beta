$ErrorActionPreference = "Stop"
$BackendUrl = if ($env:LOCALBRIDGE_BACKEND_BASE_URL) { $env:LOCALBRIDGE_BACKEND_BASE_URL } else { "http://127.0.0.1:8888" }
Set-Content -Path "localbridge_backend_url.txt" -Value $BackendUrl -NoNewline
python -m pip install --upgrade pip pyinstaller
python -m pip install -r requirements.txt
python -m PyInstaller --noconfirm --clean --onefile --windowed --name LocalBridge-Windows `
  --add-data "windows;windows" `
  --add-data "packages;packages" `
  --add-data "localbridge_backend_url.txt;." `
  clients/windows/localbridge_agent.py
Write-Host "Built dist/LocalBridge-Windows.exe with backend $BackendUrl"
