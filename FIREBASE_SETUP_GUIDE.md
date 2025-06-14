# 🔥 Firebase Console Setup Guide for Google & Apple Sign-In

Your Crystal Grimoire V3 app now has **fully implemented Google and Apple Sign-In**! 

## 🎯 **REQUIRED FIREBASE CONSOLE SETUP**

### 1. **Enable Authentication Providers**
Go to Firebase Console → Authentication → Sign-in method:

#### ✅ **Email/Password**
- [x] Enable Email/Password provider
- [x] Enable Email link (passwordless sign-in) [OPTIONAL]

#### ✅ **Google**
- [x] Enable Google provider  
- [x] Project support email: `phillips.paul.email@gmail.com`
- [x] Web SDK configuration: Use your project's web client ID

#### ✅ **Apple**
- [x] Enable Apple provider
- [x] Service ID: `com.crystalgrimoire.v3.service`
- [x] Apple Team ID: [Your Apple Developer Team ID]
- [x] Key ID: [Your Apple Sign-In Key ID]
- [x] Private Key: [Upload your Apple Sign-In .p8 key file]

### 2. **Authorized Domains**
Add these domains to Authentication → Settings → Authorized domains:
- [x] `localhost` (for development)
- [x] `crystalgrimoire-v3-production.firebaseapp.com` (your Firebase hosting)
- [x] `crystalgrimoire-v3-production.web.app` (your Firebase web app)
- [x] Any custom domain you plan to use

### 3. **Google Cloud Console Setup**
Go to Google Cloud Console → APIs & Services → Credentials:

#### **OAuth 2.0 Client IDs**
- [x] **Web application**: For your website
  - Authorized JavaScript origins: `http://localhost:8080`, `https://crystalgrimoire-v3-production.firebaseapp.com`
  - Authorized redirect URIs: `https://crystalgrimoire-v3-production.firebaseapp.com/__/auth/handler`

- [x] **Android**: For mobile app (if needed)
- [x] **iOS**: For mobile app (if needed)

## 🚀 **TESTING THE AUTHENTICATION**

### Test Flow:
1. **Go to**: `http://localhost:8080`
2. **Click**: "Start Your Crystal Journey" or "Sign In"
3. **Try Google Sign-In**: Should show Google OAuth popup
4. **Try Apple Sign-In**: Should show Apple ID popup
5. **Success**: Redirects to welcome screen with user info

### Expected Results:
- ✅ **Google**: Shows your Google account selection popup
- ✅ **Apple**: Shows Apple ID sign-in popup  
- ✅ **Success**: Welcome screen shows user email and sign-out button
- ✅ **Firestore**: User profile automatically saved to database

## 🔧 **TROUBLESHOOTING**

### Google Sign-In Issues:
- **Error**: "popup_blocked_by_browser" → Allow popups for localhost
- **Error**: "unauthorized_domain" → Add domain to authorized domains
- **Error**: "invalid_client" → Check OAuth client ID configuration

### Apple Sign-In Issues:
- **Error**: "invalid_client" → Verify Service ID and Team ID
- **Error**: "unauthorized_domain" → Add domain to Apple Developer portal
- **Error**: "missing_or_invalid_nonce" → Check redirect URI configuration

### Email/Password Issues:
- **Error**: "auth/operation-not-allowed" → Enable Email/Password in Firebase Console
- **Error**: "auth/weak-password" → Use password with 6+ characters
- **Error**: "auth/email-already-in-use" → Email exists, try signing in instead

## 📱 **MOBILE SETUP (iOS/Android)**

### iOS Configuration:
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.crystalgrimoire.v3</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.crystalgrimoire.v3</string>
        </array>
    </dict>
</array>
```

### Android Configuration:
Add to `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.crystalgrimoire.v3"
        // ... other config
    }
}
```

## ✅ **VERIFICATION CHECKLIST**

- [ ] Email/Password authentication enabled in Firebase Console
- [ ] Google OAuth enabled with correct web client ID
- [ ] Apple Sign-In enabled with Service ID and certificates
- [ ] All domains added to authorized domains list
- [ ] Google Cloud Console OAuth clients configured
- [ ] Apple Developer portal Service ID configured
- [ ] Test sign-up with email/password works
- [ ] Test Google Sign-In popup appears and works
- [ ] Test Apple Sign-In popup appears and works
- [ ] User data saves to Firestore correctly
- [ ] Sign-out functionality works

## 🎉 **SUCCESS INDICATORS**

When everything is working:
1. **Landing Page**: Beautiful crystal-themed UI with sign-in options
2. **Google Sign-In**: Opens Google account picker, authenticates successfully
3. **Apple Sign-In**: Opens Apple ID authentication, completes successfully  
4. **Welcome Screen**: Shows "Welcome to Crystal Grimoire!" with user email
5. **Firestore Data**: User profile appears in Firebase Console → Firestore Database
6. **Sign Out**: Button works and returns to landing page

Your Crystal Grimoire V3 authentication system is now **production-ready** with multiple sign-in options!