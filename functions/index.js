// functions/index.js
// functions/index.js
// functions/index.js
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } = require('@google/generative-ai');
const { mapAiResponseToUnifiedData } = require('./logic/dataMapper'); // Import the mapper

// It's good practice to initialize admin only once.
if (admin.apps.length === 0) {
  admin.initializeApp();
}

const GEMINI_API_KEY = functions.config().gemini?.key;
let genAI;
let geminiModel;

if (GEMINI_API_KEY) {
  genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
  geminiModel = genAI.getGenerativeModel({ model: "gemini-pro-vision" });
  console.log("Gemini AI Model initialized successfully.");
} else {
  console.warn("Gemini API Key not found in Firebase Functions config. Set with 'firebase functions:config:set gemini.key=\"YOUR_KEY\"'");
  console.log("Gemini related services will not be available.");
}

const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));

// Middleware to parse JSON bodies
app.use(express.json({ limit: '10mb' })); // Increased limit for base64 image data

// API v1 router (optional, but good for versioning)
const v1Router = express.Router();

// Firestore instance
const db = admin.firestore();
const crystalsCollectionRef = db.collection('crystals');

/**
 * @typedef {import('./models/unifiedData.js').UnifiedCrystalData} UnifiedCrystalData
 * @typedef {import('./models/unifiedData.js').CrystalCore} CrystalCore
 * @typedef {import('./models/unifiedData.js').VisualAnalysis} VisualAnalysis
 * @typedef {import('./models/unifiedData.js').Identification} Identification
 * @typedef {import('./models/unifiedData.js').EnergyMapping} EnergyMapping
 * @typedef {import('./models/unifiedData.js').AstrologicalData} AstrologicalData
 * @typedef {import('./models/unifiedData.js').NumerologyData} NumerologyData
 * @typedef {import('./models/unifiedData.js').UserIntegration} UserIntegration
 * @typedef {import('./models/unifiedData.js').AutomaticEnrichment} AutomaticEnrichment
 */

// Health check endpoint
v1Router.get('/health', (req, res) => {
  console.log("Received request for /health");
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    service: "CrystalGrimoire Node.js API"
  });
});

v1Router.post('/crystal/identify', async (req, res) => {
  console.log("Received request for /crystal/identify");
  const { image_data, user_context } = req.body;

  if (!image_data) {
    return res.status(400).json({ error: 'Missing image_data in request body' });
  }

  console.log(`Image data received (first 50 chars): ${typeof image_data === 'string' ? image_data.substring(0, 50) : 'Not a string'}`);
  console.log("User context received:", user_context || {});

  if (!geminiModel) {
    console.error("Gemini model not initialized due to missing API key or other issues.");
    return res.status(503).json({ error: 'Service temporarily unavailable. AI model not initialized.' });
  }

  const prompt = `
You are a Crystal Identification Expert and Metaphysical Guide.
Analyze the provided image of a crystal. Based on the image and any user context, provide a detailed identification and metaphysical profile.
Your response MUST be a single, minified, raw JSON object, without any markdown formatting (e.g., no \`\`\`json ... \`\`\`).
The JSON object should include these specific top-level keys: "identification_details", "visual_characteristics", "metaphysical_aspects", "numerology_insights", "enrichment_details".

Example of the required JSON structure (fill with actual analysis):
{
  "identification_details": {
    "stone_name": "Amethyst",
    "alternate_names": ["Purple Quartz"],
    "crystal_family": "Quartz",
    "variety_group": "Macrocrystalline Quartz",
    "stone_type_confidence": 0.95, // Confidence score (0.0 to 1.0)
    "description_accuracy_notes": "Image clarity is good, features align well with Amethyst."
  },
  "visual_characteristics": {
    "primary_color": "Purple",
    "secondary_colors": ["Lilac", "Deep Violet"],
    "luster": "Vitreous",
    "transparency_level": "Transparent to Translucent", // e.g., Opaque, Translucent, Transparent
    "crystal_system_formation": "Hexagonal (Trigonal)", // e.g., Trigonal, Monoclinic, Amorphous
    "common_habits_forms": ["Points", "Clusters", "Geodes"], // e.g., Points, Clusters, Geodes, Botryoidal
    "estimated_size_group": "Medium" // e.g., Small (thumbnail), Medium (palm-sized), Large (display) - if discernible
  },
  "metaphysical_aspects": {
    "primary_chakra_association": "Crown Chakra (Sahasrara)",
    "secondary_chakra_associations": ["Third Eye Chakra (Ajna)"],
    "elemental_correspondence": "Wind (Air)", // e.g., Earth, Water, Fire, Air/Wind, Spirit/Ether
    "planetary_rulership": ["Jupiter", "Neptune"],
    "zodiac_sign_affinity": ["Pisces", "Virgo", "Aquarius", "Capricorn"],
    "vibrational_frequency_level": "High" // e.g., Low, Medium, High, Very High
  },
  "numerology_insights": {
    "primary_number_vibration": 3, // Based on name or other calculation
    "associated_master_numbers": [], // e.g., 11, 22, 33 if applicable
    "color_numerology_link": 7, // Numerological value of its primary color
    "chakra_numerology_link": 7 // Numerological value of its primary chakra
  },
  "enrichment_details": {
    "common_healing_properties": ["Spiritual awareness", "Psychic abilities", "Inner peace and healing", "Meditation enhancement"],
    "affirmation_suggestion": "I am connected to my higher self and trust my intuition.",
    "suggested_uses_practices": ["Meditation", "Dream work", "Spiritual protection"],
    "placement_recommendations": ["Bedroom", "Meditation space"],
    "care_and_cleansing_tips": ["Cleanse with water (avoid prolonged soaking for some varieties)", "Recharge in moonlight"],
    "synergistic_crystals_pairing": ["Selenite", "Clear Quartz", "Lapis Lazuli"]
  }
}
User context (optional, use if provided): ${JSON.stringify(user_context)}
Ensure all string values are properly escaped within the JSON.
`;

  const imageParts = [
    {
      inlineData: {
        data: image_data.replace(/^data:image\/\w+;base64,/, ""), // Strip base64 prefix if present
        mimeType: image_data.startsWith('data:image/png') ? 'image/png' : 'image/jpeg', // Basic type detection
      },
    },
  ];

  const safetySettings = [
    { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
    { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
    { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
    { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
  ];

  try {
    const result = await geminiModel.generateContent([prompt, ...imageParts], { safetySettings });
    const aiJsonText = result.response.text();
    console.log("Raw AI JSON Text:", aiJsonText);

    let parsedAiJson;
    try {
      parsedAiJson = JSON.parse(aiJsonText);

      // Map the AI's response to the UnifiedCrystalData structure
      // The AI's direct output is now expected to be the main object, not nested under "identificationData"
      // based on the prompt asking for top-level keys like "identification_details", etc.
      const finalUnifiedData = mapAiResponseToUnifiedData(parsedAiJson);

      console.log("Mapped UnifiedCrystalData:", JSON.stringify(finalUnifiedData, null, 2));

      res.status(200).json(finalUnifiedData); // Send the mapped data

    } catch (parseError) {
      console.error("Error parsing AI response JSON or mapping data:", parseError);
      res.status(500).json({
        error: 'Failed to parse AI response. The AI did not return valid JSON.',
        ai_response_raw: aiJsonText // Send raw text for debugging on client if needed
      });
    }

  } catch (error) {
    console.error("Error in /crystal/identify with Gemini:", error);
    // Check if it's a specific Gemini error (e.g., safety block)
    if (error.response && error.response.promptFeedback) {
        console.error("Gemini Safety Feedback:", error.response.promptFeedback);
        return res.status(400).json({ error: 'Request blocked by AI safety filters.', details: error.response.promptFeedback });
    }
    res.status(500).json({ error: 'Failed to identify crystal due to an internal error with the AI service.' });
  }
});

// Create a new crystal
v1Router.post('/crystals', async (req, res) => {
  try {
    /** @type {import('./models/unifiedData.js').UnifiedCrystalData} */
    const crystalData = req.body;

    if (!crystalData || !crystalData.crystal_core || !crystalData.crystal_core.id) {
      return res.status(400).json({ error: 'Invalid request: crystal_core.id is required.' });
    }
    if (!crystalData.user_integration || !crystalData.user_integration.user_id || crystalData.user_integration.user_id.trim() === '') {
      return res.status(422).json({ error: 'Invalid request: user_integration.user_id is required to save to a collection.' });
    }

    const docId = crystalData.crystal_core.id;
    await crystalsCollectionRef.doc(docId).set(crystalData);
    console.log(`Crystal ${docId} created successfully.`);
    res.status(201).json(crystalData);
  } catch (error) {
    console.error("Error creating crystal:", error);
    res.status(500).json({ error: "Failed to create crystal." });
  }
});

// Get a specific crystal by ID
v1Router.get('/crystals/:crystalId', async (req, res) => {
  try {
    const crystalId = req.params.crystalId;
    if (!crystalId) {
      return res.status(400).json({ error: "Crystal ID is required." });
    }
    const doc = await crystalsCollectionRef.doc(crystalId).get();
    if (!doc.exists) {
      return res.status(404).json({ error: "Crystal not found." });
    }
    console.log(`Crystal ${crystalId} fetched successfully.`);
    res.status(200).json(doc.data());
  } catch (error) {
    console.error("Error getting crystal:", error);
    res.status(500).json({ error: "Failed to get crystal." });
  }
});

// List crystals (with optional user_id filter)
v1Router.get('/crystals', async (req, res) => {
  try {
    const userId = req.query.user_id;
    let query = crystalsCollectionRef;

    if (userId) {
      console.log(`Fetching crystals for user_id: ${userId}`);
      query = query.where('user_integration.user_id', '==', userId);
    } else {
      console.log('Fetching all crystals (default limit: 30)');
      query = query.limit(30); // Add a default limit for non-filtered queries
    }

    const snapshot = await query.get();
    if (snapshot.empty) {
      return res.status(200).json([]);
    }
    const crystals = snapshot.docs.map(doc => doc.data());
    res.status(200).json(crystals);
  } catch (error) {
    console.error("Error listing crystals:", error);
    // Check if error is due to missing index for user_id query
    if (error.message && error.message.includes('requires an index')) {
        return res.status(500).json({
            error: "Query failed. A Firestore index is likely required for filtering by user_id. Please create a composite index on the 'crystals' collection for the field 'user_integration.user_id'.",
            detail: error.message
        });
    }
    res.status(500).json({ error: "Failed to list crystals." });
  }
});

// Update a crystal
v1Router.put('/crystals/:crystalId', async (req, res) => {
  try {
    const crystalId = req.params.crystalId;
    /** @type {import('./models/unifiedData.js').UnifiedCrystalData} */
    const crystalData = req.body;

    if (!crystalData || !crystalData.crystal_core || !crystalData.crystal_core.id) {
      return res.status(400).json({ error: 'Invalid request: crystal_core.id is required in body.' });
    }
    if (crystalData.crystal_core.id !== crystalId) {
      return res.status(400).json({ error: 'Crystal ID in path does not match ID in body.' });
    }

    // Ensure user_id is present if it was part of the original logic for saving (consistency)
    if (!crystalData.user_integration || !crystalData.user_integration.user_id || crystalData.user_integration.user_id.trim() === '') {
      return res.status(422).json({ error: 'Invalid request: user_integration.user_id is required to update a collection crystal.' });
    }

    const docRef = crystalsCollectionRef.doc(crystalId);
    // Using set will create if not exists, or overwrite if exists.
    // This is fine for PUT, which implies full replacement of the resource state.
    await docRef.set(crystalData);
    console.log(`Crystal ${crystalId} updated successfully.`);
    res.status(200).json(crystalData);
  } catch (error) {
    console.error("Error updating crystal:", error);
    res.status(500).json({ error: "Failed to update crystal." });
  }
});

// Delete a crystal
v1Router.delete('/crystals/:crystalId', async (req, res) => {
  try {
    const crystalId = req.params.crystalId;

    const docRef = crystalsCollectionRef.doc(crystalId);
    const doc = await docRef.get();
    if (!doc.exists) {
      return res.status(404).json({ error: "Crystal not found for deletion." });
    }

    await docRef.delete();
    console.log(`Crystal ${crystalId} deleted successfully.`);
    res.status(200).json({ message: `Crystal ${crystalId} deleted successfully.` });
    // Or use res.status(204).send(); for No Content
  } catch (error) {
    console.error("Error deleting crystal:", error);
    res.status(500).json({ error: "Failed to delete crystal." });
  }
});


// Mount the v1 router under /api
// This means endpoints will be /api/crystal/identify, /api/crystals, /api/crystals/:crystalId etc.
app.use('/api', v1Router);

// Expose Express app as a single Firebase Function called 'api'
// This aligns with firebase.json hosting rewrite: {"source": "/api/**", "function": "api"}
exports.api = functions.https.onRequest(app);

// Optional: Keep other utility functions if needed, ensuring they don't conflict.
// For example, if functions from index_full.js (like trackCustomEvents) are still desired,
// they would be exported separately here or from their own files.
// exports.trackCustomEvents = functions.https.onCall(...)