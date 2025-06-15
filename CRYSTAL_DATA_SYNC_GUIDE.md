# Crystal Data Synchronization Guide

This guide explains the end-to-end flow for how crystal data, particularly user-specific collections, is synchronized between the frontend application, the FastAPI backend, and Firestore. It also details the necessary Firestore setup for efficient querying.

## End-to-End Data Flow for User Crystal Collections

1.  **Crystal Identification (Frontend & Backend):**
    *   The user captures an image of a crystal in the Flutter application.
    *   The app calls `BackendService.identifyCrystal()`, sending the image data (base64 encoded) and any textual user context to the `POST /api/crystal/identify` backend endpoint.
    *   The backend's `AIService` (e.g., `identify_crystal_with_gemini`) processes the image and context.
    *   The `map_ai_response_to_unified_data` function in `backend_server.py` transforms the AI's raw JSON output into a structured `UnifiedCrystalData` object. This object primarily populates the `crystal_core` (scientific details, AI-derived properties) and `automatic_enrichment` (healing properties, care instructions, etc.) sections. The `user_integration` part is typically minimal or empty at this stage.
    *   The backend returns this `UnifiedCrystalData` object to the frontend.

2.  **Saving Crystal to User's Collection (Frontend):**
    *   The user views the identified crystal details in the app.
    *   If the user decides to save the crystal to their personal collection, the frontend application takes the `UnifiedCrystalData` object received from the identification step.
    *   Crucially, the frontend (typically in `UnifiedDataService.addCrystal`) populates or updates the `user_integration` section of this `UnifiedCrystalData` object:
        *   `user_integration.user_id`: This field **must be set** to the currently authenticated user's ID (e.g., obtained from `BackendService.currentUserId` or a dedicated `AuthService`).
        *   Other fields like `user_integration.personal_notes`, `user_integration.rating`, `user_integration.added_to_collection` (timestamp) can also be set by the user via UI elements.
    *   The modified `UnifiedCrystalData` object (now including user-specific data) is then passed to `BackendService.saveCrystal()`.

3.  **Backend Saves Crystal to Collection (`POST /api/crystals`):**
    *   `BackendService.saveCrystal()` calls the `POST /api/crystals` endpoint on the FastAPI backend, sending the complete `UnifiedCrystalData` object in the request body.
    *   The backend's `create_crystal` function in `backend_server.py`:
        *   Receives the `UnifiedCrystalData`.
        *   **User ID Requirement:** It first checks if `crystal_data.user_integration.user_id` is present. If not, it returns a 422 Unprocessable Entity error, as a crystal saved to a "collection" must be associated with a user.
        *   **User ID Validation (Placeholder):** A comment in the code marks where full authentication and authorization logic will reside. When implemented, the backend will extract the `authenticated_user_id` from the auth token in the request headers. It will then compare this `authenticated_user_id` with the `user_id` provided in `crystal_data.user_integration.user_id`. If they do not match, it should raise an `HTTPException` (e.g., 403 Forbidden), preventing users from saving crystals to other users' collections.
        *   If validation passes, the backend uses `crystal_data.crystal_core.id` as the document ID and saves the entire `UnifiedCrystalData` object (as a JSON map) into the `crystals` collection in Firestore.

4.  **Fetching User's Crystal Collection (Frontend & Backend):**
    *   When the user views their collection, the Flutter app (via `UnifiedDataService` and then `BackendService.getUserCollection(userId: currentUserId)`) calls the `GET /api/crystals` backend endpoint, passing the authenticated user's ID as a `user_id` query parameter.
    *   The backend's `list_crystals` function receives this `user_id`.
    *   It queries the `crystals` collection in Firestore, filtering for documents where `user_integration.user_id` matches the provided `user_id`. This requires a Firestore index (see below).
    *   The backend returns a list of `UnifiedCrystalData` objects belonging to that user.

## Firestore Data Structure for `UnifiedCrystalData`

A document in the `crystals` collection in Firestore will generally have the following structure, based on the `UnifiedCrystalData` Pydantic model:

```json
// Document ID: value from crystal_core.id
{
  "crystal_core": {
    "id": "string (e.g., UUID, matches document ID)",
    "timestamp": "string (ISO datetime)",
    "confidence_score": "float",
    "visual_analysis": {
      "primary_color": "string",
      "secondary_colors": ["string"],
      "transparency": "string",
      "formation": "string",
      "size_estimate": "string (optional)"
    },
    "identification": {
      "stone_type": "string",
      "crystal_family": "string",
      "variety": "string (optional)",
      "confidence": "float"
    },
    "energy_mapping": {
      // ... fields ...
    },
    "astrological_data": {
      // ... fields ...
    },
    "numerology": {
      // ... fields ...
    }
  },
  "user_integration": { // This whole section can be null if not a user-owned crystal
    "user_id": "string (e.g., Firebase Auth UID)", // CRITICAL for user collections
    "added_to_collection": "string (ISO datetime, optional)",
    "personal_rating": "integer (optional)",
    "usage_frequency": "string (optional)",
    "user_experiences": ["string"],
    "intention_settings": ["string"]
  },
  "automatic_enrichment": { // This whole section can be null
    "crystal_bible_reference": "string (optional)",
    "healing_properties": ["string"],
    // ... other fields ...
    "mineral_class": "string (optional)"
  }
}
```

*   **Document ID:** The unique ID for a crystal instance is stored in `crystal_core.id` and is also used as the Firestore document ID within the `crystals` collection.
*   **User Association:** The `user_integration.user_id` field is the key link that associates a crystal document with a specific user's collection.

## Firestore Indexing for User Collections

To efficiently query the `crystals` collection for all crystals belonging to a specific user (as done by the `GET /api/crystals?user_id=xxx` endpoint), you **must** create a composite index in Firestore.

**Required Index:**

*   **Collection:** `crystals`
*   **Fields to Index:**
    1.  `user_integration.user_id` (Ascending)
    *   (Optional) You might add other fields for sorting within a user's collection, e.g., `user_integration.added_to_collection` (Descending) for recent items.
        *   `user_integration.user_id` (Ascending)
        *   `user_integration.added_to_collection` (Descending)

**How to Create the Index:**

1.  **Firebase Console:**
    *   Go to your Firebase project in the Firebase Console.
    *   Navigate to **Firestore Database** → **Indexes**.
    *   Click on **"Composite Indexes"** tab.
    *   Click **"Add Index"**.
    *   **Collection ID:** `crystals`
    *   **Fields to index:**
        *   Add field: `user_integration.user_id`, Order: Ascending.
        *   (Optional) Add another field: `user_integration.added_to_collection`, Order: Descending.
    *   Set the query scope as needed (usually "Collection").
    *   Click **"Create"**. The index will take some time to build.

2.  **`firestore.indexes.json` (for Firebase CLI deployment):**
    If you manage your Firebase project with the Firebase CLI, you can define indexes in a `firestore.indexes.json` file in your project root.

    ```json
    {
      "indexes": [
        {
          "collectionGroup": "crystals",
          "queryScope": "COLLECTION",
          "fields": [
            {
              "fieldPath": "user_integration.user_id",
              "order": "ASCENDING"
            }
            // Example for sorting by date added:
            // ,
            // {
            //   "fieldPath": "user_integration.added_to_collection",
            //   "order": "DESCENDING"
            // }
          ]
        }
        // Add other indexes here if needed
      ],
      "fieldOverrides": []
    }
    ```
    You would then deploy these indexes using `firebase deploy --only firestore:indexes`.

**Without this index, queries filtering by `user_integration.user_id` will fail or be very inefficient.**

## Summary

This synchronization mechanism ensures that identified crystals can be personalized and saved to a specific user's collection. The `user_integration.user_id` field is central to this, and proper backend validation (once auth is fully implemented) and Firestore indexing are crucial for security and performance.
