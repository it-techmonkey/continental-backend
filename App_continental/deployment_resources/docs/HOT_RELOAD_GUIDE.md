# Hot Reload Guide

## 🔥 How to Reload the Simulator

### Method 1: Hot Reload (Fast - Keeps state)
In the terminal where `flutter run` is running, press:
```
r
```
This reloads the app instantly while keeping the current state.

### Method 2: Hot Restart (Full restart - Clears state)
In the terminal, press:
```
R
```
This fully restarts the app and clears the state.

### Method 3: Stop and Restart
Press:
```
q
```
Then run again:
```bash
flutter run -d "iPhone 16 Pro Max"
```

## ✅ What's New: Authentication Guard

### Protected Routes
All protected pages (Dashboard, Portfolio, Actionable, Menu, etc.) now require authentication.

### How it Works
1. **On App Start:**
   - Checks if user has a valid token
   - If NO token → Redirects to Login
   - If YES token → Allows access to protected pages

2. **When Logging Out:**
   - Clears token and user data
   - Automatically redirects to Login
   - No manual navigation needed

3. **When Logging In:**
   - Stores token securely
   - Navigates to main app (Dashboard)
   - Token is saved for future sessions

### Pages Available Without Auth
- `/` - Splash Screen
- `/onboarding` - Onboarding
- `/login` - Login Screen

### Pages Requiring Auth
- `/bottomnav` - Main App (All tabs)
- `/profile` - Profile
- `/payments` - Payments List
- `/payments/details/:id` - Payment Details
- `/add-property` - Add Property
- `/details/:itemId` - Customer Details

### Testing the Auth Guard

1. **First Time Opening:**
   - App starts at Splash → Onboarding → Login
   - Can only access main app after login

2. **Try to Access Protected Route Without Login:**
   - Open app
   - Manually try to navigate to any protected page
   - Should automatically redirect to Login

3. **After Login:**
   - Login with credentials
   - Navigate freely through all pages
   - Logout from Menu

4. **After Logout:**
   - Token is cleared
   - Cannot access protected pages
   - Must login again

## 🎯 Current Implementation

### Files Changed
1. **lib/utils/app_routes.dart**
   - Added auth redirect logic
   - Provider-based router

2. **lib/main.dart**
   - Updated to use provider-based router
   - Listens to auth state changes

3. **lib/feature/menu/menuScreen.dart**
   - Logout now clears token
   - Proper cleanup

4. **lib/providers/auth_state_provider.dart**
   - Global auth state
   - Token management
   - Login/logout functions

## 🧪 Test Scenarios

### Test 1: First Launch
```
Expected Flow:
1. Splash Screen (2 seconds)
2. Onboarding (swipe through)
3. Login Screen
4. Enter credentials
5. Success → Dashboard
```

### Test 2: Already Logged In
```
Expected Flow:
1. Splash Screen
2. Check if token exists
3. If exists → Go directly to Dashboard
4. If not exists → Go to Onboarding → Login
```

### Test 3: Session Expiry
```
Expected Flow:
1. User has token but session expired
2. Try to access protected page
3. API returns error
4. Redirect to Login
```

### Test 4: Logout Flow
```
Expected Flow:
1. User logged in
2. Click "Log Out" in Menu
3. Token cleared
4. Redirect to Login
5. Cannot access protected pages
```

## 📱 Quick Commands

```bash
# Hot Reload
r

# Hot Restart  
R

# Quit
q

# Clear screen
c

# Help
h
```

## 🐛 Troubleshooting

**Auth guard not working?**
- Press `R` for full restart
- Check if token is being saved (debug logs)

**Can't access pages after login?**
- Check network connectivity
- Verify backend is running
- Check console for errors

**Stuck on login screen?**
- Press `R` to restart
- Try again with valid credentials

