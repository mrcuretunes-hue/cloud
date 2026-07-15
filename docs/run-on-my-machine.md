# Run the Cursor agent on your own machine (LAN access)

Use this when you want the agent to reach your **home lab** — the Home
Assistant / Node-RED VM, the media server (`192.168.1.177`), the TV
(`192.168.1.169`), etc. — and to deploy directly.

## Why a Cloud Agent can't see your LAN

A **Cloud Agent** runs in an **isolated VM in Cursor's datacenter**, even when you
launch it from the Cursor app on your Mini PC. The app is just the remote
control; the agent executes remotely. So it has **no route** to `192.168.1.x` and
can't read files on your Mini PC or its VMs. That's expected — not a
misconfiguration.

To give the agent your filesystem + LAN, run it **on a machine that's on your
network** (e.g. the Mini PC / hypervisor host). Two supported ways:

## Option A — Local desktop Agent (simplest)

1. On the Mini PC, open this repo (`cloud`) in the **Cursor desktop app**.
2. Use the **Agent in the editor sidebar** (the normal in-editor chat, Agent
   mode) — **not** the Cloud Agents panel.
3. Give it the task. Its terminal runs **on the Mini PC**, so it can read your
   Home Assistant `configuration.yaml` / Node-RED `flows.json`, reach the server
   and TV, and run the deploy.

Note: the local agent asks you to **approve terminal commands** (Cloud Agents
auto-run them). This is the whole agent running locally.

## Option B — "My Machines" (keep the Cloud Agent UI, run tool calls locally)

The agent loop still runs in Cursor's cloud, but its commands/file/network
actions execute on your Mini PC over an outbound HTTPS connection (no inbound
ports/firewall changes).

```bash
# on the Mini PC (must be on the 192.168.1.0/24 network)
git clone https://github.com/mrcuretunes-hue/cloud.git
curl https://cursor.com/install -fsS | bash
agent login
agent worker start --worker-dir /path/to/cloud   # optionally --name "minipc"
```

Then in the Cursor Agents UI, pick the Mini PC from the **environment dropdown**
and start a task. Keep the `agent worker` process running during sessions.

## What this unlocks

Once the agent runs on the Mini PC:

- It can inspect your existing **Home Assistant + Node-RED** layout and the TV
  integration, then wire Kodi in additively.
- It can **deploy** the server stack directly: `./scripts/deploy-remote.sh
  ubuntu@192.168.1.177` (or run `docker compose up -d` on the server VM).
- **No Tailscale auth key or SSH tunnel needed** — the machine is already on the
  LAN.

## Point it at the right machine

Run the local agent / worker on a host that's actually on `192.168.1.0/24` — the
Mini PC (hypervisor host) is ideal since it can reach every VM and the TV on
HDMI 1. Running it inside an isolated VM without LAN access won't help.
