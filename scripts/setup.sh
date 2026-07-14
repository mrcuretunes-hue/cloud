#!/usr/bin/env bash
# Render configuration from .env and prepare folders.
# Safe to run repeatedly (idempotent).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v envsubst >/dev/null 2>&1; then
  echo "ERROR: 'envsubst' not found. Install it first:" >&2
  echo "  Debian/Ubuntu: sudo apt-get install -y gettext-base" >&2
  echo "  Fedora/RHEL:   sudo dnf install -y gettext" >&2
  echo "  macOS:         brew install gettext" >&2
  exit 1
fi

if [ ! -f .env ]; then
  echo "No .env found -> creating one from .env.example (edit it, then re-run)."
  cp .env.example .env
fi

# Load .env
set -a
# shellcheck disable=SC1091
. ./.env
set +a

: "${SERVER_IP:?SERVER_IP must be set in .env}"
: "${DB_PORT:=3306}"
: "${KODI_DB_USER:?}" "${KODI_DB_PASSWORD:?}"
: "${SAMBA_USER:?}" "${SAMBA_PASSWORD:?}"
: "${MEDIA_ROOT:=./media}"

echo "==> Creating media folders under ${MEDIA_ROOT}"
mkdir -p "${MEDIA_ROOT}/Movies" "${MEDIA_ROOT}/TVShows" "${MEDIA_ROOT}/Music"
mkdir -p server/mariadb/data server/mariadb/init

: "${TABLET_LOCAL_MEDIA:=/storage/emulated/0}"
VARS='${SERVER_IP} ${DB_PORT} ${KODI_DB_USER} ${KODI_DB_PASSWORD} ${SAMBA_USER} ${SAMBA_PASSWORD} ${TABLET_LOCAL_MEDIA}'

echo "==> Rendering MariaDB init SQL"
envsubst "$VARS" < server/mariadb/init/01-kodi.sql.template > server/mariadb/init/01-kodi.sql

echo "==> Rendering Kodi config (controller + standalone) into build/kodi-config/"
mkdir -p build/kodi-config/controller build/kodi-config/standalone
for f in advancedsettings sources passwords; do
  envsubst "$VARS" < "kodi-config/${f}.controller.xml.template" > "build/kodi-config/controller/${f}.xml"
  echo "    build/kodi-config/controller/${f}.xml"
done
for f in advancedsettings sources; do
  envsubst "$VARS" < "kodi-config/${f}.standalone.xml.template" > "build/kodi-config/standalone/${f}.xml"
  echo "    build/kodi-config/standalone/${f}.xml"
done

cat <<EOF

Done.
  1. Start the server stack:   docker compose up -d
  2. On the tablet (${TABLET_IP:-tablet}) pick a mode with:
       ./scripts/switch-mode.sh auto         # controller if server reachable, else standalone
       ./scripts/switch-mode.sh controller   # use + update the shared server library
       ./scripts/switch-mode.sh standalone   # use the tablet's own offline library
     (or copy build/kodi-config/<mode>/ into Kodi's userdata by hand, then restart Kodi.)
  3. Add your media into ${MEDIA_ROOT}/{Movies,TVShows,Music} and let Kodi scan.
EOF
