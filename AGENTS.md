# AGENTS.md

## Cursor Cloud specific instructions

This repo is **infrastructure + config**, not an application to compile. It sets
up a Kodi shared media center:

- **Server stack** (`docker-compose.yml`): MariaDB (shared Kodi library DB) +
  Samba (SMB media shares). Meant to run on the user's server `192.168.1.177`.
- **Kodi client config** (`kodi-config/*.template` → rendered by
  `./scripts/setup.sh` into `build/kodi-config/controller/` and
  `build/kodi-config/standalone/`). A device runs in one of two modes, switched
  with `./scripts/switch-mode.sh [auto|controller|standalone]`:
  - **controller** — uses + updates the shared server MariaDB library (needs LAN).
  - **standalone** — uses the device's own local SQLite library + local media
    (`TABLET_LOCAL_MEDIA`), fully offline.
  `switch-mode.sh` copies the chosen set into `KODI_USERDATA` (default
  `~/.kodi/userdata`); Kodi must be restarted to pick up changes.

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
  in `~/.kodi/userdata/`; use `./scripts/switch-mode.sh` (or copy a
  `build/kodi-config/<mode>/` set there) to point Kodi at the shared DB + SMB
  shares (controller) or its local library (standalone). For offline library
  scans, set the source's scraper to **"Local information only"** and provide
  `.nfo` files.
- **Restarting Kodi**: the `/usr/bin/kodi` wrapper auto-relaunches `kodi.bin`, so
  killing `kodi.bin` alone won't stop it. Launch Kodi under a tmux session and
  kill that session (then any leftover `bin/kodi` PIDs) to fully restart — needed
  to reload `advancedsettings.xml`/`sources.xml` after switching modes.
- Kodi 20 (Nexus) creates DBs named `MyVideos121` / `MyMusic82` in MariaDB on
  first connect — that confirms the shared-library link is working. In standalone
  mode it instead creates a local SQLite `~/.kodi/userdata/Database/MyVideos*.db`.
