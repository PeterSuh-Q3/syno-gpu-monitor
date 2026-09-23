#!/bin/sh
printf 'Content-Type: application/json\r\n\r\n'
action=$(printf '%s' "${QUERY_STRING:-}" | sed -n 's/.*action=\([^&]*\).*/\1/p')
case "$action" in start|stop|status) ;; *) printf '{"success":false,"error":"invalid action"}\n'; exit 0 ;; esac
export GPU_CONSOLE_PKG_ROOT=/var/packages/syno-nvidia-gpu-monitor
export GPU_CONSOLE_TTYD=/var/packages/syno-nvidia-gpu-monitor/target/bin/ttyd
export GPU_CONSOLE_COMMAND=/usr/bin/nvidia-smi
export GPU_CONSOLE_PORT=17681
export GPU_CONSOLE_BASE_PATH=/nvidia-gpu-console
export GPU_CONSOLE_NGINX_LINK=/etc/nginx/conf.d/dsm.pkg-3rdparty.syno-nvidia-gpu-monitor-console.conf
export GPU_CONSOLE_NGINX_CONF=/var/packages/syno-nvidia-gpu-monitor/target/console/nvidia-console.conf
export GPU_CONSOLE_PIDFILE=/run/syno-nvidia-gpu-monitor-console.pid
exec /var/packages/syno-nvidia-gpu-monitor/target/console/console-control.sh "$action"
