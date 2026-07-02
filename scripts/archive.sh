#!/bin/bash
set -euo pipefail

VERSION="${1:-1.0.0}"
CONFIGURATION="${2:-Release}"
BUILD_CONFIGURATION="$(printf "%s" "$CONFIGURATION" | tr '[:upper:]' '[:lower:]')"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/$BUILD_CONFIGURATION"
APP_DIR="$ROOT_DIR/BooBoo.app"
DIST_DIR="$ROOT_DIR/dist"
DMG_PATH="$ROOT_DIR/BooBoo.dmg"
VERSIONED_DMG_PATH="$ROOT_DIR/BooBoo-$VERSION.dmg"

swift build -c "$BUILD_CONFIGURATION" --product BooBooGUI
swift build -c "$BUILD_CONFIGURATION" --product booboo

rm -rf "$APP_DIR" "$DIST_DIR/BooBoo.app"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" "$DIST_DIR"

cp "$BUILD_DIR/BooBooGUI" "$APP_DIR/Contents/MacOS/BooBooGUI"
cp "$BUILD_DIR/booboo" "$DIST_DIR/booboo"
cp -R "$ROOT_DIR/rules" "$APP_DIR/Contents/Resources/rules"
chmod +x "$APP_DIR/Contents/MacOS/BooBooGUI" "$DIST_DIR/booboo"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BooBooGUI</string>
    <key>CFBundleIdentifier</key>
    <string>com.sgkrishna.booboo</string>
    <key>CFBundleName</key>
    <string>BooBoo</string>
    <key>CFBundleDisplayName</key>
    <string>BooBoo</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>MIT License</string>
</dict>
</plist>
PLIST

/usr/bin/codesign --force --deep --sign - "$APP_DIR" >/dev/null
cp -R "$APP_DIR" "$DIST_DIR/BooBoo.app"

rm -f "$DMG_PATH" "$VERSIONED_DMG_PATH"
hdiutil create -volname "BooBoo" -srcfolder "$APP_DIR" -ov -format UDZO "$DMG_PATH" >/dev/null
cp "$DMG_PATH" "$VERSIONED_DMG_PATH"

echo "Archived $APP_DIR"
echo "Created $DMG_PATH"
echo "Created $VERSIONED_DMG_PATH"
