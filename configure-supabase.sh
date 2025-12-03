#!/bin/bash

# Minds Flow - Supabase Configuration Script
# This script helps configure Supabase credentials securely

set -e

echo "🚀 Minds Flow - Supabase Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if secrets.json exists
if [ ! -f "secrets.json" ]; then
    echo "⚠️  secrets.json not found!"
    echo ""
    echo "Creating secrets.json from example..."
    
    if [ -f "secrets.example.json" ]; then
        cp secrets.example.json secrets.json
        echo "✅ secrets.json created"
        echo ""
        echo "📝 Next steps:"
        echo "1. Open secrets.json"
        echo "2. Replace placeholder values with your Supabase credentials"
        echo "3. Get credentials from: https://app.supabase.com"
        echo "4. Add secrets.json to your Xcode project"
        echo "5. Run this script again to verify"
        echo ""
        exit 0
    else
        echo "❌ secrets.example.json not found!"
        exit 1
    fi
fi

# Read configuration
echo "📖 Reading configuration..."
SUPABASE_URL=$(grep -o '"url"[[:space:]]*:[[:space:]]*"[^"]*"' secrets.json | cut -d'"' -f4)
SUPABASE_KEY=$(grep -o '"anonKey"[[:space:]]*:[[:space:]]*"[^"]*"' secrets.json | cut -d'"' -f4)

# Validate URL
if [[ $SUPABASE_URL == *"your-project"* ]] || [ -z "$SUPABASE_URL" ]; then
    echo "❌ Supabase URL not configured!"
    echo ""
    echo "Please edit secrets.json and add your Supabase URL"
    echo "Example: \"url\": \"https://your-project.supabase.co\""
    exit 1
fi

# Validate Key
if [[ $SUPABASE_KEY == *"your-anon-key"* ]] || [ -z "$SUPABASE_KEY" ]; then
    echo "❌ Supabase anon key not configured!"
    echo ""
    echo "Please edit secrets.json and add your Supabase anon key"
    exit 1
fi

echo "✅ Configuration file is valid"
echo ""
echo "🔧 Configuration Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "URL: ${SUPABASE_URL}"
echo "Key: ${SUPABASE_KEY:0:20}..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if .gitignore includes secrets.json
if ! grep -q "secrets.json" .gitignore; then
    echo "⚠️  Adding secrets.json to .gitignore..."
    echo "" >> .gitignore
    echo "# Supabase Secrets" >> .gitignore
    echo "secrets.json" >> .gitignore
    echo "✅ Updated .gitignore"
else
    echo "✅ secrets.json is in .gitignore"
fi

echo ""
echo "🎉 Configuration complete!"
echo ""
echo "📱 Next steps:"
echo "1. Open Minds Flow.xcodeproj in Xcode"
echo "2. Add secrets.json to your project (File → Add Files)"
echo "3. Make sure 'Copy items if needed' is checked"
echo "4. Verify it's in 'Copy Bundle Resources' (Build Phases)"
echo "5. Clean and rebuild the project (Cmd + Shift + K, then Cmd + B)"
echo ""
echo "For detailed instructions, see SETUP.md"
echo ""
