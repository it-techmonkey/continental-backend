# How to Change Apple ID/Team for Signing

## Current Situation:
- Current account: `mrao23956@gmail.com` (Sameer Rao - Personal Team)
- Desired account: `mrao27488@gmail.com`
- New account is added but not selected

## Steps to Change:

### Step 1: Verify New Account is Added
1. In Xcode, go to **Xcode** → **Settings** (or **Preferences**)
2. Click the **"Accounts"** tab
3. You should see both accounts listed:
   - `mrao23956@gmail.com`
   - `mrao27488@gmail.com` ✅ (should be there)
3r
### Step 2: Download Certificates for New Account
1. In the Accounts window, select `mrao27488@gmail.com`
2. Click **"Download Manual Profiles"** button
3. Wait for it to complete
4. Click **"Manage Certificates..."** if needed
5. Close the Accounts window

### Step 3: Change Team in Project Settings
1. In Xcode, go back to your project
2. Click on **"Runner"** in the left sidebar (blue icon)
3. Select the **"Runner"** target
4. Click the **"Signing & Capabilities"** tab
5. Under **"Team"**, click the dropdown
6. Select the team associated with `mrao27488@gmail.com`
   - It might show as "Your Name (Team)" or just the email
7. Xcode will automatically update the provisioning profile

### Step 4: Verify Bundle Identifier
1. Make sure the **Bundle Identifier** is still `com.continentalapp.mobile`
2. If there's an error, you may need to:
   - Change the bundle ID to something unique (e.g., `com.yourcompany.continental`)
   - Or use the bundle ID associated with the new account in App Store Connect

### Step 5: Check for Errors
1. Look for any red error messages in the Signing & Capabilities section
2. If you see "No profiles for 'com.continentalapp.mobile' were found":
   - You may need to create an app in App Store Connect with this bundle ID
   - Or change the bundle ID to match an existing app

## Important Notes:

⚠️ **Bundle Identifier**: 
- If `com.continentalapp.mobile` is already registered to the old account, you'll need to either:
  - Use a different bundle ID for the new account
  - Transfer the app in App Store Connect (if possible)
  - Or use the old account for this app

⚠️ **App Store Connect**:
- Make sure the app exists in App Store Connect under the new account
- Or create a new app with the new account

## Quick Checklist:
- [ ] New account (`mrao27488@gmail.com`) is added in Xcode Accounts
- [ ] Certificates downloaded for new account
- [ ] Team changed in Signing & Capabilities
- [ ] Bundle Identifier is correct/unique
- [ ] No signing errors shown
- [ ] Ready to archive!

## If You Get Errors:

### Error: "No profiles found"
**Solution**: Create the app in App Store Connect first, or change bundle ID

### Error: "Bundle identifier is already in use"
**Solution**: 
- Use a different bundle ID (e.g., `com.yourcompany.continental`)
- Or use the account that owns the existing bundle ID

### Error: "Team not found"
**Solution**: 
- Make sure you're logged into the correct Apple ID in Xcode
- Download certificates again
- Check App Store Connect to verify the account has a developer program membership

Good luck! 🚀

