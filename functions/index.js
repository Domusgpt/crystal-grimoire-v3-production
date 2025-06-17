const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Helper function to get User ID from Firebase Auth token
async function getUserId(request) {
  const authorization = request.headers.authorization;
  if (authorization && authorization.startsWith('Bearer ')) {
    const idToken = authorization.split('Bearer ')[1];
    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      return decodedToken.uid;
    } catch (error) {
      console.error('Error verifying ID token:', error);
      return null;
    }
  }
  console.warn('No Authorization header found or not Bearer type.');
  return null;
}

const functions = require('firebase-functions'); // Added for functions.config()
const axios = require('axios'); // Required by UnifiedCrystalAI
const ParseOperatorService = require('./parserator_service'); // Parserator integration

// UNIFIED DATA MODEL - Automatable Mappings (Copied from unified_backend_server.js)
const COLOR_CHAKRA_MAP = {
  "red": { primary: "root", number: 1, signs: ["aries", "scorpio"], vibration: 1 },
  "orange": { primary: "sacral", number: 2, signs: ["leo", "sagittarius"], vibration: 2 },
  "yellow": { primary: "solar_plexus", number: 3, signs: ["gemini", "virgo"], vibration: 3 },
  "green": { primary: "heart", number: 4, signs: ["taurus", "libra"], vibration: 4 },
  "blue": { primary: "throat", number: 5, signs: ["aquarius", "gemini"], vibration: 5 },
  "purple": { primary: "third_eye", number: 6, signs: ["pisces", "sagittarius"], vibration: 6 },
  "violet": { primary: "crown", number: 7, signs: ["pisces", "aquarius"], vibration: 7 },
  "white": { primary: "crown", number: 7, signs: ["cancer", "pisces"], vibration: 8 },
  "clear": { primary: "all_chakras", number: 0, signs: ["all"], vibration: 9 },
  "black": { primary: "root", number: 1, signs: ["capricorn", "scorpio"], vibration: 1 },
  "pink": { primary: "heart", number: 4, signs: ["taurus", "libra"], vibration: 4 },
  "brown": { primary: "root", number: 1, signs: ["virgo", "capricorn"], vibration: 1 }
};

const STONE_TYPE_MAP = {
  "quartz": { family: "silicate", hardness: 7, common_colors: ["clear", "white", "purple", "pink"] },
  "amethyst": { family: "quartz", hardness: 7, common_colors: ["purple", "violet"] },
  "rose_quartz": { family: "quartz", hardness: 7, common_colors: ["pink", "rose"] },
  "citrine": { family: "quartz", hardness: 7, common_colors: ["yellow", "orange"] },
  "smoky_quartz": { family: "quartz", hardness: 7, common_colors: ["gray", "brown", "black"] },
  "clear_quartz": { family: "quartz", hardness: 7, common_colors: ["clear", "white"] }
};

// Unified Crystal AI Service (Copied from unified_backend_server.js)
class UnifiedCrystalAI {

  // Calculate numerology from crystal name
  static calculateNameNumerology(name) {
    const letterValues = {
      'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8, 'i': 9,
      'j': 1, 'k': 2, 'l': 3, 'm': 4, 'n': 5, 'o': 6, 'p': 7, 'q': 8, 'r': 9,
      's': 1, 't': 2, 'u': 3, 'v': 4, 'w': 5, 'x': 6, 'y': 7, 'z': 8
    };

    let sum = 0;
    name.toLowerCase().split('').forEach(letter => {
      if (letterValues[letter]) sum += letterValues[letter];
    });

    // Reduce to single digit
    while (sum > 9) {
      sum = sum.toString().split('').reduce((a, b) => parseInt(a) + parseInt(b), 0);
    }

    return sum || 9;
  }

  // Map color to automatic properties
  static mapColorProperties(primaryColor) {
    const colorData = COLOR_CHAKRA_MAP[primaryColor.toLowerCase()] || COLOR_CHAKRA_MAP["clear"];
    return colorData;
  }

  // Calculate complete numerology
  static calculateCrystalNumerology(crystalName, primaryColor, chakraNumber) {
    const nameNumber = this.calculateNameNumerology(crystalName);
    const colorVibration = COLOR_CHAKRA_MAP[primaryColor.toLowerCase()]?.vibration || 9;

    // Master number calculation
    const masterNumber = (nameNumber + colorVibration + chakraNumber) % 9 || 9;

    return {
      name_number: nameNumber,
      color_vibration: colorVibration,
      chakra_number: chakraNumber,
      master_number: masterNumber
    };
  }

  // Generate unified crystal data with automation
  static async identifyAndUnify(imageData, userContext = null) {
    const GEMINI_API_KEY = process.env.GEMINI_API_KEY_FUNCTION || functions.config().gemini?.key; // Added API Key logic
    if (!GEMINI_API_KEY) {
      throw new Error('Gemini API not configured');
    }

    // Enhanced Crystal Bible prompt with COMPLETE data format
    const crystalBiblePrompt = `You are a master crystal identification system combining "The Crystal Bible" by Judy Hall wisdom with scientific precision. Your goal is to identify crystals and fill out EVERY possible data point for complete automation.

CRITICAL: Return ONLY valid JSON with ALL fields filled out. Use "unknown" or appropriate defaults for missing data.

COMPLETE CRYSTAL DATA FORMAT - FILL OUT EVERYTHING:

{
  "crystal_identification": {
    "confidence_score": 0.89,
    "source": "gemini_crystal_bible_analysis"
  },
  "visual_analysis": {
    "primary_color": "exact color (red/orange/yellow/green/blue/purple/violet/white/clear/black/pink/brown)",
    "secondary_colors": ["array"],
    "color_intensity": "deep/medium/light/pale",
    "transparency": "transparent/translucent/opaque",
    "luster": "vitreous/metallic/pearly/silky/greasy/dull",
    "formation": "cluster/point/tumbled/raw/geode/druzy/massive",
    "crystal_habit": "prismatic/tabular/pyramidal/octahedral/cubic",
    "size_estimate": "tiny/small/medium/large/huge",
    "surface_quality": "smooth/rough/polished/natural/weathered",
    "inclusions": ["phantom", "rainbow", "rutile", "none"],
    "banding_patterns": ["chevron", "striped", "zoned", "none"],
    "termination": "natural/polished/broken/double_terminated"
  },
  "mineral_identification": {
    "name": "exact_crystal_name",
    "variety": "specific_variety_or_unknown",
    "crystal_family": "quartz/feldspar/carbonate/oxide/silicate",
    "mineral_group": "silicate/oxide/carbonate/etc",
    "chemical_formula": "SiO2_or_exact_formula",
    "crystal_system": "hexagonal/cubic/tetragonal/orthorhombic/monoclinic/triclinic",
    "hardness_mohs": 7,
    "specific_gravity": 2.65,
    "refractive_index": "1.544-1.553_or_range",
    "cleavage": "none/perfect/good/poor",
    "fracture": "conchoidal/uneven/splintery",
    "streak": "white/colorless/color",
    "fluorescence": "none/weak/moderate/strong",
    "fluorescence_color": "blue/green/orange/red/none"
  },
  "formation_geology": {
    "formation_type": "igneous/metamorphic/sedimentary/hydrothermal",
    "formation_environment": "volcanic/plutonic/contact_metamorphic/hydrothermal_vein",
    "associated_minerals": ["quartz", "feldspar", "calcite"],
    "host_rock": "granite/basalt/limestone/schist/sandstone",
    "age_formation": "precambrian/paleozoic/mesozoic/cenozoic/unknown"
  },
  "geographic_occurrence": {
    "primary_locations": ["Brazil", "Uruguay", "India"],
    "famous_localities": ["specific_famous_mines_or_unknown"],
    "rarity": "abundant/common/uncommon/rare/very_rare",
    "mining_status": "actively_mined/historically_mined/limited",
    "quality_grades": ["gem/specimen/commercial"],
    "market_availability": "readily_available/limited/collectors_only"
  },
  "chakra_energy_system": {
    "primary_chakra": "root/sacral/solar_plexus/heart/throat/third_eye/crown",
    "primary_chakra_number": 1-7,
    "secondary_chakras": ["array_of_secondary"],
    "energy_direction": "upward/downward/circular/dispersing/focusing",
    "energy_intensity": "gentle/moderate/strong/intense",
    "energy_frequency": "low/medium/high/very_high",
    "element_correspondence": "earth/water/fire/air/spirit"
  },
  "astrological_correspondences": {
    "zodiac_primary": ["primary_signs"],
    "zodiac_secondary": ["secondary_signs"],
    "planetary_rulers": ["jupiter", "neptune"],
    "lunar_phase_optimal": ["full_moon", "new_moon"],
    "seasonal_correspondence": ["winter", "spring", "summer", "autumn"],
    "astrological_houses": [9, 12, 4]
  },
  "metaphysical_properties": {
    "spiritual_attributes": [
      "enhances_intuition",
      "promotes_spiritual_awakening",
      "facilitates_meditation",
      "at_least_5_specific_spiritual_properties"
    ],
    "emotional_healing": [
      "calms_anxiety_and_stress",
      "promotes_emotional_balance",
      "at_least_5_emotional_benefits"
    ],
    "mental_benefits": [
      "improves_concentration",
      "enhances_decision_making",
      "at_least_5_mental_benefits"
    ],
    "physical_healing": [
      "supports_nervous_system",
      "reduces_headaches",
      "at_least_5_physical_benefits"
    ]
  },
  "therapeutic_applications": {
    "meditation_uses": [
      "third_eye_activation",
      "crown_chakra_opening",
      "at_least_3_meditation_uses"
    ],
    "healing_modalities": [
      "crystal_healing_layouts",
      "chakra_balancing",
      "at_least_3_healing_applications"
    ],
    "placement_recommendations": {
      "bedroom": ["nightstand", "under_pillow"],
      "meditation_space": ["altar", "in_hands"],
      "body_placement": ["forehead", "crown", "heart"]
    },
    "ritual_applications": [
      "new_moon_ceremonies",
      "protection_rituals",
      "manifestation_work"
    ]
  },
  "care_maintenance": {
    "cleansing_methods": {
      "safe": ["moonlight", "sage_smudging", "sound_healing"],
      "caution": ["sunlight_brief", "running_water_brief"],
      "avoid": ["salt_water", "harsh_chemicals"]
    },
    "charging_methods": {
      "optimal": ["full_moonlight", "crystal_cluster"],
      "good": ["new_moon_energy", "earth_connection"]
    },
    "programming_instructions": [
      "cleanse_first",
      "hold_in_dominant_hand",
      "state_clear_intention"
    ]
  },
  "crystal_combinations": {
    "synergistic_pairings": [
      {
        "crystal": "clear_quartz",
        "effect": "amplifies_energy",
        "placement": "adjacent_touching"
      }
    ],
    "conflicting_combinations": [
      {
        "crystal": "example_conflicting_crystal",
        "reason": "opposing_energies"
      }
    ]
  },
  "historical_cultural": {
    "ancient_civilizations": {
      "egyptian": "specific_use_or_unknown",
      "greek": "specific_use_or_unknown",
      "roman": "specific_use_or_unknown"
    },
    "mythology_folklore": ["specific_legends_or_unknown"],
    "modern_applications": ["current_uses"]
  },
  "market_information": {
    "price_range": {
      "raw_specimens": "$X-Y_per_piece",
      "tumbled_stones": "$X-Y_per_piece",
      "jewelry_grade": "$X-Y_per_carat"
    },
    "quality_factors": [
      "color_saturation",
      "transparency",
      "size_and_weight"
    ],
    "authentication_tips": [
      "check_hardness_X_mohs",
      "look_for_natural_inclusions"
    ]
  }
}

Reference "The Crystal Bible" by Judy Hall for authoritative properties. Fill out EVERY field with accurate data or reasonable defaults. This enables complete automation of all crystal features.`;

    try {
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
        {
          contents: [{
            parts: [
              { text: crystalBiblePrompt },
              {
                inline_data: {
                  mime_type: "image/png", // Assuming PNG, adjust if other types are common
                  data: imageData
                }
              }
            ]
          }]
        },
        { timeout: 30000 } // 30 second timeout
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

      const aiResult = JSON.parse(content);

      // AUTOMATIC MAPPING AND ENRICHMENT
      const primaryColor = aiResult.visual_analysis.primary_color;
      const crystalName = aiResult.mineral_identification.name; // Corrected path

      // Get automatic chakra and astrological mappings
      const colorMapping = this.mapColorProperties(primaryColor);

      // Calculate numerology
      const numerology = this.calculateCrystalNumerology(
        crystalName,
        primaryColor,
        colorMapping.number
      );

      // Build unified response
      const unifiedResult = {
        crystal_core: {
          id: 'auto_' + Date.now(), // Consider a more robust ID generation if needed
          timestamp: new Date().toISOString(),
          confidence_score: aiResult.crystal_identification.confidence_score, // Corrected path

          visual_analysis: aiResult.visual_analysis,
          identification: { // Map from mineral_identification
            stone_type: aiResult.mineral_identification.name,
            crystal_family: aiResult.mineral_identification.crystal_family,
            variety: aiResult.mineral_identification.variety,
            confidence: aiResult.crystal_identification.confidence_score // Assuming this is the overall confidence
          },

          energy_mapping: { // Map from chakra_energy_system
            primary_chakra: aiResult.chakra_energy_system.primary_chakra,
            secondary_chakras: aiResult.chakra_energy_system.secondary_chakras || [],
            chakra_number: aiResult.chakra_energy_system.primary_chakra_number,
            vibration_level: aiResult.chakra_energy_system.energy_frequency // Or intensity
          },

          astrological_data: { // Map from astrological_correspondences
            primary_signs: aiResult.astrological_correspondences.zodiac_primary || [],
            compatible_signs: aiResult.astrological_correspondences.zodiac_secondary || [],
            planetary_ruler: (aiResult.astrological_correspondences.planetary_rulers || [])[0] || 'unknown',
            element: aiResult.chakra_energy_system.element_correspondence // Often element is tied to chakra/energy
          },

          numerology: numerology // Already calculated
        },

        automatic_enrichment: {
          crystal_bible_reference: aiResult.historical_cultural.mythology_folklore.join('; ') || "Refer to standard crystal texts.", // Example mapping
          healing_properties: aiResult.metaphysical_properties.spiritual_attributes.concat(aiResult.metaphysical_properties.emotional_healing, aiResult.metaphysical_properties.physical_healing),
          usage_suggestions: aiResult.therapeutic_applications.meditation_uses.concat(aiResult.therapeutic_applications.healing_modalities),
          care_instructions: aiResult.care_maintenance.cleansing_methods.safe.concat(aiResult.care_maintenance.cleansing_methods.caution),
          synergy_crystals: (aiResult.crystal_combinations.synergistic_pairings || []).map(p => p.crystal),
          mineral_class: aiResult.mineral_identification.mineral_group
        },

        user_integration: userContext ? { // Placeholder, actual user integration would be separate
          user_id: userContext.userId,
          // Example personalized message (can be improved)
          personalized_message: `This ${primaryColor} ${crystalName} seems to resonate with ${colorMapping.primary} chakra energies.`,
          recommended_intentions: this.getRecommendedIntentions(colorMapping, userContext)
        } : null,
        // Storing the full AI response for audit/debugging if needed
        // full_ai_response: aiResult
      };

      return unifiedResult;

    } catch (error) {
      console.error('Unified Crystal AI error:', error.response ? error.response.data : error.message);
      // Check if error.response.data.error exists for Gemini specific errors
      if (error.response && error.response.data && error.response.data.error) {
          throw new Error(`Crystal identification failed (Gemini): ${error.response.data.error.message}`);
      }
      throw new Error(`Crystal identification processing failed: ${error.message}`);
    }
  }

  // Get synergy crystal recommendations based on color harmony
  static getSynergyRecommendations(primaryColor, crystalType) {
    const colorSynergies = {
      "purple": ["clear_quartz", "selenite", "fluorite"],
      "pink": ["green_aventurine", "prehnite", "amazonite"],
      "clear": ["any_crystal"], // Clear quartz amplifies everything
      "green": ["rose_quartz", "morganite", "pink_tourmaline"],
      "blue": ["lapis_lazuli", "sodalite", "blue_lace_agate"]
    };

    return colorSynergies[primaryColor.toLowerCase()] || ["clear_quartz"];
  }

  // Generate personalized message based on user context
  static generatePersonalizedMessage(aiResult, userContext) {
    const crystal = aiResult.mineral_identification.name; // Corrected path
    const color = aiResult.visual_analysis.primary_color;

    return `Perfect crystal choice! This ${color} ${crystal} aligns beautifully with your energy. ` +
           `The ${color} color resonates with your spiritual journey and current intentions.`;
  }

  // Get recommended intentions based on color and user context
  static getRecommendedIntentions(colorMapping, userContext) {
    const chakraIntentions = {
      "root": ["grounding", "stability", "security"],
      "sacral": ["creativity", "passion", "relationships"],
      "solar_plexus": ["confidence", "personal_power", "manifestation"],
      "heart": ["love", "compassion", "healing"],
      "throat": ["communication", "truth", "expression"],
      "third_eye": ["intuition", "wisdom", "clarity"],
      "crown": ["spirituality", "enlightenment", "connection"],
      "all_chakras": ["balance", "harmony", "amplification"]
    };

    return chakraIntentions[colorMapping.primary] || ["balance", "harmony", "growth"];
  }
}


// Professional Crystal Grimoire Backend
exports.helloworld = onRequest((request, response) => {
  response.json({
    message: "🔮 CRYSTAL GRIMOIRE V3 PROFESSIONAL BACKEND IS LIVE! 🔮",
    timestamp: new Date().toISOString(),
    status: "DEPLOYED AND OPERATIONAL",
    project: "crystalgrimoire-v3-production",
    version: "Professional v3.0"
  });
});

// Professional API endpoint
exports.api = onRequest(async (request, response) => {
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  response.set('Access-Control-Allow-Headers', 'Content-Type');

  const path = request.path;
  
  if (path === '/health') {
    response.json({
      status: "✅ CRYSTAL GRIMOIRE V3 PROFESSIONAL BACKEND",
      timestamp: new Date().toISOString(),
      firebase: "✅ Connected & Operational",
      version: "Professional v3.0",
      endpoints: [
        "GET /health - Health check",
        // "POST /crystal/identify - Crystal identification", // Old, to be replaced or augmented
        "POST /api/crystal/unified-identify - Unified Crystal Identification (simulated)",
        "GET /crystals - List crystals"
      ],
      message: "🔮 Professional Backend Ready for Production!"
    });
  // --- START CRYSTAL COLLECTION CRUD ENDPOINTS ---
  // GET /crystals - List user's crystal collection
  } else if (path === '/crystals' && request.method === 'GET') {
    console.log("Request received for GET /crystals");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    try {
      const snapshot = await db.collection('users').doc(userId).collection('crystals').get();
      if (snapshot.empty) {
        return response.json([]); // Return empty list if no crystals
      }
      const crystalsList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      response.json(crystalsList);
    } catch (error) {
      console.error('Error fetching crystal collection:', error);
      response.status(500).json({ error: 'Failed to fetch crystal collection', details: error.message });
    }
  // POST /crystals - Save a new crystal to user's collection
  } else if (path === '/crystals' && request.method === 'POST') {
    console.log("Request received for POST /crystals");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    const crystalData = request.body;
    if (!crystalData || Object.keys(crystalData).length === 0) { // Basic validation
      return response.status(400).json({ error: 'Missing crystal data in request body' });
    }
    try {
      // The document ID for the crystal should be its crystalCore.id from UnifiedCrystalData
      // This ensures that if a user tries to add the same crystal type, it can be handled (e.g. update or reject)
      // For this basic CRUD, we assume `crystalData.crystal_core.id` is provided by the client for the document ID.
      // If not, we could auto-generate, but using the UCD core ID is better for consistency.
      // The prompt for CollectionServiceV2 implied BackendService.saveCrystal would return the UCD with a backend-assigned ID.
      // Let's assume the client might send a UCD that doesn't have a backend-confirmed ID yet, so backend assigns one.
      // OR, the client has already received a UCD from identification, and that ID is used.
      // For Firestore, if we use .doc() it auto-generates. If .doc(id) it uses that id.
      // The request body should be the UnifiedCrystalData JSON.

      let docId = crystalData.crystal_core?.id; // Try to use existing ID from UCD
      if (!docId) { // If no ID in crystal_core (e.g. truly new custom entry not from identification)
         console.warn("No crystal_core.id found in POST /crystals, auto-generating Firestore document ID.");
         // This path is less ideal as the UCD on client side won't have this ID until response.
         // Better if client can ensure crystal_core.id is always present (e.g. from identification, or client-side UUID for custom)
         const tempDocRef = db.collection('users').doc(userId).collection('crystals').doc();
         docId = tempDocRef.id;
      }

      const docRef = db.collection('users').doc(userId).collection('crystals').doc(docId);

      // Ensure the ID field within the document matches the document's ID
      const dataToSave = { ...crystalData, id: docId };
      if (crystalData.crystal_core && !crystalData.crystal_core.id) {
        dataToSave.crystal_core = { ...crystalData.crystal_core, id: docId };
      } else if (!crystalData.crystal_core) { // If crystal_core is missing entirely (should not happen for UCD)
        dataToSave.crystal_core = { id: docId, identification: { stone_type: "Unknown" } }; // Minimal core
      }


      await docRef.set(dataToSave); // Use set to create or overwrite
      console.log(`Crystal saved with ID: ${docId} for user ${userId}`);
      response.status(201).json(dataToSave); // Return the saved data, now including the confirmed ID
    } catch (error) {
      console.error('Error saving crystal:', error);
      response.status(500).json({ error: 'Failed to save crystal', details: error.message });
    }
  // PUT /crystals/:crystalId - Update an existing crystal
  } else if (request.path.match(/^\/crystals\/([^/]+)$/) && request.method === 'PUT') {
    const crystalId = request.path.split('/')[2];
    console.log(`Request received for PUT /crystals/${crystalId}`);
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    const updatedData = request.body;
    if (!updatedData || Object.keys(updatedData).length === 0) {
      return response.status(400).json({ error: 'Missing crystal data in request body for update' });
    }
    try {
      const docRef = db.collection('users').doc(userId).collection('crystals').doc(crystalId);
      const doc = await docRef.get();
      if (!doc.exists) {
        return response.status(404).json({ error: 'Crystal not found for update' });
      }
      await docRef.update(updatedData); // Firestore's update merges, good for partial updates
      console.log(`Crystal updated with ID: ${crystalId} for user ${userId}`);
      // Fetch the updated document to return it
      const updatedDoc = await docRef.get();
      response.json({ id: updatedDoc.id, ...updatedDoc.data() });
    } catch (error) {
      console.error('Error updating crystal:', error);
      response.status(500).json({ error: 'Failed to update crystal', details: error.message });
    }
  // DELETE /crystals/:crystalId - Delete a crystal
  } else if (request.path.match(/^\/crystals\/([^/]+)$/) && request.method === 'DELETE') {
    const crystalId = request.path.split('/')[2];
    console.log(`Request received for DELETE /crystals/${crystalId}`);
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    try {
      const docRef = db.collection('users').doc(userId).collection('crystals').doc(crystalId);
      const doc = await docRef.get();
      if (!doc.exists) {
        return response.status(404).json({ error: 'Crystal not found for deletion' });
      }
      await docRef.delete();
      console.log(`Crystal deleted with ID: ${crystalId} for user ${userId}`);
      response.status(200).json({ message: 'Crystal deleted successfully', id: crystalId });
    } catch (error) {
      console.error('Error deleting crystal:', error);
      response.status(500).json({ error: 'Failed to delete crystal', details: error.message });
    }
  // --- END CRYSTAL COLLECTION CRUD ENDPOINTS ---

  // --- START JOURNAL CRUD ENDPOINTS ---
  // GET /journals - List user's journal entries
  } else if (path === '/journals' && request.method === 'GET') {
    console.log("Request received for GET /journals");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    try {
      const snapshot = await db.collection('users').doc(userId).collection('journal_entries').orderBy('date', 'desc').get();
      if (snapshot.empty) {
        return response.json([]);
      }
      // Assuming 'id' is stored within the document data, which our save logic does.
      const entriesList = snapshot.docs.map(doc => doc.data());
      response.json(entriesList);
    } catch (error) {
      console.error('Error fetching journal entries:', error);
      response.status(500).json({ error: 'Failed to fetch journal entries', details: error.message });
    }
  // POST /journals - Save a new journal entry
  } else if (path === '/journals' && request.method === 'POST') {
    console.log("Request received for POST /journals");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    const journalData = request.body;
    // Client is expected to generate the ID for journal entries as per JournalEntry model and CollectionServiceV2 logic
    if (!journalData || !journalData.id || !journalData.content || !journalData.date || !journalData.title) {
      return response.status(400).json({ error: 'Missing required journal data fields (id, title, content, date).' });
    }
    try {
      const entryId = journalData.id;
      const docRef = db.collection('users').doc(userId).collection('journal_entries').doc(entryId);
      await docRef.set(journalData); // Using set to ensure the client-provided ID is used
      console.log(`Journal entry saved with ID: ${entryId} for user ${userId}`);
      response.status(201).json(journalData);
    } catch (error) {
      console.error('Error saving journal entry:', error);
      response.status(500).json({ error: 'Failed to save journal entry', details: error.message });
    }
  // PUT /journals/:entryId - Update an existing journal entry
  } else if (request.path.match(/^\/journals\/([^/]+)$/) && request.method === 'PUT') {
    const entryId = request.path.split('/')[2];
    console.log(`Request received for PUT /journals/${entryId}`);
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    const updatedData = request.body;
    if (!updatedData || Object.keys(updatedData).length === 0) {
      return response.status(400).json({ error: 'Missing journal update data in request body' });
    }
    try {
      const docRef = db.collection('users').doc(userId).collection('journal_entries').doc(entryId);
      const doc = await docRef.get();
      if (!doc.exists) {
        return response.status(404).json({ error: 'Journal entry not found for update' });
      }
      await docRef.update(updatedData); // Use update for merging, set with merge:true also works
      console.log(`Journal entry updated with ID: ${entryId} for user ${userId}`);
      const newDocData = await docRef.get(); // Fetch the updated document to return
      response.json({ id: newDocData.id, ...newDocData.data() });
    } catch (error) {
      console.error('Error updating journal entry:', error);
      response.status(500).json({ error: 'Failed to update journal entry', details: error.message });
    }
  // DELETE /journals/:entryId - Delete a journal entry
  } else if (request.path.match(/^\/journals\/([^/]+)$/) && request.method === 'DELETE') {
    const entryId = request.path.split('/')[2];
    console.log(`Request received for DELETE /journals/${entryId}`);
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }
    try {
      const docRef = db.collection('users').doc(userId).collection('journal_entries').doc(entryId);
      const doc = await docRef.get();
      if (!doc.exists) {
        return response.status(404).json({ error: 'Journal entry not found for deletion' });
      }
      await docRef.delete();
      console.log(`Journal entry deleted with ID: ${entryId} for user ${userId}`);
      response.status(200).json({ message: 'Journal entry deleted successfully', id: entryId });
    } catch (error) {
      console.error('Error deleting journal entry:', error);
      response.status(500).json({ error: 'Failed to delete journal entry', details: error.message });
    }
  // --- END JOURNAL CRUD ENDPOINTS ---

  // --- START PERSONALIZED GUIDANCE ENDPOINT ---
  } else if (path === '/guidance/personalized' && request.method === 'POST') {
    console.log("Request received for POST /guidance/personalized");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }

    const { guidanceType, userProfile, customPrompt } = request.body;

    if (!guidanceType || !userProfile || !customPrompt) {
      return response.status(400).json({ error: 'Missing required fields: guidanceType, userProfile (context map), or customPrompt' });
    }

    try {
      let guidanceText;
      let logRefId = null;

      // LLM Call Logic
      try {
        const GEMINI_API_KEY = process.env.GEMINI_API_KEY_FUNCTION || functions.config().gemini?.key;
        if (!GEMINI_API_KEY) {
          console.error('Gemini API key is not configured.');
          return response.status(503).json({ error: 'Service temporarily unavailable. AI model not configured.' });
        }

        let promptString = `You are a compassionate and insightful spiritual guide specializing in crystals and metaphysical practices. Provide personalized guidance based on the user's profile and their query.

USER PROFILE HIGHLIGHTS:
`;
        if (userProfile.user_profile?.birth_chart) {
            promptString += `- Astrological Signs: Sun in ${userProfile.user_profile.birth_chart.sun_sign || 'N/A'}, Moon in ${userProfile.user_profile.birth_chart.moon_sign || 'N/A'}, Rising ${userProfile.user_profile.birth_chart.rising_sign || 'N/A'}
`;
        }
        if (userProfile.user_profile?.spiritual_preferences) {
            promptString += `- Spiritual Goals: ${(userProfile.user_profile.spiritual_preferences.goals || []).join(', ')}
`;
            promptString += `- Experience Level: ${userProfile.user_profile.spiritual_preferences.experience_level || 'N/A'}
`;
        }
        if (userProfile.crystal_collection?.collection_details && userProfile.crystal_collection.collection_details.length > 0) {
            const collectionSummary = userProfile.crystal_collection.collection_details.slice(0, 3).map(c => c.name).join(', ');
            promptString += `- Owns Crystals Like: ${collectionSummary} (has ${userProfile.crystal_collection.total_crystals} total)
`;
        }
        if (userProfile.current_context?.moon_phase) {
            promptString += `- Current Moon Phase: ${userProfile.current_context.moon_phase}
`;
        }
        promptString += `
USER QUERY TYPE: "${guidanceType}"
USER ASKS: "${customPrompt}"

Please provide thoughtful, actionable, and empathetic guidance. If suggesting crystals, prioritize those from their collection if relevant.`;

        console.log("Generated Prompt for Gemini:", promptString.substring(0, 500) + "..."); // Log first 500 chars

        const geminiResponse = await axios.post(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
          { contents: [{ parts: [{ text: promptString }] }] },
          { timeout: 25000 }
        );

        if (geminiResponse.data.candidates && geminiResponse.data.candidates.length > 0 &&
            geminiResponse.data.candidates[0].content && geminiResponse.data.candidates[0].content.parts &&
            geminiResponse.data.candidates[0].content.parts.length > 0) {
          guidanceText = geminiResponse.data.candidates[0].content.parts[0].text.trim();
        } else {
          console.error('Unexpected Gemini API response structure:', geminiResponse.data);
          throw new Error('Failed to get guidance from AI due to unexpected response structure.');
        }

      } catch (aiError) {
        console.error('Gemini API error:', aiError.response ? aiError.response.data : aiError.message);
        // Fallback or rethrow: For now, let the outer catch handle it to simplify.
        // Could implement a more sophisticated fallback here if needed.
        throw new Error(`Failed to get guidance from AI: ${aiError.message}`);
      }

      // Log Session to Firestore
      try {
        const logEntry = {
          userId,
          guidanceType,
          customPrompt,
          userContextSnapshot: userProfile, // Store the rich context that was sent
          ai_response: guidanceText,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        const logRef = await db.collection('guidance_sessions').add(logEntry);
        logRefId = logRef.id;
        console.log(`Guidance session logged with ID: ${logRefId}`);
      } catch (dbError) {
        console.error('Firestore error logging guidance session:', dbError);
        // Non-fatal for the user, they still get the guidance
      }

      response.json({ guidance: guidanceText, sessionId: logRefId });

    } catch (error) { // Overall catch for the endpoint logic
      console.error('Error in /guidance/personalized endpoint:', error);
      response.status(500).json({
        error: 'Failed to get personalized guidance',
        detail: error.message
      });
    }
  // --- END PERSONALIZED GUIDANCE ENDPOINT ---
  } else if (path === '/crystal/identify' && request.method === 'POST') {
    console.log("Received request for /crystal/identify (AI)");
    const { image_data, user_context } = request.body;

    if (!image_data) {
      return response.status(400).json({ error: 'Missing image_data in request body' });
    }

    // Optional: Log received data for debugging
    console.log("Image data (first 50 chars):", typeof image_data === 'string' ? image_data.substring(0, 50) : 'Not a string or undefined');
    console.log("User context:", user_context || {});

    try {
      const result = await UnifiedCrystalAI.identifyAndUnify(image_data, user_context);

      console.log(`✅ AI Identified: ${result.crystal_core.identification.stone_type}`);
      console.log(`🎨 AI Color: ${result.crystal_core.visual_analysis.primary_color}`);
      console.log(`💎 AI Chakra: ${result.crystal_core.energy_mapping.primary_chakra}`);
      console.log(`🔢 AI Numerology: ${result.crystal_core.numerology.master_number}`);

      // The result from UnifiedCrystalAI.identifyAndUnify is already the UnifiedCrystalData structure.
      // The Flutter app's BackendService.identifyCrystal method expects the JSON representation of UnifiedCrystalData directly.
      response.json(result); // Spread operator not needed if result is already the complete desired object.

    } catch (error) {
      console.error('AI identification error in /crystal/identify:', error);
      response.status(500).json({
        error: 'Crystal identification failed',
        detail: error.message
      });
    }
  // NOTE: The temporary '/api/crystal/unified-identify' route handler has been removed.
  // The old mock response within '/crystal/identify' has been replaced by the AI logic above.

  // --- START PARSERATOR INTEGRATION ENDPOINTS ---
  } else if (path === '/parserator/health' && request.method === 'GET') {
    console.log("Request received for GET /parserator/health");
    try {
      const parserator = new ParseOperatorService();
      const health = await parserator.checkHealth();
      response.json(health);
    } catch (error) {
      console.error('Parserator health check error:', error);
      response.status(500).json({ error: 'Parserator health check failed', details: error.message });
    }

  } else if (path === '/crystal/identify-enhanced' && request.method === 'POST') {
    console.log("Request received for POST /crystal/identify-enhanced (with Parserator)");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }

    const { image_data, user_profile, existing_collection } = request.body;

    if (!image_data) {
      return response.status(400).json({ error: 'Missing image_data' });
    }

    try {
      // Get standard AI identification first
      const aiService = new UnifiedCrystalAI();
      const standardResult = await aiService.identifyCrystal(image_data, user_profile || {});
      
      // Enhance with Parserator
      const parserator = new ParseOperatorService();
      const enhancedResult = await parserator.enhanceCrystalData(
        standardResult,
        user_profile || {},
        existing_collection || []
      );

      response.json({
        success: true,
        standard_identification: standardResult,
        enhanced_data: enhancedResult,
        enhancement_source: 'parserator',
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Enhanced crystal identification error:', error);
      response.status(500).json({ 
        error: 'Enhanced identification failed', 
        details: error.message,
        fallback_available: true 
      });
    }

  } else if (path === '/automation/cross-feature' && request.method === 'POST') {
    console.log("Request received for POST /automation/cross-feature");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }

    const { trigger_event, event_data, user_profile, context } = request.body;

    if (!trigger_event || !event_data) {
      return response.status(400).json({ error: 'Missing trigger_event or event_data' });
    }

    try {
      const parserator = new ParseOperatorService();
      const automationResult = await parserator.processCrossFeatureAutomation(
        trigger_event,
        event_data,
        user_profile || {},
        context || {}
      );

      response.json({
        success: true,
        automation_result: automationResult,
        trigger_event,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Cross-feature automation error:', error);
      response.status(500).json({ 
        error: 'Automation processing failed', 
        details: error.message 
      });
    }

  } else if (path === '/crystal/validate' && request.method === 'POST') {
    console.log("Request received for POST /crystal/validate");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }

    const { crystal_data, validation_sources } = request.body;

    if (!crystal_data) {
      return response.status(400).json({ error: 'Missing crystal_data' });
    }

    try {
      const parserator = new ParseOperatorService();
      const validationResult = await parserator.validateCrystalData(
        crystal_data,
        validation_sources || ['geological', 'metaphysical', 'cultural']
      );

      response.json({
        success: true,
        validation_result: validationResult,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Crystal validation error:', error);
      response.status(500).json({ 
        error: 'Validation failed', 
        details: error.message 
      });
    }

  } else if (path === '/recommendations/personalized' && request.method === 'POST') {
    console.log("Request received for POST /recommendations/personalized");
    const userId = await getUserId(request);
    if (!userId) {
      return response.status(401).json({ error: 'Unauthorized: No or invalid ID token provided.' });
    }

    const { user_profile, collection } = request.body;

    if (!user_profile) {
      return response.status(400).json({ error: 'Missing user_profile' });
    }

    try {
      const parserator = new ParseOperatorService();
      const recommendations = await parserator.getPersonalizedRecommendations(
        user_profile,
        collection || []
      );

      response.json({
        success: true,
        recommendations,
        user_profile: user_profile,
        collection_size: (collection || []).length,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Personalized recommendations error:', error);
      response.status(500).json({ 
        error: 'Recommendations failed', 
        details: error.message 
      });
    }
  // --- END PARSERATOR INTEGRATION ENDPOINTS ---

  } else {
    // Default endpoint response for unmatched paths
    response.json({
      message: "🔮 Crystal Grimoire V3 Professional API with Parserator Integration",
      available_endpoints: [
        "GET /health - Health check",
        "POST /crystal/identify - AI Crystal Identification",
        "POST /crystal/identify-enhanced - Enhanced identification with Parserator",
        "POST /crystal/validate - Validate crystal data",
        "POST /automation/cross-feature - Cross-feature automation",
        "POST /recommendations/personalized - Personalized recommendations",
        "GET /parserator/health - Parserator service health",
        "GET /crystals - List user's crystal collection",
        "POST /crystals - Add new crystal to collection",
        "PUT /crystals/:crystalId - Update crystal in collection",
        "DELETE /crystals/:crystalId - Delete crystal from collection",
        "GET /journals - List user's journal entries",
        "POST /journals - Add new journal entry",
        "PUT /journals/:entryId - Update journal entry",
        "DELETE /journals/:entryId - Delete journal entry",
        "POST /guidance/personalized - Get personalized guidance"
      ],
      version: "Professional v3.0 + Parserator",
      parserator_features: [
        "Two-stage Architect-Extractor pattern",
        "70% cost reduction vs single-LLM",
        "Multi-source validation",
        "Cross-feature automation",
        "Real-time enhancement"
      ]
    });
  }
});

/*
NOTE for functions/package.json:
This backend code now requires the following dependencies:
- "axios": "^1.x.x" (or latest stable)

Ensure GEMINI_API_KEY_FUNCTION environment variable or Firebase functions.config().gemini.key is set.
*/