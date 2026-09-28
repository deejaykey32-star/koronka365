#!/usr/bin/env bash
# Buduje natywną aplikację Android (APK) z katalogu public/ przy pomocy Capacitor.
# Wynik: public/download/milosierdzie.apk (podpięty pod przycisk „Pobierz aplikację natywną (APK)”).
# Wymaga: Node.js 22+, JDK 21, Android SDK (ANDROID_HOME) – w GitHub Actions są na ubuntu-latest.
# Podpis: jeśli ustawione są ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS,
# ANDROID_KEY_PASSWORD – wersja release podpisana Twoim kluczem; inaczej wersja debug (klucz tymczasowy).
set -euo pipefail
cd "$(dirname "$0")"
ROOT=..
OUT="$ROOT/public/download/milosierdzie.apk"
APP_VERSION=$(grep -oP 'const APP_VERSION = "\K[^"]+' "$ROOT/public/index.html")
VERSION_CODE="${VERSION_CODE:-${GITHUB_RUN_NUMBER:-1}}"

echo "== Capacitor: zależności"
npm ci --no-audit --no-fund 2>/dev/null || npm install --no-audit --no-fund

echo "== Pliki aplikacji (www) z public/"
rm -rf www && mkdir www
cp -r "$ROOT/public/." www/
rm -rf www/download www/_headers www/sw.js
cp node_modules/@capacitor/core/dist/capacitor.js www/capacitor.js
# most Capacitor ładowany tylko w wersji natywnej, przed skryptem aplikacji
sed -i 's#<script>#<script src="capacitor.js"></script>\n<script>#' www/index.html

echo "== Projekt Android"
[ -d android ] || npx cap add android
npx cap sync android

RES=android/app/src/main/res
# ikona aplikacji zamiast logo Capacitor
for d in "$RES"/mipmap-*dpi; do
  cp "$ROOT/public/icon-192.png" "$d/ic_launcher.png"
  cp "$ROOT/public/icon-192.png" "$d/ic_launcher_round.png"
  cp "$ROOT/public/icon-192.png" "$d/ic_launcher_foreground.png"
done
rm -rf "$RES/mipmap-anydpi-v26"
# ekran startowy: jednolity kolor tła obrazu (#1f1718) zamiast logo Capacitor
node -e '
const zlib=require("zlib"),fs=require("fs");
const crc=b=>{let c=~0;for(const x of b){c^=x;for(let k=0;k<8;k++)c=(c>>>1)^(0xEDB88320&-(c&1));}return ~c>>>0;};
const chunk=(t,d)=>{const l=Buffer.alloc(4);l.writeUInt32BE(d.length);const td=Buffer.concat([Buffer.from(t),d]);const c=Buffer.alloc(4);c.writeUInt32BE(crc(td));return Buffer.concat([l,td,c]);};
const ihdr=Buffer.alloc(13);ihdr.writeUInt32BE(1,0);ihdr.writeUInt32BE(1,4);ihdr[8]=8;ihdr[9]=2;
const png=Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk("IHDR",ihdr),chunk("IDAT",zlib.deflateSync(Buffer.from([0,0x1f,0x17,0x18]))),chunk("IEND",Buffer.alloc(0))]);
for(const f of process.argv.slice(1)) fs.writeFileSync(f,png);
' $(find "$RES" -name 'splash.png')

# wersja aplikacji = APP_VERSION z index.html
GRADLE=android/app/build.gradle
sed -i -E "s/versionCode [0-9]+/versionCode $VERSION_CODE/; s/versionName \"[^\"]*\"/versionName \"$APP_VERSION\"/" "$GRADLE"

echo "== Kompilacja APK (wersja $APP_VERSION, kod $VERSION_CODE)"
cd android
chmod +x gradlew
if [ -n "${ANDROID_KEYSTORE_BASE64:-}" ]; then
  KS="$PWD/release.keystore"
  echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > "$KS"
  ./gradlew --no-daemon assembleRelease \
    -Pandroid.injected.signing.store.file="$KS" \
    -Pandroid.injected.signing.store.password="$ANDROID_KEYSTORE_PASSWORD" \
    -Pandroid.injected.signing.key.alias="$ANDROID_KEY_ALIAS" \
    -Pandroid.injected.signing.key.password="$ANDROID_KEY_PASSWORD"
  rm -f "$KS"
  APK=app/build/outputs/apk/release/app-release.apk
else
  echo "UWAGA: brak klucza podpisu – buduję wersję debug. Aktualizacja wymaga wtedy odinstalowania poprzedniej."
  ./gradlew --no-daemon assembleDebug
  APK=app/build/outputs/apk/debug/app-debug.apk
fi
cd ..
mkdir -p "$(dirname "$OUT")"
cp "android/$APK" "$OUT"
ls -lh "$OUT"
