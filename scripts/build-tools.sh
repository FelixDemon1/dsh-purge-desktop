#!/bin/bash
set -euo pipefail

if [[ $# != 2 ]]; then echo 'Usage: build-tools.sh OUTPUT_TOOLS BUILD_TEMP' >&2; exit 1; fi
TOOL_ROOT="$1"
BUILD_TEMP="$2"
mkdir -p "$TOOL_ROOT" "$BUILD_TEMP/downloads"
fetch() {
  if [[ -n "${DSH_BUILD_CACHE:-}" && -f "$DSH_BUILD_CACHE/tools/$1" ]]; then cp "$DSH_BUILD_CACHE/tools/$1" "$BUILD_TEMP/downloads/$1"; return; fi
  curl -fL --retry 3 --retry-all-errors --connect-timeout 30 -o "$BUILD_TEMP/downloads/$1" "$2"
}
check() {
  echo "$2  $BUILD_TEMP/downloads/$1" | shasum -a 256 -c -
  if [[ -n "${DSH_BUILD_CACHE:-}" ]]; then mkdir -p "$DSH_BUILD_CACHE/tools"; cp "$BUILD_TEMP/downloads/$1" "$DSH_BUILD_CACHE/tools/$1"; fi
}

fetch node.tar.xz 'https://nodejs.org/dist/v24.22.2/node-v24.22.2-darwin-arm64.tar.xz'
check node.tar.xz 1f5ac075be50bed4780ea3be19a007fda95ea4d527d28d76d0b91de47d915115
mkdir -p "$TOOL_ROOT/node"
tar -xJf "$BUILD_TEMP/downloads/node.tar.xz" -C "$TOOL_ROOT/node" --strip-components=1
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=1024}"

fetch ghidra.zip 'https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip'
check ghidra.zip ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db
mkdir -p "$BUILD_TEMP/ghidra"
ditto -x -k "$BUILD_TEMP/downloads/ghidra.zip" "$BUILD_TEMP/ghidra"
mv "$BUILD_TEMP/ghidra/ghidra_12.1.4_PUBLIC" "$TOOL_ROOT/ghidra"
DECOMPILER="$TOOL_ROOT/ghidra/Ghidra/Features/Decompiler"
make -C "$DECOMPILER/src/decompile/cpp" -j4 ghidra_opt ARCH_TYPE='-arch arm64' OSDIR=mac_arm_64
mkdir -p "$DECOMPILER/os/mac_arm_64"
install -m 755 "$DECOMPILER/src/decompile/cpp/ghidra_opt" "$DECOMPILER/os/mac_arm_64/decompile"
make -C "$DECOMPILER/src/decompile/cpp" clean >/dev/null 2>&1 || true

fetch jdk.tar.gz 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_aarch64_mac_hotspot_21.0.13_9.tar.gz'
check jdk.tar.gz bf036b35b071bfb2f54f2c0af8ee8d88afa95ee6eb3dce02c0f94cfc2524d04a
mkdir -p "$BUILD_TEMP/jdk"
tar -xzf "$BUILD_TEMP/downloads/jdk.tar.gz" -C "$BUILD_TEMP/jdk"
mv "$BUILD_TEMP/jdk/jdk-21.0.13+9" "$TOOL_ROOT/jdk"

fetch rea-src.tar.gz 'https://codeload.github.com/morluto/rea/tar.gz/317bf3fe235e655b2d752d3be261cc0da7d00f2b'
check rea-src.tar.gz 2870f6dec9e942be091059f197cf9b7bf952d71a73c3270a21a9e93655742fe7
mkdir -p "$BUILD_TEMP/rea-src"
tar -xzf "$BUILD_TEMP/downloads/rea-src.tar.gz" -C "$BUILD_TEMP/rea-src" --strip-components=1
(cd "$BUILD_TEMP/rea-src" && npm ci --ignore-scripts --no-audit --no-fund --maxsockets=4 --userconfig /dev/null --registry https://registry.npmjs.org/ && npm run compile && npm run artifacts:skills && npm pack --ignore-scripts --pack-destination "$BUILD_TEMP")
mkdir -p "$TOOL_ROOT/rea"
npm install --prefix "$TOOL_ROOT/rea" --omit=dev --ignore-scripts --no-audit --no-fund --userconfig /dev/null --registry https://registry.npmjs.org/ "$BUILD_TEMP/rea-agents-6.8.0.tgz"

fetch reverse-src.tar.gz 'https://codeload.github.com/zhaoxuya520/reverse-skill/tar.gz/cab634bd855fc287f6e420c1f36fd1a6b9245960'
check reverse-src.tar.gz 934ec470ce8b96211ca828ecf0fa20bd912956f4dc1b9204d9c6d55b5d3bdd0e
mkdir -p "$TOOL_ROOT/reverse-skill"
tar -xzf "$BUILD_TEMP/downloads/reverse-src.tar.gz" -C "$TOOL_ROOT/reverse-skill" --strip-components=1

fetch craft.zip 'https://github.com/storytold/craft-anything/releases/download/v0.6.1/craft-anything-cli-0.6.1-macos-universal.zip'
check craft.zip ddbae05f52a5526e149f656b0b44cf73a60ad9ec0a33d718f330bf231b988c2f
mkdir -p "$BUILD_TEMP/craft"
ditto -x -k "$BUILD_TEMP/downloads/craft.zip" "$BUILD_TEMP/craft"
mv "$BUILD_TEMP/craft/craft-anything-cli-0.6.1-macos-universal" "$TOOL_ROOT/craft"

docker pull 'ghcr.io/ithtelab/workbuddy-manager@sha256:90cf39e5e249956a08a89c48b8bc65ed7b21bbca4c35e0dbaaec4e00d37c3317'
docker pull 'ghcr.io/ithtelab/workbuddy2api@sha256:3750abff9fd8ed8fc4f255b457891fab3aac6ae85e8eb4b385590b40ca0181bd'
docker tag 'ghcr.io/ithtelab/workbuddy-manager@sha256:90cf39e5e249956a08a89c48b8bc65ed7b21bbca4c35e0dbaaec4e00d37c3317' dsh-purge-desktop/workbuddy-manager:2.11.9
docker tag 'ghcr.io/ithtelab/workbuddy2api@sha256:3750abff9fd8ed8fc4f255b457891fab3aac6ae85e8eb4b385590b40ca0181bd' dsh-purge-desktop/workbuddy2api:2.11.9
docker image save dsh-purge-desktop/workbuddy-manager:2.11.9 dsh-purge-desktop/workbuddy2api:2.11.9 | gzip -1 > "$TOOL_ROOT/workbuddy-images.tar.gz"
