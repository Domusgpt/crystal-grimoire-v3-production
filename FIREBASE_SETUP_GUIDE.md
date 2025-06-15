# 🔥 Firebase Setup Guide for Crystal Grimoire Backend & Frontend

This guide covers setting up Firebase for both the Crystal Grimoire Flutter application (frontend authentication) and the Python backend (`backend_server.py`).

## 1. Create a Firebase Project

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Click on "Add project" (or "Create a project").
3.  Enter a project name (e.g., "CrystalGrimoireDev" or "CrystalGrimoireProd").
4.  Accept the Firebase terms and click "Continue".
5.  Choose whether to enable Google Analytics (optional for initial setup, but recommended for production apps). Click "Continue".
6.  If Analytics is enabled, configure your Google Analytics account or create a new one.
7.  Click "Create project". Wait for the project to be provisioned.

## 2. Enable Firebase Services

Once your project is created, you need to enable the necessary Firebase services from the console menu (Build section):

### A. Firebase Authentication (for Frontend)

This service is used by the Flutter app for user sign-in.

1.  Go to **Authentication** → **Sign-in method**.
2.  Enable the following providers as needed:
    *   **Email/Password**:
        *   Enable the provider.
        *   [Optional] Enable Email link (passwordless sign-in).
    *   **Google**:
        *   Enable the provider.
        *   Set your Project support email.
        *   You will need to configure OAuth consent screen in Google Cloud Console later and ensure SHA-1 fingerprints are added for Android if you build a mobile app. For web, ensure your web app's client ID is configured.
    *   **Apple**:
        *   Enable the provider.
        *   Provide Service ID, Apple Team ID, Key ID, and Private Key (.p8 file). This requires setup in the Apple Developer portal.
3.  Go to **Authentication** → **Settings** → **Authorized domains**.
4.  Ensure the following domains are added (replace with your actual project IDs/domains if different):
    *   `localhost` (for local web development)
    *   `your-firebase-project-id.firebaseapp.com`
    *   `your-firebase-project-id.web.app`
    *   Any custom domains you plan to use.

*(The rest of the frontend-specific Auth setup like Google Cloud Console OAuth client IDs, iOS/Android Info.plist/gradle changes from the original guide are still relevant if building for mobile and web and should be consulted.)*

### B. Firestore Database (for Backend)

This NoSQL database will be used by the Python backend for data storage.

1.  Go to **Firestore Database** (under Build).
2.  Click "Create database".
3.  Choose a **Security rules** mode:
    *   **Start in production mode**: Recommended. Click "Next".
        ```
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            // Allow read/write access to data only for authenticated users
            match /{document=**} {
              allow read, write: if request.auth != null;
            }
            // Example: Restrict 'crystals' collection to be world-readable, but writable only by auth users
            // match /crystals/{crystalId} {
            //   allow read: if true;
            //   allow write: if request.auth != null;
            // }
          }
        }
        ```
        *Modify these rules based on your application's specific needs after initial setup.*
    *   **Start in test mode**: Allows open access for 30 days. **WARNING:** This is insecure for production. Use only for initial, isolated development.
        ```
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            match /{document=**} {
              allow read, write: if request.time < timestamp.date(YEAR, MONTH, DAY+30); // Expires in 30 days
            }
          }
        }
        ```
4.  Choose a **Cloud Firestore location** (e.g., `us-central`, `europe-west`). This cannot be changed later. Click "Enable".

### C. Firebase Storage (Optional - If used for images by backend/frontend)
If you plan to store images or other files:
1. Go to **Storage** (under Build).
2. Click "Get started".
3. Follow the prompts to set up security rules (e.g., allow authenticated users to read/write to their own paths). Example rules:
    ```
    rules_version = '2';
    service firebase.storage {
      match /b/{bucket}/o {
        // Allow users to read/write their own files in a 'user/{userId}/' path
        match /user/{userId}/{allPaths=**} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
        // Public read for general assets if needed (e.g. crystal_images/)
        // match /crystal_images/{allPaths=**} {
        //   allow read: if true;
        // }
      }
    }
    ```

## 3. Generate Firebase Service Account Key (for Python Backend)

The Python backend (`backend_server.py`) requires a service account key to interact with Firebase services (like Firestore) with admin privileges.

1.  In the Firebase Console, go to your project.
2.  Click on **Project settings** (the gear icon ⚙️ next to "Project Overview").
3.  Go to the **Service accounts** tab.
4.  Select "Python" under "Admin SDK configuration snippet".
5.  Click on the **"Generate new private key"** button.
6.  A warning will appear about secure storage of the key. Click **"Generate key"**.
7.  A JSON file will be downloaded to your computer. This file typically has a name like `your-project-name-firebase-adminsdk-xxxx-xxxxxxxxxx.json`.

## 4. Place the Service Account Key for the Backend

1.  **Rename the downloaded JSON file** to `firebase-service-account.json`.
2.  **Place this `firebase-service-account.json` file in the root directory of your Crystal Grimoire project.** This is where `backend_server.py` expects to find it when it runs `credentials.Certificate("firebase-service-account.json")`.

    ```
    CrystalGrimoireProject/
    ├── backend_server.py
    ├── firebase-service-account.json  <-- PLACE IT HERE
    ├── lib/
    ├── tests/
    ├── docs/
    ├── pubspec.yaml
    └── ...other files
    ```

3.  **IMPORTANT SECURITY NOTE:**
    *   **DO NOT commit `firebase-service-account.json` to your Git repository.** This file contains sensitive credentials that grant admin access to your Firebase project.
    *   Add `firebase-service-account.json` to your `.gitignore` file immediately:
        ```
        # .gitignore
        # ... other entries
        firebase-service-account.json
        ```
    *   For production deployments (e.g., on a server), you should securely provide this key to your backend environment, for example, by using environment variables to store the key content or by securely copying the file to the server.

## 5. Frontend Firebase Configuration (Flutter)

For your Flutter application, you'll typically use the Firebase CLI to configure your app for different platforms (web, Android, iOS).

1.  **Install Firebase CLI:** If you haven't already, [install the Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli).
2.  **Login to Firebase:** `firebase login`
3.  **Install FlutterFire CLI:** Ensure you have the FlutterFire CLI installed. If not, run:
    ```bash
    dart pub global activate flutterfire_cli
    ```
4.  **Configure FlutterFire:**
    *   In your Flutter project root (`CrystalGrimoireProject/`), run:
        ```bash
        flutterfire configure
        ```
    *   This command will guide you through selecting your Firebase project and registering your app for different platforms (web, android, ios). It will generate a `lib/firebase_options.dart` file.
    *   Ensure your `main.dart` initializes Firebase using these options:
        ```dart
        import 'package:firebase_core/firebase_core.dart';
        import 'firebase_options.dart'; // Generated by flutterfire

        void main() async {
          WidgetsFlutterBinding.ensureInitialized();
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          runApp(MyApp());
        }
        ```

This guide should provide a comprehensive starting point for setting up Firebase for both your backend and frontend. Remember to consult the official Firebase documentation for more detailed information on specific services.

---

## 6. Using Firebase Emulators for Local Development and Testing

Firebase Emulators allow you to run Firebase services locally on your machine. This is highly recommended for development and testing as it provides a safe, fast, and free environment without affecting your production Firebase data.

### A. Install Firebase CLI
If you haven't already, install the Firebase CLI:
```bash
curl -sL https://firebase.tools | bash
# OR npm install -g firebase-tools
```
Ensure you are logged in: `firebase login`

### B. Initialize Firebase Emulators in Your Project
1.  Navigate to your project root directory (`CrystalGrimoireProject/`).
2.  If you haven't initialized Firebase in your project for other purposes (like hosting), run:
    ```bash
    firebase init
    ```
    Select "Emulators" using the spacebar, then press Enter. You can also select other services like Firestore or Hosting if you plan to use them with Firebase CLI directly.
3.  If Firebase is already initialized, you can specifically set up emulators:
    ```bash
    firebase emulators:setup
    ```
4.  **Select Emulators:** Choose the emulators you want to use. For backend testing, you'll primarily need:
    *   **Firestore Emulator**
    *   (Optional) Authentication Emulator (if you want to test auth rules with the emulator)
    *   (Optional) Storage Emulator (if you use Firebase Storage)
5.  **Port Configuration:** The setup will ask for ports for each emulator. Defaults are usually fine (e.g., Firestore: `8080`, Auth: `9099`, Storage: `9199`). Note these down. The UI port (default `4000`) is also useful.
6.  **Download Emulators:** Confirm to download the emulator binaries.
7.  A `firebase.json` file will be created or updated in your project root with the emulator configuration. Example snippet for Firestore:
    ```json
    {
      "emulators": {
        "firestore": {
          "port": "8080"
        },
        "ui": {
          "enabled": true,
          "port": "4000"
        }
      }
    }
    ```

### C. Start the Emulators
1.  From your project root, run:
    ```bash
    firebase emulators:start --only firestore
    # Add other emulators if needed, e.g., --only firestore,auth
    ```
2.  The Firestore emulator will start, typically on `localhost:8080`. The Emulator Suite UI will be available at `localhost:4000`.
3.  Keep this terminal window running while you develop or run tests.

### D. Configure Backend (Python) to Use Firestore Emulator

To make `backend_server.py` (and your `pytest` tests) use the Firestore emulator, you need to set the `FIRESTORE_EMULATOR_HOST` environment variable **before** `firebase_admin.initialize_app()` is called.

*   **For running `backend_server.py` locally with the emulator:**
    ```bash
    export FIRESTORE_EMULATOR_HOST="localhost:8080"
    # Then run your backend, e.g., using ./scripts/run_backend.sh or manually
    # The run_backend.sh script might need modification to conditionally set this variable,
    # or you can set it in your shell before running the script.
    ./scripts/run_backend.sh
    ```
    Alternatively, you can modify `run_backend.sh` to check for an argument like `--emulator`.

*   **For running `pytest` integration tests against the emulator:**
    Set the environment variable in your terminal before running `pytest`:
    ```bash
    export FIRESTORE_EMULATOR_HOST="localhost:8080"
    # You might also want to use a specific Firebase Project ID for emulated tests,
    # although the emulator often works without one for basic operations.
    # export FIREBASE_PROJECT_ID="your-test-project-id"
    pytest tests/test_integration_firestore.py
    # (Or run all tests with pytest)
    ```
    If `firebase_admin.initialize_app()` is called without arguments when `FIRESTORE_EMULATOR_HOST` is set, the Admin SDK automatically connects to the emulator using a default project ID.
    If your code explicitly provides credentials (like `credentials.Certificate("firebase-service-account.json")`), the Admin SDK might prioritize that over the emulator host variable for some operations or require a specific project ID. For emulator testing, it's often best if `initialize_app()` is called without explicit credentials if the emulator environment variable is set, allowing it to use a default unauthenticated setup for the emulator.
    The current `backend_server.py` initializes with `credentials.Certificate(...)`. This can sometimes cause issues with the emulator if not handled carefully. One common approach for testing is to conditionally initialize the app:
    ```python
    # In backend_server.py (conceptual change for easier emulator testing)
    import os
    if os.getenv('FIRESTORE_EMULATOR_HOST'):
        # Emulator mode, no specific credentials needed for default project
        firebase_admin.initialize_app()
    else:
        # Production/staging mode with service account
        cred = credentials.Certificate("firebase-service-account.json")
        firebase_admin.initialize_app(cred)
    ```
    Without this change, ensure your tests or emulator environment correctly sets up a dummy project ID if needed, or that the service account doesn't interfere with emulator detection. Often, simply setting `FIRESTORE_EMULATOR_HOST` is enough for the Admin SDK to pick up the emulator.

### E. Clearing Emulator Data
*   The Emulator UI (default `localhost:4000`) has a "Firestore" tab where you can view and manually delete data.
*   To clear Firestore data via command line (when emulators are running):
    ```bash
    firebase emulators:clear firestore
    ```
*   Your integration tests (see `tests/test_integration_firestore.py`) should include setup/teardown logic to clear relevant data before/after tests or test runs.

By using the Firebase Emulators, you can develop and test your backend's Firebase interactions locally with greater speed and safety.

---
*(Original content regarding Google & Apple Sign-In specifics, iOS/Android setup for auth, and troubleshooting from the previous version of this file can be appended or referenced here if needed, as they are valuable for frontend auth setup.)*