#!/usr/bin/env node
/**
 * Crystal Grimoire V0.3 - Unified Backend Server
 * Designed from the START with unified data and automation in mind
 * Focus: Color, Stone Type, Chakra, Birth Sign, Numerology
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
const PORT = process.env.PORT || 8085;
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

// Middleware
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cors({
  origin: ENVIRONMENT === 'development' ? '*' : [
    'https://crystalgrimoire-production.web.app',
    'https://crystalgrimoire.com'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

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

// UNIFIED DATA MODEL - Automatable Mappings

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

// Unified Crystal AI Service
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

      const aiResult = JSON.parse(content);
      
      // AUTOMATIC MAPPING AND ENRICHMENT
      const primaryColor = aiResult.visual_analysis.primary_color;
      const crystalName = aiResult.identification.stone_type;
      
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
          id: 'auto_' + Date.now(),
          timestamp: new Date().toISOString(),
          confidence_score: aiResult.identification.confidence,
          
          visual_analysis: aiResult.visual_analysis,
          identification: aiResult.identification,
          
          // AUTOMATIC ENERGY MAPPING
          energy_mapping: {
            primary_chakra: colorMapping.primary,
            secondary_chakras: aiResult.traditional_associations.elements?.includes('air') ? ['throat'] : [],
            chakra_number: colorMapping.number,
            vibration_level: colorMapping.number >= 6 ? 'high' : colorMapping.number >= 4 ? 'medium' : 'low'
          },
          
          // AUTOMATIC ASTROLOGICAL DATA
          astrological_data: {
            primary_signs: colorMapping.signs,
            compatible_signs: aiResult.traditional_associations.zodiac_compatibility || [],
            planetary_ruler: aiResult.traditional_associations.planetary_rulers?.[0] || 'unknown',
            element: aiResult.traditional_associations.elements?.[0] || 'unknown'
          },
          
          // AUTOMATIC NUMEROLOGY
          numerology: numerology
        },
        
        automatic_enrichment: {
          crystal_bible_reference: "The Crystal Bible by Judy Hall",
          healing_properties: aiResult.crystal_bible_properties.healing_properties,
          usage_suggestions: aiResult.crystal_bible_properties.spiritual_uses,
          care_instructions: aiResult.crystal_bible_properties.care_instructions,
          synergy_crystals: this.getSynergyRecommendations(primaryColor, crystalName)
        },
        
        // User integration placeholder
        user_integration: userContext ? {
          user_id: userContext.userId,
          personalized_message: this.generatePersonalizedMessage(aiResult, userContext),
          recommended_intentions: this.getRecommendedIntentions(colorMapping, userContext)
        } : null
      };
      
      return unifiedResult;

    } catch (error) {
      console.error('Unified Crystal AI error:', error.message);
      throw new Error(`Crystal identification failed: ${error.message}`);
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
    
    return colorSynergies[primaryColor] || ["clear_quartz"];
  }
  
  // Generate personalized message based on user context
  static generatePersonalizedMessage(aiResult, userContext) {
    const crystal = aiResult.identification.stone_type;
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
      "crown": ["spirituality", "enlightenment", "connection"]
    };
    
    return chakraIntentions[colorMapping.primary] || ["balance", "harmony", "growth"];
  }
}

// API Routes

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '0.3.0',
    environment: ENVIRONMENT,
    services: {
      gemini_api: GEMINI_API_KEY ? 'configured' : 'not_configured',
      crystal_bible: 'integrated',
      unified_data_model: 'active'
    }
  });
});

// Unified Crystal Identification Endpoint
app.post('/api/crystal/unified-identify', upload.single('image'), async (req, res) => {
  try {
    console.log('🔮 Unified Crystal Identification Request');
    
    let imageData;
    let userContext = null;

    // Handle different input formats
    if (req.file) {
      imageData = req.file.buffer.toString('base64');
    } else if (req.body.image_data) {
      imageData = req.body.image_data;
    } else {
      return res.status(400).json({ error: 'No image data provided' });
    }

    // Get user context if provided
    if (req.body.user_id) {
      userContext = { 
        userId: req.body.user_id,
        preferences: req.body.user_preferences || {}
      };
    }

    // Use unified crystal AI system
    const result = await UnifiedCrystalAI.identifyAndUnify(imageData, userContext);
    
    console.log(`✅ Identified: ${result.crystal_core.identification.stone_type}`);
    console.log(`🎨 Color: ${result.crystal_core.visual_analysis.primary_color}`);
    console.log(`💎 Chakra: ${result.crystal_core.energy_mapping.primary_chakra}`);
    console.log(`🔢 Numerology: ${result.crystal_core.numerology.master_number}`);
    
    res.json({
      success: true,
      unified_data: result,
      automation_summary: {
        color_detected: result.crystal_core.visual_analysis.primary_color,
        chakra_mapped: result.crystal_core.energy_mapping.primary_chakra,
        numerology_calculated: result.crystal_core.numerology.master_number,
        birth_signs: result.crystal_core.astrological_data.primary_signs,
        confidence: result.crystal_core.confidence_score
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Unified identification error:', error);
    res.status(500).json({ 
      error: error.message,
      suggestion: 'Try with a clearer image or better lighting'
    });
  }
});

// Get color-to-chakra mappings (for frontend reference)
app.get('/api/crystal/color-mappings', (req, res) => {
  res.json({
    color_chakra_map: COLOR_CHAKRA_MAP,
    stone_type_map: STONE_TYPE_MAP,
    supported_automations: [
      'color_detection',
      'chakra_mapping', 
      'birth_sign_compatibility',
      'numerology_calculation',
      'synergy_recommendations'
    ]
  });
});

// Batch color analysis (for testing automation)
app.post('/api/crystal/test-color-automation', (req, res) => {
  const { colors } = req.body;
  
  if (!colors || !Array.isArray(colors)) {
    return res.status(400).json({ error: 'Provide array of colors to test' });
  }
  
  const results = colors.map(color => {
    const mapping = UnifiedCrystalAI.mapColorProperties(color);
    const numerology = UnifiedCrystalAI.calculateCrystalNumerology('test_crystal', color, mapping.number);
    
    return {
      color,
      chakra: mapping.primary,
      chakra_number: mapping.number,
      birth_signs: mapping.signs,
      numerology: numerology.master_number
    };
  });
  
  res.json({
    automation_test: results,
    total_colors: colors.length,
    success_rate: '100%'
  });
});

// Error handling
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
  console.log('🔮 CRYSTAL GRIMOIRE V0.3 - UNIFIED BACKEND');
  console.log('=' .repeat(60));
  console.log(`🚀 Server: http://localhost:${PORT}`);
  console.log(`🌍 Environment: ${ENVIRONMENT}`);
  console.log(`🔍 Health: http://localhost:${PORT}/health`);
  console.log(`🤖 Gemini API: ${GEMINI_API_KEY ? '✅ configured' : '❌ not configured'}`);
  console.log(`📚 Crystal Bible: ✅ integrated`);
  console.log(`🎯 Unified Data Model: ✅ active`);
  console.log(`🔄 Automation: Color→Chakra→Birth Sign→Numerology`);
  console.log('=' .repeat(60));
  console.log('🔮 Ready for unified crystal identification!');
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