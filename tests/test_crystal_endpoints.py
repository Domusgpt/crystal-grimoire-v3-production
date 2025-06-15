import pytest
from fastapi.testclient import TestClient
from unittest.mock import MagicMock, AsyncMock # AsyncMock not strictly needed here if Firestore client methods are sync
import uuid
from datetime import datetime

# Sample data for UnifiedCrystalData for testing
# (Should match the structure defined in backend_server.py Pydantic models)
def create_sample_crystal_data(crystal_id: str, stone_type: str = "Test Stone"):
    return {
        "crystal_core": {
            "id": crystal_id,
            "timestamp": datetime.utcnow().isoformat(),
            "confidence_score": 0.9,
            "visual_analysis": {
                "primary_color": "Blue", "secondary_colors": [], "transparency": "Transparent", "formation": "Point"
            },
            "identification": {
                "stone_type": stone_type, "crystal_family": "TestFamily", "variety": "TestVariety", "confidence": 0.95
            },
            "energy_mapping": {
                "primary_chakra": "Throat", "secondary_chakras": [], "chakra_number": 5, "vibration_level": "High"
            },
            "astrological_data": {
                "primary_signs": ["Gemini"], "compatible_signs": [], "planetary_ruler": "Mercury", "element": "Air"
            },
            "numerology": {
                "crystal_number": 1, "color_vibration": 1, "chakra_number": 5, "master_number": 7
            }
        },
        "user_integration": None, # Or provide sample data
        "automatic_enrichment": {
            "mineral_class": "TestClass"
        }
    }

# --- Test Create Crystal ---
def test_create_crystal_success(test_client: TestClient, mock_firestore_client):
    crystal_id = str(uuid.uuid4())
    sample_data = create_sample_crystal_data(crystal_id)

    # Configure mock for firestore document set
    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    # mock_doc_ref.set = MagicMock() # .set is already a MagicMock from parent

    response = test_client.post("/api/crystals", json=sample_data)

    assert response.status_code == 200
    response_data = response.json()
    assert response_data["crystal_core"]["id"] == crystal_id
    assert response_data["crystal_core"]["identification"]["stone_type"] == "Test Stone"

    mock_firestore_client.collection.assert_called_with("crystals")
    mock_firestore_client.collection("crystals").document.assert_called_with(crystal_id)
    mock_doc_ref.set.assert_called_once()
    # TODO: Add more detailed check for what doc_ref.set was called with if possible:
    # called_with_data = mock_doc_ref.set.call_args[0][0]
    # assert called_with_data["crystal_core"]["id"] == crystal_id


def test_create_crystal_invalid_input_missing_core(test_client: TestClient):
    invalid_data = {"user_integration": None} # Missing crystal_core
    response = test_client.post("/api/crystals", json=invalid_data)
    assert response.status_code == 422 # FastAPI Unprocessable Entity

def test_create_crystal_firestore_permission_denied(test_client: TestClient, mock_firestore_client, mocker):
    # Import specific exceptions here or at top of file
    # For this example, assuming they can be imported or are base Exception types for mocking.
    # from google.cloud import exceptions as google_exceptions # Ideal
    # For now, just use a generic Exception or mock the specific string if that's checked.
    # We need to ensure these modules are available in the test environment or use generic ones.
    # Let's assume we can mock the specific exception type if available.
    # If not, we'd mock with a generic Exception and check the FastAPI response code.

    # If google.cloud.exceptions cannot be imported in this environment,
    # we might need to mock a more generic exception and ensure the endpoint
    # still returns a 500-level error.
    # For robust testing, the actual exception types should be used.
    try:
        from google.cloud import exceptions as google_exceptions
        PermissionDeniedException = google_exceptions.PermissionDenied
    except ImportError:
        # Fallback if google.cloud.exceptions is not available in test env
        # This means we can't test for specific exception handling as accurately
        class PermissionDeniedException(Exception):
            def __init__(self, message):
                super().__init__(message)

    crystal_id = str(uuid.uuid4())
    sample_data = create_sample_crystal_data(crystal_id)

    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.set.side_effect = PermissionDeniedException("Mocked Firestore permission denied")

    response = test_client.post("/api/crystals", json=sample_data)

    assert response.status_code == 500 # Expecting a generic internal server error
    # Or, if the backend maps this to a specific HTTP error (e.g., 403), test for that.
    # For now, assuming it becomes a 500 due to an unhandled specific DB exception.
    assert "permission denied" in response.json()["detail"].lower()


def test_create_crystal_firestore_deadline_exceeded(test_client: TestClient, mock_firestore_client, mocker):
    try:
        from google.api_core import exceptions as api_core_exceptions
        DeadlineExceededException = api_core_exceptions.DeadlineExceeded
    except ImportError:
        class DeadlineExceededException(Exception): # TimeoutError is also a good generic substitute
            def __init__(self, message):
                super().__init__(message)

    crystal_id = str(uuid.uuid4())
    sample_data = create_sample_crystal_data(crystal_id)

    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.set.side_effect = DeadlineExceededException("Mocked Firestore deadline exceeded")

    response = test_client.post("/api/crystals", json=sample_data)

    assert response.status_code == 500
    assert "deadline exceeded" in response.json()["detail"].lower()


# --- Test Read Crystal ---
def test_read_crystal_success(test_client: TestClient, mock_firestore_client):
    crystal_id = str(uuid.uuid4())
    sample_data = create_sample_crystal_data(crystal_id, "Amethyst")

    mock_doc_snapshot = MagicMock()
    mock_doc_snapshot.exists = True
    mock_doc_snapshot.to_dict.return_value = sample_data

    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.get.return_value = mock_doc_snapshot # Simulate sync get for now

    response = test_client.get(f"/api/crystals/{crystal_id}")

    assert response.status_code == 200
    response_data = response.json()
    assert response_data["crystal_core"]["id"] == crystal_id
    assert response_data["crystal_core"]["identification"]["stone_type"] == "Amethyst"
    mock_doc_ref.get.assert_called_once()


def test_read_crystal_not_found(test_client: TestClient, mock_firestore_client):
    crystal_id = str(uuid.uuid4())

    mock_doc_snapshot = MagicMock()
    mock_doc_snapshot.exists = False

    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.get.return_value = mock_doc_snapshot

    response = test_client.get(f"/api/crystals/{crystal_id}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Crystal not found"


# --- Test List Crystals ---
def test_list_crystals_success(test_client: TestClient, mock_firestore_client):
    crystal_id_1 = str(uuid.uuid4())
    crystal_id_2 = str(uuid.uuid4())
    sample_data_1 = create_sample_crystal_data(crystal_id_1, "Quartz")
    sample_data_2 = create_sample_crystal_data(crystal_id_2, "Citrine")

    mock_doc_snapshot_1 = MagicMock()
    mock_doc_snapshot_1.exists = True
    mock_doc_snapshot_1.to_dict.return_value = sample_data_1

    mock_doc_snapshot_2 = MagicMock()
    mock_doc_snapshot_2.exists = True
    mock_doc_snapshot_2.to_dict.return_value = sample_data_2

    mock_collection_ref = mock_firestore_client.collection("crystals")
    mock_collection_ref.stream.return_value = [mock_doc_snapshot_1, mock_doc_snapshot_2] # Simulate sync stream

    response = test_client.get("/api/crystals")
    assert response.status_code == 200
    response_data = response.json()
    assert len(response_data) == 2
    assert response_data[0]["crystal_core"]["id"] == crystal_id_1
    assert response_data[1]["crystal_core"]["id"] == crystal_id_2
    mock_collection_ref.stream.assert_called_once()

def test_list_crystals_empty(test_client: TestClient, mock_firestore_client):
    mock_collection_ref = mock_firestore_client.collection("crystals")
    mock_collection_ref.stream.return_value = []

    response = test_client.get("/api/crystals")
    assert response.status_code == 200
    assert response.json() == []

# --- Test Update Crystal ---
def test_update_crystal_success(test_client: TestClient, mock_firestore_client):
    crystal_id = str(uuid.uuid4())
    original_data = create_sample_crystal_data(crystal_id, "OldName")
    updated_data = create_sample_crystal_data(crystal_id, "NewName")
    updated_data["crystal_core"]["visual_analysis"]["primary_color"] = "Red"

    mock_doc_snapshot_exists = MagicMock()
    mock_doc_snapshot_exists.exists = True
    # We don't strictly need to_dict for the existence check, but good practice
    mock_doc_snapshot_exists.to_dict.return_value = original_data

    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.get.return_value = mock_doc_snapshot_exists
    # mock_doc_ref.set = MagicMock() # Already a MagicMock

    response = test_client.put(f"/api/crystals/{crystal_id}", json=updated_data)

    assert response.status_code == 200
    response_json = response.json()
    assert response_json["crystal_core"]["identification"]["stone_type"] == "NewName"
    assert response_json["crystal_core"]["visual_analysis"]["primary_color"] == "Red"

    mock_doc_ref.get.assert_called_once() # Existence check
    mock_doc_ref.set.assert_called_once()
    # TODO: Check data passed to set: called_with_data = mock_doc_ref.set.call_args[0][0]

def test_update_crystal_not_found(test_client: TestClient, mock_firestore_client):
    crystal_id = str(uuid.uuid4())
    update_data = create_sample_crystal_data(crystal_id)

    mock_doc_snapshot_not_exists = MagicMock()
    mock_doc_snapshot_not_exists.exists = False
    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.get.return_value = mock_doc_snapshot_not_exists

    response = test_client.put(f"/api/crystals/{crystal_id}", json=update_data)
    assert response.status_code == 404

def test_update_crystal_id_mismatch(test_client: TestClient):
    path_crystal_id = str(uuid.uuid4())
    body_crystal_id = str(uuid.uuid4()) # Different ID
    update_data = create_sample_crystal_data(body_crystal_id)

    response = test_client.put(f"/api/crystals/{path_crystal_id}", json=update_data)
    assert response.status_code == 400
    assert "mismatch" in response.json()["detail"].lower()


# --- Test Delete Crystal ---
def test_delete_crystal_success(test_client: TestClient, mock_firestore_client):
    crystal_id = str(uuid.uuid4())

    mock_doc_snapshot_exists = MagicMock()
    mock_doc_snapshot_exists.exists = True
    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.get.return_value = mock_doc_snapshot_exists
    # mock_doc_ref.delete = MagicMock() # Already a MagicMock

    response = test_client.delete(f"/api/crystals/{crystal_id}")
    assert response.status_code == 200
    assert response.json()["status"] == "success"
    assert crystal_id in response.json()["message"]
    mock_doc_ref.get.assert_called_once()
    mock_doc_ref.delete.assert_called_once()

def test_delete_crystal_not_found(test_client: TestClient, mock_firestore_client):
    crystal_id = str(uuid.uuid4())
    mock_doc_snapshot_not_exists = MagicMock()
    mock_doc_snapshot_not_exists.exists = False
    mock_doc_ref = mock_firestore_client.collection("crystals").document(crystal_id)
    mock_doc_ref.get.return_value = mock_doc_snapshot_not_exists

    response = test_client.delete(f"/api/crystals/{crystal_id}")
    assert response.status_code == 404

# TODO: Test for Firestore unavailable (mock db=None or crystals_collection=None)
# This requires modifying the fixture or test setup to simulate that condition.
# For example, a separate fixture that patches backend_server.crystals_collection to None.

def test_crud_operations_firestore_unavailable(test_client_firestore_unavailable: TestClient):
    crystal_id = str(uuid.uuid4())
    sample_data = create_sample_crystal_data(crystal_id)

    response = test_client_firestore_unavailable.post("/api/crystals", json=sample_data)
    assert response.status_code == 503
    assert "Firestore not available" in response.json()["detail"]

    response = test_client_firestore_unavailable.get(f"/api/crystals/{crystal_id}")
    assert response.status_code == 503

    response = test_client_firestore_unavailable.get("/api/crystals")
    assert response.status_code == 503

    response = test_client_firestore_unavailable.put(f"/api/crystals/{crystal_id}", json=sample_data)
    assert response.status_code == 503

    response = test_client_firestore_unavailable.delete(f"/api/crystals/{crystal_id}")
    assert response.status_code == 503

# Fixture to simulate Firestore being unavailable
@pytest.fixture
def test_client_firestore_unavailable(mocker, mock_firebase_admin): # mock_firebase_admin ensures other firebase mocks are up
    import backend_server
    from fastapi.testclient import TestClient

    # Temporarily mock crystals_collection to be None for this test client's scope
    mocker.patch.object(backend_server, 'crystals_collection', None)
    # Also mock db to be None if functions check db directly before crystals_collection
    mocker.patch.object(backend_server, 'db', None)

    with TestClient(backend_server.app) as client:
        yield client
    # Mocks are automatically undone after the test
