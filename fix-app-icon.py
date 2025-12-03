#!/usr/bin/env python3
"""
Fix App Icon - Remove alpha channel for App Store submission
"""

from PIL import Image
import sys

def remove_alpha(input_path, output_path):
    """Remove alpha channel from PNG image"""
    try:
        # Open the image
        img = Image.open(input_path)
        
        # Convert RGBA to RGB (removes alpha channel)
        if img.mode in ('RGBA', 'LA'):
            # Create a white background
            background = Image.new('RGB', img.size, (255, 255, 255))
            # Paste the image on the background
            if img.mode == 'RGBA':
                background.paste(img, mask=img.split()[3])  # Use alpha channel as mask
            else:
                background.paste(img, mask=img.split()[1])
            img = background
        elif img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Save without alpha channel
        img.save(output_path, 'PNG', optimize=True)
        print(f"✅ Icon fixed: {output_path}")
        print(f"   Mode: {img.mode}")
        print(f"   Size: {img.size}")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    input_file = "Minds Flow/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
    output_file = "Minds Flow/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
    
    print("🔧 Fixing App Icon...")
    print(f"   Input: {input_file}")
    
    if remove_alpha(input_file, output_file):
        print("✅ App icon is now ready for App Store!")
    else:
        print("❌ Failed to fix app icon")
        sys.exit(1)
