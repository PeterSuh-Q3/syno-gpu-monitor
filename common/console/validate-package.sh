#!/bin/sh
# Static validation for an unpacked SPK work tree. No DSM changes are made.
set -eu
ROOT=${1:-}
[ -d "$ROOT" ] || { echo "unpacked package root is required" >&2; exit 2; }
[ -f "$ROOT/INFO" ] || { echo "INFO missing" >&2; exit 1; }
[ -f "$ROOT/package.tgz" ] || { echo "package.tgz missing" >&2; exit 1; }
[ -f "$ROOT/scripts/postinst" ] || { echo "postinst missing" >&2; exit 1; }
[ -f "$ROOT/scripts/preuninst" ] || { echo "preuninst missing" >&2; exit 1; }
[ -x "$ROOT/target/console/console-control.sh" ] || { echo "console controller missing" >&2; exit 1; }
[ -x "$ROOT/target/bin/ttyd" ] || { echo "ttyd missing" >&2; exit 1; }
[ -f "$ROOT/target/ui/gpu-console.js" ] || { echo "shared WebUI controller missing" >&2; exit 1; }
[ -f "$ROOT/target/ui/gpu-console.css" ] || { echo "shared WebUI stylesheet missing" >&2; exit 1; }
sh -n "$ROOT/scripts/postinst" "$ROOT/scripts/preuninst" "$ROOT/target/console/console-control.sh"
echo "PASS: static package lifecycle files are present and syntactically valid"
