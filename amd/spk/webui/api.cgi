#!/bin/sh
printf 'Content-Type: application/json\r\n\r\n'
exec /var/packages/synology-amd-gpu-monitor/target/bin/amd-gpu-monitor
