#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Offline LAN Games Helper"
BUNDLE_ID="com.kiwiliu.offlinelanhelper"
DIST_DIR="dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"

echo "Building $APP_NAME for macOS..."

rm -rf "$DIST_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

echo "Running swift build..."
swift build -c release

BIN_DIR="$(swift build -c release --show-bin-path)"

EXECUTABLE=""

if [ -x "$BIN_DIR/OfflineLANHelperMac" ]; then
  EXECUTABLE="$BIN_DIR/OfflineLANHelperMac"
else
  EXECUTABLE="$(find "$BIN_DIR" -maxdepth 1 -type f -perm -111 | head -n 1 || true)"
fi

if [ -z "$EXECUTABLE" ]; then
  echo "Error: could not find built executable in $BIN_DIR"
  exit 1
fi

echo "Using executable: $EXECUTABLE"

cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/OfflineLANHelperMac"
chmod +x "$APP_DIR/Contents/MacOS/OfflineLANHelperMac"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleVersion</key>
  <string>1.0.0</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleExecutable</key>
  <string>OfflineLANHelperMac</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

for file in games.json README.md PRIVACY.md LICENSE; do
  if [ -f "$file" ]; then
    cp "$file" "$APP_DIR/Contents/Resources/$file"
  fi
done

if [ -d "assets" ]; then
  cp -R assets "$APP_DIR/Contents/Resources/assets"
fi

if command -v codesign >/dev/null 2>&1; then
  echo "Applying ad-hoc codesign..."
  codesign --force --deep --sign - "$APP_DIR" || true
fi

if command -v hdiutil >/dev/null 2>&1; then
  echo "Creating DMG..."
  hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$APP_DIR" \
    -ov \
    -format UDZO \
    "$DIST_DIR/$APP_NAME.dmg"
fi

echo "Done."
echo "App: $APP_DIR"
echo "DMG: $DIST_DIR/$APP_NAME.dmg"
