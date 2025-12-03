#!/bin/bash

# Fix App Icon - Remove alpha channel for App Store
# Apple requires app icons to be RGB without transparency

echo "🔧 Fixing App Icon for App Store..."

ICON_PATH="Minds Flow/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
TEMP_PATH="Minds Flow/Assets.xcassets/AppIcon.appiconset/temp-icon.png"

# Check if icon exists
if [ ! -f "$ICON_PATH" ]; then
    echo "❌ Icon not found: $ICON_PATH"
    exit 1
fi

echo "📋 Original icon info:"
file "$ICON_PATH"

# Method 1: Convert to JPEG and back to PNG (removes alpha)
echo ""
echo "🔄 Converting icon (removing alpha channel)..."

# Convert to JPEG (no alpha support)
sips -s format jpeg "$ICON_PATH" --out "$TEMP_PATH.jpg" > /dev/null 2>&1

# Convert back to PNG
sips -s format png "$TEMP_PATH.jpg" --out "$TEMP_PATH" > /dev/null 2>&1

# Replace original
mv "$TEMP_PATH" "$ICON_PATH"

# Clean up
rm -f "$TEMP_PATH.jpg"

echo ""
echo "📋 Fixed icon info:"
file "$ICON_PATH"

echo ""
echo "✅ App icon fixed! No alpha channel."
echo "   Ready for App Store submission."
