#!/bin/sh
# Install a pinned central GPU Top archive after checking its embedded manifest.
set -eu

ARCHIVE=${1:?archive required}
PACKAGE=${2:?package required}
VERSION=${3:?version required}
DEST=${4:?destination required}
EXECUTABLE=${5:?executable required}

command -v jq >/dev/null 2>&1 || { echo 'jq is required to verify the runtime manifest' >&2; exit 1; }
TEMP=$(mktemp -d)
trap 'rm -rf "$TEMP"' EXIT HUP INT TERM
tar -xzf "$ARCHIVE" -C "$TEMP" manifest.json runtime
MANIFEST="$TEMP/manifest.json"

jq -e --arg package "$PACKAGE" --arg version "$VERSION" '
  .package == $package and .version == $version and .architecture == "x86_64" and
  (.files | type == "array") and
  ([.files[] | select(.sha256 != null)] | length > 0) and
  all(.files[] | select(.sha256 != null); .sha256 | test("^[a-f0-9]{64}$"))
' "$MANIFEST" >/dev/null || {
  echo "Unexpected or incomplete runtime manifest in $ARCHIVE" >&2
  exit 1
}

jq -r '.files[] | select(.sha256 != null) | [.path, .sha256] | @tsv' "$MANIFEST" |
while IFS="$(printf '\t')" read -r rel expected; do
  case "$rel" in ''|/*|..|../*|*/../*|*/..) echo "Unsafe manifest path: $rel" >&2; exit 1 ;; esac
  file="$TEMP/runtime/$rel"
  [ -f "$file" ] && [ ! -L "$file" ] || { echo "Missing runtime file: $rel" >&2; exit 1; }
  actual=$(shasum -a 256 "$file" | awk '{print $1}')
  [ "$actual" = "$expected" ] || { echo "Runtime file checksum mismatch: $rel" >&2; exit 1; }
done

jq -r '.files[] | select(.type == "symlink") | [.path, .target] | @tsv' "$MANIFEST" |
while IFS="$(printf '\t')" read -r rel target; do
  case "$rel" in ''|/*|..|../*|*/../*|*/..) echo "Unsafe symlink path: $rel" >&2; exit 1 ;; esac
  [ -L "$TEMP/runtime/$rel" ] && [ "$(readlink "$TEMP/runtime/$rel")" = "$target" ] || {
    echo "Runtime symlink mismatch: $rel" >&2
    exit 1
  }
done

[ -x "$TEMP/runtime/$EXECUTABLE" ] || { echo "Runtime executable missing: $EXECUTABLE" >&2; exit 1; }
mkdir -p "$DEST"
cp -R "$TEMP/runtime/." "$DEST/"
cp "$MANIFEST" "$DEST/manifest.json"
