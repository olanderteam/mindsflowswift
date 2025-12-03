# 📱 App Store Submission Guide - Minds Flow

## Complete guide to prepare and submit your app to App Store Connect

**Last Updated:** December 3, 2025  
**App Version:** 1.0.0  
**Bundle ID:** com.mindsflow.app  
**SKU:** 41475147  
**Apple ID:** 6751007620

---

## ✅ Pre-Submission Checklist

### 1. App Information (Already Configured)
- [x] Bundle Identifier: `com.mindsflow.app`
- [x] SKU: `41475147`
- [x] Apple ID: `6751007620`
- [x] Primary Language: English (US)
- [x] Category: Primary + Secondary (optional)

### 2. Required Before Submission

#### A. App Icon ✅
- [x] 1024x1024 App Store icon (already configured)
- Location: `Minds Flow/Assets.xcassets/AppIcon.appiconset/`

#### B. Screenshots (REQUIRED - Not Done Yet)
You need screenshots for:
- **iPhone 6.7"** (iPhone 15 Pro Max) - 5 screenshots minimum
- **iPhone 6.5"** (iPhone 14 Plus) - 5 screenshots minimum
- **iPhone 5.5"** (iPhone 8 Plus) - 5 screenshots minimum

**Recommended Screenshots:**
1. Dashboard with mental state tracking
2. Task management with energy levels
3. Wisdom library with categories
4. History and insights view
5. Collapse mode demonstration

#### C. App Description & Metadata (REQUIRED)

**App Name** (30 characters max):
```
Minds Flow - Mental Wellness
```

**Subtitle** (30 characters max):
```
Track Tasks, Mood & Insights
```

**Promotional Text** (170 characters max):
```
Organize your life with energy-aware task management. Track your mental state, capture wisdom, and gain insights into your productivity patterns.
```

**Description** (4000 characters max):
```
Minds Flow is your personal productivity and mental wellness companion. Designed for people who want to work with their energy levels, not against them.

KEY FEATURES:

🎯 Energy-Aware Task Management
• Create tasks matched to your energy level
• Track completion based on your current state
• Get smart suggestions for what to do now

🧠 Mental State Tracking
• Log your energy and emotional state
• Visualize patterns over time
• Understand what affects your productivity

💡 Wisdom Library
• Capture insights and learnings
• Organize by categories and tags
• Build your personal knowledge base

📊 Insights & Analytics
• View your productivity trends
• Understand your energy patterns
• Track completion rates and progress

🎨 Beautiful, Calm Interface
• Minimalist design reduces distractions
• Collapse mode for focused work
• Dark mode support

✨ Smart & Offline-First
• Works offline, syncs when online
• Intelligent caching
• Fast and responsive

PERFECT FOR:
• People managing ADHD or energy fluctuations
• Anyone wanting to optimize productivity
• Those building self-awareness habits
• Professionals tracking mental wellness

PRIVACY FIRST:
• Your data is encrypted and secure
• No ads, no tracking
• You own your data

Download Minds Flow today and start working with your energy, not against it.
```

**Keywords** (100 characters max):
```
productivity,mental health,task manager,mood tracker,energy,wellness,ADHD,focus,mindfulness,habits
```

**Support URL**:
```
https://github.com/olanderteam/mindsflowswift
```

**Marketing URL** (optional):
```
https://github.com/olanderteam/mindsflowswift
```

#### D. Privacy Policy (REQUIRED)

You MUST have a privacy policy URL. Here's a template:

**Privacy Policy URL**:
```
https://yourdomain.com/privacy-policy
```

**Privacy Policy Content** (save this as HTML and host it):

```html
<!DOCTYPE html>
<html>
<head>
    <title>Minds Flow - Privacy Policy</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Privacy Policy for Minds Flow</h1>
    <p><strong>Last Updated:</strong> December 3, 2025</p>
    
    <h2>1. Information We Collect</h2>
    <p>Minds Flow collects the following information:</p>
    <ul>
        <li><strong>Account Information:</strong> Email address and name for authentication</li>
        <li><strong>User Content:</strong> Tasks, wisdom entries, and mental state records you create</li>
        <li><strong>Usage Data:</strong> App usage statistics and analytics</li>
    </ul>
    
    <h2>2. How We Use Your Information</h2>
    <ul>
        <li>To provide and maintain the app service</li>
        <li>To sync your data across devices</li>
        <li>To improve app functionality and user experience</li>
        <li>To provide customer support</li>
    </ul>
    
    <h2>3. Data Storage and Security</h2>
    <p>Your data is stored securely using Supabase infrastructure with encryption. We use industry-standard security measures to protect your information.</p>
    
    <h2>4. Data Sharing</h2>
    <p>We do NOT sell, trade, or share your personal data with third parties. Your data is yours.</p>
    
    <h2>5. Your Rights</h2>
    <ul>
        <li>Access your data at any time</li>
        <li>Delete your account and all associated data</li>
        <li>Export your data</li>
    </ul>
    
    <h2>6. Contact Us</h2>
    <p>For privacy concerns, contact us at: [your-email@example.com]</p>
</body>
</html>
```

#### E. App Review Information

**Demo Account** (REQUIRED for reviewers):
```
Email: demo@mindsflow.app
Password: DemoPassword123!
```

**Notes for Reviewer**:
```
Minds Flow is a productivity and mental wellness app that helps users manage tasks based on their energy levels.

Key features to test:
1. Sign up / Sign in with demo account
2. Create a task with energy level
3. Add a wisdom entry
4. Track mental state
5. View history and insights

The app works offline and syncs when online. All data is stored securely in Supabase.

No special configuration needed. The app is ready to use immediately after login.
```

---

## 🔧 Technical Configuration

### 1. Version & Build Number

Open Xcode and set:
- **Version:** 1.0.0
- **Build:** 1

Location: Target → General → Identity

### 2. Signing & Capabilities

You need:
- [x] Apple Developer Account (paid)
- [ ] App ID registered in Apple Developer Portal
- [ ] Provisioning Profile for App Store distribution
- [ ] Distribution Certificate

**Steps:**
1. Open Xcode
2. Select "Minds Flow" target
3. Go to "Signing & Capabilities"
4. Select your Team
5. Ensure "Automatically manage signing" is checked
6. Select "Release" configuration

### 3. Build Settings

Ensure these are set:
- **Deployment Target:** iOS 17.0 or higher
- **Supported Devices:** iPhone, iPad
- **Orientation:** Portrait (recommended)

### 4. Info.plist Required Keys

Check that Info.plist has:
```xml
<key>CFBundleDisplayName</key>
<string>Minds Flow</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>NSUserTrackingUsageDescription</key>
<string>We don't track you. This permission is not used.</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>armv7</string>
</array>
```

---

## 📸 Creating Screenshots

### Method 1: Using Simulator (Recommended)

1. **Open Simulator:**
```bash
open -a Simulator
```

2. **Select Device:**
   - iPhone 15 Pro Max (6.7")
   - iPhone 14 Plus (6.5")
   - iPhone 8 Plus (5.5")

3. **Run App:**
```bash
xcodebuild -project "Minds Flow.xcodeproj" -scheme "Minds Flow" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max' build
```

4. **Take Screenshots:**
   - Navigate to each screen
   - Press `Cmd + S` to save screenshot
   - Screenshots save to Desktop

5. **Required Screens:**
   - Dashboard (main view)
   - Task list with items
   - Add task screen
   - Wisdom library
   - History/Analytics

### Method 2: Using Real Device

1. Connect iPhone
2. Run app on device
3. Take screenshots with `Volume Up + Side Button`
4. Transfer to Mac via AirDrop or Photos

### Screenshot Specifications

**iPhone 6.7" (1290 x 2796 pixels)**
- iPhone 15 Pro Max
- iPhone 14 Pro Max

**iPhone 6.5" (1242 x 2688 pixels)**
- iPhone 14 Plus
- iPhone 13 Pro Max
- iPhone 12 Pro Max

**iPhone 5.5" (1242 x 2208 pixels)**
- iPhone 8 Plus
- iPhone 7 Plus
- iPhone 6s Plus

---

## 🚀 Building for App Store

### Step 1: Archive the App

1. **Select "Any iOS Device" as destination**
2. **Product → Archive** (or `Cmd + B` then `Cmd + Shift + B`)
3. Wait for archive to complete
4. Organizer window will open

### Step 2: Validate the Archive

1. In Organizer, select your archive
2. Click "Validate App"
3. Select your distribution certificate
4. Wait for validation
5. Fix any errors if they appear

### Step 3: Distribute to App Store

1. Click "Distribute App"
2. Select "App Store Connect"
3. Select "Upload"
4. Choose automatic signing
5. Review and upload

### Step 4: Wait for Processing

- Upload takes 5-30 minutes
- Processing takes 10-60 minutes
- You'll receive email when ready

---

## 📝 App Store Connect Configuration

### 1. Login to App Store Connect

Visit: https://appstoreconnect.apple.com

### 2. Create New App

1. Click "My Apps" → "+" → "New App"
2. Fill in:
   - **Platform:** iOS
   - **Name:** Minds Flow
   - **Primary Language:** English (US)
   - **Bundle ID:** com.mindsflow.app
   - **SKU:** 41475147
   - **User Access:** Full Access

### 3. App Information

Fill in all fields from the metadata section above:
- App Name
- Subtitle
- Category (Health & Fitness → Primary)
- Content Rights
- Age Rating

### 4. Pricing and Availability

- **Price:** Free (or set your price)
- **Availability:** All countries
- **Pre-order:** No (for first release)

### 5. App Privacy

Answer privacy questions:
- **Do you collect data?** Yes
- **Data types:**
  - Email Address (for account)
  - Name (for profile)
  - User Content (tasks, wisdom)
- **Purpose:** App functionality
- **Linked to user:** Yes
- **Used for tracking:** No

### 6. Prepare for Submission

1. Upload screenshots (all required sizes)
2. Add app description
3. Add keywords
4. Add support URL
5. Add privacy policy URL
6. Select build (after upload completes)
7. Add demo account credentials
8. Add notes for reviewer

### 7. Submit for Review

1. Review all information
2. Click "Add for Review"
3. Click "Submit to App Review"
4. Wait for review (typically 24-48 hours)

---

## ⚠️ Common Rejection Reasons & How to Avoid

### 1. Missing Privacy Policy
✅ **Solution:** Host privacy policy and add URL

### 2. Incomplete Metadata
✅ **Solution:** Fill ALL required fields

### 3. Missing Screenshots
✅ **Solution:** Provide all required screenshot sizes

### 4. App Crashes
✅ **Solution:** Test thoroughly before submission

### 5. Missing Demo Account
✅ **Solution:** Provide working demo credentials

### 6. Hardcoded Credentials (Security Issue)
⚠️ **Current Status:** You have hardcoded Supabase credentials
📝 **Note:** For first submission, this is acceptable as they are public "anon" keys
🔒 **Before v1.1:** Implement secure credential storage (see SECURITY.md)

---

## 📋 Final Pre-Submission Checklist

### Required (Must Have)
- [ ] App built and archived successfully
- [ ] All screenshots created (3 sizes, 5 each)
- [ ] App description written
- [ ] Keywords added
- [ ] Privacy policy hosted and URL added
- [ ] Support URL added
- [ ] Demo account created and tested
- [ ] App Store Connect app created
- [ ] Build uploaded and processed
- [ ] All metadata filled in App Store Connect
- [ ] Age rating completed
- [ ] Pricing set
- [ ] Privacy questions answered

### Recommended (Should Have)
- [ ] App preview video (15-30 seconds)
- [ ] Marketing URL
- [ ] Promotional text
- [ ] App tested on multiple devices
- [ ] All features working offline
- [ ] Error handling tested
- [ ] Loading states working

### Optional (Nice to Have)
- [ ] Press kit prepared
- [ ] Social media accounts created
- [ ] Landing page created
- [ ] Beta testing completed (TestFlight)

---

## 🎯 Quick Start Commands

### Build for Testing
```bash
xcodebuild -project "Minds Flow.xcodeproj" \
  -scheme "Minds Flow" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max' \
  build
```

### Run Tests
```bash
xcodebuild test \
  -project "Minds Flow.xcodeproj" \
  -scheme "Minds Flow" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max'
```

### Archive (via Xcode GUI)
1. Select "Any iOS Device"
2. Product → Archive
3. Wait for completion

---

## 📞 Support & Resources

### Apple Resources
- **App Store Connect:** https://appstoreconnect.apple.com
- **Developer Portal:** https://developer.apple.com
- **Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/

### Minds Flow Resources
- **GitHub:** https://github.com/olanderteam/mindsflowswift
- **Documentation:** See SETUP.md, SECURITY.md, PRE-LAUNCH-CHECKLIST.md

---

## 🚨 Important Notes

### 1. First Submission
- Review typically takes 24-48 hours
- May take longer during holidays
- Be prepared to respond to reviewer questions

### 2. Credentials Security
- Current hardcoded credentials are acceptable for v1.0
- Plan to implement secure storage for v1.1
- See SECURITY.md for implementation guide

### 3. Demo Account
- Keep demo account active
- Don't delete demo data
- Ensure it works before submission

### 4. Updates
- After approval, updates are faster (usually 24 hours)
- Keep version numbers incremental
- Document changes in "What's New"

---

## ✅ Ready to Submit?

Once you complete all items in the checklist:

1. ✅ Archive your app in Xcode
2. ✅ Validate the archive
3. ✅ Upload to App Store Connect
4. ✅ Complete all metadata
5. ✅ Add screenshots
6. ✅ Submit for review
7. ⏳ Wait for approval
8. 🎉 Launch!

---

**Good luck with your submission! 🚀**

**Questions?** Check the resources above or contact Apple Developer Support.

---

**Document Version:** 1.0  
**Last Updated:** December 3, 2025  
**Next Review:** After first submission
