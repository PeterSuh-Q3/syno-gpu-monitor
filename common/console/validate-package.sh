#!/bin/sh
# Static validation for an unpacked SPK work tree. No DSM changes are made.
set -eu
ROOT=${1:-}
[ -d "$ROOT" ] || { echo "unpacked package root is required" >&2; exit 2; }
[ -f "$ROOT/INFO" ] || { echo "INFO missing" >&2; exit 1; }
[ -f "$ROOT/package.tgz" ] || { echo "package.tgz missing" >&2; exit 1; }
[ -f "$ROOT/scripts/postinst" ] || { echo "postinst missing" >&2; exit 1; }
[ -f "$ROOT/scripts/preuninst" ] || { echo "preuninst missing" >&2; exit 1; }
if [ -f "$ROOT/scripts/console-engine" ]; then
  [ -x "$ROOT/scripts/console-runtime/ttyd" ] || { echo "ttyd missing for ttyd console" >&2; exit 1; }
  [ -x "$ROOT/scripts/console-runtime/run-top" ] || { echo "top launcher missing" >&2; exit 1; }
  [ -f "$ROOT/scripts/route.conf" ] || { echo "nginx route missing" >&2; exit 1; }
  grep -q '@TOKEN@' "$ROOT/scripts/route.conf" || { echo "console route lacks per-session token" >&2; exit 1; }
  [ -x "$ROOT/target/ui/console.cgi" ] || { echo "console CGI missing" >&2; exit 1; }
  [ -f "$ROOT/target/ui/gpu-console.js" ] || { echo "shared WebUI controller missing" >&2; exit 1; }
  [ -f "$ROOT/target/ui/gpu-console.css" ] || { echo "shared WebUI stylesheet missing" >&2; exit 1; }
  sh -n "$ROOT/scripts/console-engine" "$ROOT/scripts/console-control" "$ROOT/scripts/console-runtime/run-top" "$ROOT/target/ui/console.cgi"
  if [ -d "$ROOT/scripts/console-runtime/kernel4" ]; then
    [ -x "$ROOT/scripts/console-runtime/kernel4/bin/amdgpu_top" ] || { echo "kernel 4 amdgpu_top missing" >&2; exit 1; }
    [ -x "$ROOT/scripts/console-runtime/kernel5/bin/amdgpu_top" ] || { echo "kernel 5 amdgpu_top missing" >&2; exit 1; }
  elif [ -d "$ROOT/scripts/console-runtime/intel" ]; then
    [ -x "$ROOT/scripts/console-runtime/intel/bin/intel_gpu_top.real" ] || { echo "intel_gpu_top missing" >&2; exit 1; }
  fi
elif [ -f "$ROOT/target/ui/console.cgi" ]; then
  sh -n "$ROOT/target/ui/console.cgi"
fi
sh -n "$ROOT/scripts/postinst" "$ROOT/scripts/preuninst"
echo "PASS: static package lifecycle files are present and syntactically valid"
