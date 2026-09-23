#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
IMAGE=${SYNOCOMPILER_IMAGE:-dante90/syno-compiler:7.4}
CC=${SYNOCOMPILER_CC:-/opt/epyc7002/bin/x86_64-pc-linux-gnu-gcc}
WORK="$ROOT/work/synology-amd-gpu-monitor"
OUT="$ROOT/dist"
COMMON="$ROOT/../common/console"
CACHE="$ROOT/work-cache"
rm -rf "$WORK"
mkdir -p "$WORK/target/bin/helper" "$WORK/target/ui/images" "$WORK/scripts/console-runtime/kernel4" "$WORK/scripts/console-runtime/kernel5" "$WORK/conf" "$OUT"
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
"$COMMON/fetch-runtime.sh" 'https://github.com/PeterSuh-Q3/syno-amdgpu-top/releases/download/v0.1.1/syno-amdgpu-top-0.1.1-7.4-x86_64-kernel4.4.x.spk' '65d215c636643f9a22e52f548384ce7d93f79d777c956062761aa7ccaa4a2ec7' "$CACHE/amdgpu-top-kernel4.spk"
"$COMMON/fetch-runtime.sh" 'https://github.com/PeterSuh-Q3/syno-amdgpu-top/releases/download/v0.1.1/syno-amdgpu-top-runtime-0.1.1-x86_64-kernel5.10.55.tar.gz' '1fa9921a440d97c934416770d0f53103e7a6b8f21864c2584feb18fb638f698a' "$CACHE/amdgpu-top-kernel5.tar.gz"
TTYD_SOURCE=${TTYD_SOURCE:-"$ROOT/../../mshell-manager/src/bin/ttyd"}
[ -f "$TTYD_SOURCE" ] || { echo "ttyd missing: set TTYD_SOURCE to the MSHELL Manager binary" >&2; exit 1; }
[ "$(shasum -a 256 "$TTYD_SOURCE" | awk '{print $1}')" = '8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55' ] || { echo "ttyd checksum mismatch" >&2; exit 1; }
tar -xOf "$CACHE/amdgpu-top-kernel4.spk" package.tgz > "$WORK/kernel4-package.tgz"
tar -xzf "$WORK/kernel4-package.tgz" -C "$WORK/scripts/console-runtime/kernel4" ./bin ./lib ./share
tar -xzf "$CACHE/amdgpu-top-kernel5.tar.gz" -C "$WORK" runtime
cp -R "$WORK/runtime/." "$WORK/scripts/console-runtime/kernel5/"
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
SPK="$OUT/synology-amd-gpu-monitor-0.4.3-x86_64.spk"
tar -C "$WORK" -cf "$SPK" INFO package.tgz scripts conf PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
echo "Built $SPK"
