import pytest
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock # For mocking async functions
import uuid
from datetime import datetime

# Assuming UnifiedCrystalData and its sub-models are importable for response validation
# If backend_server.py defines them and is in root, this might be tricky.
# For now, we'll validate based on expected JSON structure.
# from backend_server import UnifiedCrystalData # This would be ideal if importable

# Updated SAMPLE_AI_RESPONSE_FULL to reflect the new simpler/flatter structure
# requested by the simplified prompt.
SAMPLE_AI_RESPONSE_FULL = {
    "overall_confidence_score": 0.9,
    # identification_details group
    "stone_name": "Amethyst",
    "variety": "Chevron Amethyst",
    "crystal_family": "Quartz",
    "identification_confidence": 0.95,
    # visual_characteristics group
    "primary_color": "Purple",
    "secondary_colors": ["Violet", "White"],
    "transparency": "Translucent",
    "formation": "Cluster",
    "size_estimate": "Medium",
    # physical_properties_summary group
    "hardness": "7",
    "crystal_system": "Hexagonal",
    # metaphysical_aspects group
    "primary_chakra": "Third Eye",
    "secondary_chakras": ["Crown"],
    "vibration_level": "High",
    "primary_zodiac_signs": ["Pisces", "Aquarius"],
    "planetary_rulers": ["Jupiter"],
    "elements": ["Water"],
    # numerology_insights group (AI's attempt)
    "crystal_number_association": 3, # AI might guess this for Amethyst
    "color_vibration_number": 5,
    "chakra_number_for_numerology": 6,
    "master_numerology_number_suggestion": 5, # AI might guess this
    # enrichment_details group
    "crystal_bible_reference": "Page 123",
    "healing_properties": ["Calming", "Intuition"],
    "usage_suggestions": ["Meditation", "Sleep aid"],
    "care_instructions": ["Cleanse monthly", "Avoid direct sunlight"],
    "synergy_crystals": ["Clear Quartz", "Selenite"],
    "mineral_class": "Silicate" # AI might provide this
}

# Updated SAMPLE_AI_RESPONSE_MINIMAL_FOR_RULES for the new flatter structure
SAMPLE_AI_RESPONSE_MINIMAL_FOR_RULES = {
    "overall_confidence_score": 0.8,
    "stone_name": "Jasper", # Numerology: J=1,A=1,S=1,P=7,E=5,R=9 -> 24 -> 6
    "crystal_family": "Quartz", # Should map to Silicate if mineral_class not provided
    "identification_confidence": 0.85,
    "primary_color": "Red", # Should map to Root chakra, number 1, and signs Aries/Scorpio
    "secondary_colors": [],
    "transparency": "Opaque",
    "formation": "Raw",
    # Metaphysical aspects largely missing for rule-based fallbacks
    "healing_properties": ["Grounding"]
    # mineral_class is missing, should be derived from crystal_family "Quartz"
    # primary_chakra, chakra_number, primary_zodiac_signs missing for rule-based
    # numerology numbers missing for calculation
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
    assert core['confidence_score'] == SAMPLE_AI_RESPONSE_FULL['overall_confidence_score'] # Mapped from top-level

    va = core['visual_analysis']
    assert va['primary_color'] == SAMPLE_AI_RESPONSE_FULL['primary_color']
    assert va['formation'] == SAMPLE_AI_RESPONSE_FULL['formation']

    ident = core['identification']
    assert ident['stone_type'] == SAMPLE_AI_RESPONSE_FULL['stone_name']
    assert ident['crystal_family'] == SAMPLE_AI_RESPONSE_FULL['crystal_family']
    assert ident['variety'] == SAMPLE_AI_RESPONSE_FULL['variety']
    assert ident['confidence'] == SAMPLE_AI_RESPONSE_FULL['identification_confidence']


    em = core['energy_mapping']
    assert em['primary_chakra'] == SAMPLE_AI_RESPONSE_FULL['primary_chakra']
    # chakra_number in energy_mapping is rule-based if AI doesn't provide it directly or if color mapping overrides
    # For this full response, AI provides it via "chakra_number_for_numerology" which maps to energy_mapping.chakra_number
    # if energy_mapping.chakra_number itself isn't directly in AI response's metaphysical_aspects.
    # The mapping function prioritizes direct em_data.get("chakra_number", 0) from AI.
    # Our sample AI response has "chakra_number_for_numerology" in "numerology_insights"
    # The map_ai_response function was: final_chakra_number = ai_chakra_number (from em_data)
    # Let's assume AI provides "chakra_number" under "metaphysical_aspects" for direct mapping.
    # If not, the test or mapping needs adjustment. For now, assume it's provided or rule-based.
    # For SAMPLE_AI_RESPONSE_FULL, it implies "primary_chakra": "Third Eye" -> number 6.
    # The mapping logic: final_chakra_number = ai_chakra_number (from em_data.get("chakra_number"))
    # If AI provides "chakra_number": 6 directly in metaphysical_aspects, this will pass.
    # If not, color mapping for "Purple" (Third Eye) should yield 6.
    assert em['chakra_number'] == 6 # Expected from "Third Eye" or direct AI numerology_insights.chakra_number_for_numerology
    assert em['vibration_level'] == SAMPLE_AI_RESPONSE_FULL['vibration_level']


    ad = core['astrological_data']
    assert ad['primary_signs'] == SAMPLE_AI_RESPONSE_FULL['primary_zodiac_signs']
    assert ad['planetary_ruler'] == SAMPLE_AI_RESPONSE_FULL['planetary_rulers'][0] # Assuming first if list
    assert ad['element'] == SAMPLE_AI_RESPONSE_FULL['elements'][0] # Assuming first if list


    num = core['numerology']
    # Rule-based calculation for Amethyst (1+4+5+2+8+7+1+2 = 30 => 3)
    assert num['crystal_number'] == 3
    # Master number: crystal_number=3 (rule), color_vibration=5 (AI), chakra_number=6 (rule/AI)
    # (3 + 5 + 6) = 14 => 1+4 = 5.
    assert num['master_number'] == 5
    assert num['chakra_number'] == 6 # Consistent


    # Validate AutomaticEnrichment
    ae = data['automatic_enrichment']
    assert ae['healing_properties'] == SAMPLE_AI_RESPONSE_FULL['healing_properties']
    assert ae['mineral_class'] == SAMPLE_AI_RESPONSE_FULL['mineral_class']

    # UserIntegration should be present with default/empty values
    assert 'user_integration' in data
    assert data['user_integration'] is None or isinstance(data['user_integration'], dict)


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
