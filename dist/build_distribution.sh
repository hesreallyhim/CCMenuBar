#!/bin/bash

# Build script for CCMenuBar - Creates multiple distribution formats
# Usage: ./build_distribution.sh

set -e

# Configuration
APP_NAME="CCMenuBar"
VERSION="1.0.0"
IDENTIFIER="com.claude.ccmenubar"
DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"  # Update this

# Paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"
DIST_DIR="$SCRIPT_DIR/dist"
RELEASE_DIR="$SCRIPT_DIR/release"

# Create directories
mkdir -p "$BUILD_DIR" "$DIST_DIR" "$RELEASE_DIR"

echo "🔨 Building CCMenuBar Distribution Packages v$VERSION"
echo "================================================"

# 1. Build the macOS Application
build_app() {
    echo "📱 Building macOS Application..."
    
    # Compile AppleScript to .app
    osacompile -o "$BUILD_DIR/$APP_NAME.app" "$SCRIPT_DIR/CCMenuBar_Enhanced.scpt"
    
    # Set app properties
    defaults write "$BUILD_DIR/$APP_NAME.app/Contents/Info.plist" CFBundleIdentifier "$IDENTIFIER"
    defaults write "$BUILD_DIR/$APP_NAME.app/Contents/Info.plist" CFBundleVersion "$VERSION"
    defaults write "$BUILD_DIR/$APP_NAME.app/Contents/Info.plist" CFBundleShortVersionString "$VERSION"
    defaults write "$BUILD_DIR/$APP_NAME.app/Contents/Info.plist" LSUIElement -bool true
    defaults write "$BUILD_DIR/$APP_NAME.app/Contents/Info.plist" LSApplicationCategoryType "public.app-category.developer-tools"
    
    # Copy icon
    cp "$SCRIPT_DIR/claude_logo.png" "$BUILD_DIR/$APP_NAME.app/Contents/Resources/" 2>/dev/null || true
    
    # Copy icon as .icns if available
    if [ -f "$SCRIPT_DIR/claude_logo.icns" ]; then
        cp "$SCRIPT_DIR/claude_logo.icns" "$BUILD_DIR/$APP_NAME.app/Contents/Resources/AppIcon.icns"
        defaults write "$BUILD_DIR/$APP_NAME.app/Contents/Info.plist" CFBundleIconFile "AppIcon"
    fi
    
    echo "  ✓ Application built"
}

# 2. Create DMG installer
create_dmg() {
    echo "💿 Creating DMG installer..."
    
    DMG_NAME="$RELEASE_DIR/$APP_NAME-$VERSION.dmg"
    
    # Create temporary DMG directory
    DMG_DIR="$BUILD_DIR/dmg"
    mkdir -p "$DMG_DIR"
    
    # Copy app
    cp -R "$BUILD_DIR/$APP_NAME.app" "$DMG_DIR/"
    
    # Create symbolic link to Applications
    ln -s /Applications "$DMG_DIR/Applications"
    
    # Copy additional files
    cp "$SCRIPT_DIR/README.md" "$DMG_DIR/" 2>/dev/null || true
    cp "$SCRIPT_DIR/ccmenubar_enhanced" "$DMG_DIR/ccmenubar-cli" 2>/dev/null || true
    
    # Create DMG
    hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_NAME"
    
    echo "  ✓ DMG created: $DMG_NAME"
}

# 3. Create PKG installer
create_pkg() {
    echo "📦 Creating PKG installer..."
    
    PKG_NAME="$RELEASE_DIR/$APP_NAME-$VERSION.pkg"
    PKG_ROOT="$BUILD_DIR/pkg-root"
    PKG_SCRIPTS="$BUILD_DIR/pkg-scripts"
    
    # Create package structure
    mkdir -p "$PKG_ROOT/Applications"
    mkdir -p "$PKG_ROOT/usr/local/bin"
    mkdir -p "$PKG_SCRIPTS"
    
    # Copy files to package root
    cp -R "$BUILD_DIR/$APP_NAME.app" "$PKG_ROOT/Applications/"
    cp "$SCRIPT_DIR/ccmenubar_enhanced" "$PKG_ROOT/usr/local/bin/ccmenubar"
    chmod +x "$PKG_ROOT/usr/local/bin/ccmenubar"
    
    # Create postinstall script
    cat > "$PKG_SCRIPTS/postinstall" << 'EOF'
#!/bin/bash
# Launch the app after installation
open "/Applications/CCMenuBar.app" 2>/dev/null || true

# Create Claude Code directory if needed
mkdir -p "$HOME/.claude"

# Notify user
osascript -e 'display notification "CCMenuBar installed successfully!" with title "Installation Complete"'

exit 0
EOF
    chmod +x "$PKG_SCRIPTS/postinstall"
    
    # Build the package
    pkgbuild \
        --root "$PKG_ROOT" \
        --scripts "$PKG_SCRIPTS" \
        --identifier "$IDENTIFIER" \
        --version "$VERSION" \
        --install-location "/" \
        "$PKG_NAME"
    
    echo "  ✓ PKG created: $PKG_NAME"
}

# 4. Create ZIP archive
create_zip() {
    echo "🗜️ Creating ZIP archive..."
    
    ZIP_NAME="$RELEASE_DIR/$APP_NAME-$VERSION.zip"
    ZIP_DIR="$BUILD_DIR/zip"
    
    mkdir -p "$ZIP_DIR"
    
    # Copy all files
    cp -R "$BUILD_DIR/$APP_NAME.app" "$ZIP_DIR/"
    cp "$SCRIPT_DIR/ccmenubar_enhanced" "$ZIP_DIR/"
    cp "$SCRIPT_DIR/install.sh" "$ZIP_DIR/"
    cp "$SCRIPT_DIR/README.md" "$ZIP_DIR/" 2>/dev/null || true
    cp "$SCRIPT_DIR/claude_code_hooks_dropdown.json" "$ZIP_DIR/" 2>/dev/null || true
    
    # Create zip
    cd "$ZIP_DIR"
    zip -r -q "$ZIP_NAME" .
    cd "$SCRIPT_DIR"
    
    echo "  ✓ ZIP created: $ZIP_NAME"
}

# 5. Create Homebrew Cask
create_homebrew_cask() {
    echo "🍺 Creating Homebrew Cask..."
    
    CASK_FILE="$RELEASE_DIR/ccmenubar.rb"
    
    # Calculate SHA256 of the DMG
    if [ -f "$RELEASE_DIR/$APP_NAME-$VERSION.dmg" ]; then
        SHA256=$(shasum -a 256 "$RELEASE_DIR/$APP_NAME-$VERSION.dmg" | awk '{print $1}')
    else
        SHA256="PLACEHOLDER_SHA256"
    fi
    
    cat > "$CASK_FILE" << EOF
cask "ccmenubar" do
  version "$VERSION"
  sha256 "$SHA256"
  
  url "https://github.com/hesreallyhim/ccmenubar/releases/download/v#{version}/CCMenuBar-#{version}.dmg"
  name "CCMenuBar"
  desc "Claude Code status tracker for macOS menu bar"
  homepage "https://github.com/hesreallyhim/ccmenubar"
  
  app "CCMenuBar.app"
  binary "#{appdir}/CCMenuBar.app/Contents/MacOS/ccmenubar"
  
  zap trash: [
    "~/Library/Preferences/com.claude.ccmenubar.plist",
    "~/.claude/settings.json.backup.*",
  ]
end
EOF
    
    echo "  ✓ Homebrew Cask created: $CASK_FILE"
}

# 6. Sign the app (if developer certificate available)
sign_app() {
    echo "🔏 Signing application..."
    
    if [ -n "$DEVELOPER_ID" ] && [ "$DEVELOPER_ID" != "Developer ID Application: Your Name (TEAM_ID)" ]; then
        codesign --force --deep --sign "$DEVELOPER_ID" "$BUILD_DIR/$APP_NAME.app"
        echo "  ✓ Application signed"
    else
        echo "  ⚠️  No developer certificate configured, skipping signing"
    fi
}

# 7. Notarize the app (if credentials available)
notarize_app() {
    echo "🎫 Notarizing application..."
    
    if [ -n "$APPLE_ID" ] && [ -n "$APPLE_PASSWORD" ]; then
        xcrun altool --notarize-app \
            --primary-bundle-id "$IDENTIFIER" \
            --username "$APPLE_ID" \
            --password "$APPLE_PASSWORD" \
            --file "$RELEASE_DIR/$APP_NAME-$VERSION.dmg"
        echo "  ✓ Notarization submitted"
    else
        echo "  ⚠️  Apple credentials not configured, skipping notarization"
    fi
}

# 8. Create installer script for web distribution
create_web_installer() {
    echo "🌐 Creating web installer..."
    
    WEB_INSTALLER="$RELEASE_DIR/web-install.sh"
    
    cat > "$WEB_INSTALLER" << 'EOF'
#!/bin/bash
# One-line web installer for CCMenuBar
# Usage: curl -sL https://your-domain.com/install.sh | bash

set -e

echo "Installing CCMenuBar..."

# Download and install
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download latest release
curl -sL "https://github.com/hesreallyhim/ccmenubar/releases/latest/download/CCMenuBar.zip" -o CCMenuBar.zip
unzip -q CCMenuBar.zip

# Run installer
bash install.sh

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "✅ CCMenuBar installed successfully!"
EOF
    
    chmod +x "$WEB_INSTALLER"
    echo "  ✓ Web installer created: $WEB_INSTALLER"
}

# 9. Generate checksums
generate_checksums() {
    echo "🔐 Generating checksums..."
    
    CHECKSUMS_FILE="$RELEASE_DIR/checksums.txt"
    
    cd "$RELEASE_DIR"
    shasum -a 256 *.dmg *.pkg *.zip 2>/dev/null > "$CHECKSUMS_FILE" || true
    
    echo "  ✓ Checksums generated: $CHECKSUMS_FILE"
}

# Main build process
main() {
    echo ""
    build_app
    sign_app
    create_dmg
    create_pkg
    create_zip
    create_homebrew_cask
    create_web_installer
    notarize_app
    generate_checksums
    
    echo ""
    echo "✨ Build complete!"
    echo ""
    echo "📦 Distribution packages created in: $RELEASE_DIR"
    echo ""
    echo "Available formats:"
    ls -lh "$RELEASE_DIR"
    echo ""
    echo "🚀 Distribution methods:"
    echo "  1. DMG: Drag-and-drop installer"
    echo "  2. PKG: Traditional macOS installer"
    echo "  3. ZIP: Manual installation"
    echo "  4. Homebrew: brew install --cask ccmenubar"
    echo "  5. Web: curl -sL https://your-url/install.sh | bash"
    echo ""
}

# Run main build
main
