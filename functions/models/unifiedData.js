// functions/models/unifiedData.js

/**
 * @typedef {Object} VisualAnalysis
 * @property {string} primary_color
 * @property {string[]} secondary_colors
 * @property {string} transparency
 * @property {string} formation
 * @property {string|null} [size_estimate]
 */

/**
 * @typedef {Object} Identification
 * @property {string} stone_type
 * @property {string} crystal_family
 * @property {string|null} [variety]
 * @property {number} confidence
 */

/**
 * @typedef {Object} EnergyMapping
 * @property {string} primary_chakra
 * @property {string[]} secondary_chakras
 * @property {number} chakra_number
 * @property {string|null} [vibration_level]
 */

/**
 * @typedef {Object} AstrologicalData
 * @property {string[]} primary_signs
 * @property {string[]} compatible_signs
 * @property {string|null} [planetary_ruler]
 * @property {string|null} [element]
 */

/**
 * @typedef {Object} NumerologyData
 * @property {number} crystal_number
 * @property {number} color_vibration
 * @property {number} chakra_number
 * @property {number} master_number
 */

/**
 * @typedef {Object} CrystalCore
 * @property {string} id - auto_generated_uuid
 * @property {string} timestamp - iso_string
 * @property {number} confidence_score
 * @property {VisualAnalysis} visual_analysis
 * @property {Identification} identification
 * @property {EnergyMapping} energy_mapping
 * @property {AstrologicalData} astrological_data
 * @property {NumerologyData} numerology
 */

/**
 * @typedef {Object} UserIntegration
 * @property {string|null} [user_id]
 * @property {string|null} [added_to_collection] - timestamp
 * @property {number|null} [personal_rating] - 1-10
 * @property {string|null} [usage_frequency] - daily|weekly|monthly|occasional
 * @property {string[]} user_experiences
 * @property {string[]} intention_settings
 */

/**
 * @typedef {Object} AutomaticEnrichment
 * @property {string|null} [crystal_bible_reference]
 * @property {string[]} healing_properties
 * @property {string[]} usage_suggestions
 * @property {string[]} care_instructions
 * @property {string[]} synergy_crystals
 * @property {string|null} [mineral_class]
 */

/**
 * @typedef {Object} UnifiedCrystalData
 * @property {CrystalCore} crystal_core
 * @property {UserIntegration|null} [user_integration]
 * @property {AutomaticEnrichment|null} [automatic_enrichment]
 */

// Factory functions could be added here if needed for creation with defaults,
// but JSDoc type definitions are the primary goal for structure definition.

// To make these types usable for documentation or potentially runtime checks (with libraries),
// you can export them (though JSDoc types are not directly exportable as runtime constructs).
// For now, defining them with JSDoc is sufficient for code clarity and future development.

module.exports = {
  // Typically you might export factory functions or classes here.
  // For JSDoc types, direct export isn't standard.
  // This file serves as a structural definition.
};
