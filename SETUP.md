# 🚀 Minds Flow - Setup Instructions

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later
- Active Supabase project

---

## 📋 Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/mindsflowswift.git
cd mindsflowswift
```

### 2. Configure Supabase Credentials

#### Step 2.1: Create Config File

Copy the example configuration file:

```bash
cp Config.example.xcconfig Config.xcconfig
```

#### Step 2.2: Get Your Supabase Credentials

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** → **API**
4. Copy the following values:
   - **Project URL** (e.g., `https://your-project.supabase.co`)
   - **Anon/Public Key** (starts with `eyJhbGciOi...`)

#### Step 2.3: Update Config.xcconfig

Open `Config.xcconfig` and replace the placeholder values:

```xcconfig
// Supabase Configuration
SUPABASE_URL = https:/$()/your-project-id.supabase.co
SUPABASE_ANON_KEY = your-actual-anon-key-here
```

**Important:** 
- Keep the `$()` in the URL (it's required by Xcode)
- Don't add quotes around the values
- Don't commit `Config.xcconfig` to version control (it's in `.gitignore`)

### 3. Configure Xcode Project

#### Step 3.1: Add Config to Project

1. Open `Minds Flow.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select the **Minds Flow** target
4. Go to **Build Settings** tab
5. Search for "Configuration"
6. Under **Configuration Settings File**, set:
   - **Debug**: `Config.xcconfig`
   - **Release**: `Config.xcconfig`

#### Step 3.2: Update Info.plist

The Info.plist should already have these entries, but verify:

1. Open `Info.plist`
2. Ensure these keys exist:
   - `SUPABASE_URL` with value `$(SUPABASE_URL)`
   - `SUPABASE_ANON_KEY` with value `$(SUPABASE_ANON_KEY)`

If they don't exist, add them:

```xml
<key>SUPABASE_URL</key>
<string>$(SUPABASE_URL)</string>
<key>SUPABASE_ANON_KEY</key>
<string>$(SUPABASE_ANON_KEY)</string>
```

### 4. Install Dependencies

The project uses Swift Package Manager. Dependencies should be resolved automatically when you open the project.

If needed, manually resolve:

1. In Xcode, go to **File** → **Packages** → **Resolve Package Versions**
2. Wait for packages to download

### 5. Build and Run

1. Select a simulator or device
2. Press **Cmd + R** to build and run
3. The app should launch successfully

---

## 🔍 Troubleshooting

### "SUPABASE_URL not found in Info.plist"

**Solution:**
1. Verify `Config.xcconfig` exists and has correct values
2. Check that `Config.xcconfig` is set in Build Settings
3. Clean build folder: **Product** → **Clean Build Folder** (Cmd + Shift + K)
4. Rebuild the project

### "Invalid Supabase URL"

**Solution:**
1. Verify the URL format in `Config.xcconfig`
2. Ensure it starts with `https://`
3. Keep the `$()` in the URL: `https:/$()/your-project.supabase.co`

### Configuration Not Loading

**Solution:**
1. Quit Xcode completely
2. Delete `DerivedData` folder:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Reopen project and rebuild

### Build Errors After Setup

**Solution:**
1. Clean build folder (Cmd + Shift + K)
2. Reset package caches: **File** → **Packages** → **Reset Package Caches**
3. Rebuild project

---

## 🗄️ Database Setup

### Required Tables

The app requires these tables in Supabase:

1. **users** - User profiles
2. **tasks** - Task management
3. **wisdom_entries** - Wisdom library
4. **mental_states** - Mental state tracking
5. **timeline_events** - User activity timeline
6. **usage_stats** - App usage statistics

### Setup Database

1. Go to your Supabase project
2. Navigate to **SQL Editor**
3. Run the SQL scripts from `.kiro/specs/supabase-integration/database-schema.md`
4. Verify tables are created in **Table Editor**

### Enable Row Level Security (RLS)

For each table, enable RLS and add policies:

```sql
-- Enable RLS
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own tasks
CREATE POLICY "Users can view own tasks"
ON tasks FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own tasks
CREATE POLICY "Users can insert own tasks"
ON tasks FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own tasks
CREATE POLICY "Users can update own tasks"
ON tasks FOR UPDATE
USING (auth.uid() = user_id);

-- Policy: Users can delete their own tasks
CREATE POLICY "Users can delete own tasks"
ON tasks FOR DELETE
USING (auth.uid() = user_id);
```

Repeat for all tables.

---

## 🔐 Security Best Practices

### DO:
✅ Keep `Config.xcconfig` in `.gitignore`  
✅ Use environment-specific configs for different environments  
✅ Rotate keys regularly  
✅ Use Row Level Security in Supabase  
✅ Validate all user inputs  

### DON'T:
❌ Commit `Config.xcconfig` to version control  
❌ Share credentials in public channels  
❌ Use production credentials in development  
❌ Hardcode credentials in source code  
❌ Disable Row Level Security  

---

## 🌍 Environment-Specific Configuration

### Development Environment

Create `Config.dev.xcconfig`:

```xcconfig
SUPABASE_URL = https:/$()/dev-project.supabase.co
SUPABASE_ANON_KEY = dev-anon-key
```

### Production Environment

Create `Config.prod.xcconfig`:

```xcconfig
SUPABASE_URL = https:/$()/prod-project.supabase.co
SUPABASE_ANON_KEY = prod-anon-key
```

Then in Build Settings, set different configs for Debug and Release.

---

## 📱 Running on Device

### 1. Configure Signing

1. Select project in Xcode
2. Select **Minds Flow** target
3. Go to **Signing & Capabilities**
4. Select your **Team**
5. Xcode will automatically manage signing

### 2. Connect Device

1. Connect iPhone/iPad via USB
2. Trust computer on device
3. Select device in Xcode
4. Press **Cmd + R** to run

---

## 🧪 Testing

### Run Unit Tests

```bash
# Command line
xcodebuild test -project "Minds Flow.xcodeproj" -scheme "Minds Flow" -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Or in Xcode
Cmd + U
```

### Run UI Tests

1. In Xcode, go to **Product** → **Test**
2. Or press **Cmd + U**

---

## 📦 Building for Release

### 1. Update Version

1. Select project in Xcode
2. Select **Minds Flow** target
3. Update **Version** and **Build** numbers

### 2. Archive

1. Select **Any iOS Device** as destination
2. Go to **Product** → **Archive**
3. Wait for archive to complete

### 3. Distribute

1. In Organizer, select archive
2. Click **Distribute App**
3. Choose distribution method:
   - **App Store Connect** - For App Store
   - **Ad Hoc** - For testing
   - **Enterprise** - For internal distribution

---

## 🆘 Support

### Documentation
- [Supabase Documentation](https://supabase.com/docs)
- [Swift Documentation](https://swift.org/documentation/)
- [Xcode Help](https://developer.apple.com/xcode/)

### Issues
If you encounter issues:
1. Check this SETUP.md file
2. Review error messages carefully
3. Check Supabase project status
4. Verify all credentials are correct

---

## 📝 Notes

- The app requires iOS 17.0 or later
- Supabase credentials are loaded at runtime from Info.plist
- Config.xcconfig is excluded from version control for security
- Always use HTTPS for Supabase URLs
- Keep your anon key secure (it's public but should not be exposed unnecessarily)

---

**Last Updated:** November 25, 2025  
**Version:** 1.0.0
