#!/bin/sh
# Shared GPU console lifecycle used by the standalone AMD/NVIDIA/Intel SPKs.
# The caller supplies only fixed, package-owned values; no user command is
# accepted. This mirrors the MSHELL Manager ttyd/nginx lifecycle.
set -eu

ACTION=${1:-}
case "$ACTION" in start|stop|status) ;; *) exit 2 ;; esac

PKG_ROOT=${GPU_CONSOLE_PKG_ROOT:?}
TTYD=${GPU_CONSOLE_TTYD:?}
COMMAND=${GPU_CONSOLE_COMMAND:?}
PORT=${GPU_CONSOLE_PORT:?}
BASE_PATH=${GPU_CONSOLE_BASE_PATH:?}
NGINX_LINK=${GPU_CONSOLE_NGINX_LINK:?}
NGINX_CONF=${GPU_CONSOLE_NGINX_CONF:?}
PIDFILE=${GPU_CONSOLE_PIDFILE:?}

mkdir -p "$(dirname "$PIDFILE")"

pids() {
  ps -eo pid=,args= 2>/dev/null | awk -v ttyd="$TTYD" -v port="$PORT" -v base="$BASE_PATH" \
    '$1 ~ /^[0-9]+$/ && index($0, ttyd) && index($0, "-p " port) && index($0, "--base-path " base) { print $1 }'
}

stop_console() {
  for pid in $(pids); do
    kill "$pid" 2>/dev/null || true
    sleep 1
    kill -9 "$pid" 2>/dev/null || true
  done
  rm -f "$PIDFILE" "$NGINX_LINK"
  systemctl reload nginx >/dev/null 2>&1 || true
}

route_ready() {
  [ -L "$NGINX_LINK" ] && nginx -t >/dev/null 2>&1
}

case "$ACTION" in
  stop)
    stop_console
    printf '{"success":true,"running":false}\n'
    ;;
  status)
    if [ -n "$(pids)" ] && route_ready; then
      printf '{"success":true,"running":true}\n'
    else
      printf '{"success":true,"running":false}\n'
    fi
    ;;
  start)
    stop_console
    ln -sf "$NGINX_CONF" "$NGINX_LINK"
    if ! nginx -t >/dev/null 2>&1 || ! systemctl reload nginx >/dev/null 2>&1; then
      rm -f "$NGINX_LINK"
      printf '{"success":false,"error":"failed to configure nginx console route"}\n'
      exit 0
    fi
    if [ ! -x "$TTYD" ] || [ ! -x "$COMMAND" ]; then
      rm -f "$NGINX_LINK"
      systemctl reload nginx >/dev/null 2>&1 || true
      printf '{"success":false,"error":"console runtime is unavailable"}\n'
      exit 0
    fi
    "$TTYD" -p "$PORT" --base-path "$BASE_PATH" -W "$COMMAND" >/dev/null 2>&1 &
    sleep 1
    pid="$(pids | head -n1 || true)"
    if [ -z "$pid" ]; then
      rm -f "$NGINX_LINK"
      systemctl reload nginx >/dev/null 2>&1 || true
      printf '{"success":false,"error":"failed to start console"}\n'
      exit 0
    fi
    printf '%s\n' "$pid" > "$PIDFILE"
    printf '{"success":true,"running":true}\n'
    ;;
esac
