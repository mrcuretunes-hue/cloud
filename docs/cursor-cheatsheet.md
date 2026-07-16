# Cursor cheat sheet (how the app is laid out)

A quick map of Cursor so the window makes sense. Tailored to this home‑lab setup.

## The two screens (same app)

| Screen | What it's for | Switch to it |
|--------|---------------|--------------|
| **Editor / IDE** | Normal code editor; Agent chat docks on the right | `Ctrl/Cmd+Shift+P` → **Open IDE**, or the `IDE ↗` button |
| **Agents Window** | Hub for running/among many agents | `Ctrl/Cmd+Shift+P` → **Open Agents Window** |

## The 4 controls on the chat box (these decide everything)

A chat = *work on **this project**, on **this branch**, running **here**, allowed to do **this**.*

| Control | Example | Meaning |
|---------|---------|---------|
| **Project** | `cloud ▾` | Which folder/repo the agent works on |
| **Branch** | `main ▾` | Which git branch |
| **Runtime** | `🖥 This PC ▾` | **WHERE it runs** (see below) |
| **Mode** | `Ask` / `Agent` | **Ask** = read‑only answers; **Agent** = edits files + runs commands |

(The model picker — e.g. `Grok`, `GPT` — is just which AI; not important day‑to‑day.)

## Runtimes (where the agent actually executes)

| Runtime | Runs on | Sees your LAN/files? | Notes |
|---------|---------|----------------------|-------|
| **Cloud** | Cursor's datacenter VM | No | Isolated; has a live **Desktop/Browser** preview pane; auto‑runs commands |
| **This PC** | The machine Cursor is open on | Yes (that machine) | Only while the app is open there |
| **My Machines** | Your own always‑on server/worker | Yes | Register with `agent worker start`; persistent; best for a home lab |

The agent's "brain" (the LLM) always runs in Cursor's cloud. **My Machines / This PC** only move where *tool calls* (commands, file edits, network) execute. See [`run-on-my-machine.md`](run-on-my-machine.md).

## Agents Window = 3 panes

1. **Left** — navigation: New Agent, Search, Automations, Customize, and your list of agent sessions.
2. **Middle** — the active conversation. Its **branch + runtime** show at the bottom.
3. **Right** — a live **Browser/Desktop** preview *inside a Cloud agent's VM*. (Absent for This PC / My Machines agents — there's no remote VM.)

## Run locally (reach your home lab)

The Runtime dropdown can't repoint an existing **Cloud** conversation, so:

1. Open the repo folder: `Ctrl/Cmd+O`.
2. Start a **new** chat: `Ctrl/Cmd+I`.
3. Set the dropdown to **This PC** (or your **My Machines** server) and mode to **Agent**.

Then the agent can read local files and reach `192.168.1.x` — no tunnels/secrets needed.

## This home lab's projects

| Project | What it is | Use it for |
|---------|-----------|-----------|
| `cloud` | This repo (Kodi media center) | Server stack, Kodi config, deploy scripts |
| `smarthome` | Home Assistant + Node‑RED | Automations, the TV integration |

## Gotchas

- **"Agent is blocked — Add N missing secrets"** — that banner comes from a past `add_secrets` request. If you're going local/My Machines, those secrets aren't needed; **dismiss/ignore** it.
- The floating strip at the screen's right edge (magnifier ⊕ / grid / keyboard) is a **Windows** overlay, **not** Cursor.
- A **Cloud** agent can't see your home network — that's by design, not a bug.

## Shortcuts

| Action | Shortcut |
|--------|----------|
| Open Agent chat pane | `Ctrl/Cmd+I` |
| Open a folder | `Ctrl/Cmd+O` |
| Cloud ↔ This PC / server + mode | dropdowns under the chat input |
| Open Agents Window | `Ctrl/Cmd+Shift+P` → **Open Agents Window** |
| Back to editor | `Ctrl/Cmd+Shift+P` → **Open IDE** |
| Manage agents on the web | [cursor.com/agents](https://cursor.com/agents) |
