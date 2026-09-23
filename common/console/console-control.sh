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
NGINX_TEMPLATE=${GPU_CONSOLE_NGINX_TEMPLATE:?}
NGINX_CONF=${GPU_CONSOLE_NGINX_CONF:?}
TOKENFILE=${GPU_CONSOLE_TOKENFILE:?}
PUBLIC_BASE=${GPU_CONSOLE_PUBLIC_BASE:?}
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
  rm -f "$PIDFILE" "$NGINX_LINK" "$NGINX_CONF" "$TOKENFILE"
  systemctl reload nginx >/dev/null 2>&1 || true
}

route_ready() {
  [ -L "$NGINX_LINK" ] && [ -s "$TOKENFILE" ] && nginx -t >/dev/null 2>&1
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
    if [ ! -x "$TTYD" ] || [ ! -x "$COMMAND" ]; then
      printf '{"success":false,"error":"console runtime is unavailable"}\n'
      exit 0
    fi
    # DSM's 3rdparty nginx locations are publicly reachable without a DSM
    # session. Issue a fresh 192-bit path only to the authenticated CGI caller.
    umask 077
    token="$(od -An -N24 -tx1 /dev/urandom | tr -d ' \n')"
    if [ "${#token}" -ne 48 ]; then
      printf '{"success":false,"error":"failed to generate console access path"}\n'
      exit 0
    fi
    printf '%s\n' "$token" > "$TOKENFILE"
    sed "s|@TOKEN@|$token|g" "$NGINX_TEMPLATE" > "$NGINX_CONF"
    ln -sf "$NGINX_CONF" "$NGINX_LINK"
    if ! nginx -t >/dev/null 2>&1 || ! systemctl reload nginx >/dev/null 2>&1; then
      stop_console
      printf '{"success":false,"error":"failed to configure nginx console route"}\n'
      exit 0
    fi
    # Bind only to loopback; the unguessable route is the sole browser path.
    # The consoles display telemetry, so browser-side terminal input is disabled.
    "$TTYD" -i lo -q -p "$PORT" --base-path "$BASE_PATH/$token" "$COMMAND" >/dev/null 2>&1 &
    sleep 1
    pid="$(pids | head -n1 || true)"
    if [ -z "$pid" ]; then
      stop_console
      printf '{"success":false,"error":"failed to start console"}\n'
      exit 0
    fi
    printf '%s\n' "$pid" > "$PIDFILE"
    printf '{"success":true,"running":true,"url":"%s/%s/"}\n' "$PUBLIC_BASE" "$token"
    ;;
esac
