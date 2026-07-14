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

Copy the generated files from `build/kodi-config/` into Kodi's userdata folder:

- `advancedsettings.xml` — connects the library to the shared MariaDB
- `sources.xml` — adds the SMB media sources
- `passwords.xml` — SMB credentials (optional)

Then in Kodi: **Videos → Files → add source** is already populated; set the
content type (Movies / TV shows), and **Update library**. Repeat on every
device — they all read/write the same shared database.

See [`docs/server-setup.md`](docs/server-setup.md) and
[`docs/tablet-setup.md`](docs/tablet-setup.md) for full details.

## Layout

| Path | Purpose |
|------|---------|
| `docker-compose.yml` | Server stack: MariaDB + Samba |
| `.env.example` | All configurable values (IPs, passwords, media path) |
| `scripts/setup.sh` | Render config from `.env`, create folders |
| `scripts/verify.sh` | Health-check the running stack |
| `server/mariadb/init/` | SQL that provisions the Kodi DB account |
| `kodi-config/*.template` | Kodi client config templates |
| `docs/` | Step-by-step server + tablet guides |
