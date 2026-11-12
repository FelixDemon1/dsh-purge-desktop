#!/bin/bash
set -euo pipefail
if [[ $# != 2 ]]; then echo 'Usage: build-redteam.sh OUTPUT BUILD_TEMP' >&2; exit 1; fi
OUT="$1"
TMP="$2"
export MACOSX_DEPLOYMENT_TARGET=13.5
mkdir -p "$OUT/bin" "$OUT/licenses" "$TMP/downloads" "$TMP/extracted"
fetch() {
  local name="$1" hash="$2" url="$3"
  if [[ -f "$TMP/downloads/$name" ]] && echo "$hash  $TMP/downloads/$name" | shasum -a 256 -c - >/dev/null 2>&1; then return; fi
  if [[ -n "${DSH_BUILD_CACHE:-}" && -f "$DSH_BUILD_CACHE/redteam/$name" ]] && echo "$hash  $DSH_BUILD_CACHE/redteam/$name" | shasum -a 256 -c - >/dev/null 2>&1; then cp "$DSH_BUILD_CACHE/redteam/$name" "$TMP/downloads/$name"; return; fi
  curl -fsSL --retry 3 --retry-all-errors --connect-timeout 30 -o "$TMP/downloads/$name" "$url"
  echo "$hash  $TMP/downloads/$name" | shasum -a 256 -c -
  if [[ -n "${DSH_BUILD_CACHE:-}" ]]; then mkdir -p "$DSH_BUILD_CACHE/redteam"; cp "$TMP/downloads/$name" "$DSH_BUILD_CACHE/redteam/$name"; fi
}
fetch nuclei.zip 7d7e291addd1fc29a9bf8d089afe878a9799b20229cbea2fb1693fc40fd4c5f0 https://github.com/projectdiscovery/nuclei/releases/download/v3.11.1/nuclei_3.11.1_macOS_arm64.zip
fetch httpx.zip 21d60328b383dba8a9fe249ac76b12edda4ec2e52a9cb21876c0a79123675569 https://github.com/projectdiscovery/httpx/releases/download/v1.12.0/httpx_1.12.0_macOS_arm64.zip
fetch dnsx.zip 6b1681e4168cf6175facea723e16fca4ca2f99c3f9f83dea8c2b79ed20a3f417 https://github.com/projectdiscovery/dnsx/releases/download/v1.3.1/dnsx_1.3.1_macOS_arm64.zip
fetch subfinder.zip af55827c9e6cdc530cca377ad459214ead16daf1b79d90e3dcefa387f644e057 https://github.com/projectdiscovery/subfinder/releases/download/v2.16.0/subfinder_2.16.0_macOS_arm64.zip
fetch ffuf.tgz 891e6358f7c72c951ce6fcef82a3736e91b34034e95edbd305505c9d31cfff13 https://github.com/ffuf/ffuf/releases/download/v2.3.0/ffuf_2.3.0_macOS_arm64.tar.gz
fetch frp.tgz 45be02b186860d375ed49a8941ae9569628a54bf14e67fc36b29c98c99dabcc6 https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_darwin_arm64.tar.gz
fetch fscan eca58aa1c1fe7fc43e48478a907be40f1b8627c39674a0365c2aa67b83377418 https://github.com/shadow1ng/fscan/releases/download/v2.2.2/fscan_2.2.2_mac_arm64
fetch gogo 1f705ca1065191c5bdfbadf5722e69c85a6640a45de67a83e4fb6f1b9064cdca https://github.com/chainreactors/gogo/releases/download/v2.15.0/gogo_darwin_arm64
fetch suo5 f5681a08ed2a5bbe8223584f3b827a09cf65878864685b862120dd010961a9f4 https://github.com/zema1/suo5/releases/download/v2.2.0/suo5-darwin-arm64
fetch chisel.gz 707a4b932eea214765146504a0df246cefc415b4297af65a80dd67cf69ba85a9 https://github.com/jpillora/chisel/releases/download/v1.12.0/chisel_1.12.0_darwin_arm64.gz
fetch ksubdomain.zip ef63157ee3401360d45bf361ab76b640327a04fc8fc719c8d27de4721745b523 https://github.com/boy-hack/ksubdomain/releases/download/v2.4.0/KSubdomain-v2.4.0-darwin-arm64.zip
fetch templates.tgz b45cdd0ee5ed7482bf0b3e9d93b81f4a110bb557a5f50cd010c7e2305617953e https://codeload.github.com/projectdiscovery/nuclei-templates/tar.gz/13f9bc679405927b7f78eb5dfd3e7260ed3d40f3
fetch nmap.tar.bz2 270e55f04915bfcecb5db8feb959d4c5ba86a48c094520a4f1c07571e1c79c59 https://nmap.org/dist/nmap-7.993.tar.bz2
fetch openssl.tgz c5524dd6bfaa8e8ff0f1be885c390d14f3ff0bd2de62a7311b65fcbb75cb7546 https://codeload.github.com/openssl/openssl/tar.gz/refs/tags/openssl-3.6.3
fetch masscan.tgz 0363e82c07e6ceee68a2da48acd0b2807391ead9a396cf9c70b53a2a901e3d5f https://codeload.github.com/robertdavidgraham/masscan/tar.gz/refs/tags/1.3.2
fetch python.tgz e956e60bc9465d577ef8062059aa05cd3a2665b4b8678a2ed24e432368330b8f 'https://github.com/astral-sh/python-build-standalone/releases/download/20261110/cpython-3.12.16%2B20261110-aarch64-apple-darwin-install_only.tar.gz'
fetch gogo-source.tgz 384a9da4f2fcf041a1e550a426e7cfb1f9826a3150504f504abb8f431069edca https://codeload.github.com/chainreactors/gogo/tar.gz/refs/tags/v2.15.0
fetch fscan-license 9e9a6cba6e93bb83c334d47b92861615b5be438e1076644ff64e7b0f35100379 https://raw.githubusercontent.com/shadow1ng/fscan/v2.2.2/LICENSE.txt
fetch gogo-license 230184f60bae2feaf244f10a8bac053c8ff33a183bcc365b4d8b876d2b7f4809 https://raw.githubusercontent.com/chainreactors/gogo/v2.15.0/LICENSE
fetch suo5-license 5b7811ea5434fa0d6af9cd9e40d54f91d28bf52cb208a3c553695439722a736d https://raw.githubusercontent.com/zema1/suo5/v2.2.0/LICENSE
fetch chisel-license 445b61eeea1445c155ad63e1c47b1abfa80a922f2f133577f19c12bf9582c0ff https://raw.githubusercontent.com/jpillora/chisel/v1.12.0/LICENSE
fetch ksubdomain-license 6655a54cfddbebca3e9cdf80720ffb482f39b5e70379d3ea1691746ab60fc67d https://raw.githubusercontent.com/boy-hack/ksubdomain/v2.4.0/LICENSE
for name in nuclei httpx dnsx subfinder; do
  mkdir -p "$TMP/extracted/$name"
  unzip -q "$TMP/downloads/$name.zip" -d "$TMP/extracted/$name"
  install -m 755 "$TMP/extracted/$name/$name" "$OUT/bin/$name"
  cp "$TMP/extracted/$name/LICENSE.md" "$OUT/licenses/$name-LICENSE"
done
mkdir -p "$TMP/extracted/ffuf" "$TMP/extracted/frp"
tar -xzf "$TMP/downloads/ffuf.tgz" -C "$TMP/extracted/ffuf"
tar -xzf "$TMP/downloads/frp.tgz" -C "$TMP/extracted/frp" --strip-components=1
install -m 755 "$TMP/extracted/ffuf/ffuf" "$OUT/bin/ffuf"
cp "$TMP/extracted/ffuf/LICENSE" "$OUT/licenses/ffuf-LICENSE"
for name in frpc frps; do install -m 755 "$TMP/extracted/frp/$name" "$OUT/bin/$name"; done
cp "$TMP/extracted/frp/LICENSE" "$OUT/licenses/frp-LICENSE"
for name in fscan gogo suo5; do install -m 755 "$TMP/downloads/$name" "$OUT/bin/$name"; done
gzip -dc "$TMP/downloads/chisel.gz" > "$OUT/bin/chisel"
unzip -p "$TMP/downloads/ksubdomain.zip" ksubdomain > "$OUT/bin/ksubdomain"
chmod 755 "$OUT/bin/chisel" "$OUT/bin/ksubdomain"
for name in fscan gogo suo5 chisel ksubdomain; do cp "$TMP/downloads/$name-license" "$OUT/licenses/$name-LICENSE"; done
cp "$TMP/downloads/gogo-source.tgz" "$OUT/licenses/gogo-source.tgz"
mkdir -p "$OUT/nuclei-templates"
tar -xzf "$TMP/downloads/templates.tgz" -C "$OUT/nuclei-templates" --strip-components=1
mkdir -p "$TMP/extracted/masscan"
tar -xzf "$TMP/downloads/masscan.tgz" -C "$TMP/extracted/masscan" --strip-components=1
make -C "$TMP/extracted/masscan" -j4
install -m 755 "$TMP/extracted/masscan/bin/masscan" "$OUT/bin/masscan"
strip -S -x "$OUT/bin/masscan"
codesign --force --sign - "$OUT/bin/masscan"
cp "$TMP/extracted/masscan/LICENSE" "$OUT/licenses/masscan-LICENSE"
mkdir -p "$TMP/extracted/nmap"
tar -xjf "$TMP/downloads/nmap.tar.bz2" -C "$TMP/extracted/nmap" --strip-components=1
mkdir -p "$TMP/extracted/openssl"
tar -xzf "$TMP/downloads/openssl.tgz" -C "$TMP/extracted/openssl" --strip-components=1
OPENSSL_PREFIX="$TMP/openssl-stage/usr/local"
(cd "$TMP/extracted/openssl" && ./Configure darwin64-arm64-cc no-shared no-tests --prefix=/usr/local --openssldir=/etc/ssl && make -j4 && make install_sw DESTDIR="$TMP/openssl-stage")
(cd "$TMP/extracted/nmap" && ./configure --prefix=/usr/local --without-zenmap --with-openssl="$OPENSSL_PREFIX" --with-libssh2=included && make -j4 && make install DESTDIR="$TMP/nmap-stage")
mv "$TMP/nmap-stage/usr/local" "$OUT/nmap"
for binary in nmap ncat nping; do codesign --force --sign - "$OUT/nmap/bin/$binary"; done
cp "$TMP/downloads/nmap.tar.bz2" "$OUT/licenses/nmap-source.tar.bz2"
cp "$TMP/extracted/openssl/LICENSE.txt" "$OUT/licenses/openssl-LICENSE"
cat > "$OUT/bin/nmap" <<'WRAPPER'
#!/bin/bash
HERE="$(cd "$(dirname "$0")/.." && pwd)"
export NMAPDIR="$HERE/nmap/share/nmap"
exec "$HERE/nmap/bin/nmap" "$@"
WRAPPER
chmod 755 "$OUT/bin/nmap"
mkdir -p "$OUT/python"
tar -xzf "$TMP/downloads/python.tgz" -C "$OUT/python" --strip-components=1
"$OUT/python/bin/python3" -m pip --isolated install --index-url https://pypi.org/simple --no-cache-dir --disable-pip-version-check -r "$(dirname "$0")/redteam-requirements.txt"
"$OUT/python/bin/python3" - "$OUT/python/bin" <<'PY'
from pathlib import Path
import sys
for path in Path(sys.argv[1]).iterdir():
    if not path.is_file() or path.is_symlink():
        continue
    data = path.read_bytes()
    line, separator, rest = data.partition(b'\n')
    if separator and line.startswith(b'#!') and b'/python' in line and b'/bin/python' in line:
        path.write_bytes(b'#!/usr/bin/env python3\n' + rest)
PY
find "$OUT/python" -type f -name '*.pyc' -delete
cat > "$OUT/bin/secretsdump.py" <<'WRAPPER'
#!/bin/bash
HERE="$(cd "$(dirname "$0")/.." && pwd)"
export PYTHONDONTWRITEBYTECODE=1
exec "$HERE/python/bin/python3" "$HERE/python/bin/secretsdump.py" "$@"
WRAPPER
chmod 755 "$OUT/bin/secretsdump.py"
