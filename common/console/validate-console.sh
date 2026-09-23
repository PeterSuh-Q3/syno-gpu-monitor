#!/bin/sh
# Lifecycle validation for a vendor console profile.
# Usage on DSM: validate-console.sh /path/to/profile.env
set -eu

PROFILE=${1:-}
[ -r "$PROFILE" ] || { echo "profile is required" >&2; exit 2; }
# shellcheck disable=SC1090
. "$PROFILE"
: "${GPU_CONSOLE_TTYD:?GPU_CONSOLE_TTYD must be set by the package wrapper}"
: "${GPU_CONSOLE_NGINX_LINK:?GPU_CONSOLE_NGINX_LINK missing}"
: "${GPU_CONSOLE_PIDFILE:?GPU_CONSOLE_PIDFILE missing}"

CONTROL=${GPU_CONSOLE_CONTROL:?GPU_CONSOLE_CONTROL must be set by the package wrapper}
[ -x "$CONTROL" ] || { echo "console controller is not executable" >&2; exit 1; }

json_running() { "$CONTROL" status | grep -q '"running":true'; }
fail() { echo "FAIL: $*" >&2; exit 1; }

echo "[1/6] controller status is queryable"
"$CONTROL" status >/dev/null || fail "status action failed"

echo "[2/6] start creates an active console"
"$CONTROL" start >/tmp/gpu-console-validate.start.json || fail "start action failed"
json_running || fail "console did not report running"

echo "[3/6] nginx route is valid"
[ -L "$GPU_CONSOLE_NGINX_LINK" ] || fail "nginx route link missing"
nginx -t >/dev/null 2>&1 || fail "nginx configuration is invalid"

echo "[4/6] stop removes process and route"
"$CONTROL" stop >/tmp/gpu-console-validate.stop.json || fail "stop action failed"
sleep 1
! json_running || fail "console remains running after stop"
[ ! -e "$GPU_CONSOLE_NGINX_LINK" ] || fail "nginx route remains after stop"
[ ! -e "$GPU_CONSOLE_PIDFILE" ] || fail "PID file remains after stop"

echo "[5/6] repeated stop is idempotent"
"$CONTROL" stop >/dev/null || fail "repeated stop failed"

echo "[6/6] nginx remains valid after cleanup"
nginx -t >/dev/null 2>&1 || fail "nginx invalid after cleanup"
rm -f /tmp/gpu-console-validate.start.json /tmp/gpu-console-validate.stop.json
echo "PASS: console lifecycle is clean"
