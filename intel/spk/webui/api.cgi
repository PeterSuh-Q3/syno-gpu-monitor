#!/bin/sh
printf 'Content-Type: application/json\r\n\r\n'
exec /var/packages/synology-intel-gpu-monitor/target/bin/intel-gpu-monitor
