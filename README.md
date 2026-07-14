# cloud — Kodi shared media center

A from-scratch setup for an easy-to-access [Kodi](https://kodi.tv) media center
shared between your **tablet (`192.168.1.163`)** and your **server
(`192.168.1.177`)** — and any other Kodi device you add later.

## How it works

```
                 ┌─────────────────────────────────────┐
                 │  SERVER  192.168.1.177               │
                 │                                      │
   Kodi          │   ┌────────────┐   ┌─────────────┐  │
 ┌────────┐ SMB  │   │  Samba     │   │  MariaDB    │  │
 │ Tablet │──────┼──▶│  file      │   │  shared     │  │
 │.163    │──────┼──▶│  shares    │   │  library DB │  │
 └────────┘ MySQL│   │ (media)    │   │(watched,    │  │
      ▲          │   └────────────┘   │ metadata)   │  │
      │          │                    └─────────────┘  │
   same library, │                                      │
   same files    └─────────────────────────────────────┘
```

Two things are shared from the server so every device behaves identically:

1. **MariaDB shared library** — each Kodi device points its video/music library
   at the same database, so watched status, resume points, and metadata stay in
   sync across devices.
2. **Samba (SMB) file shares** — each device reads the media over the *same*
   network paths (`smb://192.168.1.177/Movies`, etc.). Identical paths are
   required for the shared library to work.

The server side is packaged as Docker Compose. The Kodi side is a set of
drop-in config files generated for your IPs.

## Quick start

### 1. On the server (`192.168.1.177`)

```bash
git clone <this-repo> && cd cloud
cp .env.example .env          # edit passwords + IPs
./scripts/setup.sh            # render config + create media folders
docker compose up -d          # start MariaDB + Samba
./scripts/verify.sh           # sanity-check DB + shares
```

Put your media into `media/Movies`, `media/TVShows`, `media/Music` (or point
`MEDIA_ROOT` in `.env` at existing folders).

### 2. On each Kodi device (tablet, etc.)

`./scripts/setup.sh` renders two config sets under `build/kodi-config/`:
`controller/` (shared server library) and `standalone/` (local offline library).
Pick a mode:

```bash
./scripts/switch-mode.sh auto         # controller if the server is reachable, else standalone
./scripts/switch-mode.sh controller   # use + update the shared server library
./scripts/switch-mode.sh standalone   # use the tablet's own offline library
```

(Or copy the files from `build/kodi-config/<mode>/` into Kodi's userdata by
hand.) Restart Kodi after switching. In **controller** mode, set the content
type on each source and **Update library** — metadata + watched state then live
in the shared DB and every device stays in sync.

See [`docs/server-setup.md`](docs/server-setup.md) and
[`docs/tablet-setup.md`](docs/tablet-setup.md) for full details.

## Layout

| Path | Purpose |
|------|---------|
| `docker-compose.yml` | Server stack: MariaDB + Samba |
| `.env.example` | All configurable values (IPs, passwords, media path) |
| `scripts/setup.sh` | Render config from `.env`, create folders |
| `scripts/switch-mode.sh` | Switch a device between standalone (offline) and controller (shared) |
| `scripts/deploy-remote.sh` | Deploy the server stack to your Ubuntu server over SSH (run from your LAN) |
| `scripts/verify.sh` | Health-check the running stack |
| `scripts/backup.sh` / `scripts/restore.sh` | Back up / restore the shared library DB |
| `server/mariadb/init/` | SQL that provisions the Kodi DB account |
| `kodi-config/*.template` | Kodi client config templates |
| `docs/` | Step-by-step server + tablet guides |

## Deploying / working with LAN access

A Cursor **Cloud Agent** runs in Cursor's datacenter and can't reach your home
network. To let an agent read your home-lab configs and deploy to the server/TV,
run it on a machine on your LAN (e.g. the Mini PC / hypervisor host) — see
[`docs/run-on-my-machine.md`](docs/run-on-my-machine.md). New to the Cursor
layout? See the [`docs/cursor-cheatsheet.md`](docs/cursor-cheatsheet.md).
