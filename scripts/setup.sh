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

VARS='${SERVER_IP} ${DB_PORT} ${KODI_DB_USER} ${KODI_DB_PASSWORD} ${SAMBA_USER} ${SAMBA_PASSWORD}'

echo "==> Rendering MariaDB init SQL"
envsubst "$VARS" < server/mariadb/init/01-kodi.sql.template > server/mariadb/init/01-kodi.sql

echo "==> Rendering Kodi config into build/kodi-config/"
mkdir -p build/kodi-config
for f in advancedsettings sources passwords; do
  envsubst "$VARS" < "kodi-config/${f}.xml.template" > "build/kodi-config/${f}.xml"
  echo "    build/kodi-config/${f}.xml"
done

cat <<EOF

Done.
  1. Start the server stack:   docker compose up -d
  2. Copy the files in build/kodi-config/ into Kodi's userdata folder on the
     tablet (${TABLET_IP:-tablet}) and any other Kodi device.
  3. Add your media into ${MEDIA_ROOT}/{Movies,TVShows,Music} and let Kodi scan.
EOF
