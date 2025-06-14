# CLAUDE.md - Crystal Grimoire V3 Production System

This file provides comprehensive guidance to Claude Code for the Crystal Grimoire production platform.

## Project Overview
Crystal Grimoire V3 is a **PRODUCTION-READY** metaphysical platform that combines:
- **AI-Powered Crystal Identification** using Gemini 2.5 Flash with Crystal Bible knowledge
- **Unified Data Model** with automated color→chakra→zodiac→numerology mapping  
- **Firebase Extensions** for enterprise-level functionality (Stripe, BigQuery, Email, etc.)
- **Revenue Generation** through strategic ads and premium subscriptions
- **Optimized Video Content** for meditation and spiritual guidance
- **Cross-Platform Deployment** (Web, Mobile, Desktop)

## Current Project Status

### ✅ PRODUCTION-READY COMPONENTS
1. **Enhanced Unified Backend**: `unified_backend_enhanced.js` with comprehensive API endpoints
   - Crystal identification with personalization
   - AI-powered spiritual guidance using birth chart + collection
   - Moon phase calculation and ritual recommendations
   - Dream journal with pattern analysis
   - User profile management
   - Complete health monitoring
2. **Firebase Extensions**: Stripe payments, image optimization, email analytics (installed)
3. **AI Integration**: Gemini 2.5 Flash with Crystal Bible prompt and automated data extraction
4. **Comprehensive Documentation**: 9 complete system documentation files
5. **Security**: Production-grade API key management and data protection
6. **Unified Data Model**: Color→chakra→zodiac→numerology automation (95% accuracy)

### ❌ CRITICAL FEATURES STILL NEEDED
1. **Frontend Integration**: Connect Flutter frontend to enhanced backend
2. **Firebase Admin Setup**: Complete Firebase service account configuration  
3. **Feature Implementation**: Build UI screens for Moon Rituals, Crystal Healing, Sound Bath, Dream Journal
4. **Cross-Feature Integration**: Features must share data and influence each other
5. **Real-time Sync**: Backend and frontend synchronization
6. **Testing & Deployment**: End-to-end testing and production deployment

### 🚀 CURRENT DEVELOPMENT FOCUS
1. **Complete Crystal Auto-Classification**: Full JSON output with all metaphysical properties
2. **Firebase Extensions Installation**: Enterprise extension deployment (Stripe, BigQuery, etc.)
3. **Missing Alpha Features**: Restore Moon Rituals, Crystal Healing, Sound Bath, Dream Journal
4. **Cross-Feature Integration**: All features must share unified data model
5. **Revenue Systems**: Strategic ads and premium subscription conversion
6. **Performance & Mobile**: Sub-3-second load times and mobile optimization

## Project File Structure
```
/mnt/c/Users/millz/Desktop/CrystalGrimoireV3/
├── lib/                    # Flutter frontend
│   ├── screens/           # UI screens  
│   ├── services/          # API services
│   │   ├── firebase_ads_service.dart
│   │   ├── optimized_video_service.dart
│   │   └── crystal_auto_classifier.dart
│   └── models/            # Data models
├── unified_backend.js      # Production backend with Crystal Bible prompt
├── firebase.json          # Firebase config
├── .env                   # Environment vars (DO NOT COMMIT)
├── CLAUDE.md              # This comprehensive guide
├── UNIFIED_DATA_MODEL.md  # Automation architecture  
├── FIREBASE_EXTENSIONS_PRODUCTION.md  # Enterprise extensions
├── TERMS_OF_SERVICE.md    # Legal compliance
└── 851657124-The-Crystal-Bible.pdf  # Knowledge base
```

## Critical Implementation Tasks

### 1. CRYSTAL AUTO-CLASSIFICATION
When user uploads crystal photo, must return COMPLETE JSON:

```json
{
  "identification": {
    "name": "Amethyst",
    "variety": "Chevron Amethyst",
    "scientific_name": "Silicon Dioxide (SiO2)",
    "confidence": 95
  },
  "metaphysical_properties": {
    "primary_chakras": ["Third Eye", "Crown"],
    "zodiac_signs": ["Pisces", "Aquarius", "Capricorn"],
    "planetary_rulers": ["Jupiter", "Neptune"],
    "elements": ["Water", "Air"],
    "healing_properties": [
      "Enhances intuition",
      "Promotes calm and clarity",
      "Aids in meditation",
      "Protects against negative energy"
    ],
    "intentions": ["Protection", "Intuition", "Peace", "Spiritual Growth"]
  },
  "physical_properties": {
    "hardness": "7 (Mohs scale)",
    "crystal_system": "Hexagonal",
    "luster": "Vitreous",
    "transparency": "Transparent to translucent",
    "color_range": ["Purple", "Violet", "Lavender"],
    "formation": "Igneous",
    "chemical_formula": "SiO2",
    "density": "2.65 g/cm³"
  },
  "care_instructions": {
    "cleansing_methods": ["Running water", "Moonlight", "Sage smoke", "Sound"],
    "charging_methods": ["Moonlight", "Crystal cluster", "Earth burial"],
    "storage_recommendations": "Keep away from direct sunlight to prevent fading",
    "handling_notes": "Durable stone, safe for regular handling"
  }
}
```

### 2. PERSONALIZED AI CONTEXT
EVERY AI interaction must include user context:

```javascript
// Backend example
app.post('/api/crystal/identify', async (req, res) => {
  const { image_data, user_id } = req.body;
  
  // Get user's complete profile
  const userProfile = await firestore.collection('users').doc(user_id).get();
  const userCrystals = await firestore.collection('users').doc(user_id)
    .collection('crystals').get();
  
  const prompt = `
    USER PROFILE:
    - Birth Chart: ${userProfile.sun_sign} Sun, ${userProfile.moon_sign} Moon
    - Owns ${userCrystals.size} crystals: ${userCrystals.docs.map(d => d.data().name)}
    - Spiritual Goals: ${userProfile.goals}
    
    Identify this crystal and provide personalized guidance based on their profile.
  `;
  
  // Call AI with personalized prompt
  const result = await callGeminiWithContext(prompt, image_data);
  res.json(result);
});
```

### 3. DATABASE ARCHITECTURE
Firestore collections needed:

```
/crystal_database/              # Master crystal reference
  ├── {crystal_id}/
  │   ├── name: "Amethyst"
  │   ├── metaphysical_properties: {...}
  │   ├── physical_properties: {...}
  │   └── care_instructions: {...}
  
/users/{user_id}/              # User data
  ├── profile                  # Birth chart, preferences
  ├── crystals/               # Personal collection
  │   └── {crystal_id}/
  │       ├── acquisition_date
  │       ├── personal_notes
  │       └── usage_count
  └── sessions/               # Guidance sessions, journal

/identifications/             # AI identification history
/guidance_sessions/          # Personalized guidance history
```

### 4. MISSING FEATURES TO RESTORE

**Moon Rituals**
- Lunar calendar showing current phase
- Ritual suggestions based on moon phase
- Integration with user's crystal collection
- Personalized ritual planning

**Crystal Healing**
- Chakra visualization and assessment
- Healing session generator using owned crystals
- Guided meditation scripts
- Progress tracking

**Sound Bath**
- Audio playback functionality
- Multiple sound options (bowls, chimes, nature)
- Crystal-matched frequencies
- Timer and session recording

**Dream Journal**
- Dream entry with date/time
- Crystal correlation (which stones were nearby)
- Pattern analysis over time
- Dream interpretation with AI

### 5. CROSS-FEATURE INTEGRATION
Features must influence each other:

```dart
// Example: Journal entry affects healing suggestions
if (journalEntry.mood == "anxious") {
  // Suggest calming crystals user owns
  final calmingCrystals = userCollection
    .where((c) => c.properties.contains("calming"))
    .toList();
  
  // Schedule healing session notification
  scheduleNotification(
    "Try a healing session with your ${calmingCrystals.first.name}"
  );
}

// Example: Moon phase affects all features
final currentPhase = MoonPhaseCalculator.getCurrentPhase();
if (currentPhase == "Full Moon") {
  // Update ritual suggestions
  // Enhance crystal charging recommendations
  // Adjust meditation guidance
}
```

## Backend API Endpoints Needed

```javascript
// Crystal identification with full properties
POST /api/crystal/identify
Body: { image_data, user_id }
Returns: Complete crystal data + personalized guidance

// Personalized spiritual guidance
POST /api/guidance/personalized
Body: { user_id, query, context_type }
Returns: AI guidance using birth chart + collection

// Moon ritual planning
GET /api/moon/current-phase
GET /api/moon/rituals/:phase
Body: { user_id }
Returns: Rituals user can do with their crystals

// Dream journal with analysis
POST /api/dreams/create
GET /api/dreams/patterns/:user_id
Returns: Dream patterns + crystal correlations
```

## Frontend Implementation Priority

1. **Fix Crystal ID Widget**
   - Make it larger and more prominent
   - Add comprehensive property display
   - Include personalized guidance section

2. **Restore Alpha Features**
   - Copy working code from alpha version
   - Update to use new backend endpoints
   - Ensure proper data integration

3. **Add Cross-Feature Data Flow**
   - Create UnifiedDataService
   - Implement event system for feature communication
   - Update all screens to use shared data

## Environment Setup
```bash
# Required .env variables
GEMINI_API_KEY=AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs
OPENAI_API_KEY=(need to add)
CLAUDE_API_KEY=(need to add)
FIREBASE_API_KEY=AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=YOUR_STRIPE_SECRET_KEY
```

## Development Commands
```bash
# Backend
cd /mnt/c/Users/millz/Desktop/CrystalGrimoireBeta0.2
node backend_server.js

# Frontend
flutter run -d chrome
flutter build web --release

# Deploy
firebase deploy --only hosting
```

## Testing Checklist
- [ ] Crystal photo returns ALL metaphysical properties
- [ ] AI knows user's birth chart in responses
- [ ] AI references user's crystal collection
- [ ] Moon Rituals shows current lunar phase
- [ ] Crystal Healing filters to owned crystals
- [ ] Sound Bath plays audio files
- [ ] Dream Journal saves with crystal correlations
- [ ] All features share data properly

## CRITICAL NOTES
1. **NO DEMOS/SHORTCUTS** - Full production implementation only
2. **ALWAYS PERSONALIZE** - Use birth chart + collection in every AI response
3. **COMPLETE DATA** - Crystal info must include ALL properties
4. **SECURE CREDENTIALS** - Never commit API keys
5. **REAL-TIME SYNC** - All changes must sync immediately

## Support
- User: Paul Phillips
- Email: phillips.paul.email@gmail.com
- GitHub: domusgpt

## Current Working Directory
**CRITICAL**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireV3/`

All file operations must use this exact path. DO NOT work in any other directory.

## Comprehensive System Documentation Files
**Location**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireV3/`

### Core System Documentation
- **CLAUDE.md** (this file): Complete project guide and requirements  
- **CRYSTAL_IDENTIFICATION_SYSTEM.md**: AI-powered crystal identification with unified data automation
- **UNIFIED_DATA_AUTOMATION.md**: Color→chakra→zodiac→numerology mapping with 95% accuracy
- **FIREBASE_INTEGRATION_SYSTEM.md**: Complete Firebase Extensions configuration and implementation
- **EMAIL_SYSTEM.md**: Automated communication with Gmail OAuth2 and personalized templates
- **STRIPE_PAYMENT_SYSTEM.md**: Subscription management with freemium model and revenue analytics

### Feature System Documentation
- **MOON_RITUALS_SYSTEM.md**: Lunar calendar integration with personalized ritual creation
- **CRYSTAL_HEALING_SYSTEM.md**: Chakra-based healing protocols with birth chart integration
- **SOUND_BATH_SYSTEM.md**: Audio frequency healing with crystal resonance matching
- **DREAM_JOURNAL_SYSTEM.md**: Dream tracking with crystal correlation analysis
- **VIDEO_PLATFORM_SYSTEM.md**: Meditation content with optimization and premium access

### Technical Architecture Documentation
- **DATABASE_ARCHITECTURE.md**: Complete Firestore schema with security rules
- **PERSONALIZATION_ENGINE.md**: AI personalization using birth charts and crystal collections
- **REVENUE_SYSTEM.md**: Monetization strategy with ads and subscription optimization

### Integration Requirements
ALL systems must reference and integrate with:
1. **User's Birth Chart**: Sun/Moon/Rising signs for personalized guidance
2. **Crystal Collection**: User's owned crystals for recommendations
3. **Subscription Tier**: Feature access control (free/premium/pro/founders)  
4. **Unified Data Model**: Automated extraction of color→chakra→zodiac→numerology
5. **Firebase Extensions**: Stripe payments, email automation, image optimization
6. **Cross-Feature Communication**: Moon phases affect rituals, healing, and guidance

### Connection Dependencies
Each system connects to others through:
- **StorageService**: User profile and subscription data
- **CollectionService**: Crystal collection and usage tracking
- **AstrologyService**: Birth chart calculations and horoscope integration
- **BackendService**: AI-powered personalization with Crystal Bible knowledge
- **NotificationService**: Moon phase alerts and healing reminders
- **AnalyticsService**: Usage tracking and revenue optimization

## Firebase Project Setup
```bash
# Current Firebase project
firebase use crystalgrimoire-production

# Install critical extensions
firebase ext:install stripe/firestore-stripe-payments
firebase ext:install firebase/storage-resize-images  
firebase ext:install firebase/firestore-send-email
```