# Server setup (192.168.1.177)

The server hosts two things for the whole household: the **shared library
database** (MariaDB) and the **media file shares** (Samba).

## Prerequisites

- Docker + Docker Compose plugin
- The media files, or empty folders you'll fill later

## Steps

1. **Clone + configure**

   ```bash
   git clone <this-repo> && cd cloud
   cp .env.example .env
   ```

   Edit `.env`:

   | Variable | Meaning |
   |----------|---------|
   | `SERVER_IP` | This server's LAN IP (`192.168.1.177`) |
   | `MYSQL_ROOT_PASSWORD` | MariaDB root password — change it |
   | `KODI_DB_USER` / `KODI_DB_PASSWORD` | Account Kodi uses for the library |
   | `SAMBA_USER` / `SAMBA_PASSWORD` | Account Kodi uses for the file shares |
   | `MEDIA_ROOT` | Folder containing `Movies/ TVShows/ Music/` |

2. **Render config + create folders**

   ```bash
   ./scripts/setup.sh
   ```

3. **Start the stack**

   ```bash
   docker compose up -d
   docker compose ps
   ```

   - MariaDB listens on `3306`
   - Samba shares `Movies`, `TVShows`, `Music`

4. **Verify**

   ```bash
   ./scripts/verify.sh
   ```

   This confirms the Kodi DB account can create databases and the SMB shares
   are visible.

5. **Add media**

   Drop files into `media/Movies`, `media/TVShows`, `media/Music` (using the
   standard Kodi naming so scraping works, e.g.
   `Movies/The Matrix (1999)/The Matrix (1999).mkv`).

## Notes

- MariaDB data persists in `server/mariadb/data/`.
- Kodi creates its own databases (`MyVideosNNN`, `MyMusicNNN`) automatically on
  first launch — that's why the DB account has full privileges.
- The `01-kodi.sql` account provisioning only runs on the **first** startup
  (empty data dir). If you change credentials later, update the account with
  `mysql` manually or wipe `server/mariadb/data/`.
