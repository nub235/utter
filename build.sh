#!/bin/bash
set -e

APP_NAME="Utter"
BUILD_DIR="build"
SCHEME="Utter"
CONFIG="Release"

echo "Building $APP_NAME..."
xcodebuild -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build

APP_PATH="$BUILD_DIR/Build/Products/$CONFIG/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/Build/Products/$CONFIG/$APP_NAME.dmg"

echo "Signing..."
codesign --deep --sign - "$APP_PATH"

echo "Setting permissions..."
chmod +x "$APP_PATH/Contents/MacOS/$APP_NAME"

echo "Packaging DMG..."
rm -f "$DMG_PATH"
STAGING_DIR="$BUILD_DIR/dmg-staging"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"
hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"
rm -rf "$STAGING_DIR"

echo "Done: $DMG_PATH"
