#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
mkdir -p "$ROOT/dist"
cc=${CC:-cc}
"$cc" -O2 -Wall -Wextra -Werror -o "$ROOT/dist/amd-gpu-monitor" "$ROOT/src/amd-gpu-monitor.c"
echo "Built $ROOT/dist/amd-gpu-monitor"
