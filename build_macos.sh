#!/usr/bin/env bash
set -euo pipefail
<<<<<<< HEAD
swift build -c release
mkdir -p dist
cp -R .build/release/OfflineLANHelperMac dist/OfflineLANHelperMac
=======

ROOT="$(cd "$(dirname "$0")" && pwd)"
SWIFT_PROJECT="$ROOT/OfflineLANHelperMac"
DIST="$ROOT/dist"
APP_NAME="Offline LAN Games Helper"
APP_BUNDLE="$DIST/$APP_NAME.app"
DMG_PATH="$DIST/$APP_NAME.dmg"
EXECUTABLE_NAME="OfflineLANHelperMac"

if ! command -v swift >/dev/null 2>&1; then
  echo "Swift toolchain not found."
  echo "This packaging script is for the maintainer/developer on macOS."
  echo "End users do not need Swift, Xcode, Python, Homebrew, pip, or PyInstaller."
  echo "Build the release on macOS with Xcode or the Swift toolchain, then distribute the .app or .dmg from dist."
  exit 1
fi

if [ ! -f "$SWIFT_PROJECT/Package.swift" ]; then
  echo "Missing Swift package: $SWIFT_PROJECT/Package.swift"
  exit 1
fi

cd "$SWIFT_PROJECT"
cp "$ROOT/games.json" "$SWIFT_PROJECT/Sources/OfflineLANHelperMac/Resources/games.json"
swift build -c release

rm -rf "$APP_BUNDLE" "$DMG_PATH"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
mkdir -p "$DIST"

cp "$SWIFT_PROJECT/.build/release/$EXECUTABLE_NAME" "$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"
cp "$SWIFT_PROJECT/Packaging/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

cp "$ROOT/assets/offline_lan_helper.icns" "$APP_BUNDLE/Contents/Resources/offline_lan_helper.icns"
cp "$ROOT/assets/kiwi_logo.png" "$APP_BUNDLE/Contents/Resources/kiwi_logo.png"
cp "$ROOT/assets/offline_lan_helper.png" "$APP_BUNDLE/Contents/Resources/offline_lan_helper.png"
cp "$ROOT/games.json" "$APP_BUNDLE/Contents/Resources/games.json"
cp "$ROOT/README.md" "$APP_BUNDLE/Contents/Resources/README.md"
cp "$ROOT/PRIVACY.md" "$APP_BUNDLE/Contents/Resources/PRIVACY.md"
cp "$ROOT/LICENSE" "$APP_BUNDLE/Contents/Resources/LICENSE"

if [ -d "$SWIFT_PROJECT/.build/release/${EXECUTABLE_NAME}_${EXECUTABLE_NAME}.resources" ]; then
  cp -R "$SWIFT_PROJECT/.build/release/${EXECUTABLE_NAME}_${EXECUTABLE_NAME}.resources" "$APP_BUNDLE/Contents/Resources/"
fi
if [ -d "$SWIFT_PROJECT/.build/release/${EXECUTABLE_NAME}_${EXECUTABLE_NAME}.bundle" ]; then
  cp -R "$SWIFT_PROJECT/.build/release/${EXECUTABLE_NAME}_${EXECUTABLE_NAME}.bundle" "$APP_BUNDLE/Contents/Resources/"
fi

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_BUNDLE"
fi

if command -v hdiutil >/dev/null 2>&1; then
  STAGING="$(mktemp -d)"
  cp -R "$APP_BUNDLE" "$STAGING/"
  hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "$DMG_PATH"
  rm -rf "$STAGING"
fi

echo
echo "Native macOS app build complete."
echo "App bundle: $APP_BUNDLE"
if [ -f "$DMG_PATH" ]; then
  echo "DMG: $DMG_PATH"
else
  echo "DMG was not created because hdiutil was not available."
fi
echo
echo "End users only need the .app or .dmg. They do not need Python, Homebrew, pip, PyInstaller, Xcode, or terminal commands."
>>>>>>> 9532c1b66abdcb1517e6078f0b87f7ed28af5c30
