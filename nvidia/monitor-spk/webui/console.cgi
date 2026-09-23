#!/bin/sh
printf 'Content-Type: text/plain; charset=utf-8\r\n\r\n'
AUTH_USER="$(/usr/syno/synoman/webman/modules/authenticate.cgi 2>/dev/null)"
if [ -z "$AUTH_USER" ]; then printf 'Unauthorized\n'; exit 0; fi
if ! id -nG "$AUTH_USER" 2>/dev/null | tr ' ' '\n' | grep -qx administrators; then
    printf 'Administrator privileges required\n'
    exit 0
fi
case "${QUERY_STRING:-}" in
    action=output) exec /usr/bin/nvidia-smi ;;
    *) printf 'Invalid action\n'; exit 0 ;;
esac
