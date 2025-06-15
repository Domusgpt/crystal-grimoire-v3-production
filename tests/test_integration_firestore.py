import pytest
import os
import uuid
from datetime import datetime
from fastapi.testclient import TestClient

# These tests are intended to run against a Firebase Emulator.
# Ensure FIRESTORE_EMULATOR_HOST is set in the environment before running.
# e.g., export FIRESTORE_EMULATOR_HOST="localhost:8080"
# Also, a Firebase app must be initialized. This might require a separate
# entry point or conftest.py setup for integration tests that doesn't mock firebase_admin.

# Conditional skip if emulator is not running/configured
# This requires a way to check if the emulator is actually available.
# For now, we assume it is if these tests are explicitly run.
skip_if_emulator_not_configured = pytest.mark.skipif(
    not os.getenv("FIRESTORE_EMULATOR_HOST"),
    reason="FIRESTORE_EMULATOR_HOST not set, skipping Firestore integration tests."
)

# Sample data function (can be shared or redefined from unit tests)
def create_sample_crystal_data_for_integration(crystal_id: str, stone_type: str = "IntegTestStone"):
    return {
        "crystal_core": {
            "id": crystal_id,
            "timestamp": datetime.utcnow().isoformat(),
            "confidence_score": 0.88,
            "visual_analysis": {"primary_color": "Green", "secondary_colors": [], "transparency": "Opaque", "formation": "Massive"},
            "identification": {"stone_type": stone_type, "crystal_family": "TestIntegFamily", "variety": "Raw", "confidence": 0.92},
            "energy_mapping": {"primary_chakra": "Heart", "secondary_chakras": [], "chakra_number": 4, "vibration_level": "Medium"},
            "astrological_data": {"primary_signs": ["Taurus"], "compatible_signs": [], "planetary_ruler": "Venus", "element": "Earth"},
            "numerology": {"crystal_number": 2, "color_vibration": 2, "chakra_number": 4, "master_number": 8}
        },
        "user_integration": None,
        "automatic_enrichment": {"mineral_class": "TestIntegClass"}
    }

@pytest.fixture(scope="function")
def integration_test_client():
    """
    Provides a TestClient for integration tests.
    This fixture assumes that the global firebase_admin app is initialized
    and pointing to the emulator (via FIRESTORE_EMULATOR_HOST).
    It purposefully DOES NOT use the mock_firebase_admin fixture from conftest.py.
    Running these tests typically requires a different pytest invocation or setup
    that avoids applying the unit test mocks.
    """
    from backend_server import app, db # db here should be the real one connected to emulator

    if not os.getenv("FIRESTORE_EMULATOR_HOST"):
        pytest.skip("FIRESTORE_EMULATOR_HOST not set, skipping Firestore integration tests.")

    if db is None: # Check if db somehow got mocked to None
         pytest.fail("Firestore client (db) is None. Firebase app not initialized correctly for integration tests.")

    # Clear the 'crystals' collection before each test
    crystals_ref = db.collection('crystals')
    docs = crystals_ref.limit(100).stream() # Limit to avoid large deletions if something goes wrong
    for doc in docs:
        doc.reference.delete()

    yield TestClient(app)

    # Teardown: Clear the 'crystals' collection after each test
    docs = crystals_ref.limit(100).stream()
    for doc in docs:
        doc.reference.delete()


@skip_if_emulator_not_configured
def test_create_and_read_crystal_integration(integration_test_client: TestClient):
    from backend_server import db # Use the actual db instance for verification

    crystal_id = str(uuid.uuid4())
    stone_type = "IntegrationAmethyst"
    sample_data = create_sample_crystal_data_for_integration(crystal_id, stone_type)

    # 1. Create Crystal
    response_create = integration_test_client.post("/api/crystals", json=sample_data)
    assert response_create.status_code == 200
    created_data = response_create.json()
    assert created_data["crystal_core"]["id"] == crystal_id
    assert created_data["crystal_core"]["identification"]["stone_type"] == stone_type

    # Verify directly in Firestore emulator
    doc_ref = db.collection("crystals").document(crystal_id)
    doc = doc_ref.get()
    assert doc.exists
    assert doc.to_dict()["crystal_core"]["identification"]["stone_type"] == stone_type

    # 2. Read Crystal
    response_read = integration_test_client.get(f"/api/crystals/{crystal_id}")
    assert response_read.status_code == 200
    read_data = response_read.json()
    assert read_data["crystal_core"]["id"] == crystal_id
    assert read_data["crystal_core"]["identification"]["stone_type"] == stone_type


@skip_if_emulator_not_configured
def test_list_crystals_integration(integration_test_client: TestClient):
    from backend_server import db

    crystal_id_1 = str(uuid.uuid4())
    crystal_id_2 = str(uuid.uuid4())
    sample_data_1 = create_sample_crystal_data_for_integration(crystal_id_1, "IntegQuartz")
    sample_data_2 = create_sample_crystal_data_for_integration(crystal_id_2, "IntegCitrine")

    # Create some crystals directly for setup consistency if needed, or via API
    db.collection("crystals").document(crystal_id_1).set(sample_data_1)
    db.collection("crystals").document(crystal_id_2).set(sample_data_2)

    response_list = integration_test_client.get("/api/crystals")
    assert response_list.status_code == 200
    list_data = response_list.json()
    assert len(list_data) >= 2 # Could be more if other tests ran without perfect cleanup and no isolation

    ids_in_response = [item["crystal_core"]["id"] for item in list_data]
    assert crystal_id_1 in ids_in_response
    assert crystal_id_2 in ids_in_response

@skip_if_emulator_not_configured
def test_update_crystal_integration(integration_test_client: TestClient):
    from backend_server import db
    crystal_id = str(uuid.uuid4())
    stone_type_initial = "InitialStone"
    stone_type_updated = "UpdatedStone"
    sample_data = create_sample_crystal_data_for_integration(crystal_id, stone_type_initial)

    # Create initial crystal
    db.collection("crystals").document(crystal_id).set(sample_data)

    updated_payload = sample_data.copy() # Shallow copy is fine as we only change a nested value
    updated_payload["crystal_core"]["identification"]["stone_type"] = stone_type_updated
    updated_payload["crystal_core"]["visual_analysis"]["primary_color"] = "Red"


    response_update = integration_test_client.put(f"/api/crystals/{crystal_id}", json=updated_payload)
    assert response_update.status_code == 200
    update_response_data = response_update.json()
    assert update_response_data["crystal_core"]["identification"]["stone_type"] == stone_type_updated
    assert update_response_data["crystal_core"]["visual_analysis"]["primary_color"] == "Red"

    # Verify in Firestore
    doc = db.collection("crystals").document(crystal_id).get()
    assert doc.exists
    assert doc.to_dict()["crystal_core"]["identification"]["stone_type"] == stone_type_updated
    assert doc.to_dict()["crystal_core"]["visual_analysis"]["primary_color"] == "Red"


@skip_if_emulator_not_configured
def test_delete_crystal_integration(integration_test_client: TestClient):
    from backend_server import db
    crystal_id = str(uuid.uuid4())
    sample_data = create_sample_crystal_data_for_integration(crystal_id, "ToDeleteStone")

    # Create initial crystal
    db.collection("crystals").document(crystal_id).set(sample_data)

    # Ensure it exists
    doc = db.collection("crystals").document(crystal_id).get()
    assert doc.exists

    response_delete = integration_test_client.delete(f"/api/crystals/{crystal_id}")
    assert response_delete.status_code == 200
    assert response_delete.json()["status"] == "success"

    # Verify in Firestore
    doc_after_delete = db.collection("crystals").document(crystal_id).get()
    assert not doc_after_delete.exists

@skip_if_emulator_not_configured
def test_read_non_existent_crystal_integration(integration_test_client: TestClient):
    non_existent_id = str(uuid.uuid4())
    response_read = integration_test_client.get(f"/api/crystals/{non_existent_id}")
    assert response_read.status_code == 404
    assert response_read.json()["detail"] == "Crystal not found"

# Note: Identification endpoint tests are harder to make true integration tests
# because they depend on an external AI service. For emulator context, we'd focus
# on how data *related* to identification might be stored or retrieved if there were
# such Firestore interactions in that endpoint (currently, it doesn't directly save to DB).
# The existing unit tests for identification with mocked AI are more appropriate for that logic.
