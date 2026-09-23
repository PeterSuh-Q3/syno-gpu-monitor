#!/bin/sh
printf 'Content-Type: application/json\r\n\r\n'
AUTH_USER="$(/usr/syno/synoman/webman/modules/authenticate.cgi 2>/dev/null)"
if [ -z "$AUTH_USER" ]; then printf '{"success":false,"error":"unauthorized"}\n'; exit 0; fi
if ! id -nG "$AUTH_USER" 2>/dev/null | tr ' ' '\n' | grep -qx administrators; then printf '{"success":false,"error":"administrator privileges required"}\n'; exit 0; fi
action=$(printf '%s' "${QUERY_STRING:-}" | sed -n 's/.*action=\([^&]*\).*/\1/p')
case "$action" in start|stop|status) ;; *) printf '{"success":false,"error":"invalid action"}\n'; exit 0 ;; esac
HELPER=/var/packages/syno-nvidia-gpu-monitor/target/bin/helper/monitor-helper
[ -u "$HELPER" ] && [ -x "$HELPER" ] || { printf '{"success":false,"error":"privilege helper unavailable"}\n'; exit 0; }
exec "$HELPER" "console-$action"
