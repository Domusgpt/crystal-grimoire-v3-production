#!/usr/bin/env node
/**
 * Crystal Grimoire Production Backend Server (Node.js)
 * High-performance API server for Crystal Grimoire application
 */

const express = require('express');
const cors = require('cors');
const multer = require('multer');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

// Load environment variables
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8081;
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || '';

// Middleware
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true }));

// CORS configuration
const corsOptions = {
  origin: ENVIRONMENT === 'development' ? '*' : [
    'https://crystalgrimoire-production.web.app',
    'https://crystalgrimoire.com'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));

// File upload configuration
const upload = multer({
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  storage: multer.memoryStorage()
});

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Import Firebase Admin SDK
const admin = require('firebase-admin');

let db = null;
let firebaseInitialized = false;

// Initialize Firebase Admin if credentials are available
try {
  const serviceAccount = require('./firebase-service-account.json');
  
  // Check if service account has valid private key
  if (serviceAccount.private_key && serviceAccount.private_key.includes('BEGIN PRIVATE KEY')) {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: 'crystalgrimoire-production'
      });
    }
    db = admin.firestore();
    firebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized successfully');
  } else {
    console.log('⚠️  Firebase service account file exists but private key is not configured');
  }
} catch (error) {
  console.log('⚠️  Firebase service account not found or invalid. Running in standalone mode.');
  console.log('   To enable full features, add proper firebase-service-account.json');
}

// AI Service Functions
class AIService {
  // Build comprehensive user context from Firebase
  static async buildUserContext(userId) {
    if (!firebaseInitialized || !db || !userId) {
      console.log('Firebase not initialized or no user ID provided - using default context');
      return {
        profile: {
          name: 'Crystal Enthusiast',
          birthChart: {},
          sunSign: 'Leo',
          moonSign: 'Pisces',
          risingSign: 'Sagittarius',
          spiritualGoals: ['Peace', 'Clarity', 'Growth'],
          experienceLevel: 'Intermediate'
        },
        crystalCollection: [
          { name: 'Clear Quartz', type: 'Quartz', usageCount: 5, intentions: ['Clarity', 'Amplification'] },
          { name: 'Amethyst', type: 'Quartz', usageCount: 3, intentions: ['Peace', 'Intuition'] }
        ],
        collectionSize: 2,
        favoriteTypes: ['Quartz', 'Feldspar'],
        currentDate: new Date().toISOString(),
        moonPhase: this.getCurrentMoonPhase()
      };
    }

    try {
      // Get user profile
      const userDoc = await db.collection('users').doc(userId).get();
      const userProfile = userDoc.exists ? userDoc.data() : {};
      
      // Get user's crystal collection
      const crystalsSnapshot = await db.collection('users').doc(userId)
        .collection('crystals').get();
      const crystalCollection = crystalsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      return {
        profile: {
          name: userProfile.name || 'Crystal Enthusiast',
          birthChart: userProfile.birthChart || {},
          sunSign: userProfile.birthChart?.sunSign || 'Leo',
          moonSign: userProfile.birthChart?.moonSign || 'Pisces',
          risingSign: userProfile.birthChart?.risingSign || 'Sagittarius',
          spiritualGoals: userProfile.spiritualGoals || ['Peace', 'Clarity', 'Growth'],
          experienceLevel: userProfile.experienceLevel || 'Intermediate'
        },
        crystalCollection: crystalCollection.map(c => ({
          name: c.crystalName,
          type: c.crystalType,
          usageCount: c.usageCount || 0,
          intentions: c.intentions || []
        })),
        collectionSize: crystalCollection.length,
        favoriteTypes: this.analyzeFavoriteTypes(crystalCollection),
        currentDate: new Date().toISOString(),
        moonPhase: this.getCurrentMoonPhase()
      };
    } catch (error) {
      console.error('Error building user context:', error);
      return null;
    }
  }
  
  // Analyze user's favorite crystal types
  static analyzeFavoriteTypes(collection) {
    const typeCount = {};
    collection.forEach(crystal => {
      const type = crystal.crystalType || 'Unknown';
      typeCount[type] = (typeCount[type] || 0) + 1;
    });
    return Object.entries(typeCount)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([type]) => type);
  }
  
  // Calculate current moon phase
  static getCurrentMoonPhase() {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    
    // Simple moon phase calculation
    const c = Math.floor(365.25 * year);
    const e = Math.floor(30.6 * month);
    const jd = c + e + day - 694039.09;
    const phase = jd / 29.53;
    const phaseIndex = Math.floor((phase - Math.floor(phase)) * 8);
    
    const phases = [
      'New Moon', 'Waxing Crescent', 'First Quarter', 'Waxing Gibbous',
      'Full Moon', 'Waning Gibbous', 'Last Quarter', 'Waning Crescent'
    ];
    
    return phases[phaseIndex] || 'New Moon';
  }
  
  // Comprehensive crystal identification with personalization
  static async identifyCrystalWithComprehensiveOutput(imageData, userContext = null) {
    if (!GEMINI_API_KEY) {
      throw new Error('Gemini API not configured');
    }

    const contextString = userContext ? `
USER PROFILE:
- Name: ${userContext.profile.name}
- Astrological: ${userContext.profile.sunSign} Sun, ${userContext.profile.moonSign} Moon, ${userContext.profile.risingSign} Rising
- Crystal Collection: ${userContext.collectionSize} crystals owned
- Favorite Types: ${userContext.favoriteTypes.join(', ')}
- Experience Level: ${userContext.profile.experienceLevel}
- Spiritual Goals: ${userContext.profile.spiritualGoals.join(', ')}
- Current Moon Phase: ${userContext.moonPhase}

PERSONALIZATION REQUIREMENTS:
1. Reference their astrological profile when discussing crystal properties
2. Compare to crystals they already own
3. Suggest how this crystal complements their collection
4. Provide guidance specific to their experience level
5. Connect to their stated spiritual goals
6. Include moon phase recommendations
` : 'No user context provided - provide general information';

    const prompt = `
You are an expert crystal identification and metaphysical guidance system. 
Analyze this crystal image and provide COMPREHENSIVE information in JSON format.

${contextString}

Return ONLY valid JSON with this COMPLETE structure:
{
  "identification": {
    "name": "exact crystal name",
    "variety": "specific variety or type if applicable",
    "scientific_name": "chemical composition",
    "confidence": 90
  },
  "metaphysical_properties": {
    "primary_chakras": ["list all relevant chakras"],
    "secondary_chakras": ["additional chakra associations"],
    "zodiac_signs": ["all associated zodiac signs"],
    "planetary_rulers": ["all planetary associations"],
    "elements": ["Fire", "Earth", "Air", "Water", "Spirit"],
    "healing_properties": [
      "detailed healing property 1",
      "detailed healing property 2",
      "detailed healing property 3",
      "at least 5-7 specific healing properties"
    ],
    "emotional_benefits": ["stress relief", "confidence", "etc"],
    "spiritual_benefits": ["intuition", "connection", "etc"],
    "mental_benefits": ["focus", "clarity", "memory", "etc"],
    "physical_benefits": ["pain relief", "energy", "etc"],
    "intentions": ["Love", "Protection", "Abundance", "Healing", "Clarity", "Grounding", "etc"],
    "energy_type": "Amplifying/Grounding/Protective/Transmuting",
    "vibration_level": "High/Medium/Low"
  },
  "physical_properties": {
    "hardness": "exact Mohs scale rating",
    "crystal_system": "Hexagonal/Cubic/Tetragonal/etc",
    "luster": "Vitreous/Metallic/Pearly/etc",
    "transparency": "Transparent/Translucent/Opaque",
    "color_range": ["list all color variations"],
    "formation": "Igneous/Metamorphic/Sedimentary",
    "chemical_formula": "exact chemical formula",
    "density": "specific gravity in g/cm³",
    "refractive_index": "numerical range",
    "cleavage": "Perfect/Good/Poor/None",
    "fracture": "Conchoidal/Uneven/etc",
    "streak": "color when powdered",
    "fluorescence": "Yes/No and color if applicable"
  },
  "care_instructions": {
    "cleansing_methods": ["safe cleansing methods for this specific crystal"],
    "charging_methods": ["best charging methods for this crystal"],
    "methods_to_avoid": ["water/salt/sun if damaging"],
    "storage_recommendations": "specific storage advice",
    "handling_notes": "specific care instructions",
    "maintenance_frequency": "how often to cleanse/charge",
    "programming_instructions": "how to program this crystal"
  },
  "spiritual_guidance": {
    "meditation_uses": ["specific meditation techniques"],
    "ritual_applications": ["ritual uses"],
    "crystal_grids": ["grid placement suggestions"],
    "pairing_suggestions": ["crystals that work well with this one"],
    "placement_recommendations": {
      "home": ["where to place in home"],
      "body": ["where to wear or place on body"],
      "workspace": ["office/desk placement"]
    },
    "lunar_phase_usage": "best moon phases to work with this crystal",
    "seasonal_associations": "seasons when most powerful"
  },
  "historical_cultural": {
    "ancient_uses": ["historical applications"],
    "folklore": ["myths and legends"],
    "cultural_significance": ["cultural meanings"],
    "modern_applications": ["contemporary uses"],
    "geological_formation": "how this crystal forms in nature",
    "major_deposits": ["primary locations found"],
    "rarity": "Common/Uncommon/Rare/Very Rare",
    "price_range": "Budget/Moderate/Premium/Luxury"
  },
  "personalized_guidance": {
    "for_your_sign": "specific guidance based on user's astrological profile",
    "collection_synergy": "how this works with crystals they already own",
    "current_moon_recommendation": "what to do with this crystal in current moon phase",
    "personal_affirmation": "custom affirmation for this user and crystal",
    "next_steps": ["specific actions they can take"],
    "warning_notes": "any cautions based on their profile"
  }
}`;

    try {
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
        {
          contents: [{
            parts: [
              { text: prompt },
              {
                inline_data: {
                  mime_type: "image/png",
                  data: imageData
                }
              }
            ]
          }]
        },
        { timeout: 30000 }
      );

      let content = response.data.candidates[0].content.parts[0].text;
      
      // Clean up the response to ensure valid JSON
      content = content.trim();
      if (content.startsWith('```json')) {
        content = content.substring(7);
      }
      if (content.endsWith('```')) {
        content = content.substring(0, content.length - 3);
      }
      content = content.trim();

      return JSON.parse(content);

    } catch (error) {
      console.error('Gemini API error:', error.message);
      throw new Error(`AI identification failed: ${error.message}`);
    }
  }
  
  // Save identification to Firestore
  static async saveIdentificationToFirestore(userId, result) {
    if (!firebaseInitialized || !db) {
      console.log('Firebase not initialized - identification not saved to database');
      return 'local_' + Date.now();
    }

    try {
      const identificationRef = db.collection('identifications').doc();
      await identificationRef.set({
        userId,
        result,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        confidence: result.identification?.confidence || 0,
        crystalName: result.identification?.name || 'Unknown'
      });
      
      console.log(`Saved identification ${identificationRef.id} for user ${userId}`);
      return identificationRef.id;
    } catch (error) {
      console.error('Error saving identification:', error);
      return null;
    }
  }
}

// API Routes

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: ENVIRONMENT,
    services: {
      gemini_api: GEMINI_API_KEY ? 'configured' : 'not_configured',
      openai_api: OPENAI_API_KEY ? 'configured' : 'not_configured',
      firebase: firebaseInitialized ? 'initialized' : 'not_initialized'
    }
  });
});

// API status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    api_version: '1.0.0',
    environment: ENVIRONMENT,
    features: {
      crystal_identification: true,
      collection_management: true,
      usage_tracking: true,
      multi_model_ai: !!(GEMINI_API_KEY || OPENAI_API_KEY)
    },
    endpoints: {
      identify: '/api/crystal/identify',
      collection: '/api/crystal/collection',
      save: '/api/crystal/save',
      usage: '/api/usage'
    }
  });
});

// Crystal identification endpoint with comprehensive output
app.post('/api/crystal/identify', upload.single('image'), async (req, res) => {
  try {
    console.log('🔮 Crystal identification request received');
    
    let imageData;
    let userId = req.body.user_id;
    let userContext = null;

    // Handle different input formats
    if (req.file) {
      // File upload
      imageData = req.file.buffer.toString('base64');
    } else if (req.body.image_data) {
      // Base64 data
      imageData = req.body.image_data;
    } else {
      return res.status(400).json({ error: 'No image data provided' });
    }

    // Build comprehensive user context if userId provided
    if (userId) {
      console.log(`Building user context for user: ${userId}`);
      userContext = await AIService.buildUserContext(userId);
    }

    // Use Gemini with comprehensive prompt
    if (GEMINI_API_KEY) {
      const result = await AIService.identifyCrystalWithComprehensiveOutput(imageData, userContext);
      
      // Save identification to database
      if (userId) {
        await AIService.saveIdentificationToFirestore(userId, result);
      }
      
      res.json({
        identification: result.identification || {},
        metaphysical_properties: result.metaphysical_properties || {},
        physical_properties: result.physical_properties || {},
        care_instructions: result.care_instructions || {},
        spiritual_guidance: result.spiritual_guidance || {},
        historical_cultural: result.historical_cultural || {},
        personalized_guidance: result.personalized_guidance || {},
        confidence: result.identification?.confidence || 0.8,
        source: 'gemini-pro-vision',
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(503).json({ error: 'No AI services configured' });
    }

  } catch (error) {
    console.error('Crystal identification error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Import database schema
const { DATABASE_SCHEMA, SAMPLE_CRYSTALS } = require('./database_schema.js');

// Crystal Database Endpoints

// Get crystal database (with pagination and filtering)
app.get('/api/crystal/database', async (req, res) => {
  try {
    const { 
      limit = 20, 
      offset = 0, 
      chakra, 
      intention, 
      zodiac_sign, 
      element,
      search 
    } = req.query;

    let crystals = [...SAMPLE_CRYSTALS];

    // Apply filters
    if (chakra) {
      crystals = crystals.filter(c => 
        c.metaphysical_properties.primary_chakras.includes(chakra) ||
        c.metaphysical_properties.secondary_chakras?.includes(chakra)
      );
    }

    if (intention) {
      crystals = crystals.filter(c => 
        c.metaphysical_properties.intentions.includes(intention)
      );
    }

    if (zodiac_sign) {
      crystals = crystals.filter(c => 
        c.metaphysical_properties.zodiac_signs.includes(zodiac_sign)
      );
    }

    if (element) {
      crystals = crystals.filter(c => 
        c.metaphysical_properties.elements.includes(element)
      );
    }

    if (search) {
      const searchLower = search.toLowerCase();
      crystals = crystals.filter(c => 
        c.name.toLowerCase().includes(searchLower) ||
        c.scientific_name.toLowerCase().includes(searchLower) ||
        c.metaphysical_properties.healing_properties.some(prop => 
          prop.toLowerCase().includes(searchLower)
        )
      );
    }

    // Pagination
    const total = crystals.length;
    const paginatedCrystals = crystals.slice(
      parseInt(offset), 
      parseInt(offset) + parseInt(limit)
    );

    res.json({
      crystals: paginatedCrystals,
      total_count: total,
      limit: parseInt(limit),
      offset: parseInt(offset),
      filters_applied: { chakra, intention, zodiac_sign, element, search }
    });

  } catch (error) {
    console.error('Crystal database error:', error);
    res.status(500).json({ error: 'Failed to fetch crystal database' });
  }
});

// Get specific crystal by ID
app.get('/api/crystal/database/:crystal_id', (req, res) => {
  try {
    const { crystal_id } = req.params;
    const crystal = SAMPLE_CRYSTALS.find(c => c.id === crystal_id);

    if (!crystal) {
      return res.status(404).json({ error: 'Crystal not found' });
    }

    res.json(crystal);
  } catch (error) {
    console.error('Crystal lookup error:', error);
    res.status(500).json({ error: 'Failed to fetch crystal' });
  }
});

// User Collection Endpoints

// Get user's crystal collection
app.get('/api/user/:user_id/collection', async (req, res) => {
  try {
    const { user_id } = req.params;

    if (!firebaseInitialized || !db) {
      // Return mock data for testing
      return res.json({
        user_id,
        crystals: [
          {
            id: 'user_crystal_1',
            crystal_id: 'amethyst_001',
            crystal_name: 'Amethyst',
            acquisition_date: new Date().toISOString(),
            personal_notes: 'My first crystal, very calming',
            usage_count: 5,
            favorite: true
          }
        ],
        total_count: 1,
        last_updated: new Date().toISOString()
      });
    }

    // Get user's crystal collection from Firestore
    const collectionSnapshot = await db.collection('users').doc(user_id)
      .collection('crystals').get();
    
    const crystals = collectionSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json({
      user_id,
      crystals,
      total_count: crystals.length,
      last_updated: new Date().toISOString()
    });

  } catch (error) {
    console.error('Collection fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch user collection' });
  }
});

// Add crystal to user's collection
app.post('/api/user/:user_id/collection', async (req, res) => {
  try {
    const { user_id } = req.params;
    const crystalData = req.body;

    if (!firebaseInitialized || !db) {
      // Mock response for testing
      console.log(`Would save crystal to collection for user ${user_id}:`, crystalData.crystal_name);
      return res.json({
        status: 'success',
        crystal_id: 'mock_' + Date.now(),
        added_at: new Date().toISOString()
      });
    }

    // Add to user's collection in Firestore
    const collectionRef = db.collection('users').doc(user_id).collection('crystals');
    const docRef = await collectionRef.add({
      ...crystalData,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      usage_count: 0,
      favorite: false
    });

    res.json({
      status: 'success',
      crystal_id: docRef.id,
      added_at: new Date().toISOString()
    });

  } catch (error) {
    console.error('Collection save error:', error);
    res.status(500).json({ error: 'Failed to add crystal to collection' });
  }
});

// Update crystal in user's collection
app.put('/api/user/:user_id/collection/:crystal_id', async (req, res) => {
  try {
    const { user_id, crystal_id } = req.params;
    const updateData = req.body;

    if (!firebaseInitialized || !db) {
      console.log(`Would update crystal ${crystal_id} for user ${user_id}`);
      return res.json({
        status: 'success',
        updated_at: new Date().toISOString()
      });
    }

    // Update in Firestore
    await db.collection('users').doc(user_id)
      .collection('crystals').doc(crystal_id)
      .update({
        ...updateData,
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      });

    res.json({
      status: 'success',
      updated_at: new Date().toISOString()
    });

  } catch (error) {
    console.error('Collection update error:', error);
    res.status(500).json({ error: 'Failed to update crystal' });
  }
});

// Usage tracking endpoint
app.post('/api/usage', (req, res) => {
  const { user_id, feature, metadata } = req.body;
  
  console.log(`Usage tracked: ${feature} for user ${user_id}`);
  
  res.json({
    status: 'tracked',
    timestamp: new Date().toISOString()
  });
});

// Crystal search endpoint
app.get('/api/crystal/search', (req, res) => {
  const { q, limit = 20 } = req.query;
  
  // Mock search results for now
  res.json({
    query: q,
    results: [],
    total: 0,
    limit: parseInt(limit)
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Server error:', error);
  res.status(500).json({ 
    error: 'Internal server error',
    message: ENVIRONMENT === 'development' ? error.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('🔮 CRYSTAL GRIMOIRE BACKEND SERVER STARTED');
  console.log('=' .repeat(50));
  console.log(`🚀 Server running on: http://localhost:${PORT}`);
  console.log(`🌍 Environment: ${ENVIRONMENT}`);
  console.log(`🔍 Health check: http://localhost:${PORT}/health`);
  console.log(`📋 API status: http://localhost:${PORT}/api/status`);
  console.log(`🤖 Gemini API: ${GEMINI_API_KEY ? '✅ configured' : '❌ not configured'}`);
  console.log(`🤖 OpenAI API: ${OPENAI_API_KEY ? '✅ configured' : '❌ not configured'}`);
  console.log('=' .repeat(50));
  console.log('🔮 Backend ready for Crystal Grimoire app integration!');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🛑 Server shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('🛑 Server interrupted, shutting down...');
  process.exit(0);
});