#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
IMAGE=${SYNOCOMPILER_IMAGE:-dante90/syno-compiler:7.4}
CC=${SYNOCOMPILER_CC:-/opt/epyc7002/bin/x86_64-pc-linux-gnu-gcc}
PACKAGE=synology-intel-gpu-monitor
VERSION=0.3.1
WORK="$ROOT/work/$PACKAGE"
OUT="$ROOT/dist"
COMMON="$ROOT/../common/console"
CACHE="$ROOT/work-cache"

rm -rf "$WORK"
mkdir -p "$WORK/target/bin/helper" "$WORK/target/ui/images" "$WORK/scripts/console-runtime/intel" "$WORK/conf" "$OUT"
docker run --rm --platform linux/amd64 --entrypoint /bin/bash -u 0 -v "$ROOT:/work" -w /work "$IMAGE" -lc "'$CC' -O2 -s -Wall -Wextra -Werror -o /work/work/$PACKAGE/target/bin/intel-gpu-monitor /work/src/intel-gpu-monitor.c"
docker run --rm --platform linux/amd64 --entrypoint /bin/bash -u 0 -v "$ROOT:/work" -w /work "$IMAGE" -lc "'$CC' -O2 -s -Wall -Wextra -Werror -o /work/work/$PACKAGE/target/bin/helper/intel-gpu-monitor-helper /work/src/intel-gpu-monitor-helper.c"
chmod 0755 "$WORK/target/bin/intel-gpu-monitor"
chmod 0550 "$WORK/target/bin/helper/intel-gpu-monitor-helper"
cp "$ROOT/spk/INFO" "$WORK/INFO"
cp "$ROOT/spk/scripts/"* "$WORK/scripts/"
chmod 0755 "$WORK/scripts/"*
cp "$ROOT/spk/conf/privilege" "$WORK/conf/privilege"
cp "$ROOT/spk/webui/"* "$WORK/target/ui/"
chmod 0755 "$WORK/target/ui/api.cgi" "$WORK/target/ui/console.cgi"
cp "$ROOT/../common/webui/gpu-console.css" "$WORK/target/ui/"
cp "$ROOT/../common/webui/gpu-console.js" "$WORK/target/ui/"
cp "$COMMON/console-control.sh" "$WORK/scripts/console-engine"
sed -e 's|@PACKAGE@|SynoIntelGpuMonitor|g' -e 's|@BASE_PATH@|intel-gpu-console|g' -e 's|@PORT@|17685|g' "$COMMON/route.conf.template" > "$WORK/scripts/route.conf"
mv "$WORK/scripts/run-top" "$WORK/scripts/console-runtime/run-top"
"$COMMON/fetch-runtime.sh" 'https://github.com/PeterSuh-Q3/syno-intel-gpu-top/releases/download/v0.1.2/syno-intel-gpu-top-runtime-0.1.2-x86_64-kernel5.10.55.tar.gz' '98041f2e93ba17f99eabc2c31a6a676dfb59e25fdac87f1651e54f49ac8a5928' "$CACHE/intel-gpu-top.tar.gz"
TTYD_SOURCE=${TTYD_SOURCE:-"$ROOT/../../mshell-manager/src/bin/ttyd"}
[ -f "$TTYD_SOURCE" ] || { echo "ttyd missing: set TTYD_SOURCE to the MSHELL Manager binary" >&2; exit 1; }
[ "$(shasum -a 256 "$TTYD_SOURCE" | awk '{print $1}')" = '8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55' ] || { echo "ttyd checksum mismatch" >&2; exit 1; }
tar -xzf "$CACHE/intel-gpu-top.tar.gz" -C "$WORK" runtime
cp -R "$WORK/runtime/." "$WORK/scripts/console-runtime/intel/"
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
SPK="$OUT/$PACKAGE-$VERSION-x86_64.spk"
tar -C "$WORK" -cf "$SPK" INFO package.tgz scripts conf PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
echo "Built $SPK"
