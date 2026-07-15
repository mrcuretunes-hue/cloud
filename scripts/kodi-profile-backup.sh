#!/usr/bin/env bash
# Back up a Kodi profile (add-ons, repositories, and settings) so you can move it
# to a clean Kodi install while keeping your add-ons and most settings.
#
# Run this ON the device that has the Kodi you want to keep.
#
# Usage:
#   ./scripts/kodi-profile-backup.sh [output-dir]
#   KODI_HOME=/path/to/.kodi ./scripts/kodi-profile-backup.sh
#
# Produces: <output-dir>/kodi-profile-<timestamp>.tar.gz
# Captures: addons/ (add-ons + repos) and userdata/ (settings, sources,
# favourites, per-add-on data, add-on database). Skips caches and downloaded
# packages, which Kodi regenerates.
set -euo pipefail

KODI_HOME="${KODI_HOME:-$HOME/.kodi}"
OUT_DIR="${1:-./kodi-backups}"

if [ ! -d "$KODI_HOME/userdata" ]; then
  echo "No Kodi profile at '$KODI_HOME' (set KODI_HOME to the folder containing 'userdata/')." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$OUT_DIR/kodi-profile-${STAMP}.tar.gz"

# Include addons/ only if present (some installs keep it elsewhere).
INCLUDE=(userdata)
[ -d "$KODI_HOME/addons" ] && INCLUDE+=(addons)

echo "==> Backing up ${INCLUDE[*]} from ${KODI_HOME}"
tar czf "$OUT" -C "$KODI_HOME" \
  --exclude='userdata/Thumbnails' \
  --exclude='userdata/Database/Textures*.db' \
  --exclude='addons/packages' \
  --exclude='addons/temp' \
  --exclude='userdata/addon_data/*/temp' \
  "${INCLUDE[@]}"

echo "Backup complete: $(du -h "$OUT" | cut -f1) -> $OUT"
echo "Move this file to the tablet and run: ./scripts/kodi-profile-restore.sh $OUT"
