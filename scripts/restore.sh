#!/usr/bin/env bash
# Restore the shared Kodi library from a backup created by scripts/backup.sh.
# Usage: ./scripts/restore.sh backups/kodi-YYYYmmdd-HHMMSS.sql.gz
# WARNING: this overwrites the current databases. Stop Kodi on all devices first.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: $0 <backup-file.sql.gz>" >&2
  echo "Available backups:" >&2
  ls -1t backups/kodi-*.sql.gz 2>/dev/null >&2 || echo "  (none)" >&2
  exit 1
fi

set -a; . ./.env; set +a
: "${MYSQL_ROOT_PASSWORD:?}"

echo "==> Restoring ${FILE} into MariaDB (overwrites existing data)"
gunzip -c "$FILE" | docker compose exec -T mariadb sh -c \
  "exec mariadb -uroot -p\"${MYSQL_ROOT_PASSWORD}\""

echo "Restore complete. Restart Kodi on your devices to pick up the library."
