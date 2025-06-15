import pytest
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock # For mocking async functions
import uuid
from datetime import datetime

# Assuming UnifiedCrystalData and its sub-models are importable for response validation
# If backend_server.py defines them and is in root, this might be tricky.
# For now, we'll validate based on expected JSON structure.
# from backend_server import UnifiedCrystalData # This would be ideal if importable

# SAMPLE_AI_RESPONSE_FULL now reflects the direct keys or keys within logical groups
# as requested by the simplified prompt.
SAMPLE_AI_RESPONSE_FULL = {
    "overall_confidence_score": 0.9,
    "identification_details": {
        "stone_name": "Amethyst",
        "variety": "Chevron Amethyst",
        "crystal_family": "Quartz",
        "identification_confidence": 0.95
    },
    "visual_characteristics": {
        "primary_color": "Purple",
        "secondary_colors": ["Violet", "White"],
        "transparency": "Translucent",
        "formation": "Cluster",
        "size_estimate": "Medium"
    },
    "physical_properties_summary": {
        "hardness": "7",
        "crystal_system": "Hexagonal"
    },
    "metaphysical_aspects": {
        "primary_chakra": "Third Eye",
        "secondary_chakras": ["Crown"],
        "vibration_level": "High",
        "primary_zodiac_signs": ["Pisces", "Aquarius"],
        "planetary_rulers": ["Jupiter"], # Changed to list as per Pydantic, though prompt asks for string
        "elements": ["Water"]           # Changed to list as per Pydantic
    },
    "numerology_insights": {
        "crystal_number_association": 3,
        "color_vibration_number": 5,
        "chakra_number_for_numerology": 6,
        "master_numerology_number_suggestion": 5
    },
    "enrichment_details": {
        "crystal_bible_reference": "Page 123",
        "healing_properties": ["Calming", "Intuition"],
        "usage_suggestions": ["Meditation", "Sleep aid"],
        "care_instructions": ["Cleanse monthly", "Avoid direct sunlight"],
        "synergy_crystals": ["Clear Quartz", "Selenite"],
        "mineral_class": "Silicate"
    }
}

# SAMPLE_AI_RESPONSE_MINIMAL_FOR_RULES reflects the simplified structure
SAMPLE_AI_RESPONSE_MINIMAL_FOR_RULES = {
    "overall_confidence_score": 0.8,
    "identification_details": {
        "stone_name": "Jasper",
        "crystal_family": "Quartz", # For deriving mineral_class
        "identification_confidence": 0.85
    },
    "visual_characteristics": {
        "primary_color": "Red", # For chakra and sign fallback
        "secondary_colors": [],
        "transparency": "Opaque",
        "formation": "Raw"
    },
    # Metaphysical aspects largely missing for rule-based fallbacks
    "enrichment_details": { # Need at least one key from this group for parsing
        "healing_properties": ["Grounding"]
    }
    # mineral_class is missing from enrichment_details
    # primary_chakra, chakra_number, primary_zodiac_signs missing from metaphysical_aspects
    # numerology numbers missing from numerology_insights
}


def test_identify_crystal_success(test_client: TestClient, mocker):
    # Mock AIService.identify_crystal_with_gemini
    # Since AIService.identifyCrystal now calls BackendService.identifyCrystal which calls AIService.identify_crystal_with_gemini
    # we need to mock the lowest level call that produces the AI json.
    # That is backend_server.AIService.identify_crystal_with_gemini
    mock_ai_call = mocker.patch(
        'backend_server.AIService.identify_crystal_with_gemini',
        new_callable=AsyncMock, # Use AsyncMock for async methods
        return_value=SAMPLE_AI_RESPONSE_FULL
    )

    request_data = {
        "image_data": "fake_base64_image_data",
        "user_context": {"text_description": "A beautiful purple crystal"}
    }
    response = test_client.post("/api/crystal/identify", json=request_data)

    assert response.status_code == 200
    data = response.json()

    mock_ai_call.assert_called_once()

    # Validate CrystalCore
    core = data['crystal_core']
    assert uuid.UUID(core['id'], version=4)
    assert datetime.fromisoformat(core['timestamp'].replace("Z", "+00:00"))
    assert core['confidence_score'] == SAMPLE_AI_RESPONSE_FULL['overall_confidence_score']

    va = core['visual_analysis']
    expected_va = SAMPLE_AI_RESPONSE_FULL['visual_characteristics']
    assert va['primary_color'] == expected_va['primary_color']
    assert va['formation'] == expected_va['formation']
    assert va['secondary_colors'] == expected_va['secondary_colors']
    assert va['transparency'] == expected_va['transparency']
    assert va['size_estimate'] == expected_va['size_estimate']


    ident = core['identification']
    expected_ident = SAMPLE_AI_RESPONSE_FULL['identification_details']
    assert ident['stone_type'] == expected_ident['stone_name']
    assert ident['crystal_family'] == expected_ident['crystal_family']
    assert ident['variety'] == expected_ident['variety']
    assert ident['confidence'] == expected_ident['identification_confidence']


    em = core['energy_mapping']
    expected_em_ai = SAMPLE_AI_RESPONSE_FULL['metaphysical_aspects']
    assert em['primary_chakra'] == expected_em_ai['primary_chakra']
    assert em['secondary_chakras'] == expected_em_ai['secondary_chakras']
    assert em['vibration_level'] == expected_em_ai['vibration_level']
    # chakra_number is derived by rule (purple -> third eye -> 6) or from numerology_insights
    assert em['chakra_number'] == 6


    ad = core['astrological_data']
    assert ad['primary_signs'] == expected_em_ai['primary_zodiac_signs']
    assert ad['planetary_ruler'] == expected_em_ai['planetary_rulers'][0] # mapping takes first if list
    assert ad['element'] == expected_em_ai['elements'][0] # mapping takes first if list


    num = core['numerology']
    expected_num_ai = SAMPLE_AI_RESPONSE_FULL['numerology_insights']
    # Rule-based calculation for Amethyst (1+4+5+2+8+7+1+2 = 30 => 3)
    assert num['crystal_number'] == 3
    assert num['color_vibration'] == expected_num_ai['color_vibration_number']
    assert num['chakra_number'] == expected_num_ai['chakra_number_for_numerology'] # from AI via numerology_insights
    # Master number: crystal_number=3 (rule), color_vibration=5 (AI), chakra_number=6 (AI)
    # (3 + 5 + 6) = 14 => 1+4 = 5.
    assert num['master_number'] == 5


    # Validate AutomaticEnrichment
    ae = data['automatic_enrichment']
    expected_ae_ai = SAMPLE_AI_RESPONSE_FULL['enrichment_details']
    assert ae['healing_properties'] == expected_ae_ai['healing_properties']
    assert ae['mineral_class'] == expected_ae_ai['mineral_class']
    assert ae['usage_suggestions'] == expected_ae_ai['usage_suggestions']
    assert ae['care_instructions'] == expected_ae_ai['care_instructions']
    assert ae['synergy_crystals'] == expected_ae_ai['synergy_crystals']
    assert ae['crystal_bible_reference'] == expected_ae_ai['crystal_bible_reference']

    # UserIntegration should be present and be a dict (empty if no specific user data was part of identification)
    # map_ai_response_to_unified_data initializes it as an empty UserIntegration object
    assert 'user_integration' in data
    assert isinstance(data['user_integration'], dict)
    # Since it's initialized empty by map_ai_response_to_unified_data, user_id should be None
    assert data['user_integration'].get('user_id') is None
    assert data['user_integration'].get('personal_rating') is None
    assert data['user_integration'].get('user_experiences') == []
    assert data['user_integration'].get('intention_settings') == []


def test_identify_crystal_rule_based_fallbacks(test_client: TestClient, mocker):
    mocker.patch(
        'backend_server.AIService.identify_crystal_with_gemini',
        new_callable=AsyncMock,
        return_value=SAMPLE_AI_RESPONSE_MINIMAL_FOR_RULES
    )

    request_data = {"image_data": "another_fake_image_data"}
    response = test_client.post("/api/crystal/identify", json=request_data)

    assert response.status_code == 200
    data = response.json()

    core = data['crystal_core']
    # Chakra mapping from "Red"
    assert core['energy_mapping']['primary_chakra'] == "root"
    assert core['energy_mapping']['chakra_number'] == 1
    # Astrological signs from "Red"
    assert sorted(core['astrological_data']['primary_signs']) == sorted(["aries", "scorpio"])

    # Numerology for "Jasper" (J=1,A=1,S=1,P=7,E=5,R=9 => 24 => 6)
    assert core['numerology']['crystal_number'] == 6
    # Master number: crystal_number=6, color_vibration=0 (default from AI), chakra_number=1 (rule-based)
    # (6 + 0 + 1) % 9 = 7
    assert core['numerology']['master_number'] == 7
    assert core['numerology']['chakra_number'] == 1 # Consistent with energy_mapping

    # Mineral class for "Quartz" family
    assert data['automatic_enrichment']['mineral_class'] == "Silicate"
    assert data['automatic_enrichment']['healing_properties'] == ["Grounding"]


def test_identify_crystal_ai_failure(test_client: TestClient, mocker):
    mocker.patch(
        'backend_server.AIService.identify_crystal_with_gemini',
        new_callable=AsyncMock,
        side_effect=Exception("AI service unavailable")
    )

    request_data = {"image_data": "fake_image_data_for_ai_failure"}
    response = test_client.post("/api/crystal/identify", json=request_data)

    assert response.status_code == 500 # Or whatever error AIService propagates
    data = response.json()
    assert "AI identification failed" in data.get("detail", "").lower() or \
           "ai service unavailable" in data.get("detail", "").lower()

def test_identify_crystal_invalid_input_no_image(test_client: TestClient):
    response = test_client.post("/api/crystal/identify", json={"user_context": {}})
    assert response.status_code == 422 # FastAPI validation error for missing image_data
