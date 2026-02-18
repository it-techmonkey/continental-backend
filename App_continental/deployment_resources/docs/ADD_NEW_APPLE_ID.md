# How to Add New Apple ID to Xcode

## Current Situation:
- Only `mrao23956@gmail.com` is visible in Xcode Accounts
- Need to add `mrao27488@gmail.com`

## Steps to Add New Apple ID:

### Step 1: Add the Account
1. In the Xcode Accounts window (which is currently open)
2. Look at the bottom left of the "Apple IDs" section
3. Click the **"+"** (plus) button
4. A dropdown menu will appear
5. Select **"Apple ID"** from the dropdown

### Step 2: Sign In
1. A sign-in dialog will appear
2. Enter the email: `mrao27488@gmail.com`
3. Enter the password for that account
4. Click **"Next"** or **"Sign In"**

### Step 3: Two-Factor Authentication (if prompted)
1. If the account has 2FA enabled, you'll be asked for a verification code
2. Enter the code sent to your trusted device
3. Complete the sign-in process

### Step 4: Verify Account is Added
1. After signing in, you should see **both accounts** in the list:
   - `mrao23956@gmail.com`
   - `mrao27488@gmail.com` ✅ (newly added)
2. Select `mrao27488@gmail.com` to see its details

### Step 5: Download Certificates
1. With `mrao27488@gmail.com` selected
2. Click **"Download Manual Profiles"** button
3. Wait for it to complete
4. Check if there's a Team listed (it might show "Personal Team" or a company team)

### Step 6: Close and Go to Project Settings
1. Close the Accounts window
2. Go back to your project
3. Click **"Runner"** → **"Runner" target** → **"Signing & Capabilities"**
4. Change the **Team** dropdown to the team for `mrao27488@gmail.com`

## Troubleshooting:

### If "+" button doesn't work:
- Make sure you're in the Accounts tab
- Try clicking the "+" button at the bottom of the Apple IDs list

### If sign-in fails:
- Make sure you're using the correct password
- Check if the account has 2FA enabled (you'll need the code)
- Make sure the account has Apple Developer access

### If no Team appears:
- The account might not have an Apple Developer Program membership
- You need a paid developer account ($99/year) to upload to TestFlight
- Personal Team (free) can only test on your own devices, not TestFlight

### If you see "Personal Team" only:
- Personal Team = Free account (can't upload to TestFlight)
- You need an Apple Developer Program membership ($99/year) for TestFlight
- Make sure `mrao27488@gmail.com` has an active developer account

## Important Notes:

⚠️ **Developer Account Required**:
- To upload to TestFlight, you need a **paid Apple Developer Program** membership
- Free "Personal Team" accounts cannot upload to TestFlight
- Cost: $99/year

⚠️ **Account Type**:
- If you see "Personal Team" → Free account (TestFlight not available)
- If you see a company/team name → Paid developer account (TestFlight available)

## Quick Steps Summary:
1. Click **"+"** button in Accounts window
2. Select **"Apple ID"**
3. Sign in with `mrao27488@gmail.com`
4. Complete 2FA if prompted
5. Download profiles
6. Change Team in project settings

Good luck! 🚀

