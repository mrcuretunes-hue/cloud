# AGENTS.md

## Cursor Cloud specific instructions

This repo is **infrastructure + config**, not an application to compile. It sets
up a Kodi shared media center:

- **Server stack** (`docker-compose.yml`): MariaDB (shared Kodi library DB) +
  Samba (SMB media shares). Meant to run on the user's server `192.168.1.177`.
- **Kodi client config** (`kodi-config/*.template` → rendered into
  `build/kodi-config/`): drop-in `advancedsettings.xml`, `sources.xml`,
  `passwords.xml` for each Kodi device (e.g. the tablet `192.168.1.163`).

### Running / testing in the cloud VM

- The real IPs (`192.168.1.x`) are the user's LAN and are **not reachable** from
  the VM. To test locally, set `SERVER_IP=127.0.0.1` in `.env`; MariaDB is
  published on `127.0.0.1:3306` and Samba uses host networking so shares are
  reachable at `//127.0.0.1`.
- Standard flow (see `README.md` / `docs/server-setup.md`):
  `./scripts/setup.sh` → `docker compose up -d` → `./scripts/verify.sh`.
- `scripts/setup.sh` renders templates with `envsubst` and is idempotent.
  Rendered files, `.env`, `media/`, and `server/mariadb/data/` are git-ignored.

### Non-obvious caveats

- **Docker must be started manually** — there is no systemd in the VM. Start it
  once per session (e.g. in a tmux session): `sudo dockerd`. Docker 29 requires
  `/etc/docker/daemon.json` with `storage-driver: fuse-overlayfs` **and**
  `features.containerd-snapshotter: false` for fuse-overlayfs to work; iptables
  must be set to `iptables-legacy`. (This config persists in the snapshot.)
- **MariaDB init SQL only runs on first startup** (empty data dir). If you change
  DB credentials, either update the account with `mysql` manually or wipe
  `server/mariadb/data/`.
- **Kodi GUI testing**: an XFCE desktop is available on `DISPLAY=:1` (TigerVNC).
  Launch with `DISPLAY=:1 kodi`. There's no GPU, so Kodi falls back to software
  rendering (EGL/VDPAU warnings are expected and harmless). Kodi userdata lives
  in `~/.kodi/userdata/`; copy the rendered `build/kodi-config/*.xml` there to
  point Kodi at the shared DB + SMB shares. For offline library scans, set the
  source's scraper to **"Local information only"** and provide `.nfo` files.
- Kodi 20 (Nexus) creates DBs named `MyVideos121` / `MyMusic82` in MariaDB on
  first connect — that confirms the shared-library link is working.
