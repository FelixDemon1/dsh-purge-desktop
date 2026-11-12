#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
  echo 'This build requires an Apple Silicon Mac.' >&2; exit 1
fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMP_BUILD="$(mktemp -d "${TMPDIR:-/tmp}/dsh-purge-build.XXXXXX")"
trap 'rm -rf "$TEMP_BUILD"' EXIT
mkdir -p "$ROOT/dist" "$TEMP_BUILD/downloads" "$TEMP_BUILD/purge" "$TEMP_BUILD/home/profiles/desktop/pkgs"

curl -fL --retry 3 -o "$TEMP_BUILD/downloads/dsh.zip" 'https://download.deepseek.com/dsh-desk/bin/mac-arm64/deepseek-harness-0.2.1-rc.2-mac-arm64.zip'
curl -fL --retry 3 -o "$TEMP_BUILD/downloads/purge.tgz" 'https://github.com/kingcharleslzy-ai/dsh-purge/releases/download/v1.6.88/dsh-purge-community-1.6.88.tgz'
echo '1131da00d7474b5373f3ffc580686b4b009464b68bd35d761c4352824f964604  '"$TEMP_BUILD/downloads/dsh.zip" | shasum -a 256 -c -
echo '4a557104b06c96c4aab1441a1d6b9dc627bfab5938fa1d64cde624de13fec86e  '"$TEMP_BUILD/downloads/purge.tgz" | shasum -a 256 -c -
ditto -x -k "$TEMP_BUILD/downloads/dsh.zip" "$TEMP_BUILD/extracted"
APP="$TEMP_BUILD/extracted/DeepSeek Harness.app"
codesign --verify --deep --strict "$APP"
tar -xzf "$TEMP_BUILD/downloads/purge.tgz" -C "$TEMP_BUILD/purge"
cp "$TEMP_BUILD/downloads/purge.tgz" "$TEMP_BUILD/home/profiles/desktop/pkgs/purge.tgz"
cp "$ROOT/profile/"* "$TEMP_BUILD/home/profiles/desktop/"
(cd "$TEMP_BUILD/home/profiles/desktop" && npm ci --ignore-scripts --no-audit --no-fund --userconfig /dev/null)
node "$ROOT/scripts/assemble.mjs" "$APP" "$TEMP_BUILD/purge/package" "$TEMP_BUILD/home"
node "$ROOT/scripts/finish.mjs" "$APP"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier io.github.felixdemon1.dsh-purge-desktop' "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ROOT/dist/DSH-Purge-Desktop-mac-arm64.zip"
(cd "$ROOT/dist" && shasum -a 256 DSH-Purge-Desktop-mac-arm64.zip > SHA256SUMS.txt)
echo "Built: $ROOT/dist/DSH-Purge-Desktop-mac-arm64.zip"
