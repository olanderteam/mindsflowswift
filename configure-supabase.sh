#!/bin/bash

# Minds Flow - Supabase Configuration Script
# This script helps configure Supabase credentials securely

set -e

echo "🚀 Minds Flow - Supabase Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Config.xcconfig exists
if [ ! -f "Config.xcconfig" ]; then
    echo "⚠️  Config.xcconfig not found!"
    echo ""
    echo "Creating Config.xcconfig from example..."
    
    if [ -f "Config.example.xcconfig" ]; then
        cp Config.example.xcconfig Config.xcconfig
        echo "✅ Config.xcconfig created"
        echo ""
        echo "📝 Next steps:"
        echo "1. Open Config.xcconfig"
        echo "2. Replace placeholder values with your Supabase credentials"
        echo "3. Get credentials from: https://app.supabase.com"
        echo "4. Run this script again to verify"
        echo ""
        exit 0
    else
        echo "❌ Config.example.xcconfig not found!"
        exit 1
    fi
fi

# Read configuration
echo "📖 Reading configuration..."
SUPABASE_URL=$(grep "SUPABASE_URL" Config.xcconfig | cut -d'=' -f2 | xargs)
SUPABASE_KEY=$(grep "SUPABASE_ANON_KEY" Config.xcconfig | cut -d'=' -f2 | xargs)

# Validate URL
if [[ $SUPABASE_URL == *"your-project"* ]] || [ -z "$SUPABASE_URL" ]; then
    echo "❌ SUPABASE_URL not configured!"
    echo ""
    echo "Please edit Config.xcconfig and add your Supabase URL"
    echo "Example: SUPABASE_URL = https://\$()/your-project.supabase.co"
    exit 1
fi

# Validate Key
if [[ $SUPABASE_KEY == *"your-anon-key"* ]] || [ -z "$SUPABASE_KEY" ]; then
    echo "❌ SUPABASE_ANON_KEY not configured!"
    echo ""
    echo "Please edit Config.xcconfig and add your Supabase anon key"
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

# Check if .gitignore includes Config.xcconfig
if ! grep -q "Config.xcconfig" .gitignore; then
    echo "⚠️  Adding Config.xcconfig to .gitignore..."
    echo "" >> .gitignore
    echo "# Supabase Configuration" >> .gitignore
    echo "Config.xcconfig" >> .gitignore
    echo "✅ Updated .gitignore"
else
    echo "✅ Config.xcconfig is in .gitignore"
fi

echo ""
echo "🎉 Configuration complete!"
echo ""
echo "📱 Next steps:"
echo "1. Open Minds Flow.xcodeproj in Xcode"
echo "2. Go to Project Settings → Build Settings"
echo "3. Search for 'Configuration Settings File'"
echo "4. Set Debug and Release to: Config.xcconfig"
echo "5. Clean and rebuild the project"
echo ""
echo "For detailed instructions, see SETUP.md"
echo ""
