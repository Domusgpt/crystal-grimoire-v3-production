# CORRECT FIREBASE CLI COMMANDS - Updated Syntax

## 🚀 Proper Firebase CLI Extension Installation

### Current Firebase CLI Syntax (2025):
```bash
# Interactive installation (recommended for first time)
firebase ext:install stripe/firestore-stripe-payments

# With params file
firebase ext:install stripe/firestore-stripe-payments --params-file=config.json

# With inline params  
firebase ext:install stripe/firestore-stripe-payments --params=KEY1=value1,KEY2=value2
```

---

## 💳 1. STRIPE PAYMENTS - INTERACTIVE
```bash
# Navigate to your project directory first
cd /mnt/c/Users/millz/Desktop/CrystalGrimoireV0.3\(current\)

# Select project
firebase use crystalgrimoire-production

# Install interactively (RECOMMENDED)
firebase ext:install stripe/firestore-stripe-payments
```

**The CLI will prompt you for:**
- STRIPE_SECRET_KEY: `YOUR_STRIPE_SECRET_KEY
- PRODUCTS_COLLECTION: `products`
- CUSTOMERS_COLLECTION: `customers`
- SUBSCRIPTIONS_COLLECTION: `subscriptions`
- SYNC_USERS_ON_CREATE: `yes`

---

## 🖼️ 2. RESIZE IMAGES - INTERACTIVE
```bash
firebase ext:install firebase/storage-resize-images
```

**Prompts will ask for:**
- IMG_BUCKET: `crystalgrimoire-production.appspot.com`
- IMG_SIZES: `200x200,400x400,800x800,1200x1200`
- IMG_TYPE: `webp`
- WEBP_QUALITY: `85`
- IMG_DELETE_ORIGINAL: `no`

---

## 📧 3. SEND EMAIL - INTERACTIVE  
```bash
firebase ext:install firebase/firestore-send-email
```

**You'll be prompted for:**
- SMTP_CONNECTION_URI: `smtps://phillips.paul.email%40gmail.com:YOUR_APP_PASSWORD@smtp.gmail.com:465`
- DEFAULT_FROM: `Crystal Grimoire <noreply@crystalgrimoire.com>`
- EMAIL_COLLECTION: `mail`

---

## 🔧 ALTERNATIVE: Using Extension Manifest

Create `firebase-extensions.json`:
```json
{
  "stripe-payments": {
    "source": "stripe/firestore-stripe-payments",
    "params": {
      "STRIPE_SECRET_KEY": "YOUR_STRIPE_SECRET_KEY
      "PRODUCTS_COLLECTION": "products",
      "CUSTOMERS_COLLECTION": "customers",
      "SUBSCRIPTIONS_COLLECTION": "subscriptions",
      "SYNC_USERS_ON_CREATE": "yes"
    }
  },
  "image-resize": {
    "source": "firebase/storage-resize-images", 
    "params": {
      "IMG_BUCKET": "crystalgrimoire-production.appspot.com",
      "IMG_SIZES": "200x200,400x400,800x800,1200x1200",
      "IMG_TYPE": "webp",
      "WEBP_QUALITY": "85"
    }
  }
}
```

Then install from manifest:
```bash
firebase deploy --only extensions
```

---

## 📋 STEP-BY-STEP INSTALLATION GUIDE

### 1. **Check Firebase CLI Version**
```bash
firebase --version
# Should be 12.0.0 or higher for latest features
```

### 2. **Update if needed**
```bash
npm install -g firebase-tools@latest
```

### 3. **Login and Set Project**
```bash
firebase login
firebase projects:list
firebase use crystalgrimoire-production
```

### 4. **Install Extensions One by One**
```bash
# Start with most critical
firebase ext:install stripe/firestore-stripe-payments

# Then image processing
firebase ext:install firebase/storage-resize-images

# User engagement
firebase ext:install firebase/firestore-send-email

# Push notifications
firebase ext:install firebase/firestore-send-fcm

# And so on...
```

### 5. **Check Installation Status**
```bash
firebase ext:list
```

---

## 🚨 COMMON ISSUES & FIXES

### **Issue: "unknown option --params"**
**Solution:** Use interactive mode or `--params-file`

### **Issue: "Extension not found"**
**Solution:** Check extension name with `firebase ext:browse`

### **Issue: "Permission denied"**
**Solution:** Make sure you have Firebase admin access

### **Issue: "Billing required"**
**Solution:** Enable billing in Firebase console

---

## 💡 PRO TIPS

1. **Use Interactive Mode First**: Easier to understand what each param does
2. **Save Responses**: CLI shows the params file after interactive install
3. **Test in Development**: Install on test project first
4. **Check Logs**: `firebase functions:log` shows extension activity
5. **Read Documentation**: Each extension has specific setup requirements

---

## 🔥 QUICK START COMMANDS

```bash
# Essential setup
cd /mnt/c/Users/millz/Desktop/CrystalGrimoireV0.3\(current\)
firebase use crystalgrimoire-production

# Install core extensions
firebase ext:install stripe/firestore-stripe-payments
firebase ext:install firebase/storage-resize-images  
firebase ext:install firebase/firestore-send-email

# Check what's installed
firebase ext:list

# View in console
firebase open extensions
```

**Use INTERACTIVE MODE - it's much easier and shows you exactly what each parameter does!**