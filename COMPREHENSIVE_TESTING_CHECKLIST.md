# 🔮 Crystal Grimoire V3 - Comprehensive Testing Checklist

## Testing Environment
- **URL**: https://crystalgrimoire-v3-production.web.app
- **Browser**: Chrome (recommended)
- **Platform**: Web (Desktop)

---

## 1. 🔐 AUTHENTICATION SYSTEM

### ✅ Google Sign-In
- [ ] Click "Start Your Crystal Journey" button
- [ ] Click Google Sign-in button 
- [ ] Verify Google OAuth popup/redirect works
- [ ] Confirm successful login and redirect to home
- [ ] Check user name appears in header
- [ ] Verify authentication persists on page refresh

### ✅ Logout Functionality
- [ ] Navigate to Account/Settings screen
- [ ] Click logout button
- [ ] Verify return to auth gate screen
- [ ] Confirm no cached user data remains

### ✅ Auth Persistence
- [ ] Sign in with Google
- [ ] Close browser tab
- [ ] Reopen app URL
- [ ] Verify automatic sign-in without re-authentication

---

## 2. 📸 CRYSTAL IDENTIFICATION

### ✅ Main Crystal ID Widget
- [ ] Verify prominent Crystal ID card is visible on home screen
- [ ] Check "Crystal Identification" button is large and prominent
- [ ] Verify correct usage count display (5 left for free users)
- [ ] Test "Watch ad for +1 ID" functionality

### ✅ Photo Upload Process
- [ ] Click Crystal Identification button
- [ ] Verify camera screen opens
- [ ] Test photo upload from device
- [ ] Test photo capture with camera (if available)
- [ ] Verify loading screen during AI analysis

### ✅ AI Analysis Results
- [ ] Upload crystal photo
- [ ] Verify AI returns crystal identification
- [ ] Check all crystal properties are displayed:
  - [ ] Crystal name and variety
  - [ ] Metaphysical properties
  - [ ] Chakras and zodiac signs
  - [ ] Healing properties
  - [ ] Physical properties
  - [ ] Care instructions
- [ ] Test "Add to Collection" button functionality

### ✅ Ad Reward System (Free Users)
- [ ] Verify ad dialog appears for free users
- [ ] Test "Watch Ad" button
- [ ] Verify video loading screen plays
- [ ] Confirm +1 identification granted after ad
- [ ] Test usage limit enforcement

---

## 3. 💎 CRYSTAL COLLECTION

### ✅ Collection Screen Access
- [ ] Navigate to Collection via bottom nav
- [ ] Navigate to Collection via main features grid
- [ ] Verify collection screen loads properly

### ✅ Collection Management
- [ ] View existing crystal collection
- [ ] Test "Add Crystal" button
- [ ] Add crystal manually with all fields
- [ ] Edit existing crystal details
- [ ] Delete crystal from collection
- [ ] Verify crystal search/filter functionality

### ✅ Collection Display
- [ ] Verify crystal cards show correct information
- [ ] Test crystal detail view
- [ ] Check crystal images display properly
- [ ] Verify acquisition date and notes

### ✅ Data Persistence
- [ ] Add crystal to collection
- [ ] Refresh page
- [ ] Verify crystal remains in collection
- [ ] Check sync across different screens

---

## 4. 🌟 SPIRITUAL GUIDANCE

### ✅ Guidance Screen Access
- [ ] Navigate to guidance (PRO users only)
- [ ] For free users, verify PRO upgrade prompt

### ✅ Personalized AI Responses
- [ ] Input spiritual question
- [ ] Verify AI response includes:
  - [ ] User's birth chart information
  - [ ] Reference to user's crystal collection
  - [ ] Personalized recommendations
- [ ] Test different types of guidance requests

### ✅ Response Quality
- [ ] Check responses are relevant and helpful
- [ ] Verify responses reference user's actual crystals
- [ ] Test follow-up questions functionality

---

## 5. 👤 PROFILE & ACCOUNT MANAGEMENT

### ✅ Account Screen
- [ ] Navigate to Account screen
- [ ] Verify user profile information displays
- [ ] Check subscription tier display
- [ ] Test profile edit functionality

### ✅ Birth Chart Integration
- [ ] Add birth date, time, and location
- [ ] Verify birth chart calculation
- [ ] Check astrological information display
- [ ] Test birth chart integration in guidance

### ✅ Subscription Management
- [ ] View current subscription tier
- [ ] Test upgrade to Premium/PRO
- [ ] Verify feature access changes with tier
- [ ] Check subscription persistence

---

## 6. 🛍️ MARKETPLACE

### ✅ Marketplace Access
- [ ] Navigate to Marketplace screen
- [ ] Verify crystal listings display
- [ ] Test search and filter functionality

### ✅ Marketplace Features
- [ ] Browse crystal listings
- [ ] View crystal details
- [ ] Test buy/sell functionality (if implemented)
- [ ] Verify user permissions based on tier

---

## 7. ⚙️ SETTINGS & PREFERENCES

### ✅ Settings Screen
- [ ] Navigate to Settings screen
- [ ] Test all toggle switches
- [ ] Verify preference changes save
- [ ] Test logout functionality

### ✅ App Preferences
- [ ] Notification settings
- [ ] Theme preferences (if available)
- [ ] Language settings (if available)
- [ ] Privacy settings

---

## 8. 🌙 ADDITIONAL FEATURES

### ✅ Moon Rituals (PRO Feature)
- [ ] Access Moon Ritual screen
- [ ] View current moon phase
- [ ] Browse ritual recommendations
- [ ] Test ritual planning functionality

### ✅ Crystal Healing (PRO Feature)
- [ ] Access Crystal Healing screen
- [ ] Test chakra assessment
- [ ] Use owned crystals in healing sessions
- [ ] Verify guided meditation functionality

### ✅ Sound Bath (PRO Feature)
- [ ] Access Sound Bath screen
- [ ] Test audio playback
- [ ] Verify multiple sound options
- [ ] Test timer functionality

### ✅ Journal (PRO Feature)
- [ ] Access Journal screen
- [ ] Create new journal entry
- [ ] Attach crystals to entries
- [ ] View entry history

---

## 9. 🎨 UI/UX TESTING

### ✅ Navigation
- [ ] Test bottom navigation bar
- [ ] Verify all screen transitions
- [ ] Check back button functionality
- [ ] Test deep linking (if available)

### ✅ Visual Elements
- [ ] Verify all animations play smoothly
- [ ] Check color scheme consistency
- [ ] Test responsive design elements
- [ ] Verify loading states display properly

### ✅ Interactive Elements
- [ ] Test all buttons and taps
- [ ] Verify form validation
- [ ] Check error message display
- [ ] Test gesture controls

---

## 10. 📊 DATA SYNC & PERSISTENCE

### ✅ Cross-Feature Integration
- [ ] Add crystal via identification
- [ ] Verify it appears in collection
- [ ] Use crystal in guidance session
- [ ] Check integration across all features

### ✅ Real-time Sync
- [ ] Make changes in one screen
- [ ] Navigate to another screen
- [ ] Verify changes are reflected immediately

### ✅ Offline Capability
- [ ] Test app with poor connection
- [ ] Verify cached data availability
- [ ] Check sync when connection restored

---

## 11. 🚨 ERROR HANDLING

### ✅ Network Errors
- [ ] Test with no internet connection
- [ ] Verify appropriate error messages
- [ ] Check graceful degradation

### ✅ Input Validation
- [ ] Test invalid form inputs
- [ ] Verify validation messages
- [ ] Check required field enforcement

### ✅ Edge Cases
- [ ] Test with empty collection
- [ ] Upload invalid image file
- [ ] Test extremely long text inputs
- [ ] Check behavior with missing data

---

## 12. 💰 MONETIZATION FEATURES

### ✅ Ad Display
- [ ] Verify banner ads display for free users
- [ ] Check ad placement and sizing
- [ ] Test ad interaction
- [ ] Verify ads hidden for premium users

### ✅ Subscription Prompts
- [ ] Test PRO feature access restrictions
- [ ] Verify upgrade prompts display
- [ ] Check subscription flow
- [ ] Test feature unlock after upgrade

---

## TESTING RESULTS TRACKING

### Status Key:
- ✅ **PASS** - Feature works correctly
- ❌ **FAIL** - Feature broken or not working
- ⚠️ **ISSUE** - Feature works but has problems
- 🔄 **TESTING** - Currently being tested
- ⏸️ **SKIP** - Not applicable or not implemented

### Notes Section:
```
Date: ___________
Tester: ___________

Issues Found:
1. 
2. 
3. 

Suggestions:
1.
2.
3.
```

---

## PRIORITY TESTING ORDER

1. **Authentication** (Complete login flow)
2. **Crystal Identification** (Core feature)
3. **Collection Management** (Data persistence)
4. **Navigation** (All screen access)
5. **Profile/Settings** (User data)
6. **PRO Features** (Advanced functionality)
7. **UI/UX Polish** (Visual and interaction)
8. **Error Handling** (Edge cases)

Let's start testing systematically! 🚀