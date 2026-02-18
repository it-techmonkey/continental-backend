# Google Maps Troubleshooting Guide

## Current Issue: White/Blank Map Screen

Your bundle ID is: `com.example.continental`

### Steps to Fix in Google Cloud Console:

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Select your project

2. **Enable Required APIs:**
   - Navigate to: APIs & Services → Library
   - Enable these APIs:
     - **Maps SDK for iOS** ✅
     - **Maps SDK for Android** ✅
     - **Places API** (optional, for future features)

3. **Check API Key Restrictions:**
   - Go to: APIs & Services → Credentials
   - Find your API key: `AIzaSyBwby2gck2kXMs5B7euXe2YzyZ3myq3Ly0`
   - Click to edit
   - Under "Application restrictions":
     - For iOS: Add bundle ID `com.example.continental`
     - For Android: Add package name `com.example.continental`
   - Under "API restrictions":
     - Select "Restrict key"
     - Enable only:
       - Maps SDK for iOS
       - Maps SDK for Android

4. **Check Billing:**
   - Google Maps requires billing to be enabled (even for free tier)
   - Go to: Billing → Link a billing account
   - Free tier includes $200/month credit (usually enough)

5. **Verify Restrictions Match:**
   - Bundle ID must match exactly: `com.example.continental`
   - Case-sensitive!

### Alternative: Use Unrestricted Key (For Testing Only):

For quick testing, you can temporarily remove API restrictions:
- Edit API key
- Under "Application restrictions" → Select "None"
- ⚠️ **WARNING:** Remove restrictions only for testing. Always restrict in production!

### After Making Changes:

1. Wait 5-10 minutes for changes to propagate
2. Fully restart the app (not just hot reload)
3. Delete app from device/simulator
4. Reinstall and test

### Verify API Key is Working:

Check terminal logs for:
- ✅ `🗺️ Map created successfully!` = Good
- ❌ Any Google Maps errors = Check API key restrictions

### Your Current Bundle ID:
- iOS: `com.example.continental`
- Android: `com.example.continental`

Make sure these EXACTLY match in Google Cloud Console!

