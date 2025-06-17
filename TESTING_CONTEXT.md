# Testing Context Guide for Crystal Grimoire

This guide provides context for testing the Crystal Grimoire application, focusing on the integration between the Flutter client (Web and Android) and the Node.js Firebase Functions backend API.

## 1. Overall Testing Goal

The primary goal is to ensure the Flutter application correctly interacts with the deployed Node.js Firebase Functions API for all crystal-related features, using the `UnifiedCrystalData` model consistently. This includes verifying data flow, UI updates, error handling, and core user scenarios.

## 2. Key Backend API Endpoints (Node.js Firebase Functions)

The Flutter application will interact with the following API endpoints, hosted at `https://crystalgrimoire-production.web.app/api/`:

-   **`GET /health`**: Checks the health of the API.
-   **`POST /crystal/identify`**: For identifying crystals from an image and user context. Expects image data, returns `UnifiedCrystalData`.
-   **`POST /crystals`**: Creates a new crystal entry in the user's collection. Expects `UnifiedCrystalData` (with `user_integration.user_id` populated), returns the created `UnifiedCrystalData`.
-   **`GET /crystals`**: Lists crystals. Can be filtered by `?user_id=<ID>` to get a specific user's collection. Returns an array of `UnifiedCrystalData`.
-   **`GET /crystals/:crystalId`**: Fetches a single crystal by its ID. Returns `UnifiedCrystalData`.
-   **`PUT /crystals/:crystalId`**: Updates an existing crystal. Expects full `UnifiedCrystalData`, returns the updated `UnifiedCrystalData`.
-   **`DELETE /crystals/:crystalId`**: Deletes a crystal from the collection.

## 3. Key End-to-End Test Flows

Refer to the detailed end-to-end test plans previously outlined. A summary includes:

### 3.1. User Authentication
-   **Verify**: Users can log in (e.g., using Firebase Authentication client-side).
-   **Context**: While the Node.js API doesn't handle login/registration directly, it expects `user_integration.user_id` (which should be the Firebase Auth UID) for operations like saving crystals or fetching a user's collection. Ensure this ID is correctly passed from the client.

### 3.2. Crystal Identification
-   **Action**: Use the Flutter app's UI to upload an image of a crystal and submit it for identification.
-   **Verify**:
    -   A `POST` request is successfully made to `/api/crystal/identify`.
    -   The app receives a valid `UnifiedCrystalData` object from the backend.
    -   The UI correctly displays all relevant information from `UnifiedCrystalData` (name, family, colors, chakras, healing properties, care instructions, etc.).
    -   Error states (e.g., invalid image, AI error) are handled gracefully.

### 3.3. Crystal Collection Management
-   **Saving Crystal**:
    -   After identification, save the crystal to the user's collection.
    -   Verify a `POST` request to `/api/crystals` is made with the correct `UnifiedCrystalData` payload (including `user_integration.user_id`).
    -   Confirm data is saved in Firestore and the UI updates.
-   **Viewing Collection**:
    -   Navigate to the collection screen.
    -   Verify a `GET` request to `/api/crystals?user_id=<UID>` is made.
    -   The UI correctly displays the list of crystals using data from `UnifiedCrystalData`.
-   **Viewing Crystal Details**:
    -   Select a crystal from the collection.
    *   Verify its details (from `UnifiedCrystalData`) are displayed correctly on the detail screen.
-   **Updating Crystal** (if UI for editing exists, e.g., for notes within `UserIntegration`):
    *   Edit a crystal's information.
    *   Verify a `PUT` request to `/api/crystals/:crystalId` is made with the updated `UnifiedCrystalData`.
    *   Confirm data is updated in Firestore and UI.
-   **Deleting Crystal** (if UI for deleting exists):
    *   Delete a crystal from the collection.
    *   Verify a `DELETE` request to `/api/crystals/:crystalId` is made.
    *   Confirm data is deleted from Firestore and UI.

## 4. Data Model Focus
-   Throughout all tests, pay close attention to the structure and content of `UnifiedCrystalData` objects being sent to and received from the backend.
-   Ensure all relevant fields are populated and displayed correctly in the UI.
-   Verify that derived data in `UnifiedCrystalData` (numerology, chakra mapping, mineral class from the backend's `dataMapper.js`) is accurate.

## 5. Critical Areas for Testing
-   **Flutter Client Refactoring**: The client has undergone significant model and service layer refactoring. Test thoroughly for any regressions or new bugs introduced, especially around data handling and display.
-   **New Node.js Backend**: This is a new backend implementation. Test all its endpoints for correctness, error handling, and performance under typical load.
-   **Firestore Interaction**: Ensure data is being written to and read from Firestore correctly by the Node.js functions, including correct document IDs (`crystal_core.id`) and user ID filtering.
-   **Error Handling**: Test how the Flutter app responds to various backend errors (4xx, 5xx status codes, network issues).

## 6. Test Accounts / Data
-   **Initial State**: After deploying the Node.js backend fresh, the `crystals` collection in Firestore will likely be empty.
-   **Test User**: `phillips.paul.email@gmail.com` has been mentioned previously. If this user logs in, they will initially have an empty crystal collection with this new backend. Test adding crystals to this account.
-   Consider testing with multiple user accounts to ensure data isolation.

## 7. Important Security Note
-   **Stripe Secret Key**: Re-confirm that the Flutter client build process **DOES NOT** include the `STRIPE_SECRET_KEY` via dart-defines. All Stripe operations requiring a secret key must be handled by a secure backend API. If such functionality is needed, it would require adding new secure endpoints to the Node.js Firebase Functions API.

This guide should help focus the testing efforts on the most critical aspects of the application.
