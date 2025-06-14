# FIREBASE EXTENSIONS - PRODUCTION CONFIGURATION
## Crystal Grimoire V0.3 - Complete Extension Setup

### 🤖 1. **Firebase AI Logic** (CRITICAL FOR CRYSTAL ID)
**Extension ID:** `firebase/ai-logic`
**Purpose:** AI-powered crystal identification with automatic data extraction

#### Configuration Variables:
```env
# Core AI Configuration
GOOGLE_AI_API_KEY=AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs
GEMINI_MODEL=gemini-1.5-flash
MAX_TOKENS=2048
TEMPERATURE=0.3
TOP_P=0.95

# Input/Output Configuration
INPUT_BUCKET=crystalgrimoire-production.appspot.com
OUTPUT_COLLECTION=crystal_identifications
PROCESSED_COLLECTION=processed_crystals

# Trigger Configuration
TRIGGER_DOCUMENT_PATH=crystal_uploads/{documentId}
TRIGGER_FIELD=image_url
STATUS_FIELD=processing_status

# Response Format
RESPONSE_FORMAT=structured_json
INCLUDE_CONFIDENCE_SCORE=true
ENABLE_BATCH_PROCESSING=true

# Custom Prompt Configuration
SYSTEM_PROMPT="You are a geology and crystal healing expert who identifies and gives information on stones, crystals, and other minerals in a sagely and confident way..."
RESPONSE_SCHEMA={
  "color": "string",
  "stone_type": "string", 
  "mineral_class": "string",
  "chakra": "string",
  "zodiac": "array",
  "number": "integer"
}

# Error Handling
RETRY_ATTEMPTS=3
TIMEOUT_SECONDS=30
FALLBACK_ENABLED=true
```

---

### 💳 2. **Stripe Payments** (REVENUE GENERATION)
**Extension ID:** `stripe/firestore-stripe-payments`
**Purpose:** Handle subscriptions, one-time purchases, premium access

#### Configuration Variables:
```env
# Stripe Configuration
STRIPE_SECRET_KEY=YOUR_STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Product Configuration
PRODUCTS_COLLECTION=products
CUSTOMERS_COLLECTION=customers
SUBSCRIPTIONS_COLLECTION=subscriptions
PRICES_COLLECTION=prices

# Subscription Configuration
SYNC_USERS_ON_CREATE=true
DELETE_STRIPE_CUSTOMERS=false
AUTOMATICALLY_TAX=true
TAX_RATES_COLLECTION=tax_rates

# Webhook Configuration
WEBHOOK_EVENTS=customer.subscription.created,customer.subscription.updated,customer.subscription.deleted,invoice.payment_succeeded,invoice.payment_failed,checkout.session.completed

# Security Configuration
STRIPE_API_VERSION=2023-10-16
ENABLE_CUSTOMER_PORTAL=true
CUSTOMER_PORTAL_URL=https://crystalgrimoire.com/billing
```

---

### 📧 3. **Trigger Email** (USER ENGAGEMENT)
**Extension ID:** `firebase/firestore-send-email`
**Purpose:** Welcome emails, premium notifications, crystal insights

#### Configuration Variables:
```env
# SMTP Configuration
SMTP_CONNECTION_URI=smtps://phillips.paul.email%40gmail.com:your_app_password@smtp.gmail.com:465
DEFAULT_FROM=Crystal Grimoire <noreply@crystalgrimoire.com>
DEFAULT_REPLY_TO=support@crystalgrimoire.com

# Email Collection Configuration
EMAIL_COLLECTION=mail
EMAIL_DOCUMENTS_COLLECTION=mail
USERS_COLLECTION=users
TEMPLATES_COLLECTION=email_templates

# Advanced Configuration
TESTING=false
ALLOW_MULTIPLE_DESTINATIONS=true
DELIVERY_ATTEMPTS=3
BCC_RECIPIENTS=analytics@crystalgrimoire.com

# Template Configuration
TEMPLATE_ENGINE=handlebars
TEMPLATE_VARIABLES_COLLECTION=template_variables
ATTACHMENT_MAX_SIZE=25MB
ENABLE_HTML_TEMPLATES=true

# Tracking Configuration
ENABLE_OPEN_TRACKING=true
ENABLE_CLICK_TRACKING=true
TRACKING_DOMAIN=crystalgrimoire.com
```

---

### 🖼️ 4. **Resize Images** (CRYSTAL PHOTO OPTIMIZATION)
**Extension ID:** `firebase/storage-resize-images`
**Purpose:** Optimize crystal photos for AI processing and display

#### Configuration Variables:
```env
# Image Processing Configuration
IMG_BUCKET=crystalgrimoire-production.appspot.com
IMG_SIZES=200x200,400x400,800x800,1200x1200,1920x1920
IMG_DELETE_ORIGINAL=false
IMG_TYPE=webp

# Quality and Compression
WEBP_QUALITY=85
JPEG_QUALITY=90
PNG_COMPRESSION=6
PROGRESSIVE_JPEG=true

# Processing Configuration
FUNCTION_MEMORY=2GB
FUNCTION_TIMEOUT=540
MAX_IMAGE_SIZE=32MB
INCLUDE_PATH_LIST=crystal_uploads,user_photos,collection_images

# Metadata Configuration
PRESERVE_METADATA=true
STRIP_COLOR_PROFILE=false
CACHE_CONTROL_HEADER=public,max-age=31536000

# Advanced Options
SHARP_OPTIONS={"rotate": true, "withoutEnlargement": true}
BACKGROUND_COLOR={"r": 255, "g": 255, "b": 255, "alpha": 0}
```

---

### 🔍 5. **Algolia Search** (CRYSTAL DATABASE SEARCH)
**Extension ID:** `algolia/firestore-algolia-search`
**Purpose:** Powerful search for crystal database, user collections

#### Configuration Variables:
```env
# Algolia Configuration
ALGOLIA_APP_ID=your_algolia_app_id
ALGOLIA_API_KEY=your_algolia_admin_api_key
ALGOLIA_INDEX_NAME=crystal_database

# Collection Configuration
COLLECTION_PATH=crystal_database
FIELDS=name,scientific_name,color,chakra,zodiac,healing_properties,description
TRANSFORM_FUNCTION=transform_crystal_data

# Search Configuration
INDEX_SETTINGS={
  "searchableAttributes": [
    "name",
    "scientific_name", 
    "color",
    "chakra",
    "healing_properties",
    "tags"
  ],
  "attributesForFaceting": [
    "color",
    "chakra", 
    "zodiac",
    "mineral_class",
    "rarity"
  ],
  "customRanking": [
    "desc(popularity)",
    "asc(name)"
  ]
}

# Sync Configuration
SYNC_MODE=update
BATCH_SIZE=1000
ENABLE_PARTIAL_UPDATES=true
```

---

### 📊 6. **BigQuery Export** (ANALYTICS & INSIGHTS)
**Extension ID:** `firebase/firestore-bigquery-export`
**Purpose:** Advanced analytics on crystal usage, user behavior

#### Configuration Variables:
```env
# BigQuery Configuration
PROJECT_ID=crystalgrimoire-production
DATASET_ID=crystal_analytics
TABLE_ID=firestore_export

# Collection Configuration
COLLECTION_PATH=users/{userId}/crystal_sessions,crystal_identifications,user_analytics
DATASET_LOCATION=us-central1
USE_NEW_SNAPSHOT_QUERY_SYNTAX=true

# Export Configuration
CLUSTERING_FIELDS=user_id,timestamp,crystal_type
PARTITION_FIELD=timestamp
PARTITION_TYPE=DAY
BACKUP_COLLECTION=true

# Schema Configuration
SCHEMA_FILES=crystal_sessions_schema.json,identifications_schema.json
WILDCARD_COLUMN_NAME=data
ENABLE_SCHEMA_INFERENCE=true

# Performance Configuration
STREAMING_BUFFER_SIZE=1000
BATCH_SIZE=1000
MAX_RETRY_ATTEMPTS=3
```

---

### 🎬 7. **Video Intelligence** (MEDITATION VIDEO ANALYSIS)
**Extension ID:** `google-cloud/video-intelligence-api`
**Purpose:** Analyze and optimize your meditation videos

#### Configuration Variables:
```env
# Video Processing Configuration
INPUT_BUCKET=crystalgrimoire-videos
OUTPUT_BUCKET=crystalgrimoire-analyzed-videos
ANALYSIS_FEATURES=LABEL_DETECTION,SPEECH_TRANSCRIPTION,OBJECT_TRACKING

# Processing Configuration
LANGUAGE_CODE=en-US
ALTERNATIVE_LANGUAGE_CODES=es,fr,de
MODEL=latest
VIDEO_CONTEXT_SEGMENTS=true

# Output Configuration
OUTPUT_FORMAT=json
INCLUDE_CONFIDENCE_SCORES=true
SEGMENT_LABELS=true
SHOT_CHANGE_DETECTION=true

# Webhook Configuration
WEBHOOK_URL=https://crystalgrimoire.com/api/video-analysis-webhook
WEBHOOK_SECRET=your_webhook_secret

# Advanced Features
FACE_DETECTION=false
EXPLICIT_CONTENT_DETECTION=false
LOGO_RECOGNITION=true
PERSON_DETECTION=false
```

---

### 📱 8. **Messaging (FCM)** (PUSH NOTIFICATIONS)
**Extension ID:** `firebase/firestore-send-fcm`
**Purpose:** Crystal insights, daily guidance, premium notifications

#### Configuration Variables:
```env
# FCM Configuration
COLLECTION_PATH=notifications
TOKEN_FIELD=fcm_token
PAYLOAD_FIELD=notification_payload
TTL_FIELD=ttl

# Message Configuration
DEFAULT_TTL=86400
BATCH_SIZE=500
MAX_RETRY_ATTEMPTS=3
DELIVERY_RECEIPT_REQUESTED=true

# Topic Configuration
ENABLE_TOPIC_MANAGEMENT=true
TOPICS_COLLECTION=fcm_topics
AUTO_SUBSCRIBE_USERS=true

# Advanced Configuration
PRIORITY=high
COLLAPSE_KEY=crystal_insights
CONTENT_AVAILABLE=true
MUTABLE_CONTENT=true

# Analytics Configuration
ENABLE_MESSAGE_ANALYTICS=true
TRACK_OPENS=true
TRACK_CONVERSIONS=true
```

---

### 🔐 9. **Auth with Custom Claims** (SUBSCRIPTION MANAGEMENT)
**Extension ID:** `firebase/auth-custom-claims`
**Purpose:** Manage premium access, subscription tiers

#### Configuration Variables:
```env
# Claims Configuration
CLAIMS_COLLECTION=user_claims
USER_COLLECTION=users
CLAIMS_FIELD=custom_claims

# Subscription Configuration
SUBSCRIPTION_FIELD=subscription_tier
SUBSCRIPTION_STATUS_FIELD=subscription_status
PREMIUM_CLAIM=is_premium
TIER_CLAIM=subscription_tier

# Access Control
ADMIN_EMAILS=phillips.paul.email@gmail.com
MODERATOR_ROLE=crystal_moderator
PREMIUM_ROLES=premium,pro,founders

# Automatic Claims
AUTO_SET_CLAIMS=true
VERIFY_EMAIL_CLAIM=email_verified
PHONE_VERIFIED_CLAIM=phone_verified
ACCOUNT_AGE_CLAIM=account_age_days
```

---

### 📈 10. **Analytics to BigQuery** (CONVERSION TRACKING)
**Extension ID:** `firebase/analytics-bigquery-export`
**Purpose:** Track user journeys, conversion funnels, revenue analytics

#### Configuration Variables:
```env
# Export Configuration
PROJECT_ID=crystalgrimoire-production
DATASET_ID=analytics_crystal_grimoire
DATASET_LOCATION=us-central1

# Event Configuration
INCLUDE_ADVERTISING_ID=false
EXPORT_EVENTS=true
EXPORT_USER_DATA=true
EXPORT_ITEMS=true

# Data Configuration
DAILY_EXPORT_ENABLED=true
STREAMING_EXPORT_ENABLED=true
INCLUDE_INTRADAY_TABLES=true
FRESH_DAILY_EXPORT_ENABLED=true

# Privacy Configuration
EXCLUDE_USER_ID=false
EXCLUDE_ADVERTISING_ID=true
IP_ANONYMIZATION=true
```

---

## 🚀 INSTALLATION ORDER & DEPENDENCIES

### Phase 1 - Core Infrastructure
1. **Firebase AI Logic** (Crystal identification core)
2. **Stripe Payments** (Revenue foundation)
3. **Resize Images** (Photo optimization)

### Phase 2 - User Experience  
4. **Trigger Email** (User engagement)
5. **FCM Messaging** (Push notifications)
6. **Auth Custom Claims** (Access control)

### Phase 3 - Advanced Features
7. **Algolia Search** (Crystal database search)
8. **Video Intelligence** (Meditation content)

### Phase 4 - Analytics & Optimization
9. **BigQuery Export** (Data analytics)
10. **Analytics BigQuery** (Conversion tracking)

## 💡 PRO TIPS

- **Test each extension in development first**
- **Monitor billing costs - some extensions have usage charges**
- **Set up proper IAM roles for each extension**
- **Use environment variables for all sensitive configuration**
- **Enable logging for troubleshooting**

This gives you ENTERPRISE-LEVEL functionality with proper configuration for each extension!