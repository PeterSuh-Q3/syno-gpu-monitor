#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
IMAGE=${SYNOCOMPILER_IMAGE:-dante90/syno-compiler:7.4}
CC=${SYNOCOMPILER_CC:-/opt/epyc7002/bin/x86_64-pc-linux-gnu-gcc}
WORK="$ROOT/work/synology-amd-gpu-monitor"
OUT="$ROOT/dist"
rm -rf "$WORK"
mkdir -p "$WORK/target/bin" "$WORK/target/ui/images" "$WORK/scripts" "$WORK/conf" "$OUT"
docker run --rm --platform linux/amd64 --entrypoint /bin/bash -u 0 -v "$ROOT:/work" -w /work "$IMAGE" -lc "'$CC' -O2 -s -Wall -Wextra -Werror -o /work/work/synology-amd-gpu-monitor/target/bin/amd-gpu-monitor /work/src/amd-gpu-monitor.c"
chmod 0755 "$WORK/target/bin/amd-gpu-monitor"
cp "$ROOT/spk/INFO" "$WORK/INFO"
cp "$ROOT/spk/scripts/"* "$WORK/scripts/"
chmod 0755 "$WORK/scripts/"*
cp "$ROOT/spk/conf/privilege" "$WORK/conf/privilege"
cp "$ROOT/spk/webui/"* "$WORK/target/ui/"
cp "$ROOT/spk/PACKAGE_ICON_256.PNG" "$WORK/target/ui/images/icon_256.png"
cp "$ROOT/spk/PACKAGE_ICON.PNG" "$WORK/PACKAGE_ICON.PNG"
cp "$ROOT/spk/PACKAGE_ICON_256.PNG" "$WORK/PACKAGE_ICON_256.PNG"
tar -C "$WORK/target" -czf "$WORK/package.tgz" .
printf 'extractsize="%s"\n' "$(du -sk "$WORK/target" | awk '{print $1}')" >> "$WORK/INFO"
printf 'create_time="%s"\n' "$(date +%Y%m%d-%H:%M:%S)" >> "$WORK/INFO"
printf 'checksum="%s"\n' "$(md5sum "$WORK/package.tgz" | awk '{print $1}')" >> "$WORK/INFO"
SPK="$OUT/synology-amd-gpu-monitor-0.1.0-x86_64.spk"
tar -C "$WORK" -cf "$SPK" INFO package.tgz scripts conf PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
echo "Built $SPK"
