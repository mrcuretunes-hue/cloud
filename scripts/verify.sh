#!/usr/bin/env bash
# Health-check the running server stack: MariaDB reachable + Kodi account can
# create databases, and the SMB shares are listable.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

set -a; . ./.env; set +a
: "${DB_PORT:=3306}"
HOST="${1:-127.0.0.1}"
fail=0

echo "==> Checking MariaDB at ${HOST}:${DB_PORT} as ${KODI_DB_USER}"
if mysql -h "$HOST" -P "$DB_PORT" -u "$KODI_DB_USER" -p"$KODI_DB_PASSWORD" \
     -e "CREATE DATABASE IF NOT EXISTS kodi_healthcheck; DROP DATABASE kodi_healthcheck;" 2>/dev/null; then
  echo "    OK: connected and can create/drop databases"
else
  echo "    FAIL: could not connect or missing privileges"; fail=1
fi

echo "==> Listing SMB shares on ${HOST} as ${SAMBA_USER}"
if smbclient -L "//${HOST}" -U "${SAMBA_USER}%${SAMBA_PASSWORD}" -m SMB3 2>/dev/null \
     | grep -Eq "Movies|TVShows|Music"; then
  echo "    OK: media shares are visible"
else
  echo "    FAIL: shares not visible"; fail=1
fi

[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Some checks failed."
exit "$fail"
