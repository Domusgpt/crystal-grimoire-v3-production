# Build & Deployment Guide for Crystal Grimoire

This guide provides instructions for building the Flutter applications (Web and Android) and deploying the Node.js Firebase Functions backend API.

## Prerequisites

1.  **Flutter SDK**: Ensure Flutter SDK is installed and configured correctly. Run `flutter doctor` and resolve any critical issues.
2.  **Firebase CLI**: Ensure Firebase CLI is installed (`npm install -g firebase-tools`) and you are logged in (`firebase login`).
3.  **Google Cloud SDK (gcloud)**: Ensure gcloud CLI is installed and you are logged in (`gcloud auth login`), with the project set to `crystalgrimoire-production`.
4.  **Node.js & npm**: Required for Firebase Functions development and Firebase CLI. Node.js v20 is specified in `functions/package.json`.
5.  **API Keys & Configuration Files**:
    *   Obtain necessary API keys (Gemini, Firebase Web App keys, Stripe keys).
    *   For Android builds, ensure you have the `google-services.json` file from Firebase project settings and place it in `android/app/`.

## 1. Building the Flutter Application

The Flutter application uses `--dart-define` to pass API keys and configuration at build time. Replace placeholders like `YOUR_..._KEY` with actual values.

**IMPORTANT SECURITY NOTE on `STRIPE_SECRET_KEY`**: The Stripe secret key should **NEVER** be included in client-side application builds. The `--dart-define=STRIPE_SECRET_KEY=...` argument listed below is based on previous project configurations but is a **critical security risk**. All operations requiring the Stripe secret key must be handled by a secure backend API. Remove this dart-define from client builds and implement corresponding backend endpoints for Stripe actions.

### 1.1. Flutter Web App

Command:
```bash
flutter build web --release \
  --dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY_PLACEHOLDER" \
  --dart-define=FIREBASE_API_KEY="YOUR_FIREBASE_API_KEY_PLACEHOLDER" \
  --dart-define=FIREBASE_PROJECT_ID="crystalgrimoire-production" \
  --dart-define=FIREBASE_AUTH_DOMAIN="YOUR_FIREBASE_AUTH_DOMAIN_PLACEHOLDER" \
  --dart-define=FIREBASE_STORAGE_BUCKET="YOUR_FIREBASE_STORAGE_BUCKET_PLACEHOLDER" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="YOUR_FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER" \
  --dart-define=FIREBASE_APP_ID="YOUR_FIREBASE_APP_ID_PLACEHOLDER" \
  --dart-define=STRIPE_PUBLISHABLE_KEY="YOUR_STRIPE_PUBLISHABLE_KEY_PLACEHOLDER" \
  # --dart-define=STRIPE_SECRET_KEY="DO_NOT_USE_STRIPE_SECRET_KEY_IN_CLIENT_BUILDS" # Critical Security Risk
```
-   **Output**: `build/web/`

### 1.2. Flutter Android App (APK)

Command:
```bash
flutter build apk --release \
  --dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY_PLACEHOLDER" \
  --dart-define=FIREBASE_API_KEY="YOUR_FIREBASE_API_KEY_PLACEHOLDER" \
  --dart-define=FIREBASE_PROJECT_ID="crystalgrimoire-production" \
  --dart-define=FIREBASE_AUTH_DOMAIN="YOUR_FIREBASE_AUTH_DOMAIN_PLACEHOLDER" \
  --dart-define=FIREBASE_STORAGE_BUCKET="YOUR_FIREBASE_STORAGE_BUCKET_PLACEHOLDER" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="YOUR_FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER" \
  --dart-define=FIREBASE_APP_ID="YOUR_FIREBASE_APP_ID_PLACEHOLDER" \
  --dart-define=STRIPE_PUBLISHABLE_KEY="YOUR_STRIPE_PUBLISHABLE_KEY_PLACEHOLDER" \
  # --dart-define=STRIPE_SECRET_KEY="DO_NOT_USE_STRIPE_SECRET_KEY_IN_CLIENT_BUILDS" # Critical Security Risk
```
-   **Output**: `build/app/outputs/flutter-apk/app-release.apk`
-   To build an App Bundle instead, replace `apk` with `appbundle`. The output will be in `build/app/outputs/bundle/release/`.

## 2. Deploying the Node.js Firebase Functions API

The backend API is implemented as an Express app within a single Firebase Function defined in `functions/index.js`.

### 2.1. Set Environment Variables

Securely store API keys and other configuration needed by the backend functions. The primary key for the current API is the Gemini API key.
Run the following command (replace placeholder with actual key):
```bash
firebase functions:config:set gemini.key="YOUR_ACTUAL_GEMINI_API_KEY" --project crystalgrimoire-production
# Add other configurations if needed, e.g.:
# firebase functions:config:set stripe.secret_key="YOUR_STRIPE_SECRET_KEY_FOR_BACKEND_USE_ONLY" --project crystalgrimoire-production
```
-   Access these in `functions/index.js` using `functions.config().gemini.key`.

### 2.2. Deploy the API Function

This command deploys *only* the `api` function (the Express app) exported from `functions/index.js`. This is recommended to avoid deploying other potentially outdated or conflicting functions in other `.js` files within the `functions/` directory.
```bash
firebase deploy --only functions:api --project crystalgrimoire-production
```
-   Firebase CLI will automatically install dependencies from `functions/package.json` before deployment.
-   Ensure your Firebase project is configured to use the **Node.js 20** runtime for functions, as specified in `functions/package.json`.

### 2.3. Firestore Indexing

The Node.js API includes a query to list crystals by user ID (`user_integration.user_id`). This requires a composite index in Firestore on the `crystals` collection.
-   **Collection ID**: `crystals`
-   **Fields to Index**: `user_integration.user_id` (Ascending)
-   Create this index via the Firebase Console (Firestore Database > Indexes > Composite Indexes > Add Index) or by defining it in `firestore.indexes.json` and deploying with `firebase deploy --only firestore:indexes`. Without this index, queries filtering by `user_id` will fail or be very inefficient.

## 3. Deploying Flutter Web App to Firebase Hosting

After successfully building the Flutter web app (Step 1.1):
```bash
firebase deploy --only hosting --project crystalgrimoire-production
```
-   This command deploys the content of `build/web/` to Firebase Hosting.
-   The `firebase.json` file is already configured with `"public": "build/web"` and rewrite rules to direct `/api/**` requests to the `api` Firebase Function.

## 4. Backend URL for Flutter App Configuration

The Flutter application (`lib/config/backend_config.dart`) should be configured to use the following base URL for API requests when in production:
```
https://crystalgrimoire-production.web.app/api
```
-   Local development typically uses `http://localhost:8081/api` (if running the Node.js Express app locally via Firebase emulators or directly). The `BackendConfig.baseUrl` in Flutter already handles this distinction.

This guide should provide the necessary context for building and deploying the main components of the Crystal Grimoire application.
