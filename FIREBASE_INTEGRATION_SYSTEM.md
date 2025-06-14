# Firebase Integration System

## Overview
The Firebase Integration System provides the complete backend infrastructure for Crystal Grimoire, leveraging Firebase Extensions for enterprise-level functionality including payments, email, storage, authentication, and analytics.

## Current Firebase Extensions

### 1. ✅ Firestore Stripe Payments (v0.3.4)
**Purpose**: Complete subscription and payment processing
**Configuration**:
```json
{
  "firestore-stripe-payments": "stripe/firestore-stripe-payments@0.3.4"
}
```

**Environment Variables**:
```env
STRIPE_PUBLISHABLE_KEY=pk_live_51PMpy5P7RjgzZkITofdd9PKcjsMIWGPuaf7cUhNJImqq275D8k8z7tVoGPzrWvla5RUiF1tAAHsYu3qBVWWHVxym00JwtRER7t
STRIPE_SECRET_KEY=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
STRIPE_PREMIUM_PRICE_ID=price_1RWLUuP7RjgzZkITg22yi41w
STRIPE_PRO_PRICE_ID=price_1RWLUvP7RjgzZkITm0kK5iJA
STRIPE_FOUNDERS_PRICE_ID=price_1RWLUvP7RjgzZkITCigXVDcH
```

**Firestore Collections Created**:
- `customers/{uid}` - Customer data and subscription status
- `products` - Available subscription products
- `prices` - Pricing information for products
- `payments` - Payment history and invoices

**Usage**:
```dart
// Subscribe user to premium plan
await FirebaseFirestore.instance
  .collection('customers')
  .doc(user.uid)
  .collection('checkout_sessions')
  .add({
    'price': 'price_1RWLUuP7RjgzZkITg22yi41w',
    'success_url': 'https://crystalgrimoire.com/success',
    'cancel_url': 'https://crystalgrimoire.com/cancel',
  });
```

### 2. ✅ Storage Resize Images (v0.2.9)
**Purpose**: Automatic image optimization for crystal photos
**Configuration**:
```json
{
  "storage-resize-images": "firebase/storage-resize-images@0.2.9"
}
```

**Settings**:
- **Bucket**: crystalgrimoire-production.appspot.com
- **Image sizes**: 200x200,400x400,800x800,1200x1200
- **Output formats**: JPEG (85% quality), PNG (compression 6), WebP (80% quality)
- **Resize options**: `{"fit":"inside","position":"centre","withoutEnlargement":true}`
- **Placeholder path**: `placeholders/unknown-stone.jpg`

**Usage**:
```dart
// Upload crystal image - automatically creates resized versions
final ref = FirebaseStorage.instance.ref('crystal_uploads/${crystalId}.jpg');
await ref.putFile(imageFile);

// Access resized versions
final thumb = FirebaseStorage.instance.ref('crystal_uploads/${crystalId}_200x200.jpg');
final medium = FirebaseStorage.instance.ref('crystal_uploads/${crystalId}_400x400.jpg');
final large = FirebaseStorage.instance.ref('crystal_uploads/${crystalId}_800x800.jpg');
```

### 3. ✅ Firestore Send Email (v0.2.3)
**Purpose**: Automated email notifications and communications
**Configuration**:
```json
{
  "firestore-send-email": "firebase/firestore-send-email@0.2.3"
}
```

**Settings**:
- **Collection**: `mail`
- **SMTP**: `smtps://smtp.gmail.com:465`
- **From**: `Crystal Grimoire <phillips.paul.email@gmail.com>`
- **Default Subject**: `Notification from Crystal Grimoire`

**Email Templates**:
```javascript
// Welcome email
const welcomeEmail = {
  to: user.email,
  template: {
    name: 'welcome',
    data: {
      userName: user.displayName,
      crystalCount: 0,
      subscriptionTier: 'free'
    }
  }
}

// Crystal identification complete
const identificationEmail = {
  to: user.email,
  template: {
    name: 'crystal_identified',
    data: {
      crystalName: result.identification.name,
      confidence: result.confidence,
      imageUrl: result.imageUrl,
      chakra: result.automation_data.chakra,
      zodiac: result.automation_data.zodiac
    }
  }
}
```

**Usage**:
```dart
// Send email notification
await FirebaseFirestore.instance.collection('mail').add({
  'to': user.email,
  'template': {
    'name': 'crystal_identified',
    'data': {
      'crystalName': crystal.name,
      'confidence': crystal.confidence,
      'imageUrl': crystal.imageUrl,
    }
  }
});
```

## Planned Firebase Extensions

### 4. 🟡 Auth Custom Claims (Pending)
**Purpose**: Role-based access control and subscription management
**Extension**: `firebase/auth-custom-claims@0.1.8`

**Configuration**:
```javascript
// Custom claims for subscription tiers
const customClaims = {
  free: {
    crystalLimit: 10,
    features: ['basic_identification', 'simple_journal']
  },
  premium: {
    crystalLimit: 100, 
    features: ['advanced_identification', 'moon_rituals', 'healing_sessions']
  },
  pro: {
    crystalLimit: 1000,
    features: ['all_features', 'bulk_identification', 'expert_consultations']
  },
  founders: {
    crystalLimit: -1, // unlimited
    features: ['all_features', 'early_access', 'direct_support']
  }
}
```

### 5. 🟡 Firestore BigQuery Export (Pending)
**Purpose**: Analytics and business intelligence
**Extension**: `firebase/firestore-bigquery-export@0.1.14`

**Collections to Export**:
- `crystals` - Crystal identification data
- `users` - User profiles and preferences  
- `collections` - User crystal collections
- `sessions` - App usage sessions
- `payments` - Revenue and subscription data

### 6. 🟡 Algolia Firestore Sync (Pending)
**Purpose**: Advanced crystal search and filtering
**Extension**: `algolia/firestore-algolia-search@0.9.7`

**Search Indices**:
```javascript
const searchIndices = {
  crystals: {
    searchableAttributes: [
      'name',
      'alternate_names', 
      'mineral_class',
      'color',
      'chakra',
      'zodiac',
      'healing_properties'
    ],
    facets: [
      'mineral_class',
      'chakra', 
      'zodiac',
      'color',
      'hardness',
      'formation'
    ]
  }
}
```

### 7. 🟡 Firebase ML Model Hosting (Pending)
**Purpose**: On-device crystal identification
**Extension**: Custom implementation

### 8. 🟡 FCM Push Notifications (Pending)
**Purpose**: User engagement and retention
**Extension**: Built-in Firebase feature

## Database Architecture

### Core Collections

#### Users Collection
```javascript
users/{uid}: {
  profile: {
    email: string,
    displayName: string,
    photoURL: string,
    birthDate: timestamp,
    birthTime: string,
    birthLocation: {
      city: string,
      country: string,
      latitude: number,
      longitude: number
    },
    timezone: string
  },
  subscription: {
    tier: 'free' | 'premium' | 'pro' | 'founders',
    status: 'active' | 'cancelled' | 'past_due',
    subscriptionId: string,
    currentPeriodEnd: timestamp,
    created: timestamp
  },
  astrology: {
    sunSign: string,
    moonSign: string,
    ascendant: string,
    dominantElement: string,
    planetaryPositions: object,
    birthChart: object
  },
  preferences: {
    notifications: boolean,
    emailUpdates: boolean,
    healingReminders: boolean,
    moonPhaseAlerts: boolean
  },
  stats: {
    crystalsIdentified: number,
    collectionsCreated: number,
    journalEntries: number,
    ritualsCompleted: number,
    lastActive: timestamp
  }
}
```

#### Crystals Collection
```javascript
crystals/{crystalId}: {
  identification: {
    name: string,
    alternate_names: string[],
    confidence: number,
    identified_at: timestamp,
    verification_status: 'pending' | 'verified' | 'disputed'
  },
  automation_data: {
    color: {
      primary: string,
      secondary: string[],
      intensity: number
    },
    stone_type: {
      name: string,
      family: string,
      confidence: number
    },
    mineral_class: {
      class: string,
      group: string,
      crystal_system: string,
      hardness: string
    },
    chakra: {
      primary: string,
      secondary: string[],
      healing_properties: string[]
    },
    zodiac: {
      primary_signs: string[],
      ruling_planet: string,
      elemental_affinity: string
    },
    numerology: {
      number: number,
      meaning: string,
      life_path_compatibility: number[]
    }
  },
  comprehensive_data: {
    physical_properties: object,
    metaphysical_properties: object,
    formation_info: object,
    geographic_origins: string[],
    healing_applications: object,
    historical_significance: string
  },
  images: {
    original: string,
    thumbnail: string,
    medium: string,
    large: string
  },
  user_data: {
    user_id: string,
    collection_id: string,
    added_at: timestamp,
    acquisition_info: {
      source: string,
      date: timestamp,
      price: number,
      location: string
    },
    personal_notes: string,
    usage_log: {
      meditation_sessions: number,
      healing_sessions: number,
      ritual_uses: number,
      last_used: timestamp
    }
  }
}
```

#### Collections Collection
```javascript
collections/{collectionId}: {
  metadata: {
    name: string,
    description: string,
    user_id: string,
    created_at: timestamp,
    updated_at: timestamp,
    is_public: boolean,
    tags: string[]
  },
  crystals: {
    crystal_ids: string[],
    count: number,
    categories: {
      by_chakra: object,
      by_color: object,
      by_zodiac: object,
      by_mineral_class: object
    }
  },
  analytics: {
    chakra_coverage: object,
    elemental_balance: object,
    zodiac_compatibility: object,
    collection_value: number,
    rarity_score: number
  }
}
```

## Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Crystals are readable by owner or public collections
    match /crystals/{crystalId} {
      allow read, write: if request.auth != null && 
        (resource.data.user_data.user_id == request.auth.uid ||
         get(/databases/$(database)/documents/collections/$(resource.data.user_data.collection_id)).data.metadata.is_public == true);
    }
    
    // Collections access control
    match /collections/{collectionId} {
      allow read: if request.auth != null && 
        (resource.data.metadata.user_id == request.auth.uid || 
         resource.data.metadata.is_public == true);
      allow write: if request.auth != null && 
        resource.data.metadata.user_id == request.auth.uid;
    }
    
    // Email collection (write-only for sending emails)
    match /mail/{emailId} {
      allow write: if request.auth != null;
    }
    
    // Stripe customers collection (managed by extension)
    match /customers/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

### Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Crystal images
    match /crystal_uploads/{allPaths=**} {
      allow read: if true; // Public read for crystal images
      allow write: if request.auth != null;
    }
    
    // User profile images
    match /user_photos/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Placeholders are public read
    match /placeholders/{allPaths=**} {
      allow read: if true;
    }
  }
}
```

## Performance Optimization

### Firestore Indices
```javascript
// Composite indices for efficient queries
const indices = [
  {
    collection: 'crystals',
    fields: ['user_data.user_id', 'automation_data.chakra.primary', 'identification.name']
  },
  {
    collection: 'crystals', 
    fields: ['automation_data.zodiac.primary_signs', 'automation_data.color.primary']
  },
  {
    collection: 'collections',
    fields: ['metadata.user_id', 'metadata.is_public', 'metadata.created_at']
  }
]
```

### Caching Strategy
```dart
class FirebaseCache {
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);
  
  static Future<T> getCached<T>(String key, Future<T> Function() fetcher) async {
    final cached = _cache[key];
    if (cached != null && cached['timestamp'].isAfter(DateTime.now().subtract(_cacheTimeout))) {
      return cached['data'] as T;
    }
    
    final data = await fetcher();
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now()
    };
    return data;
  }
}
```

## Monitoring & Analytics

### Firebase Analytics Events
```dart
class CrystalGrimoireAnalytics {
  static void trackCrystalIdentification(String crystalName, double confidence) {
    FirebaseAnalytics.instance.logEvent(
      name: 'crystal_identified',
      parameters: {
        'crystal_name': crystalName,
        'confidence': confidence,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }
    );
  }
  
  static void trackSubscriptionUpgrade(String fromTier, String toTier) {
    FirebaseAnalytics.instance.logEvent(
      name: 'subscription_upgrade',
      parameters: {
        'from_tier': fromTier,
        'to_tier': toTier,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }
    );
  }
}
```

## Deployment Configuration

### Firebase CLI Commands
```bash
# Deploy all Firebase features
firebase deploy

# Deploy specific features
firebase deploy --only firestore:rules
firebase deploy --only storage:rules  
firebase deploy --only functions
firebase deploy --only hosting

# Install additional extensions
firebase ext:install firebase/firestore-bigquery-export
firebase ext:install algolia/firestore-algolia-search
firebase ext:install firebase/auth-custom-claims
```

### Environment Setup
```bash
# Production deployment
firebase use crystalgrimoire-production
firebase deploy

# Development deployment
firebase use crystalgrimoire-dev
firebase deploy
```

This Firebase integration provides a robust, scalable backend infrastructure supporting all Crystal Grimoire features with enterprise-level security, performance, and analytics capabilities.