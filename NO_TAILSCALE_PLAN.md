# No-Tailscale Product Plan

The product goal is:

```text
Install LocalBridge -> open the website -> pair devices -> copy and paste.
```

Users should not have to install Tailscale, know IP addresses, open ports, copy secrets, or run terminal commands.

## What the Website Can Do

The website can own:

- downloads
- onboarding
- pairing sessions
- device registration
- approval
- dashboard status
- relay configuration
- account/billing in the future

The website cannot silently read or write the operating-system clipboard across computers. Browsers do not allow that as a background cross-device sync feature.

So LocalBridge still needs a native app on each computer.

## What Replaces Tailscale

Tailscale is only needed by the current direct transport because one device must reach the other device directly.

To remove Tailscale, both native apps should connect outward to a LocalBridge cloud relay:

```text
Windows app  ->  LocalBridge relay  <-  macOS app
```

Both apps make outbound WebSocket connections. Users do not need inbound firewall rules, private IPs, Tailscale, port forwarding, or LAN setup.

## Required Backend Pieces

### 1. Pairing API

Already present.

Responsibilities:

- register each local native app
- create short-lived pairing sessions
- approve pairing
- issue a shared secret
- tell both native apps which relay URL to use

### 2. Relay Service

Needed for no-Tailscale mode.

Responsibilities:

- accept WebSocket connections from native apps
- authenticate with the shared secret from pairing
- place both paired devices in the same relay room
- forward clipboard messages between paired devices
- never store clipboard history
- enforce message size limits
- rate-limit abusive clients

Netlify Functions are not enough for this because they do not provide a long-running WebSocket server. Use a small always-on service such as Fly.io, Render, Railway, a VPS, or Cloudflare Durable Objects.

### 3. Native Apps

Needed.

Responsibilities:

- read local clipboard
- write local clipboard
- connect to the LocalBridge relay
- authenticate using pairing credentials
- reconnect automatically
- filter sensitive-looking clipboard values

## Target User Flow

1. User opens the LocalBridge website.
2. User downloads LocalBridge for Windows/macOS.
3. User opens the native app on both devices.
4. Website detects the local app on each device.
5. User clicks **Register device** on both devices.
6. User creates a pairing session on device A.
7. User joins the session on device B.
8. User approves on device A.
9. User clicks **Finish pairing** on device B.
10. Both apps connect to the cloud relay.
11. Clipboard sync works without Tailscale.

## Current State

The repository currently has:

- website onboarding
- local native control API
- pairing API
- local pairing broker for development
- direct WebSocket clipboard engine
- credential fetch for the second paired device

The missing production piece is the cloud relay transport and native-agent relay mode.

## Implementation Checklist

1. Add `LOCALBRIDGE_RELAY_URL` to backend configuration.
2. Return `transport: "cloud-relay"` and `relayUrl` from pairing approval.
3. Add a relay WebSocket service.
4. Update native apps to connect outbound to `relayUrl`.
5. Keep direct WebSocket mode as a development fallback.
6. Update public user guide to remove Tailscale from normal setup.
7. Deploy website/API and relay before publishing native builds.
