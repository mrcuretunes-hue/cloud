#!/usr/bin/env bash
# Switch a Kodi device between:
#   controller - uses + UPDATES the shared library on the server (needs the LAN)
#   standalone - uses this device's OWN local library (works offline)
#
# Usage:
#   ./scripts/switch-mode.sh auto         # controller if server reachable, else standalone
#   ./scripts/switch-mode.sh controller
#   ./scripts/switch-mode.sh standalone
#
# Applies to KODI_USERDATA (default ~/.kodi/userdata). Restart Kodi afterwards.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

set -a; . ./.env; set +a
: "${SERVER_IP:?}"; : "${DB_PORT:=3306}"

MODE="${1:-auto}"
USERDATA="${KODI_USERDATA:-$HOME/.kodi/userdata}"
CFG="build/kodi-config"

if [ ! -d "$CFG/controller" ] || [ ! -d "$CFG/standalone" ]; then
  echo "Rendered config missing. Run ./scripts/setup.sh first." >&2
  exit 1
fi

server_reachable() {
  timeout 3 bash -c ">/dev/tcp/${SERVER_IP}/${DB_PORT}" 2>/dev/null
}

if [ "$MODE" = "auto" ]; then
  if server_reachable; then
    MODE=controller
    echo "Server ${SERVER_IP}:${DB_PORT} is reachable -> controller mode"
  else
    MODE=standalone
    echo "Server ${SERVER_IP}:${DB_PORT} not reachable -> standalone mode"
  fi
fi

mkdir -p "$USERDATA"
case "$MODE" in
  controller)
    cp "$CFG/controller/advancedsettings.xml" "$USERDATA/"
    cp "$CFG/controller/sources.xml"          "$USERDATA/"
    cp "$CFG/controller/passwords.xml"        "$USERDATA/"
    ;;
  standalone)
    cp "$CFG/standalone/advancedsettings.xml" "$USERDATA/"
    cp "$CFG/standalone/sources.xml"          "$USERDATA/"
    rm -f "$USERDATA/passwords.xml"
    ;;
  *)
    echo "Usage: $0 [auto|standalone|controller]" >&2
    exit 1
    ;;
esac

echo "$MODE" > "$USERDATA/.kodi-mode"
echo "Switched to '${MODE}' mode in ${USERDATA}. Restart Kodi to apply."
