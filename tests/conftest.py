import pytest
import asyncio
from unittest.mock import MagicMock, patch

# This fixture provides a new event loop for each test function.
# It's crucial for testing asyncio code with pytest.
@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for each test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture
def mock_firestore_client():
    """Fixture for a mocked Firestore client."""
    mock_client = MagicMock() # spec=firestore.Client can be added if firebase_admin.firestore is importable here

    # Mock typical document and collection structures and methods
    mock_doc_ref = MagicMock()
    mock_doc_ref.get.return_value = MagicMock(exists=False) # Default: doc doesn't exist
    mock_doc_ref.set.return_value = None
    mock_doc_ref.delete.return_value = None

    mock_collection_ref = MagicMock()
    mock_collection_ref.document.return_value = mock_doc_ref
    mock_collection_ref.stream.return_value = [] # Default: empty collection

    mock_client.collection.return_value = mock_collection_ref
    return mock_client

@pytest.fixture(autouse=True)
def mock_firebase_admin(mocker, mock_firestore_client):
    """Mocks firebase_admin initialization and firestore client globally for tests."""
    mocker.patch('firebase_admin.credentials.Certificate', return_value=MagicMock())
    mocker.patch('firebase_admin.initialize_app', return_value=MagicMock())
    mocker.patch('firebase_admin.firestore.client', return_value=mock_firestore_client)

    # This is tricky: backend_server.py likely initializes its 'db' and 'crystals_collection'
    # at import time. To ensure these use the mock_firestore_client, we might need to
    # either ensure this fixture runs before backend_server is imported by any test module,
    # or reload backend_server, or directly patch backend_server.db and backend_server.crystals_collection.

    # For now, we rely on autouse=True and hope imports happen after mock setup.
    # If direct patching is needed:
    # import backend_server
    # backend_server.db = mock_firestore_client
    # backend_server.crystals_collection = mock_firestore_client.collection('crystals') if mock_firestore_client else None


@pytest.fixture(scope="function") # Use function scope if app state changes per test
def test_client(mock_firebase_admin, mock_firestore_client): # Added mock_firestore_client for direct use
    """Fixture for the FastAPI TestClient."""
    import backend_server # Import here to use mocked firebase
    from fastapi.testclient import TestClient

    # Ensure module-level db and crystals_collection are using the mocked client
    # This is crucial if they were initialized at the original import time of backend_server
    backend_server.db = mock_firestore_client
    backend_server.crystals_collection = mock_firestore_client.collection('crystals') if mock_firestore_client else None
    # Also re-assign to app instance if the app itself holds a db reference (not typical for FastAPI modules)
    # if hasattr(backend_server.app, 'db'):
    # backend_server.app.db = mock_firestore_client

    with TestClient(backend_server.app) as client:
        yield client

# To allow 'from firebase_admin import firestore' in backend_server.py when testing:
# We might need to ensure that firebase_admin.firestore is a MagicMock that can provide a 'client' attribute.
# The mocker.patch in mock_firebase_admin for 'firebase_admin.firestore.client' handles the client() call.
# If 'firebase_admin.firestore' itself is accessed as a module, it might need to be mocked too.
# Example: mocker.patch('firebase_admin.firestore', return_value=MagicMock(client=mock_firestore_client))

# For 'from firebase_admin import credentials, firestore'
# mocker.patch('firebase_admin.credentials')
# mocker.patch('firebase_admin.firestore') -> this would make firestore.client() fail unless firestore mock has a client attr.
# The current patch 'firebase_admin.firestore.client' is more specific and usually better.

# Add a dummy firebase_admin module to sys.modules if firebase-admin is not actually installed in the test runner env
# This is more for local testing if you don't want to install firebase-admin.
# In a proper CI/test env, firebase-admin should be installed.
import sys
if 'firebase_admin' not in sys.modules:
    sys.modules['firebase_admin'] = MagicMock()
    sys.modules['firebase_admin.firestore'] = MagicMock()
    sys.modules['firebase_admin.credentials'] = MagicMock()

# Need to import firebase_admin here for the spec in mock_firestore_client to work if used
# However, this might cause issues with when it's mocked.
# For now, removing spec from mock_firestore_client's MagicMock to avoid import order issues.
# If firebase_admin is importable, spec=firestore.Client is good.
import firebase_admin # For type hinting if needed, but careful with mocks.
# from firebase_admin import firestore # For spec type

# The patch for 'firebase_admin.firestore.client' in mock_firebase_admin
# should cover most cases where backend_server.py calls firestore.client().
# The key is that this conftest.py is processed before test files import backend_server.
