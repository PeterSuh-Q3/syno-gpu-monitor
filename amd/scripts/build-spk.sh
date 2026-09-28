#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
VERSION=0.4.4
IMAGE=${SYNOCOMPILER_IMAGE:-dante90/syno-compiler:7.4}
CC=${SYNOCOMPILER_CC:-/opt/epyc7002/bin/x86_64-pc-linux-gnu-gcc}
WORK="$ROOT/work/synology-amd-gpu-monitor"
OUT=${SPK_OUTPUT_DIR:-"$ROOT/dist"}
COMMON="$ROOT/../common/console"
CACHE="$ROOT/work-cache"
rm -rf "$WORK"
mkdir -p "$WORK/target/bin/helper" "$WORK/target/ui/images" "$WORK/scripts/console-runtime/amd" "$WORK/conf" "$OUT"
docker run --rm --platform linux/amd64 --entrypoint /bin/bash -u 0 -v "$ROOT:/work" -w /work "$IMAGE" -lc "'$CC' -O2 -s -Wall -Wextra -Werror -o /work/work/synology-amd-gpu-monitor/target/bin/amd-gpu-monitor /work/src/amd-gpu-monitor.c"
docker run --rm --platform linux/amd64 --entrypoint /bin/bash -u 0 -v "$ROOT:/work" -w /work "$IMAGE" -lc "'$CC' -O2 -s -Wall -Wextra -Werror -o /work/work/synology-amd-gpu-monitor/target/bin/helper/amd-gpu-monitor-helper /work/src/amd-gpu-monitor-helper.c"
chmod 0755 "$WORK/target/bin/amd-gpu-monitor"
chmod 0550 "$WORK/target/bin/helper/amd-gpu-monitor-helper"
cp "$ROOT/spk/INFO" "$WORK/INFO"
cp "$ROOT/spk/scripts/"* "$WORK/scripts/"
chmod 0755 "$WORK/scripts/"*
cp "$ROOT/spk/conf/privilege" "$WORK/conf/privilege"
cp "$ROOT/spk/webui/"* "$WORK/target/ui/"
chmod 0755 "$WORK/target/ui/api.cgi" "$WORK/target/ui/console.cgi"
cp "$ROOT/../common/webui/gpu-console.css" "$WORK/target/ui/"
cp "$ROOT/../common/webui/gpu-console.js" "$WORK/target/ui/"
cp "$COMMON/console-control.sh" "$WORK/scripts/console-engine"
sed -e 's|@PACKAGE@|SynoAmdGpuMonitor|g' -e 's|@BASE_PATH@|amdgpu-console|g' -e 's|@PORT@|17684|g' "$COMMON/route.conf.template" > "$WORK/scripts/route.conf"
mv "$WORK/scripts/run-top" "$WORK/scripts/console-runtime/run-top"
"$COMMON/fetch-runtime.sh" 'https://github.com/PeterSuh-Q3/syno-amdgpu-top/releases/download/v0.1.2/syno-amdgpu-top-runtime-0.1.2-x86_64.tar.gz' 'e784dad38728591906532760bcdedd3a536f03aad80b5650c2cd206cdd482a7f' "$CACHE/amdgpu-top-0.1.2-x86_64.tar.gz"
TTYD_SOURCE=${TTYD_SOURCE:-"$ROOT/../../mshell-manager/src/bin/ttyd"}
[ -f "$TTYD_SOURCE" ] || { echo "ttyd missing: set TTYD_SOURCE to the MSHELL Manager binary" >&2; exit 1; }
[ "$(shasum -a 256 "$TTYD_SOURCE" | awk '{print $1}')" = '8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55' ] || { echo "ttyd checksum mismatch" >&2; exit 1; }
"$COMMON/install-runtime.sh" "$CACHE/amdgpu-top-0.1.2-x86_64.tar.gz" syno-amdgpu-top 0.1.2 "$WORK/scripts/console-runtime/amd" bin/amdgpu_top
cp "$TTYD_SOURCE" "$WORK/scripts/console-runtime/ttyd"
chmod 0755 "$WORK/scripts/console-engine" "$WORK/scripts/console-runtime/run-top" "$WORK/scripts/console-runtime/ttyd"
cp "$ROOT/spk/PACKAGE_ICON_256.PNG" "$WORK/target/ui/images/icon_256.png"
cp "$ROOT/spk/PACKAGE_ICON.PNG" "$WORK/PACKAGE_ICON.PNG"
cp "$ROOT/spk/PACKAGE_ICON_256.PNG" "$WORK/PACKAGE_ICON_256.PNG"
tar -C "$WORK/target" -czf "$WORK/package.tgz" .
"$COMMON/validate-package.sh" "$WORK"
printf 'extractsize="%s"\n' "$(du -sk "$WORK/target" | awk '{print $1}')" >> "$WORK/INFO"
printf 'create_time="%s"\n' "$(date +%Y%m%d-%H:%M:%S)" >> "$WORK/INFO"
printf 'checksum="%s"\n' "$(md5sum "$WORK/package.tgz" | awk '{print $1}')" >> "$WORK/INFO"
SPK="$OUT/synology-amd-gpu-monitor-$VERSION-x86_64.spk"
tar -C "$WORK" -cf "$SPK" INFO package.tgz scripts conf PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
echo "Built $SPK"
