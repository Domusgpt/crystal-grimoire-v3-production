# FIREBASE CLI COMMANDS - Individual Extension Installation

## 🚀 Quick Setup Commands

### Prerequisites
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Select your project
firebase use crystalgrimoire-production

# List available extensions
firebase ext:browse
```

---

## 💳 1. STRIPE PAYMENTS
```bash
firebase ext:install stripe/firestore-stripe-payments \
  --project=crystalgrimoire-production \
  --params-file=stripe-payments-config.json
```

**Create `stripe-payments-config.json`:**
```json
{
  "STRIPE_SECRET_KEY": "YOUR_STRIPE_SECRET_KEY
  "PRODUCTS_COLLECTION": "products",
  "CUSTOMERS_COLLECTION": "customers",
  "SUBSCRIPTIONS_COLLECTION": "subscriptions",
  "SYNC_USERS_ON_CREATE": "true",
  "DELETE_STRIPE_CUSTOMERS": "false",
  "AUTOMATICALLY_TAX": "true",
  "CUSTOMER_PORTAL_URL": "https://crystalgrimoire.com/billing"
}
```

---

## 🖼️ 2. RESIZE IMAGES
```bash
firebase ext:install firebase/storage-resize-images \
  --project=crystalgrimoire-production \
  --params=image-resize-config.json
```

**Create `image-resize-config.json`:**
```json
{
  "IMG_BUCKET": "crystalgrimoire-production.appspot.com",
  "IMG_SIZES": "200x200,400x400,800x800,1200x1200,1920x1920",
  "IMG_TYPE": "webp",
  "WEBP_QUALITY": "85",
  "JPEG_QUALITY": "90",
  "IMG_DELETE_ORIGINAL": "false",
  "FUNCTION_MEMORY": "2GB",
  "FUNCTION_TIMEOUT": "540",
  "INCLUDE_PATH_LIST": "crystal_uploads,user_photos,collection_images",
  "CACHE_CONTROL_HEADER": "public,max-age=31536000"
}
```

---

## 📧 3. SEND EMAIL
```bash
firebase ext:install firebase/firestore-send-email \
  --project=crystalgrimoire-production \
  --params=email-config.json
```

**Create `email-config.json`:**
```json
{
  "SMTP_CONNECTION_URI": "smtps://phillips.paul.email%40gmail.com:your_gmail_app_password@smtp.gmail.com:465",
  "DEFAULT_FROM": "Crystal Grimoire <noreply@crystalgrimoire.com>",
  "DEFAULT_REPLY_TO": "support@crystalgrimoire.com",
  "EMAIL_COLLECTION": "mail",
  "USERS_COLLECTION": "users",
  "TEMPLATES_COLLECTION": "email_templates",
  "ENABLE_HTML_TEMPLATES": "true",
  "ENABLE_OPEN_TRACKING": "true",
  "ENABLE_CLICK_TRACKING": "true",
  "DELIVERY_ATTEMPTS": "3"
}
```

---

## 📱 4. FCM MESSAGING
```bash
firebase ext:install firebase/firestore-send-fcm \
  --project=crystalgrimoire-production \
  --params=fcm-config.json
```

**Create `fcm-config.json`:**
```json
{
  "COLLECTION_PATH": "notifications",
  "TOKEN_FIELD": "fcm_token",
  "PAYLOAD_FIELD": "notification_payload",
  "TTL_FIELD": "ttl",
  "DEFAULT_TTL": "86400",
  "BATCH_SIZE": "500",
  "MAX_RETRY_ATTEMPTS": "3",
  "PRIORITY": "high",
  "ENABLE_MESSAGE_ANALYTICS": "true",
  "TRACK_OPENS": "true"
}
```

---

## 🔐 5. AUTH CUSTOM CLAIMS
```bash
firebase ext:install firebase/auth-custom-claims \
  --project=crystalgrimoire-production \
  --params=auth-claims-config.json
```

**Create `auth-claims-config.json`:**
```json
{
  "CLAIMS_COLLECTION": "user_claims",
  "USER_COLLECTION": "users",
  "CLAIMS_FIELD": "custom_claims",
  "SUBSCRIPTION_FIELD": "subscription_tier",
  "SUBSCRIPTION_STATUS_FIELD": "subscription_status",
  "PREMIUM_CLAIM": "is_premium",
  "TIER_CLAIM": "subscription_tier",
  "AUTO_SET_CLAIMS": "true",
  "ADMIN_EMAILS": "phillips.paul.email@gmail.com"
}
```

---

## 📊 6. BIGQUERY EXPORT
```bash
firebase ext:install firebase/firestore-bigquery-export \
  --project=crystalgrimoire-production \
  --params=bigquery-config.json
```

**Create `bigquery-config.json`:**
```json
{
  "PROJECT_ID": "crystalgrimoire-production",
  "DATASET_ID": "crystal_analytics", 
  "TABLE_ID": "firestore_export",
  "COLLECTION_PATH": "users/{userId}/crystal_sessions,crystal_identifications,user_analytics",
  "DATASET_LOCATION": "us-central1",
  "CLUSTERING_FIELDS": "user_id,timestamp,crystal_type",
  "PARTITION_FIELD": "timestamp",
  "PARTITION_TYPE": "DAY",
  "BACKUP_COLLECTION": "true"
}
```

---

## 🔍 7. ALGOLIA SEARCH
```bash
firebase ext:install algolia/firestore-algolia-search \
  --project=crystalgrimoire-production \
  --params=algolia-config.json
```

**Create `algolia-config.json`:**
```json
{
  "ALGOLIA_APP_ID": "your_algolia_app_id_here",
  "ALGOLIA_API_KEY": "your_algolia_admin_api_key_here",
  "ALGOLIA_INDEX_NAME": "crystal_database",
  "COLLECTION_PATH": "crystal_database",
  "FIELDS": "name,scientific_name,color,chakra,zodiac,healing_properties,description,tags",
  "TRANSFORM_FUNCTION": "transform_crystal_data",
  "SYNC_MODE": "update",
  "BATCH_SIZE": "1000",
  "ENABLE_PARTIAL_UPDATES": "true"
}
```

---

## 🎬 8. VIDEO INTELLIGENCE
```bash
firebase ext:install google-cloud/video-intelligence-api \
  --project=crystalgrimoire-production \
  --params=video-config.json
```

**Create `video-config.json`:**
```json
{
  "INPUT_BUCKET": "crystalgrimoire-videos",
  "OUTPUT_BUCKET": "crystalgrimoire-analyzed-videos",
  "ANALYSIS_FEATURES": "LABEL_DETECTION,SPEECH_TRANSCRIPTION,OBJECT_TRACKING",
  "LANGUAGE_CODE": "en-US",
  "MODEL": "latest",
  "OUTPUT_FORMAT": "json",
  "INCLUDE_CONFIDENCE_SCORES": "true",
  "WEBHOOK_URL": "https://crystalgrimoire.com/api/video-analysis-webhook"
}
```

---

## 📈 9. ANALYTICS TO BIGQUERY
```bash
firebase ext:install firebase/analytics-bigquery-export \
  --project=crystalgrimoire-production \
  --params=analytics-bigquery-config.json
```

**Create `analytics-bigquery-config.json`:**
```json
{
  "PROJECT_ID": "crystalgrimoire-production",
  "DATASET_ID": "analytics_crystal_grimoire",
  "DATASET_LOCATION": "us-central1",
  "INCLUDE_ADVERTISING_ID": "false",
  "EXPORT_EVENTS": "true",
  "EXPORT_USER_DATA": "true",
  "DAILY_EXPORT_ENABLED": "true",
  "STREAMING_EXPORT_ENABLED": "true"
}
```

---

## 🛠️ MANAGEMENT COMMANDS

### List all installed extensions
```bash
firebase ext:list --project=crystalgrimoire-production
```

### Update an extension
```bash
firebase ext:update stripe-firestore-stripe-payments --project=crystalgrimoire-production
```

### Configure an extension after installation
```bash
firebase ext:configure stripe-firestore-stripe-payments --project=crystalgrimoire-production
```

### View extension logs
```bash
firebase functions:log --project=crystalgrimoire-production
```

### Uninstall an extension
```bash
firebase ext:uninstall stripe-firestore-stripe-payments --project=crystalgrimoire-production
```

---

## 🚀 BATCH INSTALLATION SCRIPT

Create `install-all-extensions.sh`:
```bash
#!/bin/bash
set -e

echo "🔮 Installing all Crystal Grimoire extensions..."

# Core revenue and processing
firebase ext:install stripe/firestore-stripe-payments --params=stripe-payments-config.json
firebase ext:install firebase/storage-resize-images --params=image-resize-config.json

# User engagement
firebase ext:install firebase/firestore-send-email --params=email-config.json
firebase ext:install firebase/firestore-send-fcm --params=fcm-config.json
firebase ext:install firebase/auth-custom-claims --params=auth-claims-config.json

# Analytics and search
firebase ext:install firebase/firestore-bigquery-export --params=bigquery-config.json
firebase ext:install algolia/firestore-algolia-search --params=algolia-config.json

# Advanced features
firebase ext:install google-cloud/video-intelligence-api --params=video-config.json
firebase ext:install firebase/analytics-bigquery-export --params=analytics-bigquery-config.json

echo "✅ All extensions installed successfully!"
firebase ext:list
```

Make it executable:
```bash
chmod +x install-all-extensions.sh
./install-all-extensions.sh
```

This gives you **COMPLETE CLI CONTROL** over all Firebase Extensions with proper configuration files!