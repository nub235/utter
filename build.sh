#!/bin/bash
set -e

APP_NAME="Utter"
BUILD_DIR="build"
SCHEME="Utter"
CONFIG="Debug"

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
ZIP_PATH="$BUILD_DIR/Build/Products/$CONFIG/$APP_NAME.zip"

echo "Signing..."
codesign --deep --sign - "$APP_PATH"

echo "Setting permissions..."
chmod +x "$APP_PATH/Contents/MacOS/$APP_NAME"

echo "Packaging..."
cd "$BUILD_DIR/Build/Products/$CONFIG"
ditto -c -k --sequesterRsrc --keepParent "$APP_NAME.app" "$APP_NAME.zip"
cd -

echo "Done: $ZIP_PATH"
