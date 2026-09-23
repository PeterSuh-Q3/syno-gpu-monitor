#!/bin/sh
set -eu
URL=${1:?URL required}
SHA256=${2:?SHA256 required}
DEST=${3:?destination required}
if [ -f "$DEST" ] && [ "$(shasum -a 256 "$DEST" | awk '{print $1}')" = "$SHA256" ]; then
  exit 0
fi
mkdir -p "$(dirname "$DEST")"
TMP=$(mktemp "${DEST}.XXXXXX")
trap 'rm -f "$TMP"' EXIT HUP INT TERM
curl -fL --retry 3 --connect-timeout 20 -o "$TMP" "$URL"
ACTUAL=$(shasum -a 256 "$TMP" | awk '{print $1}')
if [ "$ACTUAL" != "$SHA256" ]; then
  printf 'Checksum mismatch for %s: expected %s, got %s\n' "$URL" "$SHA256" "$ACTUAL" >&2
  exit 1
fi
mv "$TMP" "$DEST"
