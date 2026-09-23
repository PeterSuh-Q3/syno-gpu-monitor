#!/bin/sh
printf 'Content-Type: application/json; charset=utf-8\r\n\r\n'
AUTH_USER="$(/usr/syno/synoman/webman/modules/authenticate.cgi 2>/dev/null)"
if [ -z "$AUTH_USER" ]; then
  printf '{"success":false,"error":"unauthorized - sign in to DSM first"}\n'
  exit 0
fi
if ! id -nG "$AUTH_USER" 2>/dev/null | tr ' ' '\n' | grep -qx administrators; then
  printf '{"success":false,"error":"administrator privileges required"}\n'
  exit 0
fi
case "${QUERY_STRING:-}" in
  action=start) ACTION=console-start ;;
  action=stop) ACTION=console-stop ;;
  action=status) ACTION=console-status ;;
  *) printf '{"success":false,"error":"invalid action"}\n'; exit 0 ;;
esac
HELPER=/var/packages/synology-intel-gpu-monitor/target/bin/helper/intel-gpu-monitor-helper
if [ ! -u "$HELPER" ] || [ ! -x "$HELPER" ]; then
  printf '{"success":false,"error":"privilege helper is unavailable"}\n'
  exit 0
fi
exec "$HELPER" "$ACTION"
