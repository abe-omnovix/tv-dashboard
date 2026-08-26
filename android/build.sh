#!/bin/bash
# Builds skylight.apk with raw SDK tools — no Gradle needed.
set -euo pipefail
cd "$(dirname "$0")"

SDK=/opt/homebrew/share/android-commandlinetools
BT="$SDK/build-tools/34.0.0"
PLATFORM="$SDK/platforms/android-34/android.jar"
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

OUT=build
rm -rf "$OUT"
mkdir -p "$OUT/classes"

# 1. Assemble assets: shared web page, with Google Fonts links swapped
#    for the TTFs bundled in assets/fonts/.
python3 - <<'PY'
import re
src = open("../index.html").read()
fontface = """<style>
@font-face { font-family: 'Cormorant Garamond'; src: url('fonts/CormorantGaramond.ttf'); font-weight: 300 700; font-style: normal; }
@font-face { font-family: 'Cormorant Garamond'; src: url('fonts/CormorantGaramond-Italic.ttf'); font-weight: 300 700; font-style: italic; }
@font-face { font-family: 'Outfit'; src: url('fonts/Outfit.ttf'); font-weight: 100 900; font-style: normal; }
</style>"""
out = re.sub(r"<!-- webfonts:start -->.*?<!-- webfonts:end -->", fontface, src, flags=re.S)
assert out != src, "webfonts markers not found in ../index.html"
open("app/src/main/assets/index.html", "w").write(out)
print("assets/index.html assembled (local fonts)")
PY

# 1b. Bake secrets into the APK as config.json (local-only file; gitignored)
if [ -f secrets.json ]; then
  cp secrets.json app/src/main/assets/config.json
  echo "config.json baked from secrets.json"
else
  rm -f app/src/main/assets/config.json
fi

# 2. Link manifest + assets into a resource-only APK
"$BT/aapt2" link -o "$OUT/base.apk" \
  --manifest app/src/main/AndroidManifest.xml \
  -I "$PLATFORM" \
  -A app/src/main/assets \
  --min-sdk-version 26 --target-sdk-version 34

# 3. Compile the service and dex it
"$JAVA_HOME/bin/javac" --release 8 -classpath "$PLATFORM" \
  -d "$OUT/classes" $(find app/src/main/java -name "*.java")
"$BT/d8" --lib "$PLATFORM" --release --output "$OUT" \
  $(find "$OUT/classes" -name "*.class")

# 4. Add classes.dex, align, sign (throwaway self-signed key)
(cd "$OUT" && zip -q -j base.apk classes.dex)
"$BT/zipalign" -f 4 "$OUT/base.apk" "$OUT/aligned.apk"
if [ ! -f keystore.jks ]; then
  "$JAVA_HOME/bin/keytool" -genkeypair -keystore keystore.jks -alias skylight \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass skylight -keypass skylight -dname "CN=Skylight"
fi
"$BT/apksigner" sign --ks keystore.jks --ks-pass pass:skylight \
  --key-pass pass:skylight --out "$OUT/skylight.apk" "$OUT/aligned.apk"

echo "Built $OUT/skylight.apk"
