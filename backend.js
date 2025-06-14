#!/usr/bin/env node
/**
 * Crystal Grimoire V3 - Unified Backend (Enhanced)
 * Production-ready backend with Crystal Bible integration + all features
 */

const express = require('express');
const cors = require('cors');
const multer = require('multer');
const axios = require('axios');
const admin = require('firebase-admin');

require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8085;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

// Initialize Firebase Admin
let db;
try {
  if (!admin.apps.length) {
    // Check if we're in emulator mode
    if (process.env.FIRESTORE_EMULATOR_HOST) {
      admin.initializeApp({
        projectId: 'crystalgrimoire-production'
      });
      console.log('🔧 Using Firebase Emulator');
    } else {
      // Production mode - requires service account
      admin.initializeApp({
        projectId: 'crystalgrimoire-production',
        // Will use GOOGLE_APPLICATION_CREDENTIALS env var if set
      });
      console.log('🔥 Using Firebase Production');
    }
  }
  db = admin.firestore();
  console.log('✅ Firebase Admin initialized successfully');
} catch (error) {
  console.warn('⚠️  Firebase Admin not configured, running in API-only mode:', error.message);
  db = null;
}

app.use(express.json({ limit: '50mb' }));
app.use(cors({ origin: '*' }));

const upload = multer({
  limits: { fileSize: 10 * 1024 * 1024 },
  storage: multer.memoryStorage()
});

// ================================
// CRYSTAL IDENTIFICATION SYSTEM
// ================================

// Enhanced Crystal Bible prompt with user personalization
const getCrystalIdentificationPrompt = (userContext = null) => {
  let prompt = `You are a geology and crystal healing expert who identifies and gives information on stones, crystals, and other minerals in a sagely and confident way. You blend the wisdom of a spiritual advisor with the precision of a scientific expert.

Your knowledge comes from authoritative sources including "The Crystal Bible" by Judy Hall, "Healing Crystals: The A-Z Guide to 430 Gemstones" by Michael Gienger, and comprehensive geological databases.

Guidelines for Identification:
1. **Scientific Accuracy**: Provide precise geological classification, crystal system, hardness, formation process
2. **Metaphysical Wisdom**: Include chakra associations, healing properties, spiritual significance
3. **Practical Guidance**: Cleansing methods, charging techniques, usage recommendations
4. **Color Analysis**: Extract primary and secondary colors for chakra correlation
5. **Astrological Connections**: Zodiac signs, planetary rulers, elemental associations
6. **Numerological Value**: Calculate crystal name numerology (A=1, B=2, etc., reduce to 1-9)`;

  if (userContext) {
    prompt += `

PERSONAL CONTEXT FOR THIS USER:
- Birth Chart: ${userContext.sunSign} Sun, ${userContext.moonSign} Moon, ${userContext.ascendant} Rising
- Crystal Collection: Owns ${userContext.crystalCount} crystals including ${userContext.topCrystals?.join(', ') || 'various stones'}
- Spiritual Goals: ${userContext.spiritualGoals || 'General spiritual growth'}
- Subscription Tier: ${userContext.subscriptionTier}

Provide personalized guidance based on their astrological profile and current collection.`;
  }

  prompt += `

**RESPONSE FORMAT REQUIRED:**

First provide your spiritual advisor response with identification and guidance.

Then end with this EXACT format:

AUTOMATION_DATA:
{
  "identification": {
    "name": "Crystal Name",
    "variety": "Specific variety if applicable", 
    "scientific_name": "Chemical formula",
    "confidence": 95
  },
  "automation_data": {
    "color": "primary_color_name",
    "stone_type": "crystal_name",
    "mineral_class": "quartz/feldspar/beryl/garnet/tourmaline/oxide/carbonate/etc",
    "chakra": "primary_chakra",
    "zodiac": ["primary_signs"],
    "number": calculated_numerology_number_1_to_9
  },
  "metaphysical_properties": {
    "primary_chakras": ["chakra1", "chakra2"],
    "healing_properties": ["property1", "property2", "property3"],
    "spiritual_significance": "Main spiritual purpose",
    "emotional_healing": "Emotional benefits",
    "intentions": ["intention1", "intention2"]
  },
  "physical_properties": {
    "hardness": "X (Mohs scale)",
    "crystal_system": "system_name",
    "formation": "formation_type",
    "color_range": ["color1", "color2"],
    "transparency": "transparent/translucent/opaque"
  },
  "care_instructions": {
    "cleansing": ["method1", "method2"],
    "charging": ["method1", "method2"],
    "storage": "storage_recommendations"
  }
}`;

  return prompt;
};

// Crystal identification with full properties
app.post('/api/crystal/identify', upload.single('image'), async (req, res) => {
  try {
    let imageData;
    if (req.file) {
      imageData = req.file.buffer.toString('base64');
    } else if (req.body.image_data) {
      imageData = req.body.image_data;
    } else {
      return res.status(400).json({ error: 'No image data provided' });
    }

    // Get user context for personalization
    let userContext = null;
    if (req.body.user_id && db) {
      try {
        const userDoc = await db.collection('users').doc(req.body.user_id).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          const crystalsSnapshot = await db.collection('users').doc(req.body.user_id)
            .collection('crystals').limit(5).get();
          
          userContext = {
            sunSign: userData.astrology?.sunSign || 'Unknown',
            moonSign: userData.astrology?.moonSign || 'Unknown', 
            ascendant: userData.astrology?.ascendant || 'Unknown',
            crystalCount: crystalsSnapshot.size,
            topCrystals: crystalsSnapshot.docs.map(doc => doc.data().name),
            spiritualGoals: userData.profile?.spiritualGoals,
            subscriptionTier: userData.subscription?.tier || 'free'
          };
        }
      } catch (error) {
        console.warn('Could not fetch user context:', error);
      }
    }

    const prompt = getCrystalIdentificationPrompt(userContext);

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
    
    // Extract the user message and automation data
    const automationIndex = content.indexOf('AUTOMATION_DATA:');
    let userMessage = content;
    let crystalData = null;

    if (automationIndex !== -1) {
      userMessage = content.substring(0, automationIndex).trim();
      const jsonPart = content.substring(automationIndex + 16).trim();
      
      try {
        crystalData = JSON.parse(jsonPart);
      } catch (e) {
        console.error('Failed to parse automation data:', e);
      }
    }

    // Save identification to database if user provided and db available
    if (req.body.user_id && crystalData && db) {
      try {
        await db.collection('identifications').add({
          userId: req.body.user_id,
          crystalData: crystalData,
          userMessage: userMessage,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          imageSize: req.file ? req.file.size : 0
        });
      } catch (error) {
        console.warn('Could not save identification:', error);
      }
    }

    res.json({
      success: true,
      user_message: userMessage,
      crystal_data: crystalData,
      personalized: !!userContext,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Crystal identification error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// ================================
// PERSONALIZED GUIDANCE SYSTEM
// ================================

app.post('/api/guidance/personalized', async (req, res) => {
  try {
    const { user_id, query, context_type = 'general' } = req.body;

    if (!user_id || !query) {
      return res.status(400).json({ error: 'user_id and query are required' });
    }

    // Get user's complete profile
    const userDoc = await db.collection('users').doc(user_id).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data();
    
    // Get user's crystal collection
    const crystalsSnapshot = await db.collection('users').doc(user_id)
      .collection('crystals').get();
    
    const userCrystals = crystalsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    // Build personalized prompt
    const guidancePrompt = `You are a wise spiritual advisor and crystal healing expert. Provide personalized guidance for this user.

USER PROFILE:
- Birth Chart: ${userData.astrology?.sunSign || 'Unknown'} Sun, ${userData.astrology?.moonSign || 'Unknown'} Moon, ${userData.astrology?.ascendant || 'Unknown'} Rising
- Dominant Element: ${userData.astrology?.dominantElement || 'Unknown'}
- Crystal Collection: ${userCrystals.length} crystals including ${userCrystals.slice(0, 5).map(c => c.name).join(', ')}
- Spiritual Goals: ${userData.profile?.spiritualGoals || 'General spiritual growth'}
- Current Challenges: ${userData.profile?.currentChallenges || 'Not specified'}

CONTEXT TYPE: ${context_type}

USER'S QUESTION: ${query}

Provide guidance that:
1. References their specific birth chart and astrological influences
2. Suggests crystals from their actual collection when relevant
3. Offers practical spiritual advice
4. Includes any relevant moon phase or planetary information
5. Addresses their specific spiritual goals

Be warm, wise, and specific to their unique situation.`;

    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        contents: [{
          parts: [{ text: guidancePrompt }]
        }]
      },
      { timeout: 30000 }
    );

    const guidance = response.data.candidates[0].content.parts[0].text;

    // Save guidance session
    await db.collection('guidance_sessions').add({
      userId: user_id,
      query: query,
      response: guidance,
      contextType: context_type,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({
      success: true,
      guidance: guidance,
      context_type: context_type,
      personalization_data: {
        birth_chart: userData.astrology,
        crystal_count: userCrystals.length,
        spiritual_goals: userData.profile?.spiritualGoals
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Personalized guidance error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// ================================
// MOON PHASE & RITUAL SYSTEM
// ================================

// Moon phase calculation
const getMoonPhase = (date = new Date()) => {
  const LUNAR_CYCLE = 29.5305882;
  const KNOWN_NEW_MOON = new Date('2000-01-06T18:14:00Z');
  
  const daysSinceNewMoon = (date - KNOWN_NEW_MOON) / (1000 * 60 * 60 * 24);
  const phase = (daysSinceNewMoon % LUNAR_CYCLE) / LUNAR_CYCLE;
  
  if (phase < 0.125) return { name: 'New Moon', emoji: '🌑', phase: 'new' };
  if (phase < 0.25) return { name: 'Waxing Crescent', emoji: '🌒', phase: 'waxing_crescent' };
  if (phase < 0.375) return { name: 'First Quarter', emoji: '🌓', phase: 'first_quarter' };
  if (phase < 0.5) return { name: 'Waxing Gibbous', emoji: '🌔', phase: 'waxing_gibbous' };
  if (phase < 0.625) return { name: 'Full Moon', emoji: '🌕', phase: 'full' };
  if (phase < 0.75) return { name: 'Waning Gibbous', emoji: '🌖', phase: 'waning_gibbous' };
  if (phase < 0.875) return { name: 'Last Quarter', emoji: '🌗', phase: 'last_quarter' };
  return { name: 'Waning Crescent', emoji: '🌘', phase: 'waning_crescent' };
};

app.get('/api/moon/current-phase', (req, res) => {
  const currentPhase = getMoonPhase();
  res.json({
    success: true,
    moon_phase: currentPhase,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/moon/rituals/:phase', async (req, res) => {
  try {
    const { phase } = req.params;
    const { user_id } = req.query;

    const ritualTemplates = {
      new: {
        name: 'New Moon Intention Setting',
        focus: 'New beginnings, manifestation, goal setting',
        energy: 'Planting seeds, fresh starts',
        recommended_crystals: ['Clear Quartz', 'Selenite', 'Black Tourmaline', 'Labradorite'],
        ritual_steps: [
          'Cleanse your space with sage or palo santo',
          'Light a white candle for new beginnings',
          'Hold your intention crystal and set clear goals',
          'Write your intentions on paper',
          'Place crystals around your written intentions',
          'Meditate on your goals for 10-15 minutes'
        ],
        duration: 30
      },
      full: {
        name: 'Full Moon Release & Gratitude',
        focus: 'Release, gratitude, culmination, power',
        energy: 'Peak energy, letting go, celebration',
        recommended_crystals: ['Moonstone', 'Selenite', 'Clear Quartz', 'Amethyst'],
        ritual_steps: [
          'Create sacred space under moonlight if possible',
          'Light silver or white candles',
          'Hold moonstone or selenite',
          'Express gratitude for what has manifested',
          'Write down what you want to release',
          'Safely burn or bury the release paper',
          'Charge your crystals in moonlight'
        ],
        duration: 45
      },
      first_quarter: {
        name: 'First Quarter Action Ritual',
        focus: 'Taking action, overcoming obstacles, decision making',
        energy: 'Forward momentum, willpower, courage',
        recommended_crystals: ['Citrine', 'Tiger\'s Eye', 'Carnelian', 'Red Jasper'],
        ritual_steps: [
          'Set up your space with action-oriented crystals',
          'Light yellow or orange candles for energy',
          'Review your new moon intentions',
          'Identify specific actions to take',
          'Hold citrine while visualizing success',
          'Create an action plan with deadlines'
        ],
        duration: 25
      },
      last_quarter: {
        name: 'Last Quarter Forgiveness Ritual',
        focus: 'Forgiveness, release, breaking patterns',
        energy: 'Letting go, healing, reflection',
        recommended_crystals: ['Rose Quartz', 'Smoky Quartz', 'Apache Tear', 'Lepidolite'],
        ritual_steps: [
          'Create a peaceful, healing environment',
          'Light pink candles for heart healing',
          'Hold rose quartz over your heart',
          'Practice forgiveness meditation',
          'Release old patterns and grudges',
          'Send love to yourself and others'
        ],
        duration: 35
      }
    };

    const ritual = ritualTemplates[phase];
    if (!ritual) {
      return res.status(404).json({ error: 'Ritual not found for this phase' });
    }

    // If user provided, personalize with their crystals
    if (user_id) {
      try {
        const crystalsSnapshot = await db.collection('users').doc(user_id)
          .collection('crystals').get();
        
        const userCrystals = crystalsSnapshot.docs.map(doc => doc.data().name);
        const availableCrystals = ritual.recommended_crystals.filter(crystal =>
          userCrystals.some(userCrystal => 
            userCrystal.toLowerCase().includes(crystal.toLowerCase())
          )
        );

        if (availableCrystals.length > 0) {
          ritual.user_available_crystals = availableCrystals;
          ritual.personalized_note = `You have ${availableCrystals.join(', ')} in your collection - perfect for this ritual!`;
        } else {
          ritual.alternative_crystals = userCrystals.slice(0, 3);
          ritual.personalized_note = `While you don't have the traditional crystals, try using ${userCrystals.slice(0, 3).join(', ')} from your collection.`;
        }
      } catch (error) {
        console.warn('Could not personalize ritual:', error);
      }
    }

    res.json({
      success: true,
      phase: phase,
      ritual: ritual,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Moon ritual error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// ================================
// DREAM JOURNAL SYSTEM
// ================================

app.post('/api/dreams/create', async (req, res) => {
  try {
    const { user_id, dream_content, crystals_present, dream_date, additional_data } = req.body;

    if (!user_id || !dream_content) {
      return res.status(400).json({ error: 'user_id and dream_content are required' });
    }

    // Get current moon phase for the dream date
    const dreamDateObj = dream_date ? new Date(dream_date) : new Date();
    const moonPhase = getMoonPhase(dreamDateObj);

    // Extract dream elements using AI
    const extractionPrompt = `Extract key elements from this dream narrative and return as JSON:

Dream: ${dream_content}

Extract:
1. Main themes (transformation, fear, love, journey, etc.)
2. Symbols (water, animals, objects, people)
3. Emotional tone (peaceful, anxious, joyful, fearful, etc.)
4. Colors mentioned
5. Locations (home, forest, water, etc.)

Return ONLY valid JSON in this format:
{
  "themes": ["theme1", "theme2"],
  "symbols": ["symbol1", "symbol2"],
  "emotional_tone": "primary_emotion",
  "colors": ["color1", "color2"],
  "locations": ["location1", "location2"]
}`;

    const extractionResponse = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        contents: [{
          parts: [{ text: extractionPrompt }]
        }]
      },
      { timeout: 15000 }
    );

    let extractedElements = {};
    try {
      const extractedText = extractionResponse.data.candidates[0].content.parts[0].text;
      extractedElements = JSON.parse(extractedText);
    } catch (e) {
      console.warn('Could not extract dream elements:', e);
      extractedElements = {
        themes: [],
        symbols: [],
        emotional_tone: 'neutral',
        colors: [],
        locations: []
      };
    }

    // Create dream entry
    const dreamEntry = {
      userId: user_id,
      content: dream_content,
      dreamDate: admin.firestore.Timestamp.fromDate(dreamDateObj),
      moonPhase: moonPhase,
      crystalsPresent: crystals_present || [],
      extractedElements: extractedElements,
      additionalData: additional_data || {},
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    };

    const dreamRef = await db.collection('dreams').add(dreamEntry);

    res.json({
      success: true,
      dream_id: dreamRef.id,
      moon_phase: moonPhase,
      extracted_elements: extractedElements,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Dream creation error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

app.get('/api/dreams/patterns/:user_id', async (req, res) => {
  try {
    const { user_id } = req.params;
    const { timeframe = 30 } = req.query; // days

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(timeframe));

    const dreamsSnapshot = await db.collection('dreams')
      .where('userId', '==', user_id)
      .where('dreamDate', '>=', admin.firestore.Timestamp.fromDate(startDate))
      .orderBy('dreamDate', 'desc')
      .get();

    const dreams = dreamsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    // Analyze patterns
    const symbolCount = {};
    const themeCount = {};
    const moonPhaseCount = {};
    const emotionalTones = {};

    dreams.forEach(dream => {
      // Count symbols
      dream.extractedElements?.symbols?.forEach(symbol => {
        symbolCount[symbol] = (symbolCount[symbol] || 0) + 1;
      });

      // Count themes
      dream.extractedElements?.themes?.forEach(theme => {
        themeCount[theme] = (themeCount[theme] || 0) + 1;
      });

      // Count moon phases
      const phase = dream.moonPhase?.phase || 'unknown';
      moonPhaseCount[phase] = (moonPhaseCount[phase] || 0) + 1;

      // Count emotional tones
      const tone = dream.extractedElements?.emotional_tone || 'neutral';
      emotionalTones[tone] = (emotionalTones[tone] || 0) + 1;
    });

    const patterns = {
      total_dreams: dreams.length,
      timeframe_days: parseInt(timeframe),
      recurring_symbols: Object.entries(symbolCount)
        .filter(([_, count]) => count >= 2)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10),
      recurring_themes: Object.entries(themeCount)
        .filter(([_, count]) => count >= 2)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10),
      moon_phase_distribution: moonPhaseCount,
      emotional_distribution: emotionalTones,
      most_active_moon_phase: Object.entries(moonPhaseCount)
        .sort((a, b) => b[1] - a[1])[0]?.[0] || 'none'
    };

    res.json({
      success: true,
      patterns: patterns,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Dream patterns error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// ================================
// USER MANAGEMENT SYSTEM
// ================================

app.post('/api/users/profile', async (req, res) => {
  try {
    const { user_id, profile_data } = req.body;

    if (!user_id) {
      return res.status(400).json({ error: 'user_id is required' });
    }

    await db.collection('users').doc(user_id).set({
      profile: profile_data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    res.json({
      success: true,
      message: 'Profile updated successfully',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

app.get('/api/users/:user_id/profile', async (req, res) => {
  try {
    const { user_id } = req.params;

    const userDoc = await db.collection('users').doc(user_id).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      profile: userDoc.data(),
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// ================================
// HEALTH & STATUS ENDPOINTS
// ================================

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    version: '3.0.0',
    features: [
      'Crystal Identification',
      'Personalized Guidance', 
      'Moon Rituals',
      'Dream Journal',
      'User Management'
    ],
    apis: {
      gemini: GEMINI_API_KEY ? 'configured' : 'not_configured',
      firebase: 'configured'
    },
    timestamp: new Date().toISOString()
  });
});

app.get('/api/status', async (req, res) => {
  try {
    // Test database connection
    await db.collection('_health_check').doc('test').set({
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({
      status: 'operational',
      services: {
        gemini_ai: GEMINI_API_KEY ? 'online' : 'offline',
        firestore: 'online',
        crystal_identification: 'online',
        moon_phases: 'online',
        dream_journal: 'online'
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    res.status(500).json({
      status: 'degraded',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('🔮 CRYSTAL GRIMOIRE V3 - UNIFIED BACKEND (ENHANCED)');
  console.log(`🚀 Server: http://localhost:${PORT}`);
  console.log(`🤖 Gemini AI: ${GEMINI_API_KEY ? '✅' : '❌'}`);
  console.log(`🔥 Firebase: ✅`);
  console.log(`📚 Crystal Bible: ✅`);
  console.log(`🌙 Moon Rituals: ✅`);
  console.log(`💭 Dream Journal: ✅`);
  console.log(`🎯 Unified Data Model: ✅`);
  console.log(`✨ Personalization: ✅`);
  console.log('');
  console.log('📋 Available Endpoints:');
  console.log('  POST /api/crystal/identify - Crystal identification with personalization');
  console.log('  POST /api/guidance/personalized - AI guidance using birth chart + collection');
  console.log('  GET  /api/moon/current-phase - Current moon phase');
  console.log('  GET  /api/moon/rituals/:phase - Moon ritual suggestions');
  console.log('  POST /api/dreams/create - Create dream journal entry');
  console.log('  GET  /api/dreams/patterns/:user_id - Dream pattern analysis');
  console.log('  POST /api/users/profile - Update user profile');
  console.log('  GET  /api/users/:user_id/profile - Get user profile');
  console.log('  GET  /health - Basic health check');
  console.log('  GET  /api/status - Detailed system status');
});

module.exports = app;