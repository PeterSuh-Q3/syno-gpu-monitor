#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
PACKAGE=syno-nvidia-gpu-monitor
VERSION=0.6.2
PLATFORM=x86_64
IMAGE=${SYNOCOMPILER_IMAGE:-dante90/syno-compiler:7.4}
CC=${SYNOCOMPILER_CC:-/opt/epyc7002/bin/x86_64-pc-linux-gnu-gcc}
WORK="$ROOT/work/$PACKAGE-$PLATFORM"
OUT="$ROOT/dist"
rm -rf "$WORK"
mkdir -p "$WORK/target/bin/helper" "$WORK/target/ui/images" "$WORK/scripts" "$WORK/conf" "$WORK/webapi" "$OUT"
docker run --rm --platform linux/amd64 --entrypoint /bin/bash -u 0 -v "$ROOT:/work" -w /work "$IMAGE" -lc "'$CC' -O2 -s -Wall -Wextra -Werror -o /work/work/$PACKAGE-$PLATFORM/target/bin/syno-nvidia-gpu-monitor /work/monitor-spk/src/syno-nvidia-gpu-monitor.c -ldl"
docker run --rm --platform linux/amd64 --entrypoint /bin/bash -u 0 -v "$ROOT:/work" -w /work "$IMAGE" -lc "'$CC' -O2 -s -Wall -Wextra -Werror -o /work/work/$PACKAGE-$PLATFORM/target/bin/helper/monitor-helper /work/monitor-spk/src/monitor-helper.c"
chmod 0755 "$WORK/target/bin/syno-nvidia-gpu-monitor"
chmod 0550 "$WORK/target/bin/helper/monitor-helper"
cp "$ROOT/monitor-spk/src/syno-nvidia-gpu-monitor-status.sh" "$WORK/target/bin/"
chmod 0755 "$WORK/target/bin/syno-nvidia-gpu-monitor-status.sh"
cp "$ROOT/monitor-spk/scripts/"* "$WORK/scripts/"; chmod 0755 "$WORK/scripts/"*
cp "$ROOT/monitor-spk/conf/privilege" "$WORK/conf/privilege"
cp "$ROOT/monitor-spk/webapi/SYNO.NvidiaGpuMonitor" "$WORK/webapi/"; chmod 0755 "$WORK/webapi/SYNO.NvidiaGpuMonitor"
cp "$ROOT/monitor-spk/webui/"* "$WORK/target/ui/"; chmod 0755 "$WORK/target/ui/api.cgi"
cp "$ROOT/PACKAGE_ICON_256.PNG" "$WORK/target/ui/images/icon_256.png"
cp "$ROOT/monitor-spk/INFO" "$WORK/INFO"
for icon in PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG; do cp "$ROOT/$icon" "$WORK/$icon"; done
tar -C "$WORK/target" -czf "$WORK/package.tgz" .
printf 'extractsize="%s"\ncreate_time="%s"\nchecksum="%s"\n' "$(du -sk "$WORK/target" | awk '{print $1}')" "$(date +%Y%m%d-%H:%M:%S)" "$(md5sum "$WORK/package.tgz" | awk '{print $1}')" >> "$WORK/INFO"
tar -C "$WORK" -cf "$OUT/$PACKAGE-$VERSION-$PLATFORM.spk" INFO package.tgz scripts conf webapi PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
echo "Built $OUT/$PACKAGE-$VERSION-$PLATFORM.spk"
