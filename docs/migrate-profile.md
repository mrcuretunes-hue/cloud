# Move your Kodi to a clean install (keep add-ons + settings)

You can reinstall Kodi fresh on the tablet and **keep your add-ons,
repositories, and most settings**. Kodi stores all of that in two folders under
its home directory (`.kodi/`):

- `addons/` — installed add-ons **and** repositories
- `userdata/` — settings (`guisettings.xml`), sources (`sources.xml`),
  favourites (`favourites.xml`), per-add-on data (`addon_data/`), the add-on
  database, `advancedsettings.xml`, etc.

Migrating is just: back up those from the old Kodi, restore them onto the clean
install.

## Steps

**1. On the old Kodi (the one you want to keep):**
```bash
KODI_HOME=/path/to/.kodi ./scripts/kodi-profile-backup.sh ./kodi-backups
```
This writes `kodi-backups/kodi-profile-<timestamp>.tar.gz` (add-ons + userdata,
skipping caches and downloaded packages).

**2. Clean install Kodi on the tablet**, then fully quit it once.

**3. Restore onto the tablet:**
```bash
KODI_HOME=/path/to/.kodi ./scripts/kodi-profile-restore.sh kodi-profile-<timestamp>.tar.gz
```
It saves a copy of any existing profile first, then extracts your add-ons +
settings. Start Kodi.

**4. (Optional) set shared vs offline mode:**
```bash
./scripts/switch-mode.sh auto
```

### Kodi userdata locations (for `KODI_HOME`)

| Platform | `.kodi` path |
|----------|--------------|
| Android | `Android/data/org.xbmc.kodi/files/.kodi` |
| Windows | `%APPDATA%\Kodi` |
| Linux | `~/.kodi` |
| LibreELEC / CoreELEC | `/storage/.kodi` |

## Caveats

- **Match the Kodi major version** on the clean install when you can. Moving
  across a major version (e.g. 20 → 21) can disable add-ons that aren't updated.
- **Binary add-ons are platform-specific.** Add-ons with compiled parts (some
  PVR clients, `inputstream.*`) won't work if you move between different OSes
  (e.g. Windows/Linux → Android) — reinstall those from their repo. Plain
  script/plugin add-ons (most add-ons and repos) transfer fine.
- Add-ons may show as **disabled** after restore until you enable them once.
- The backup skips `Thumbnails/`, the textures cache, and `addons/packages/` —
  Kodi regenerates these.
