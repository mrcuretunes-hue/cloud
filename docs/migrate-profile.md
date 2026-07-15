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

## Same tablet, clean reinstall (Android) — easiest method

If the Kodi you want to keep is already on the tablet and you're reinstalling on
that same tablet, everything is compatible (same platform + version), so **all**
add-ons — including binary ones — carry over. The simplest on-device way (no PC,
no shell) is Kodi's own **Backup** add-on:

1. **Install the Backup add-on** in your current Kodi: Add-ons → Install from
   repository → Kodi Add-on repository → Program add-ons → **Backup** → Install.
2. In Backup → Settings, set the **backup location to a folder OUTSIDE the app's
   data** — e.g. internal shared storage `/storage/emulated/0/KodiBackup`, an SD
   card, or a cloud/network folder. Select what to include (add-ons + userdata).
3. Run **Backup now**.

   > CRITICAL on Android: uninstalling the Kodi app (or "Clear data") **deletes**
   > `Android/data/org.xbmc.kodi/`, which is where the profile lives. So the
   > backup MUST live somewhere else (shared storage / SD / cloud) before you
   > wipe. Verify the backup zip exists in that folder first.

4. **Clean install:** either uninstall + reinstall Kodi, or Settings → Apps →
   Kodi → Storage → **Clear data** for a fresh profile.
5. Reinstall the Backup add-on on the fresh Kodi, point it at the same location,
   and choose **Restore**. Restart Kodi.

Alternatively, if you have a PC: copy the whole `Android/data/org.xbmc.kodi/files/.kodi`
folder off the tablet before wiping, then copy it back after. (Note: on Android
11+ this app-data folder isn't reachable via plain `adb pull`/most file managers,
which is why the on-device Backup add-on is the reliable route.)

The `scripts/kodi-profile-backup.sh` / `restore.sh` below are for Linux/desktop
Kodi (or Android via Termux) — handy if you manage the profile from a computer.

## Steps (Linux/desktop, or via a computer)

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
