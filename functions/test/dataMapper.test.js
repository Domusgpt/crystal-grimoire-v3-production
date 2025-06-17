// functions/test/dataMapper.test.js

const { mapAiResponseToUnifiedData } = require('../logic/dataMapper'); // Adjust path if needed
const assert = require('assert'); // Using Node.js built-in assert

// --- Helper for deep equality check (basic version) ---
function deepEqual(obj1, obj2) {
  // For this test, we'll rely on JSON stringify for a basic check,
  // as a full deep equal is complex. Node's assert.deepStrictEqual is better if available.
  // However, assert.deepStrictEqual might not work well with UUIDs and timestamps if not handled.
  // For simplicity here, we'll compare key parts or use JSON.stringify if objects are simple.
  try {
    assert.deepStrictEqual(obj1, obj2);
    return true;
  } catch (e) {
    console.error("Deep comparison failed:", e.message);
    console.error("Expected:", JSON.stringify(obj1, null, 2));
    console.error("Actual:", JSON.stringify(obj2, null, 2));
    return false;
  }
}

// --- Test Suite ---
const tests = {
  test_basic_mapping: () => {
    const aiResponse = {
      overall_confidence_score: 0.85,
      identification_details: {
        stone_name: "Amethyst",
        crystal_family: "Quartz",
        variety: "Chevron Amethyst",
        identification_confidence: 0.9
      },
      visual_characteristics: {
        primary_color: "Purple",
        secondary_colors: ["White", "Violet"],
        transparency: "Translucent", // This should map to transparency_level in the mapper
        formation: "Cluster"    // This should map to crystal_system_formation in the mapper
      },
      metaphysical_aspects: {
        primary_chakra: "Third Eye", // This should map to primary_chakra_association
        secondary_chakras: ["Crown"], // This should map to secondary_chakra_associations
        vibration_level: "High",      // This should map to vibrational_frequency_level
        primary_zodiac_signs: ["Pisces", "Aquarius"] // This should map to zodiac_sign_affinity
        // chakra_number provided by color map if not here
      },
      numerology_insights: {
        // AI might not provide all, relying on calculation
        // crystal_number_association: 3,
        // color_vibration_number: 6,
        // master_numerology_number_suggestion: 5
      },
      enrichment_details: {
        healing_properties: ["Calming", "Intuition"], // This should map to common_healing_properties
        usage_suggestions: ["Meditation", "Sleep aid"], // This should map to suggested_uses_practices
        care_instructions: ["Cleanse with water", "Recharge under moonlight"], // This should map to care_and_cleansing_tips
        synergy_crystals: ["Clear Quartz"], // This should map to synergistic_crystals_pairing
        mineral_class: "Silicate" // AI provides it
      }
    };

    const result = mapAiResponseToUnifiedData(aiResponse);

    assert.ok(result.crystal_core.id, "Should generate an ID");
    assert.ok(result.crystal_core.timestamp, "Should generate a timestamp");
    assert.strictEqual(result.crystal_core.confidence_score, 0.85);

    // Identification
    assert.strictEqual(result.crystal_core.identification.stone_type, "Amethyst");
    assert.strictEqual(result.crystal_core.identification.crystal_family, "Quartz");
    assert.strictEqual(result.crystal_core.identification.variety, "Chevron Amethyst");
    assert.strictEqual(result.crystal_core.identification.confidence, 0.9);

    // Visual - check against the fallback keys used in the mapper
    assert.strictEqual(result.crystal_core.visual_analysis.primary_color, "Purple");
    assert.deepStrictEqual(result.crystal_core.visual_analysis.secondary_colors, ["White", "Violet"]);
    assert.strictEqual(result.crystal_core.visual_analysis.transparency, "Translucent");
    assert.strictEqual(result.crystal_core.visual_analysis.formation, "Cluster");


    // Energy Mapping (Purple -> Third Eye, Number 6 from map)
    // primary_chakra_association is the key the mapper looks for first
    assert.strictEqual(result.crystal_core.energy_mapping.primary_chakra, "Third Eye");
    assert.deepStrictEqual(result.crystal_core.energy_mapping.secondary_chakras, ["Crown"]);
    assert.strictEqual(result.crystal_core.energy_mapping.chakra_number, 6); // Derived from "Purple" via COLOR_CHAKRA_SIGN_MAP

    // Numerology (Amethyst = 1+4+5+2+8+9+1+2 = 32 = 5. Purple color vibration (e.g. 7 from map). Chakra 6. Master = (5+0+6)%9=11%9=2 if color vib is 0)
    assert.strictEqual(result.crystal_core.numerology.crystal_number, 5, "Numerology: crystal_number for Amethyst");
    assert.strictEqual(result.crystal_core.numerology.color_vibration, 0, "Numerology: color_vibration (default if not in AI and not from color map)");
    assert.strictEqual(result.crystal_core.numerology.chakra_number, 6, "Numerology: chakra_number for Third Eye");
    assert.strictEqual(result.crystal_core.numerology.master_number, 2, "Numerology: master_number for Amethyst (5+0+6)=11 -> 2");


    // Enrichment
    assert.strictEqual(result.automatic_enrichment.mineral_class, "Silicate");
    assert.deepStrictEqual(result.automatic_enrichment.healing_properties, ["Calming", "Intuition"]);
    assert.deepStrictEqual(result.automatic_enrichment.usage_suggestions, ["Meditation", "Sleep aid"]);
    assert.deepStrictEqual(result.automatic_enrichment.care_instructions, ["Cleanse with water", "Recharge under moonlight"]);
    assert.deepStrictEqual(result.automatic_enrichment.synergy_crystals, ["Clear Quartz"]);


    console.log("test_basic_mapping: PASSED");
  },

  test_missing_ai_fields: () => {
    const aiResponse = {
      overall_confidence_score: 0.7,
      identification_details: {
        stone_name: "Rose Quartz",
      },
      visual_characteristics: {
        primary_color: "Pink",
      },
    };
    const result = mapAiResponseToUnifiedData(aiResponse);

    assert.strictEqual(result.crystal_core.identification.stone_type, "Rose Quartz");
    assert.strictEqual(result.crystal_core.identification.crystal_family, "Unknown");
    assert.strictEqual(result.crystal_core.identification.confidence, 0.0);

    assert.strictEqual(result.crystal_core.visual_analysis.primary_color, "Pink");
    assert.deepStrictEqual(result.crystal_core.visual_analysis.secondary_colors, []);

    assert.strictEqual(result.crystal_core.energy_mapping.primary_chakra, "heart"); // Pink -> heart
    assert.strictEqual(result.crystal_core.energy_mapping.chakra_number, 4); // Pink -> heart -> 4

    // Rose Quartz = 9+6+1+5+0+8+3+1+9+2+8 = 52 => 7. (Note: X=0 if not in map)
    // The mapper uses NUMEROLOGY_LETTER_VALUES. 'q'=8, 'u'=3, 'a'=1, 'r'=9, 't'=2, 'z'=8.
    // R=9 O=6 S=1 E=5 (space) Q=8 U=3 A=1 R=9 T=2 Z=8 => 9+6+1+5+0+8+3+1+9+2+8 = 52 => 7
    assert.strictEqual(result.crystal_core.numerology.crystal_number, 7, "Numerology: Rose Quartz crystal_number");
    assert.strictEqual(result.crystal_core.numerology.color_vibration, 0);
    assert.strictEqual(result.crystal_core.numerology.chakra_number, 4); // from Pink color -> heart chakra
    // Master: (7 (Rose Quartz) + 0 (color default) + 4 (chakra)) % 9 = 11 % 9 = 2.
    assert.strictEqual(result.crystal_core.numerology.master_number, 2);


    assert.ok(result.automatic_enrichment, "Enrichment should exist with defaults");
    assert.deepStrictEqual(result.automatic_enrichment.healing_properties, []);
    assert.strictEqual(result.automatic_enrichment.mineral_class, null);


    console.log("test_missing_ai_fields: PASSED");
  },

  test_numerology_calculation_name_only_via_mapAi: () => {
    const aiResponse = {
      identification_details: { stone_name: "Selenite" }, // Selenite = 1+5+3+5+5+9+2+5 = 35 -> 8
      visual_characteristics: { primary_color: "White" }, // White -> Crown, 7
    };
    const result = mapAiResponseToUnifiedData(aiResponse);
    assert.strictEqual(result.crystal_core.numerology.crystal_number, 8, "Numerology: Selenite crystal_number");
    assert.strictEqual(result.crystal_core.numerology.chakra_number, 7, "Numerology: Selenite (White) chakra_number");
    // Master: (8 + 0 + 7) % 9 = 15 % 9 = 6
    assert.strictEqual(result.crystal_core.numerology.master_number, 6, "Numerology: Selenite master_number");

    console.log("test_numerology_calculation_name_only_via_mapAi: PASSED");
  },

  test_mineral_class_derivation: () => {
    const aiResponse = {
      identification_details: { stone_name: "Calcite", crystal_family: "Calcite" },
      visual_characteristics: { primary_color: "Orange" },
    };
    let result = mapAiResponseToUnifiedData(aiResponse);
    assert.strictEqual(result.automatic_enrichment.mineral_class, "Carbonate", "Derived mineral class for Calcite");

    const aiResponseFluorite = {
      identification_details: { stone_name: "Fluorite", crystal_family: "Fluorite" },
      visual_characteristics: { primary_color: "Green" },
    };
    result = mapAiResponseToUnifiedData(aiResponseFluorite);
    assert.strictEqual(result.automatic_enrichment.mineral_class, "Halide", "Derived mineral class for Fluorite");

    const aiResponseUnknownFamily = {
      identification_details: { stone_name: "Wonderstone", crystal_family: "MysteryRock" },
      visual_characteristics: { primary_color: "Rainbow" },
    };
    result = mapAiResponseToUnifiedData(aiResponseUnknownFamily);
    assert.strictEqual(result.automatic_enrichment.mineral_class, null, "Mineral class null for unknown family");

    console.log("test_mineral_class_derivation: PASSED");
  }

};

// --- Test Runner ---
// This basic runner will try to execute tests. Node.js assert throws on failure.
function runTests() {
  let passed = 0;
  let failed = 0;
  const testNames = Object.keys(tests);

  console.log("Starting dataMapper tests...\n");

  for (const testName of testNames) {
    try {
      tests[testName]();
      // console.log(`${testName}: PASSED`); // Individual pass messages are now in each test
      passed++;
    } catch (e) {
      // The error message from assert is usually quite good.
      console.error(`\n${testName}: FAILED`);
      console.error(e); // Log the full error object from assert
      failed++;
    }
  }
  console.log(`\n--------------------
Tests completed: ${passed} passed, ${failed} failed.
--------------------`);

  if (failed > 0) {
    // To signal failure to an external script, you might use process.exit(1)
    // For this environment, just logging is fine.
    console.error("ATTENTION: SOME TESTS FAILED.");
  } else {
    console.log("ALL TESTS PASSED SUCCESSFULLY.");
  }
}

// This allows running tests by executing `node functions/test/dataMapper.test.js`
// It also handles the calculateNameNumerologyNumber for the test_numerology_calculation_name_only test case.
if (require.main === module) {
    // This is a simplified way to expose calculateNameNumerologyNumber for testing without formally exporting it.
    // In a more complex setup, you'd use module.exports in dataMapper.js and require it properly.
    const fs = require('fs');
    const path = require('path');
    try {
        const dataMapperContent = fs.readFileSync(path.join(__dirname, '../logic/dataMapper.js'), 'utf8');

        // Extract NUMEROLOGY_LETTER_VALUES (it's a const in the module scope)
        const numerologyValuesMatch = dataMapperContent.match(/const NUMEROLOGY_LETTER_VALUES = ({[^;]*};)/);
        if (numerologyValuesMatch && numerologyValuesMatch[1]) {
            // Make it available globally for the eval context of the function below
            global.NUMEROLOGY_LETTER_VALUES_EVAL = JSON.parse(numerologyValuesMatch[1].slice(0,-1)); // remove trailing semicolon
        } else {
            console.error("Could not extract NUMEROLOGY_LETTER_VALUES for test setup.");
        }

        const calcFuncMatch = dataMapperContent.match(/function calculateNameNumerologyNumber\(name\) {[^}]*}/s);
        if (calcFuncMatch && calcFuncMatch[0]) {
            // Make the function globally available for the tests that might call it directly (though not strictly needed for these tests)
            // The direct test for calculateNameNumerologyNumber was removed, but this shows how it could be done.
            // global.calculateNameNumerologyNumber = new Function('name', `
            //   const NUMEROLOGY_LETTER_VALUES = global.NUMEROLOGY_LETTER_VALUES_EVAL;
            //   return (${calcFuncMatch[0]})(name);
            // `);
        } else {
            console.warn("Could not extract calculateNameNumerologyNumber for direct test setup (not critical for current tests).");
        }
    } catch(e) {
        console.error("Error setting up test environment for calculateNameNumerologyNumber:", e);
    }
  runTests();
}

module.exports = { tests, runTests }; // Export for potential programmatic running
