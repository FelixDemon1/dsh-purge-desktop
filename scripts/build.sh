#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
  echo 'This build requires an Apple Silicon Mac.' >&2; exit 1
fi
node -e 'const [major,minor,patch]=process.versions.node.split(".").map(Number); if (!((major===22 && (minor>23 || minor===23 && patch>=4)) || (major===24 && (minor>22 || minor===22 && patch>=1)) || (major===26 && (minor>12 || minor===12 && patch>=1)) || major>26)) { console.error("The build requires Node 22.23.4+, 24.22.1+ or 26.12.1+ in those release lines."); process.exit(1) }'
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/build"
export DSH_BUILD_CACHE="$ROOT/build/download-cache"
TEMP_BUILD="$(mktemp -d "$ROOT/build/dsh-purge-build.XXXXXX")"
trap 'rm -rf "$TEMP_BUILD"' EXIT
mkdir -p "$ROOT/dist" "$TEMP_BUILD/downloads" "$TEMP_BUILD/purge" "$TEMP_BUILD/home/profiles/desktop/pkgs"

mkdir -p "$DSH_BUILD_CACHE/base"
for name in dsh.zip purge.tgz; do
  [[ ! -f "$DSH_BUILD_CACHE/base/$name" ]] || cp "$DSH_BUILD_CACHE/base/$name" "$TEMP_BUILD/downloads/$name"
done
[[ -f "$TEMP_BUILD/downloads/dsh.zip" ]] || curl -fL --retry 3 -o "$TEMP_BUILD/downloads/dsh.zip" 'https://download.deepseek.com/dsh-desk/bin/mac-arm64/deepseek-harness-0.2.1-rc.2-mac-arm64.zip'
[[ -f "$TEMP_BUILD/downloads/purge.tgz" ]] || curl -fL --retry 3 -o "$TEMP_BUILD/downloads/purge.tgz" 'https://github.com/kingcharleslzy-ai/dsh-purge/releases/download/v1.6.88/dsh-purge-community-1.6.88.tgz'
echo '1131da00d7474b5373f3ffc580686b4b009464b68bd35d761c4352824f964604  '"$TEMP_BUILD/downloads/dsh.zip" | shasum -a 256 -c -
echo '4a557104b06c96c4aab1441a1d6b9dc627bfab5938fa1d64cde624de13fec86e  '"$TEMP_BUILD/downloads/purge.tgz" | shasum -a 256 -c -
cp "$TEMP_BUILD/downloads/dsh.zip" "$TEMP_BUILD/downloads/purge.tgz" "$DSH_BUILD_CACHE/base/"
ditto -x -k "$TEMP_BUILD/downloads/dsh.zip" "$TEMP_BUILD/extracted"
APP="$TEMP_BUILD/extracted/DeepSeek Harness.app"
codesign --verify --deep --strict "$APP"
tar -xzf "$TEMP_BUILD/downloads/purge.tgz" -C "$TEMP_BUILD/purge"
cp "$TEMP_BUILD/downloads/purge.tgz" "$TEMP_BUILD/home/profiles/desktop/pkgs/purge.tgz"
cp "$ROOT/profile/package.json" "$ROOT/profile/package-lock.json" "$ROOT/profile/cordis.yml" "$ROOT/profile/cordis.patch.yml" "$TEMP_BUILD/home/profiles/desktop/"
ditto "$ROOT/profile/portable-presets" "$TEMP_BUILD/home/profiles/desktop/pkgs/portable-presets"
(cd "$TEMP_BUILD/home/profiles/desktop" && npm ci --ignore-scripts --no-audit --no-fund --userconfig /dev/null)
node "$ROOT/scripts/assemble.mjs" "$APP" "$TEMP_BUILD/purge/package" "$TEMP_BUILD/home"
node "$ROOT/scripts/configure-presets.mjs" "$APP/Contents/Resources/profile-template" "$TEMP_BUILD/purge/package"
ditto "$ROOT/manager" "$APP/Contents/Resources/profile-template/manager"
bash "$ROOT/scripts/build-tools.sh" "$TEMP_BUILD/tools" "$TEMP_BUILD/tools-build"
bash "$ROOT/scripts/build-redteam.sh" "$TEMP_BUILD/tools/redteam" "$TEMP_BUILD/redteam-build"
ditto "$TEMP_BUILD/tools" "$APP/Contents/Resources/tools"
node "$ROOT/scripts/finish.mjs" "$APP"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier io.github.felixdemon1.dsh-purge-desktop' "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"
mkdir -p "$TEMP_BUILD/DSH-Purge-Desktop-Full"
mv "$APP" "$TEMP_BUILD/DSH-Purge-Desktop-Full/DSH Purge Desktop.app"
cp "$ROOT/manager/start-workbuddy.command" "$TEMP_BUILD/DSH-Purge-Desktop-Full/Start WorkBuddy Manager.command"
cp "$ROOT/README.md" "$TEMP_BUILD/DSH-Purge-Desktop-Full/README.md"
chmod +x "$TEMP_BUILD/DSH-Purge-Desktop-Full/Start WorkBuddy Manager.command"
ditto -c -k --sequesterRsrc --keepParent "$TEMP_BUILD/DSH-Purge-Desktop-Full" "$ROOT/dist/DSH-Purge-Desktop-Full-mac-arm64.zip"
(cd "$ROOT/dist" && shasum -a 256 DSH-Purge-Desktop-Full-mac-arm64.zip > SHA256SUMS-FULL.txt)
echo "Built: $ROOT/dist/DSH-Purge-Desktop-Full-mac-arm64.zip"
