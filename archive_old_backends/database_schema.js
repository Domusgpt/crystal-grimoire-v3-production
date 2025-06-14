#!/usr/bin/env node
/**
 * Crystal Grimoire Database Schema and Initialization
 * Creates comprehensive Firestore collections with sample data
 */

const admin = require('firebase-admin');

// Database Schema Documentation
const DATABASE_SCHEMA = {
  "/crystal_database": {
    description: "Master crystal reference database",
    structure: {
      "crystal_id": {
        name: "string",
        scientific_name: "string", 
        crystal_system: "string",
        hardness: "string",
        color_variations: "array",
        formation_type: "string",
        chemical_formula: "string",
        metaphysical_properties: {
          primary_chakras: "array",
          secondary_chakras: "array", 
          zodiac_signs: "array",
          planetary_rulers: "array",
          elements: "array",
          healing_properties: "array",
          emotional_benefits: "array",
          spiritual_benefits: "array",
          mental_benefits: "array",
          physical_benefits: "array",
          intentions: "array",
          energy_type: "string",
          vibration_level: "string"
        },
        physical_properties: {
          luster: "string",
          transparency: "string",
          density: "string",
          refractive_index: "string",
          cleavage: "string",
          fracture: "string",
          streak: "string",
          fluorescence: "string"
        },
        care_instructions: {
          cleansing_methods: "array",
          charging_methods: "array",
          methods_to_avoid: "array",
          storage_recommendations: "string",
          handling_notes: "string",
          maintenance_frequency: "string"
        },
        cultural_info: {
          ancient_uses: "array",
          folklore: "array",
          cultural_significance: "array",
          modern_applications: "array",
          major_deposits: "array",
          rarity: "string",
          price_range: "string"
        },
        pairing_suggestions: "array",
        created_at: "timestamp",
        updated_at: "timestamp"
      }
    }
  },

  "/users/{user_id}": {
    description: "User profiles and data",
    structure: {
      profile: {
        name: "string",
        email: "string",
        birth_date: "timestamp",
        birth_time: "string",
        birth_location: "string",
        latitude: "number",
        longitude: "number",
        subscription_tier: "string", // free, premium, pro, founders
        experience_level: "string",  // beginner, intermediate, advanced
        spiritual_goals: "array",
        created_at: "timestamp",
        last_login: "timestamp"
      },
      birth_chart: {
        sun_sign: "string",
        moon_sign: "string",
        rising_sign: "string",
        mercury_sign: "string",
        venus_sign: "string",
        mars_sign: "string",
        jupiter_sign: "string",
        saturn_sign: "string",
        uranus_sign: "string",
        neptune_sign: "string",
        pluto_sign: "string",
        element_dominance: "array",
        modality_dominance: "array",
        house_placements: "object",
        aspects: "array",
        calculated_at: "timestamp"
      }
    }
  },

  "/users/{user_id}/crystals": {
    description: "User's personal crystal collection",
    structure: {
      "crystal_collection_id": {
        crystal_id: "string", // References /crystal_database
        crystal_name: "string",
        crystal_type: "string",
        acquisition_date: "timestamp",
        acquisition_method: "string", // purchased, gifted, found
        personal_notes: "string",
        usage_count: "number",
        favorite: "boolean",
        location_stored: "string",
        intentions_set: "array",
        personal_experiences: "array",
        energy_rating: "number", // 1-10 user rating
        synergy_notes: "string",
        last_used: "timestamp",
        created_at: "timestamp"
      }
    }
  },

  "/users/{user_id}/sessions": {
    description: "User sessions and activities",
    structure: {
      "session_id": {
        session_type: "string", // healing, meditation, ritual, guidance
        crystals_used: "array", // crystal IDs from user collection
        duration_minutes: "number",
        mood_before: "string",
        mood_after: "string",
        moon_phase: "string",
        astrological_weather: "object",
        notes: "string",
        effectiveness_rating: "number", // 1-10
        intentions: "array",
        outcomes: "array",
        created_at: "timestamp"
      }
    }
  },

  "/users/{user_id}/journal_entries": {
    description: "Dream journal and spiritual insights",
    structure: {
      "entry_id": {
        entry_type: "string", // dream, insight, experience, ritual
        title: "string",
        content: "string",
        crystals_mentioned: "array",
        crystals_used: "array",
        moon_phase: "string",
        astrological_context: "object",
        mood: "string",
        energy_level: "number",
        insights: "array",
        symbols: "array",
        emotions: "array",
        created_at: "timestamp",
        updated_at: "timestamp"
      }
    }
  },

  "/identifications": {
    description: "AI crystal identification history",
    structure: {
      "identification_id": {
        user_id: "string",
        image_url: "string",
        result: "object", // Complete identification JSON
        confidence: "number",
        crystal_name: "string",
        processing_time_ms: "number",
        ai_model_used: "string",
        user_feedback: "object",
        added_to_collection: "boolean",
        created_at: "timestamp"
      }
    }
  },

  "/guidance_sessions": {
    description: "Personalized spiritual guidance history",
    structure: {
      "session_id": {
        user_id: "string",
        query: "string",
        context_type: "string", // crystal_selection, healing, ritual, general
        user_context: "object", // Birth chart, collection, etc.
        ai_response: "string",
        crystals_recommended: "array",
        actions_suggested: "array",
        user_rating: "number",
        follow_up_queries: "array",
        created_at: "timestamp"
      }
    }
  },

  "/moon_calendar": {
    description: "Lunar calendar and ritual suggestions",
    structure: {
      "date": { // YYYY-MM-DD format
        moon_phase: "string",
        phase_percentage: "number",
        zodiac_sign: "string",
        void_of_course: "boolean",
        eclipses: "object",
        recommended_crystals: "array",
        ritual_suggestions: "array",
        energy_themes: "array",
        best_activities: "array",
        avoid_activities: "array"
      }
    }
  },

  "/crystal_synergies": {
    description: "Crystal pairing and combination data",
    structure: {
      "combination_id": {
        primary_crystal: "string",
        secondary_crystals: "array",
        synergy_type: "string", // amplifying, balancing, protective, manifesting
        combined_properties: "array",
        recommended_uses: "array",
        placement_suggestions: "object",
        chakra_alignments: "array",
        astrological_timing: "object",
        user_experiences: "array",
        effectiveness_rating: "number"
      }
    }
  }
};

// Sample data for crystal database
const SAMPLE_CRYSTALS = [
  {
    id: "amethyst_001",
    name: "Amethyst",
    scientific_name: "Silicon Dioxide (SiO2)",
    crystal_system: "Hexagonal",
    hardness: "7",
    color_variations: ["Purple", "Violet", "Lavender", "Deep Purple"],
    formation_type: "Igneous",
    chemical_formula: "SiO2",
    metaphysical_properties: {
      primary_chakras: ["Third Eye", "Crown"],
      secondary_chakras: ["Heart"],
      zodiac_signs: ["Pisces", "Aquarius", "Capricorn", "Virgo"],
      planetary_rulers: ["Jupiter", "Neptune"],
      elements: ["Water", "Air"],
      healing_properties: [
        "Enhances intuition and psychic abilities",
        "Promotes emotional balance and inner peace",
        "Aids in meditation and spiritual growth",
        "Protects against negative energy and psychic attack",
        "Supports addiction recovery and breaking harmful patterns",
        "Calms anxiety and stress",
        "Improves sleep quality and dream recall"
      ],
      emotional_benefits: ["Peace", "Clarity", "Emotional balance", "Stress relief"],
      spiritual_benefits: ["Enhanced intuition", "Spiritual protection", "Higher consciousness"],
      mental_benefits: ["Clear thinking", "Decision making", "Focus during meditation"],
      physical_benefits: ["Better sleep", "Headache relief", "Nervous system support"],
      intentions: ["Protection", "Intuition", "Peace", "Spiritual Growth", "Clarity"],
      energy_type: "Transmuting",
      vibration_level: "High"
    },
    physical_properties: {
      luster: "Vitreous",
      transparency: "Transparent to translucent",
      density: "2.65 g/cm³",
      refractive_index: "1.544-1.553",
      cleavage: "None",
      fracture: "Conchoidal",
      streak: "White",
      fluorescence: "None"
    },
    care_instructions: {
      cleansing_methods: ["Running water", "Moonlight", "Sage smoke", "Sound healing"],
      charging_methods: ["Moonlight", "Crystal cluster", "Earth burial"],
      methods_to_avoid: ["Extended sunlight (may fade)"],
      storage_recommendations: "Keep away from direct sunlight to prevent color fading",
      handling_notes: "Durable stone, safe for regular handling and water exposure",
      maintenance_frequency: "Cleanse weekly, charge monthly"
    },
    cultural_info: {
      ancient_uses: ["Ancient Greeks carved drinking vessels", "Medieval European bishops' rings"],
      folklore: ["Prevents intoxication", "Promotes sobriety and clear thinking"],
      cultural_significance: ["Symbol of royalty", "Stone of bishops", "February birthstone"],
      modern_applications: ["Meditation", "Jewelry", "Home decoration", "Crystal healing"],
      major_deposits: ["Brazil", "Uruguay", "Russia", "South Korea", "United States"],
      rarity: "Common",
      price_range: "Budget to Premium"
    },
    pairing_suggestions: ["Clear Quartz", "Rose Quartz", "Citrine", "Selenite", "Fluorite"]
  },
  
  {
    id: "rose_quartz_001", 
    name: "Rose Quartz",
    scientific_name: "Silicon Dioxide (SiO2)",
    crystal_system: "Hexagonal",
    hardness: "7",
    color_variations: ["Pale Pink", "Deep Rose", "Peachy Pink"],
    formation_type: "Igneous",
    chemical_formula: "SiO2",
    metaphysical_properties: {
      primary_chakras: ["Heart"],
      secondary_chakras: ["Higher Heart"],
      zodiac_signs: ["Taurus", "Libra"],
      planetary_rulers: ["Venus"],
      elements: ["Water", "Earth"],
      healing_properties: [
        "Opens and heals the heart chakra",
        "Promotes unconditional love and self-love",
        "Helps heal emotional wounds and trauma",
        "Attracts love and romantic relationships",
        "Encourages compassion and forgiveness",
        "Supports emotional healing after loss",
        "Enhances feminine energy and nurturing"
      ],
      emotional_benefits: ["Self-love", "Compassion", "Emotional healing", "Heart opening"],
      spiritual_benefits: ["Unconditional love", "Divine feminine connection", "Heart chakra activation"],
      mental_benefits: ["Self-acceptance", "Positive self-talk", "Emotional intelligence"],
      physical_benefits: ["Heart health", "Circulation", "Skin healing", "Reproductive health"],
      intentions: ["Love", "Healing", "Self-Care", "Compassion", "Relationships"],
      energy_type: "Nurturing",
      vibration_level: "Medium"
    },
    physical_properties: {
      luster: "Vitreous",
      transparency: "Translucent",
      density: "2.65 g/cm³", 
      refractive_index: "1.544-1.553",
      cleavage: "None",
      fracture: "Conchoidal",
      streak: "White",
      fluorescence: "None"
    },
    care_instructions: {
      cleansing_methods: ["Moonlight", "Running water", "Rose petals", "Sound healing"],
      charging_methods: ["Moonlight", "Rose ceremony", "Heart-centered meditation"],
      methods_to_avoid: ["Extended sunlight (may fade)", "Salt water"],
      storage_recommendations: "Keep near the bed or heart space for maximum benefit",
      handling_notes: "Very gentle energy, safe for all users including children",
      maintenance_frequency: "Cleanse gently weekly, charge with loving intention"
    },
    cultural_info: {
      ancient_uses: ["Egyptian beauty masks", "Roman love tokens"],
      folklore: ["Gift from Cupid", "Heals broken hearts"],
      cultural_significance: ["Universal symbol of love", "Mother's stone"],
      modern_applications: ["Self-care rituals", "Relationship healing", "Meditation"],
      major_deposits: ["Brazil", "Madagascar", "South Africa", "India"],
      rarity: "Common",
      price_range: "Budget"
    },
    pairing_suggestions: ["Green Aventurine", "Morganite", "Rhodonite", "Prehnite", "Amazonite"]
  }
];

// Function to initialize the database
async function initializeDatabase() {
  console.log('🔮 Initializing Crystal Grimoire Database...');
  console.log('📋 Database Schema:');
  
  Object.keys(DATABASE_SCHEMA).forEach(collection => {
    console.log(`  📁 ${collection}`);
    console.log(`     ${DATABASE_SCHEMA[collection].description}`);
  });
  
  console.log('\n💎 Sample Crystal Data:');
  SAMPLE_CRYSTALS.forEach(crystal => {
    console.log(`  🔸 ${crystal.name} (${crystal.id})`);
    console.log(`     Chakras: ${crystal.metaphysical_properties.primary_chakras.join(', ')}`);
    console.log(`     Intentions: ${crystal.metaphysical_properties.intentions.join(', ')}`);
  });
  
  return {
    schema: DATABASE_SCHEMA,
    sampleData: SAMPLE_CRYSTALS
  };
}

// Export for use in other modules
module.exports = {
  DATABASE_SCHEMA,
  SAMPLE_CRYSTALS,
  initializeDatabase
};

// Run if called directly
if (require.main === module) {
  initializeDatabase()
    .then(() => console.log('\n✅ Database schema ready for implementation'))
    .catch(console.error);
}