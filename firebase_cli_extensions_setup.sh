#!/bin/bash
# Firebase CLI Extensions Setup for Crystal Grimoire V0.3
# Run this script to install all production extensions

# Make sure you're logged in and have the right project
echo "🔮 CRYSTAL GRIMOIRE - FIREBASE EXTENSIONS SETUP"
echo "================================================"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Install with: npm install -g firebase-tools"
    exit 1
fi

# Login and select project
echo "🔐 Logging into Firebase..."
firebase login
firebase use crystalgrimoire-production

echo "📦 Installing Firebase Extensions..."

# 1. STRIPE PAYMENTS (Revenue Core)
echo "💳 Installing Stripe Payments..."
firebase ext:install stripe/firestore-stripe-payments \
  --params='{
    "STRIPE_SECRET_KEY": "YOUR_STRIPE_SECRET_KEY
    "PRODUCTS_COLLECTION": "products",
    "CUSTOMERS_COLLECTION": "customers", 
    "SUBSCRIPTIONS_COLLECTION": "subscriptions",
    "SYNC_USERS_ON_CREATE": "true",
    "AUTOMATICALLY_TAX": "true"
  }'

# 2. RESIZE IMAGES (Crystal Photo Optimization)
echo "🖼️ Installing Image Resize..."
firebase ext:install firebase/storage-resize-images \
  --params='{
    "IMG_BUCKET": "crystalgrimoire-production.appspot.com",
    "IMG_SIZES": "200x200,400x400,800x800,1200x1200,1920x1920",
    "IMG_TYPE": "webp",
    "WEBP_QUALITY": "85",
    "IMG_DELETE_ORIGINAL": "false",
    "FUNCTION_MEMORY": "2GB",
    "INCLUDE_PATH_LIST": "crystal_uploads,user_photos,collection_images"
  }'

# 3. SEND EMAIL (User Engagement)
echo "📧 Installing Email Trigger..."
firebase ext:install firebase/firestore-send-email \
  --params='{
    "SMTP_CONNECTION_URI": "smtps://phillips.paul.email%40gmail.com:your_app_password@smtp.gmail.com:465",
    "DEFAULT_FROM": "Crystal Grimoire <noreply@crystalgrimoire.com>",
    "EMAIL_COLLECTION": "mail",
    "USERS_COLLECTION": "users",
    "ENABLE_HTML_TEMPLATES": "true",
    "ENABLE_OPEN_TRACKING": "true",
    "ENABLE_CLICK_TRACKING": "true"
  }'

# 4. FCM MESSAGING (Push Notifications)
echo "📱 Installing FCM Messaging..."
firebase ext:install firebase/firestore-send-fcm \
  --params='{
    "COLLECTION_PATH": "notifications",
    "TOKEN_FIELD": "fcm_token",
    "PAYLOAD_FIELD": "notification_payload",
    "DEFAULT_TTL": "86400",
    "BATCH_SIZE": "500",
    "PRIORITY": "high",
    "ENABLE_MESSAGE_ANALYTICS": "true"
  }'

# 5. AUTH CUSTOM CLAIMS (Subscription Management)
echo "🔐 Installing Auth Custom Claims..."
firebase ext:install firebase/auth-custom-claims \
  --params='{
    "CLAIMS_COLLECTION": "user_claims",
    "USER_COLLECTION": "users",
    "CLAIMS_FIELD": "custom_claims",
    "SUBSCRIPTION_FIELD": "subscription_tier",
    "PREMIUM_CLAIM": "is_premium",
    "AUTO_SET_CLAIMS": "true",
    "ADMIN_EMAILS": "phillips.paul.email@gmail.com"
  }'

# 6. BIGQUERY EXPORT (Analytics)
echo "📊 Installing BigQuery Export..."
firebase ext:install firebase/firestore-bigquery-export \
  --params='{
    "PROJECT_ID": "crystalgrimoire-production",
    "DATASET_ID": "crystal_analytics",
    "TABLE_ID": "firestore_export",
    "COLLECTION_PATH": "users/{userId}/crystal_sessions,crystal_identifications,user_analytics",
    "DATASET_LOCATION": "us-central1",
    "CLUSTERING_FIELDS": "user_id,timestamp,crystal_type",
    "PARTITION_FIELD": "timestamp",
    "PARTITION_TYPE": "DAY"
  }'

# 7. ALGOLIA SEARCH (Crystal Database Search)
echo "🔍 Installing Algolia Search..."
firebase ext:install algolia/firestore-algolia-search \
  --params='{
    "ALGOLIA_APP_ID": "your_algolia_app_id",
    "ALGOLIA_API_KEY": "your_algolia_admin_api_key",
    "ALGOLIA_INDEX_NAME": "crystal_database",
    "COLLECTION_PATH": "crystal_database",
    "FIELDS": "name,scientific_name,color,chakra,zodiac,healing_properties,description",
    "SYNC_MODE": "update",
    "BATCH_SIZE": "1000"
  }'

echo "✅ EXTENSIONS INSTALLATION COMPLETE!"
echo ""
echo "📋 NEXT STEPS:"
echo "1. Configure your Stripe webhook endpoints"
echo "2. Set up your Gmail app password for SMTP"
echo "3. Get your Algolia API keys"
echo "4. Configure BigQuery permissions"
echo "5. Test each extension in the Firebase console"
echo ""
echo "🔮 Crystal Grimoire is now enterprise-ready!"

# Show installed extensions
echo "📦 Currently installed extensions:"
firebase ext:list