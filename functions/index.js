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

// Mount the v1 router under /api
app.use('/api', v1Router); // This means endpoint will be /api/crystal/identify

// Expose Express app as a single Firebase Function called 'api'
// This aligns with firebase.json hosting rewrite: {"source": "/api/**", "function": "api"}
exports.api = functions.https.onRequest(app);

// Optional: Keep other utility functions if needed, ensuring they don't conflict.
// For example, if functions from index_full.js (like trackCustomEvents) are still desired,
// they would be exported separately here or from their own files.
// exports.trackCustomEvents = functions.https.onCall(...)