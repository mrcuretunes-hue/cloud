#!/usr/bin/env bash
# Back up the shared Kodi library database to ./backups.
# Because the library lives on the server, this captures everything every device
# (incl. the tablet) has added. Safe to run from cron.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

set -a; . ./.env; set +a
: "${MYSQL_ROOT_PASSWORD:?}"
KEEP="${BACKUP_KEEP:-14}"

mkdir -p backups
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="backups/kodi-${STAMP}.sql.gz"

echo "==> Dumping all databases -> ${OUT}"
docker compose exec -T mariadb sh -c \
  "exec mariadb-dump -uroot -p\"${MYSQL_ROOT_PASSWORD}\" --all-databases --single-transaction --routines --events" \
  | gzip -9 > "$OUT"

echo "==> Pruning old backups (keeping ${KEEP})"
ls -1t backups/kodi-*.sql.gz 2>/dev/null | tail -n "+$((KEEP + 1))" | while read -r old; do
  echo "    removing $old"; rm -f "$old"
done

echo "Backup complete: $(du -h "$OUT" | cut -f1) -> $OUT"
