// functions/logic/dataMapper.js
const { v4: uuidv4 } = require('uuid'); // For generating UUIDs

/**
 * @typedef {import('../models/unifiedData.js').UnifiedCrystalData} UnifiedCrystalData
 * @typedef {import('../models/unifiedData.js').CrystalCore} CrystalCore
 * @typedef {import('../models/unifiedData.js').VisualAnalysis} VisualAnalysis
 * @typedef {import('../models/unifiedData.js').Identification} Identification
 * @typedef {import('../models/unifiedData.js').EnergyMapping} EnergyMapping
 * @typedef {import('../models/unifiedData.js').AstrologicalData} AstrologicalData
 * @typedef {import('../models/unifiedData.js').NumerologyData} NumerologyData
 * @typedef {import('../models/unifiedData.js').UserIntegration} UserIntegration
 * @typedef {import('../models/unifiedData.js').AutomaticEnrichment} AutomaticEnrichment
 */

// Numerology constants and calculation (ported from Python backend_server.py)
const NUMEROLOGY_LETTER_VALUES = {
    'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 6, 'g': 7, 'h': 8, 'i': 9,
    'j': 1, 'k': 2, 'l': 3, 'm': 4, 'n': 5, 'o': 6, 'p': 7, 'q': 8, 'r': 9,
    's': 1, 't': 2, 'u': 3, 'v': 4, 'w': 5, 'x': 6, 'y': 7, 'z': 8
};

function calculateNameNumerologyNumber(name) {
    if (!name || typeof name !== 'string') {
        return 0;
    }
    const nameLower = name.toLowerCase();
    let total = 0;
    for (const char of nameLower) {
        total += NUMEROLOGY_LETTER_VALUES[char] || 0;
    }
    while (total > 9) {
        let s = String(total);
        total = s.split('').reduce((sum, digit) => sum + parseInt(digit, 10), 0);
        if (total <= 9) break;
    }
    return total === 0 && name.length > 0 ? 0 : total; // Avoid returning 0 for valid names unless sum is 0
}

const COLOR_CHAKRA_SIGN_MAP = {
    "red": { primary_chakra: "root", number: 1, signs: ["aries", "scorpio"] },
    "orange": { primary_chakra: "sacral", number: 2, signs: ["leo", "sagittarius"] },
    "yellow": { primary_chakra: "solar_plexus", number: 3, signs: ["gemini", "virgo"] },
    "green": { primary_chakra: "heart", number: 4, signs: ["taurus", "libra"] },
    "pink": { primary_chakra: "heart", number: 4, signs: ["taurus", "libra"] },
    "blue": { primary_chakra: "throat", number: 5, signs: ["aquarius", "gemini"] },
    "purple": { primary_chakra: "third_eye", number: 6, signs: ["pisces", "sagittarius"] },
    "violet": { primary_chakra: "crown", number: 7, signs: ["pisces", "aquarius"] },
    "white": { primary_chakra: "crown", number: 7, signs: ["cancer", "pisces"] },
    "clear": { primary_chakra: "all_chakras", number: 0, signs: ["all"] },
    "black": { primary_chakra: "root", number: 1, signs: ["capricorn", "scorpio"] },
    "brown": { primary_chakra: "root", number: 1, signs: ["capricorn", "virgo"] }
};

const CRYSTAL_FAMILY_TO_MINERAL_CLASS = {
    "quartz": "Silicate", "feldspar": "Silicate", "beryl": "Silicate",
    "tourmaline": "Silicate", "garnet": "Silicate", "mica": "Silicate",
    "pyroxene": "Silicate", "amphibole": "Silicate", "zeolite": "Silicate",
    "corundum": "Oxide", "hematite": "Oxide", "magnetite": "Oxide", "spinel": "Oxide",
    "calcite": "Carbonate", "aragonite": "Carbonate", "malachite": "Carbonate",
    "azurite": "Carbonate", "siderite": "Carbonate", "dolomite": "Carbonate",
    "gypsum": "Sulfate", "barite": "Sulfate", "celestite": "Sulfate",
    "apatite": "Phosphate", "turquoise": "Phosphate",
    "pyrite": "Sulfide", "galena": "Sulfide", "sphalerite": "Sulfide",
    "halite": "Halide", "fluorite": "Halide",
};


/**
 * Maps the raw JSON object from AI to the UnifiedCrystalData structure.
 * @param {Object} aiJsonResponse - The parsed JSON object from the AI.
 * @returns {UnifiedCrystalData}
 */
function mapAiResponseToUnifiedData(aiJsonResponse) {
    const idDetails = aiJsonResponse.identification_details || {};
    const visualChars = aiJsonResponse.visual_characteristics || {};
    // const physicalPropsSummary = aiJsonResponse.physical_properties_summary || {}; // Not directly used in core model but could be in enrichment
    const metaAspects = aiJsonResponse.metaphysical_aspects || {};
    const numInsights = aiJsonResponse.numerology_insights || {};
    const enrichDetails = aiJsonResponse.enrichment_details || {};

    /** @type {VisualAnalysis} */
    const visual_analysis = {
        primary_color: visualChars.primary_color || "Unknown",
        secondary_colors: visualChars.secondary_colors || [],
        transparency: visualChars.transparency_level || visualChars.transparency || "Unknown", // Added fallback for transparency_level
        formation: visualChars.crystal_system_formation || visualChars.formation || "Unknown", // Added fallback for crystal_system_formation
        size_estimate: visualChars.estimated_size_group || visualChars.size_estimate || null // Added fallback for estimated_size_group
    };

    /** @type {Identification} */
    const identification = {
        stone_type: idDetails.stone_name || idDetails.name || "Unknown",
        crystal_family: idDetails.crystal_family || "Unknown",
        variety: idDetails.variety_group || idDetails.variety || null, // Added fallback for variety_group
        confidence: typeof idDetails.stone_type_confidence === 'number' ? idDetails.stone_type_confidence : (typeof idDetails.identification_confidence === 'number' ? idDetails.identification_confidence : 0.0) // Added fallback for stone_type_confidence
    };

    let finalPrimaryChakra = metaAspects.primary_chakra_association || metaAspects.primary_chakra || "Unknown"; // Fallback for primary_chakra_association
    let aiMetaChakraNumber = metaAspects.chakra_number || 0;
    let aiNumChakraNumber = numInsights.chakra_numerology_link || numInsights.chakra_number_for_numerology || 0; // Fallback for chakra_numerology_link
    let finalChakraNumber = aiMetaChakraNumber || aiNumChakraNumber;
    let finalSecondaryChakras = metaAspects.secondary_chakra_associations || metaAspects.secondary_chakras || []; // Fallback for secondary_chakra_associations
    let finalPrimarySigns = metaAspects.zodiac_sign_affinity || metaAspects.primary_zodiac_signs || []; // Fallback for zodiac_sign_affinity

    const mappedChakraInfo = COLOR_CHAKRA_SIGN_MAP[visual_analysis.primary_color.toLowerCase()];
    if (mappedChakraInfo) {
        if (finalPrimaryChakra === "Unknown" || !finalPrimaryChakra) {
            finalPrimaryChakra = mappedChakraInfo.primary_chakra;
        }
        if (finalChakraNumber === 0 && mappedChakraInfo.number !== 0) {
            finalChakraNumber = mappedChakraInfo.number;
        }
        if (finalPrimarySigns.length === 0 && mappedChakraInfo.signs[0] !== "all") {
            finalPrimarySigns = [...new Set([...finalPrimarySigns, ...mappedChakraInfo.signs])];
        }
    }

    /** @type {EnergyMapping} */
    const energy_mapping = {
        primary_chakra: finalPrimaryChakra,
        secondary_chakras: finalSecondaryChakras,
        chakra_number: finalChakraNumber,
        vibration_level: metaAspects.vibrational_frequency_level || metaAspects.vibration_level || null // Fallback for vibrational_frequency_level
    };

    /** @type {AstrologicalData} */
    const astrological_data = {
        primary_signs: finalPrimarySigns,
        compatible_signs: metaAspects.compatible_signs || [], // No direct fallback in example, keep as is
        planetary_ruler: (metaAspects.planetary_rulership && metaAspects.planetary_rulership[0]) || (metaAspects.planetary_rulers && metaAspects.planetary_rulers[0]) || null, // Fallback for planetary_rulership
        element: metaAspects.elemental_correspondence || (metaAspects.elements && metaAspects.elements[0]) || null // Fallback for elemental_correspondence
    };

    const aiCrystalNumber = numInsights.primary_number_vibration || numInsights.crystal_number_association || 0; // Fallback for primary_number_vibration
    const aiColorVibration = numInsights.color_numerology_link || numInsights.color_vibration_number || 0; // Fallback for color_numerology_link
    const aiMasterNumber = numInsights.associated_master_numbers && numInsights.associated_master_numbers.length > 0 ? numInsights.associated_master_numbers[0] : (numInsights.master_numerology_number_suggestion || 0); // Fallback for associated_master_numbers

    let finalNumerologyChakraNumber = aiNumChakraNumber || finalChakraNumber;

    const calculatedCrystalNumber = calculateNameNumerologyNumber(identification.stone_type);
    const finalCrystalNumber = aiCrystalNumber || calculatedCrystalNumber;

    let calculatedMasterNumber = 0;
    if (finalCrystalNumber !== 0 && (aiColorVibration !== 0 || finalNumerologyChakraNumber !== 0) ) { // Ensure not all are zero
        let currentSum = finalCrystalNumber + (aiColorVibration || 0) + (finalNumerologyChakraNumber || 0) ;
        while (currentSum > 9) {
            if (currentSum === 11 || currentSum === 22 || currentSum === 33) { // Check for master numbers
                break;
            }
            let s = String(currentSum);
            currentSum = s.split('').reduce((sum, digit) => sum + parseInt(digit, 10), 0);
        }
        calculatedMasterNumber = currentSum;
    }

    const finalMasterNumber = aiMasterNumber || calculatedMasterNumber;

    if (finalNumerologyChakraNumber === 0 && energy_mapping.chakra_number !== 0) {
        finalNumerologyChakraNumber = energy_mapping.chakra_number;
    }


    /** @type {NumerologyData} */
    const numerology = {
        crystal_number: finalCrystalNumber,
        color_vibration: aiColorVibration || 0,
        chakra_number: finalNumerologyChakraNumber,
        master_number: finalMasterNumber
    };

    /** @type {CrystalCore} */
    const crystal_core = {
        id: uuidv4(),
        timestamp: new Date().toISOString(),
        confidence_score: typeof idDetails.stone_type_confidence === 'number' ? idDetails.stone_type_confidence : (typeof aiJsonResponse.overall_confidence_score === 'number' ? aiJsonResponse.overall_confidence_score : 0.0),
        visual_analysis,
        identification,
        energy_mapping,
        astrological_data,
        numerology
    };

    let derivedMineralClass = null;
    const aiMineralClass = enrichDetails.mineral_class; // AI might provide this directly
    if (!aiMineralClass && identification.crystal_family && identification.crystal_family !== "Unknown") {
        // Attempt to derive from crystal_family if AI doesn't provide it
        derivedMineralClass = CRYSTAL_FAMILY_TO_MINERAL_CLASS[identification.crystal_family.toLowerCase()] || null;
    }

    /** @type {AutomaticEnrichment} */
    const automatic_enrichment = {
        crystal_bible_reference: enrichDetails.crystal_bible_reference || null,
        healing_properties: enrichDetails.common_healing_properties || enrichDetails.healing_properties || [], // Fallback for common_healing_properties
        usage_suggestions: enrichDetails.suggested_uses_practices || enrichDetails.usage_suggestions || [], // Fallback for suggested_uses_practices
        care_instructions: enrichDetails.care_and_cleansing_tips || enrichDetails.care_instructions || [], // Fallback for care_and_cleansing_tips
        synergy_crystals: enrichDetails.synergistic_crystals_pairing || enrichDetails.synergy_crystals || [], // Fallback for synergistic_crystals_pairing
        mineral_class: aiMineralClass || derivedMineralClass // Prioritize AI, then derived
    };

    /** @type {UserIntegration} */
    const user_integration = { // Default empty user integration
        user_id: null, // This would be populated later if a user saves this crystal
        added_to_collection: null,
        personal_rating: null,
        usage_frequency: null,
        user_experiences: [],
        intention_settings: []
    };

    /** @type {UnifiedCrystalData} */
    const unifiedData = {
        crystal_core,
        automatic_enrichment,
        user_integration
    };

    return unifiedData;
}

module.exports = {
    mapAiResponseToUnifiedData,
    calculateNameNumerologyNumber // Exporting for potential direct use or testing
};
