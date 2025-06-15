import pytest
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock # For mocking async functions
import uuid
from datetime import datetime

# Assuming UnifiedCrystalData and its sub-models are importable for response validation
# If backend_server.py defines them and is in root, this might be tricky.
# For now, we'll validate based on expected JSON structure.
# from backend_server import UnifiedCrystalData # This would be ideal if importable

SAMPLE_AI_RESPONSE_FULL = {
    "crystal_core": {
        "confidence_score": 0.9,
        "visual_analysis": {
            "primary_color": "Purple",
            "secondary_colors": ["Violet", "White"],
            "transparency": "Translucent",
            "formation": "Cluster",
            "size_estimate": "Medium"
        },
        "identification": {
            "stone_type": "Amethyst",
            "crystal_family": "Quartz",
            "variety": "Chevron Amethyst",
            "confidence": 0.95
        },
        "energy_mapping": {
            "primary_chakra": "Third Eye",
            "secondary_chakras": ["Crown"],
            "chakra_number": 6,
            "vibration_level": "High"
        },
        "astrological_data": {
            "primary_signs": ["Pisces", "Aquarius"],
            "compatible_signs": ["Virgo", "Capricorn"],
            "planetary_ruler": "Jupiter",
            "element": "Water"
        },
        "numerology": {
            "crystal_number": 3, # Expected from "Amethyst"
            "color_vibration": 5, # Example value
            "chakra_number": 6,
            "master_number": 5 # (3+5+6=14 -> 5)
        }
    },
    "automatic_enrichment": {
        "crystal_bible_reference": "Page 123",
        "healing_properties": ["Calming", "Intuition"],
        "usage_suggestions": ["Meditation", "Sleep aid"],
        "care_instructions": ["Cleanse monthly", "Avoid direct sunlight"],
        "synergy_crystals": ["Clear Quartz", "Selenite"],
        "mineral_class": "Silicate"
    }
}

SAMPLE_AI_RESPONSE_MINIMAL_FOR_RULES = {
    "crystal_core": {
        "confidence_score": 0.8,
        "visual_analysis": {
            "primary_color": "Red", # Should map to Root chakra, number 1
            "secondary_colors": [],
            "transparency": "Opaque",
            "formation": "Raw"
        },
        "identification": {
            "stone_type": "Jasper", # Numerology: J=1, A=1, S=1, P=7, E=5, R=9 -> 1+1+1+7+5+9 = 24 -> 6
            "crystal_family": "Quartz", # Should map to Silicate
            "confidence": 0.85
        },
        "energy_mapping": {
            # Missing primary_chakra, chakra_number - should be rule-based
        },
        "astrological_data": {
            # Missing primary_signs - should be rule-based from color Red (Aries, Scorpio)
        },
        "numerology": {
            # Missing crystal_number, master_number - should be calculated
            # color_vibration might be 0, chakra_number (from rule) will be 1
        }
    },
    "automatic_enrichment": {
        # Missing mineral_class - should be derived
        "healing_properties": ["Grounding"],
    }
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
    assert uuid.UUID(core['id'], version=4) # Check if 'id' is a valid UUID4
    assert datetime.fromisoformat(core['timestamp'].replace("Z", "+00:00")) # Check timestamp
    assert core['confidence_score'] == SAMPLE_AI_RESPONSE_FULL['crystal_core']['confidence_score']

    va = core['visual_analysis']
    expected_va = SAMPLE_AI_RESPONSE_FULL['crystal_core']['visual_analysis']
    assert va['primary_color'] == expected_va['primary_color']
    assert va['formation'] == expected_va['formation']

    ident = core['identification']
    expected_ident = SAMPLE_AI_RESPONSE_FULL['crystal_core']['identification']
    assert ident['stone_type'] == expected_ident['stone_type']
    assert ident['crystal_family'] == expected_ident['crystal_family']

    em = core['energy_mapping']
    expected_em = SAMPLE_AI_RESPONSE_FULL['crystal_core']['energy_mapping']
    assert em['primary_chakra'] == expected_em['primary_chakra']
    assert em['chakra_number'] == expected_em['chakra_number']

    ad = core['astrological_data']
    expected_ad = SAMPLE_AI_RESPONSE_FULL['crystal_core']['astrological_data']
    assert ad['primary_signs'] == expected_ad['primary_signs'] # List comparison

    num = core['numerology']
    expected_num = SAMPLE_AI_RESPONSE_FULL['crystal_core']['numerology']
    assert num['crystal_number'] == expected_num['crystal_number']
    assert num['master_number'] == expected_num['master_number']
    assert num['chakra_number'] == expected_num['chakra_number']


    # Validate AutomaticEnrichment
    ae = data['automatic_enrichment']
    expected_ae = SAMPLE_AI_RESPONSE_FULL['automatic_enrichment']
    assert ae['healing_properties'] == expected_ae['healing_properties']
    assert ae['mineral_class'] == expected_ae['mineral_class']

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
