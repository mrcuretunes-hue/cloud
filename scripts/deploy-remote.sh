#!/usr/bin/env bash
# Deploy the server stack (MariaDB + Samba [+ backups]) to your Ubuntu server
# over SSH. Run this FROM a machine on the same LAN as the server.
#
# Usage:
#   ./scripts/deploy-remote.sh [--no-up] [--backup] <ssh-target> [remote-dir]
#
#   <ssh-target>  e.g.  ubuntu@192.168.1.177
#   [remote-dir]  where to put the project on the server (default: ~/kodi-cloud)
#   --no-up       sync + render config only; don't run "docker compose up"
#   --backup      also start the scheduled backup container (profile: backup)
#
# Requirements: ssh + rsync locally; docker + compose plugin on the server.
# Edit .env BEFORE deploying (SERVER_IP, passwords, MEDIA_ROOT) — it is copied
# to the server so the stack uses your real settings.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DO_UP=1
PROFILE_ARGS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --no-up)  DO_UP=0; shift ;;
    --backup) PROFILE_ARGS="--profile backup"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) break ;;
  esac
done

TARGET="${1:?ssh-target required, e.g. ubuntu@192.168.1.177}"
REMOTE_DIR="${2:-kodi-cloud}"

command -v rsync >/dev/null || { echo "rsync is required locally." >&2; exit 1; }
[ -f .env ] || echo "WARN: no local .env; the server will fall back to .env.example defaults." >&2

echo "==> Syncing project to ${TARGET}:${REMOTE_DIR}"
rsync -az --delete \
  --exclude '.git/' \
  --exclude 'build/' \
  --exclude 'media/' \
  --exclude 'backups/' \
  --exclude 'server/mariadb/data/' \
  ./ "${TARGET}:${REMOTE_DIR}/"

# .env is excluded from --delete safety above only if absent; send it explicitly.
if [ -f .env ]; then
  echo "==> Copying .env"
  rsync -az .env "${TARGET}:${REMOTE_DIR}/.env"
fi

echo "==> Rendering config on the server"
ssh "$TARGET" "cd '${REMOTE_DIR}' && ./scripts/setup.sh"

if [ "$DO_UP" -eq 1 ]; then
  echo "==> Starting the stack on the server"
  ssh "$TARGET" "cd '${REMOTE_DIR}' && docker compose ${PROFILE_ARGS} up -d && ./scripts/verify.sh"
  echo "Deployed and running on ${TARGET}."
else
  echo "==> Validating compose on the server (no up)"
  ssh "$TARGET" "cd '${REMOTE_DIR}' && docker compose config >/dev/null && echo 'compose OK'"
  echo "Synced + rendered on ${TARGET} (stack not started)."
fi
