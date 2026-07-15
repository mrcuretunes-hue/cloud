#!/usr/bin/env bash
# Restore a Kodi profile (add-ons + settings) onto a CLEAN Kodi install, so the
# fresh install keeps your add-ons, repositories, and most settings.
#
# Run this ON the tablet (or target device) AFTER a clean Kodi install.
#
# Usage:
#   ./scripts/kodi-profile-restore.sh <kodi-profile-*.tar.gz>
#   KODI_HOME=/path/to/.kodi ./scripts/kodi-profile-restore.sh <file>
#
# IMPORTANT:
#   - Fully quit Kodi first (so it doesn't overwrite files on exit).
#   - Add-ons with BINARY parts (e.g. some PVR/inputstream) are platform-specific;
#     moving between different OSes (e.g. Windows/Linux -> Android) may require
#     reinstalling those from their repo. Plain script/plugin add-ons transfer fine.
#   - Use a matching Kodi major version on the clean install when possible.
set -euo pipefail

FILE="${1:-}"
KODI_HOME="${KODI_HOME:-$HOME/.kodi}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: $0 <kodi-profile-*.tar.gz>" >&2
  exit 1
fi

if pgrep -f 'kodi.bin' >/dev/null 2>&1; then
  echo "WARNING: Kodi appears to be running. Quit it fully before restoring." >&2
fi

mkdir -p "$KODI_HOME"

# Safety copy of any existing profile.
if [ -d "$KODI_HOME/userdata" ]; then
  BAK="${KODI_HOME}.pre-restore-$(date +%Y%m%d-%H%M%S)"
  echo "==> Existing profile found; saving a copy at ${BAK}"
  cp -a "$KODI_HOME" "$BAK"
fi

echo "==> Restoring ${FILE} into ${KODI_HOME}"
tar xzf "$FILE" -C "$KODI_HOME"

echo "Restore complete."
echo "Start Kodi. To set shared vs offline mode afterward, run:"
echo "  ./scripts/switch-mode.sh auto"
