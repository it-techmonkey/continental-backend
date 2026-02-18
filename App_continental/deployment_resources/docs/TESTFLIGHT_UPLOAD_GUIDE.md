# TestFlight Upload Guide

This guide will help you upload your iOS app to TestFlight using Xcode.

## Prerequisites

1. ✅ Apple Developer Account (you mentioned you have access)
2. ✅ Xcode installed on your Mac
3. ✅ App configured with proper Bundle Identifier
4. ✅ Signing certificates set up

## Step-by-Step Instructions

### Step 1: Open the Project in Xcode

1. Navigate to the iOS folder:
   ```bash
   cd App_continental/ios
   ```

2. Open the workspace (NOT the project):
   ```bash
   open Runner.xcworkspace
   ```
   ⚠️ **Important**: Always open `.xcworkspace`, not `.xcodeproj` when using CocoaPods

### Step 2: Configure Signing & Capabilities

1. In Xcode, select the **Runner** project in the left sidebar
2. Select the **Runner** target
3. Go to the **Signing & Capabilities** tab
4. Check **"Automatically manage signing"**
5. Select your **Team** (your Apple Developer account)
6. Xcode will automatically:
   - Create/select a Bundle Identifier
   - Generate provisioning profiles
   - Set up signing certificates

### Step 3: Update Bundle Identifier (if needed)

1. In **Signing & Capabilities**, check the **Bundle Identifier**
2. It should be unique (e.g., `com.yourcompany.continental`)
3. If you need to change it, update it here
4. Make sure it matches your App Store Connect app

### Step 4: Set Build Configuration

1. In the top toolbar, select **"Any iOS Device"** or a specific device
2. Make sure you're NOT selecting a simulator (simulators can't be archived)

### Step 5: Clean Build Folder

1. Go to **Product** → **Clean Build Folder** (or press `Shift + Cmd + K`)
2. This ensures a fresh build

### Step 6: Archive the App

1. Go to **Product** → **Archive**
2. Wait for the build to complete (this may take several minutes)
3. The **Organizer** window will open automatically when the archive is complete

### Step 7: Upload to App Store Connect

1. In the **Organizer** window, you should see your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"**
4. Click **"Next"**
5. Select **"Upload"**
6. Click **"Next"**
7. Review the app information
8. Click **"Upload"**
9. Wait for the upload to complete (this may take 10-30 minutes)

### Step 8: Process in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → Select your app
3. Go to **TestFlight** tab
4. Wait for processing to complete (usually 10-30 minutes)
5. You'll see a notification when processing is done

### Step 9: Add Testers

1. In TestFlight, go to **Internal Testing** or **External Testing**
2. Add testers by:
   - **Internal Testing**: Add team members (up to 100)
   - **External Testing**: Add email addresses (requires Beta App Review)

### Step 10: Testers Install TestFlight

1. Testers need to install the **TestFlight** app from the App Store
2. They'll receive an email invitation
3. They can install your app from TestFlight

## Troubleshooting

### Issue: "No signing certificate found"
**Solution**: 
- Make sure you're logged into Xcode with your Apple ID
- Go to Xcode → Settings → Accounts
- Add your Apple ID if not already added
- Download manual profiles if needed

### Issue: "Bundle identifier is already in use"
**Solution**:
- Change the bundle identifier to something unique
- Or use the existing app in App Store Connect

### Issue: "Archive failed"
**Solution**:
- Make sure you selected "Any iOS Device" (not a simulator)
- Clean build folder and try again
- Check for build errors in the Issue Navigator

### Issue: "Upload failed"
**Solution**:
- Check your internet connection
- Make sure you have the latest Xcode version
- Try uploading again (sometimes it's a temporary issue)

## Quick Commands

```bash
# Navigate to iOS folder
cd App_continental/ios

# Open workspace in Xcode
open Runner.xcworkspace

# Clean Flutter build
cd ../..
flutter clean
flutter pub get

# Build iOS (optional, Xcode will do this)
flutter build ios --release
```

## Notes

- ⚠️ **Always use `.xcworkspace`**, not `.xcodeproj`
- ⚠️ **Archive only works with "Any iOS Device"** selected, not simulators
- ⚠️ **First upload may take longer** (30-60 minutes for processing)
- ⚠️ **External testing requires Beta App Review** (can take 24-48 hours)
- ⚠️ **Internal testing is instant** (no review needed)

## Next Steps After Upload

1. Wait for processing to complete
2. Add testers in App Store Connect
3. Testers install TestFlight app
4. Testers receive invitation email
5. Start testing!

Good luck! 🚀

