# LocalBridge

LocalBridge syncs clipboard text between your Windows and macOS devices.

The beta product goal is simple:

```text
Install LocalBridge -> open the website -> connect two devices -> copy and paste.
```

LocalBridge uses a website for onboarding, downloads, device status, and short-lived pairing. The actual operating-system clipboard sync is handled by native Python agents. Browser JavaScript does not read or write clipboard contents across computers.

## Architecture

```text
localbridge/
  apps/
    web/                  React + TypeScript website and dashboard
  clients/
    windows/              Minimal Windows native UI launcher
    mac/                  Minimal macOS native UI launcher
  services/
    pairing/              Pairing service logic and tests
  packages/
    protocol/             JavaScript protocol validation
    crypto/               JavaScript token and secret helpers
    shared/               Python protocol, identity, config, and security helpers
  netlify/
    functions/            Netlify pairing API
  windows/                Preserved Windows clipboard WebSocket server
  mac/                    Preserved macOS clipboard WebSocket client
  build/                  PyInstaller build scripts
  docs/                   Architecture and pairing notes
```

## How pairing works

1. The native agent creates a stable local device identity on first launch.
2. Each device registers with the Netlify pairing API.
3. Device A creates a short-lived pairing session.
4. Device B joins the session.
5. Device A explicitly approves the request.
6. The API returns a fresh shared secret and endpoint metadata to the agents.
7. Clipboard text syncs between agents using the configured transport.

Pairing states:

```text
UNPAIRED -> PAIRING -> PAIR_APPROVAL_REQUIRED -> PAIRED -> CONNECTED -> DISCONNECTED -> RECONNECTING
```

## Security model

- Clipboard contents are never stored in Netlify.
- Clipboard contents are never shown in the dashboard.
- Clipboard contents are not written to logs.
- Pairing sessions expire after five minutes.
- Pairing sessions are single-use.
- Shared secrets are generated with cryptographically secure randomness.
- Frontend JavaScript never receives permanent app secrets for arbitrary devices.
- Native messages are validated and capped at `MAX_CLIPBOARD_BYTES`.
- Sensitive-data filtering is preserved in the Windows and macOS agents.
- Direct WebSocket mode must stay on a private reachable network and must not be exposed publicly without authentication.
- Public no-Tailscale mode requires a cloud relay so both native apps can connect outward.

## Development

Install JavaScript dependencies:

```bash
npm install
```

Install Python dependencies:

```bash
python3 -m pip install -r requirements.txt
```

Python 3.9+ is supported for the native helper modules.

Run the web app:

```bash
npm run dev
```

Open the local site at `http://localhost:5173`.

Run the Netlify web app and functions locally:

```bash
npm run netlify:dev
```

Run the Windows agent during development:

```powershell
python clients\windows\localbridge_agent.py
```

Run the macOS agent during development:

```bash
python3 clients/mac/localbridge_agent.py
```

Legacy manual `.env` mode still works for development:

- `windows/.env` may define `LISTEN_HOST`, `ALLOWED_PEER`, `PORT`, `SECRET`, and `MAX_CLIPBOARD_BYTES`.
- `mac/.env` may define `WINDOWS_TAILSCALE_IP`, `PORT`, `SECRET`, `MAX_CLIPBOARD_BYTES`, and `BLOCK_SENSITIVE_PATTERNS`.

## Tests

Run all tests:

```bash
npm test
```

The suite covers pairing token generation, expiration, single-use approval, invalid device rejection, auth validation, clipboard payload limits, sensitive-data filtering, and protocol messages.

## Deploy to Netlify

1. Push this repository to GitHub.
2. Create a Netlify site from the repository.
3. Use the included `netlify.toml`.
4. Configure Netlify Blobs for the pairing function.
5. Publish signed native agent builds as release artifacts and update the download links in `apps/web/src/main.tsx`.

Netlify Functions are used only for short-lived pairing/authentication/control operations. They are not used as a permanent WebSocket server. No-Tailscale public sync needs a separate relay service; see [`docs/NO_TAILSCALE_PLAN.md`](docs/NO_TAILSCALE_PLAN.md).

## Build native clients

Windows:

```powershell
./build/build_windows.ps1
```

Output:

```text
dist/LocalBridge-Windows.exe
```

macOS:

```bash
bash build/build_mac.sh
```

Output:

```text
dist/LocalBridge-Mac.app
```

GitHub Actions can also build both artifacts from `.github/workflows/build.yml`.

## User setup

For a detailed first-time user guide, see [`docs/USER_GUIDE.md`](docs/USER_GUIDE.md).

1. Open the LocalBridge website.
2. Download the Windows or macOS agent on each device.
3. Open LocalBridge on both devices.
4. Approve the pairing request.
5. Click **Finish pairing** on the second device after approval.
6. Copy on one device and paste on the other.

No clipboard content appears on the website.

## Clean install smoke test

To verify a new user can start from nothing:

1. Delete old LocalBridge user data:

   ```bash
   rm -rf "$HOME/Library/Application Support/LocalBridge" "$HOME/Library/Logs/localbridge"
   ```

   On Windows, delete `%LOCALAPPDATA%\LocalBridge`.

2. Start the local pairing broker for a development/demo build:

   ```bash
   node local_broker.mjs
   ```

3. In another terminal, run the web app:

   ```bash
   npm run dev
   ```

4. Run the native agent setup on each device:

   ```bash
   ./setup_mac.command
   ```

   On Windows, double-click `setup_windows.bat`.

5. Use the website pairing panel:
   register both devices, create a session on device A, join from device B, approve on device A, then finish pairing on device B.

For public beta builds, deploy the website and Netlify Functions first, then build native clients with:

```bash
LOCALBRIDGE_BACKEND_BASE_URL="https://YOUR-SITE.netlify.app" bash build/build_mac.sh
```

Windows:

```powershell
$env:LOCALBRIDGE_BACKEND_BASE_URL="https://YOUR-SITE.netlify.app"
./build/build_windows.ps1
```

## Known limitations

- A website cannot silently install native apps or grant OS clipboard access.
- Unsigned beta builds may require manual OS approval.
- The current direct sync transport requires both devices to be reachable on a private network. The public product should replace this with the planned cloud relay so users do not need Tailscale.
- Production pairing storage should use Netlify Blobs or another durable store with expiry cleanup.
- The current local UI is intentionally minimal and should be replaced by signed tray/menu-bar apps before a broad public beta.

## License

MIT. See `LICENSE`.
