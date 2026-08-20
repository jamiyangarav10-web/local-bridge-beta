# LocalBridge User Guide

This guide is for someone installing LocalBridge on two computers for the first time.

## What You Need

- Two computers: one Windows computer and one macOS computer.
- The LocalBridge website URL.
- The LocalBridge native app for each computer.

LocalBridge uses the website only for pairing. Clipboard text is synced by the native apps.

For the current direct-transport development build, both computers must be on a reachable private network. Tailscale is one way to do that.

For the target public beta, users should not need Tailscale. LocalBridge should use a cloud relay instead.

## First-Time Setup

### 1. Open the LocalBridge Website

Open the LocalBridge website in a browser.

For local demo/testing, use:

```text
http://127.0.0.1:5173
```

For a public beta, use the deployed website URL provided by the LocalBridge owner.

### 2. Install the Native App

On Windows, download and open:

```text
LocalBridge-Windows.exe
```

On macOS, download and open:

```text
LocalBridge-Mac.app
```

If you are using the development folder instead of packaged apps:

Windows:

```bat
setup_windows.bat
```

macOS:

```bash
./setup_mac.command
```

When asked for a backend URL, use the LocalBridge website/backend URL given to you.

For local demo/testing, use:

```text
http://127.0.0.1:8888
```

Keep the native app running while pairing.

## Pair Two Devices

Do these steps with LocalBridge running on both computers.

### On both devices

1. Open the LocalBridge website.
2. Click **Register device**.

### On the first device

1. Click **Create session**.
2. Copy the pairing ID.

### On the second device

1. Paste the pairing ID into **Pairing ID**.
2. Click **Join session**.

### Back on the first device

1. Confirm that the second device joined.
2. Click **Approve**.

### Back on the second device

1. Click **Finish pairing**.

After this, both devices should show that credentials are stored locally.

## Use LocalBridge

Copy text on one computer.

Paste on the other computer.

Clipboard text should move between the paired devices while both native apps are running.

## Remove Pairing

To disconnect a paired device:

1. Open the LocalBridge native app.
2. Click **Remove paired device**.

Or use the website dashboard button:

```text
Remove paired device
```

You can pair again later with a new pairing session.

## Clean Reinstall

Use this if you want to test the same experience as a new user.

On macOS, delete old LocalBridge data:

```bash
rm -rf "$HOME/Library/Application Support/LocalBridge" "$HOME/Library/Logs/localbridge"
```

On Windows, delete:

```text
%LOCALAPPDATA%\LocalBridge
```

Then install and pair again from the beginning.

## Troubleshooting

If the website says the agent is not detected:

- Make sure the native LocalBridge app is open.
- Make sure the browser is on the same computer as the native app.
- Refresh the website.

If pairing fails:

- Register both devices again.
- Create a new session.
- Pairing sessions expire after five minutes.
- Make sure you clicked **Finish pairing** on the second device after approval.

If clipboard sync does not work:

- Make sure both native apps are still running.
- For the current direct build, make sure both computers can reach each other on the private network.
- Click **Reconnect** in the LocalBridge app or website.
- Try copying plain text first.

LocalBridge does not sync sensitive-looking values such as private keys or bearer tokens.
