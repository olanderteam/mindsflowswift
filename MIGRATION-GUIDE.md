# 🔄 Migration Guide - Secure Credentials

## Overview

This guide helps you migrate from hardcoded credentials to secure configuration.

---

## ⚠️ IMPORTANT: Before You Start

**BACKUP YOUR CREDENTIALS:**
The old `SupabaseConfig.swift` had these values:
- URL: `https://txlukdftqiqbpdxuuozp.supabase.co`
- Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

Save these somewhere safe before proceeding!

---

## 🚀 Quick Migration (5 minutes)

### Step 1: Create Config File

```bash
# Run the configuration script
./configure-supabase.sh
```

This will create `Config.xcconfig` from the example.

### Step 2: Add Your Credentials

Open `Config.xcconfig` and update:

```xcconfig
SUPABASE_URL = https:/$()/txlukdftqiqbpdxuuozp.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4bHVrZGZ0cWlxYnBkeHV1b3pwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzU2NzcsImV4cCI6MjA3NTg1MTY3N30.D4DXTknWbq2zHp3UKA_ecohfmP-11mNGhCkv8hYfMks
```

**Note:** Keep the `$()` in the URL - it's required by Xcode!

### Step 3: Configure Xcode

1. Open `Minds Flow.xcodeproj`
2. Select the project (blue icon at top)
3. Select **Minds Flow** target
4. Go to **Build Settings** tab
5. Search for "configuration"
6. Find **Configuration Settings File**
7. Set both Debug and Release to: `$(SRCROOT)/Config.xcconfig`

### Step 4: Add to Info.plist

Since the project uses the new Xcode format without a separate Info.plist:

1. Select the project
2. Select **Minds Flow** target
3. Go to **Info** tab
4. Click **+** to add new entries:
   - Key: `SUPABASE_URL`, Value: `$(SUPABASE_URL)`
   - Key: `SUPABASE_ANON_KEY`, Value: `$(SUPABASE_ANON_KEY)`

### Step 5: Clean and Build

```bash
# Clean build folder
# In Xcode: Product → Clean Build Folder (Cmd + Shift + K)

# Or via command line:
xcodebuild clean -project "Minds Flow.xcodeproj" -scheme "Minds Flow"

# Build
xcodebuild -project "Minds Flow.xcodeproj" -scheme "Minds Flow" -sdk iphonesimulator
```

### Step 6: Verify

Run the app and check the console for:

```
✅ Supabase configuration is valid
📍 Using Supabase URL: https://txlukdftqiqbpdxuuozp.supabase.co
```

---

## 🔍 Troubleshooting

### Error: "SUPABASE_URL not found in Info.plist"

**Cause:** Configuration not properly linked

**Solution:**
1. Verify `Config.xcconfig` exists and has correct values
2. Check Build Settings → Configuration Settings File
3. Verify Info.plist has the keys
4. Clean build folder and rebuild

### Error: "Invalid Supabase URL"

**Cause:** URL format issue

**Solution:**
1. Check URL in `Config.xcconfig`
2. Ensure it has `$()` in the middle: `https:/$()/project.supabase.co`
3. No quotes around the value

### Build Succeeds but App Crashes

**Cause:** Values not being read at runtime

**Solution:**
1. Check Info.plist has both keys
2. Verify values are `$(SUPABASE_URL)` and `$(SUPABASE_ANON_KEY)`
3. Clean DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
4. Rebuild

### Configuration Not Loading

**Cause:** Xcode caching issue

**Solution:**
1. Quit Xcode completely
2. Delete DerivedData
3. Reopen project
4. Clean and rebuild

---

## 📋 Verification Checklist

After migration, verify:

- [ ] `Config.xcconfig` exists with correct credentials
- [ ] `Config.xcconfig` is in `.gitignore`
- [ ] Build Settings points to `Config.xcconfig`
- [ ] Info.plist has both keys
- [ ] App builds successfully
- [ ] App runs without crashes
- [ ] Supabase connection works
- [ ] Authentication works
- [ ] Data sync works

---

## 🔒 Security Verification

Ensure security is maintained:

- [ ] No credentials in source code
- [ ] `Config.xcconfig` not committed to Git
- [ ] `.gitignore` includes `Config.xcconfig`
- [ ] `Config.example.xcconfig` has no real credentials
- [ ] Team members have their own `Config.xcconfig`

---

## 👥 Team Migration

### For Team Lead:

1. **Communicate the change**
   ```
   Subject: IMPORTANT: Supabase Configuration Change
   
   We've migrated to secure credential management.
   
   Action Required:
   1. Pull latest changes
   2. Run: ./configure-supabase.sh
   3. Add your credentials to Config.xcconfig
   4. Follow MIGRATION-GUIDE.md
   
   DO NOT commit Config.xcconfig!
   ```

2. **Provide credentials securely**
   - Use password manager
   - Or encrypted communication
   - Never via email or Slack

3. **Verify everyone is set up**
   - Check with each team member
   - Ensure builds work for everyone

### For Team Members:

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Run configuration script**
   ```bash
   ./configure-supabase.sh
   ```

3. **Get credentials from team lead**
   - Request via secure channel
   - Add to `Config.xcconfig`

4. **Verify setup**
   - Build and run
   - Test authentication
   - Confirm data sync

---

## 🔄 Rollback Plan

If you need to rollback:

### Option 1: Revert Commit

```bash
git revert HEAD
git push origin main
```

### Option 2: Manual Rollback

1. Restore old `SupabaseConfig.swift`:
   ```swift
   static let projectURL = "https://txlukdftqiqbpdxuuozp.supabase.co"
   static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   ```

2. Remove `Config.xcconfig` from Build Settings
3. Clean and rebuild

**Note:** Rollback is NOT recommended for security reasons!

---

## 📚 Additional Resources

- [SETUP.md](SETUP.md) - Complete setup instructions
- [SECURITY.md](SECURITY.md) - Security policies
- [Xcode Configuration Files](https://nshipster.com/xcconfig/)
- [Supabase Security](https://supabase.com/docs/guides/platform/security)

---

## 🆘 Need Help?

If you're stuck:

1. Check this guide thoroughly
2. Review error messages
3. Check SETUP.md
4. Ask team lead
5. Check Xcode console for detailed errors

---

## ✅ Post-Migration Tasks

After successful migration:

- [ ] Update team documentation
- [ ] Add to onboarding checklist
- [ ] Schedule security review
- [ ] Plan credential rotation
- [ ] Document lessons learned

---

**Migration Date:** November 25, 2025  
**Version:** 1.0.0  
**Status:** ✅ Complete
