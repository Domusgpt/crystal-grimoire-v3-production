# 🔮 Crystal Grimoire Beta0.2 - Unified Metaphysical Experience Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
[![Stripe](https://img.shields.io/badge/Stripe-Integrated-green.svg)](https://stripe.com)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)

## ✨ Overview

Crystal Grimoire Beta0.2 is a **unified metaphysical experience platform** that seamlessly integrates:
- 💎 Crystal identification and collection management
- 🌙 Personalized astrology and horoscopes
- 🧘 Guided healing and meditation
- 📓 Spiritual journaling with mood tracking
- 🌟 Moon rituals and sacred practices
- 🤖 AI-powered personalized guidance
- 🛍️ Crystal marketplace with community features

Every feature interconnects through shared user data to create deeply personalized spiritual experiences.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/domusgpt/CrystalGrimoireBeta0.2.git
cd CrystalGrimoireBeta0.2

# Run the setup script
cd scripts && ./quick-start.sh

# Configure your API keys and Firebase settings
# See FIREBASE_SETUP_GUIDE.md and docs/API_KEYS_CONFIGURATION.md
# Create .env file in project root as per docs/API_KEYS_CONFIGURATION.md
# Place firebase-service-account.json in project root as per FIREBASE_SETUP_GUIDE.md

# Setup and run the Python backend (from project root)
./scripts/backend_setup.sh  # Run this once to set up Python environment
./scripts/run_backend.sh    # Run this to start the backend server

# Start the frontend (new terminal, from project root)
flutter run -d web-server --web-port 3000
# Or your preferred device: flutter run
```

## 🏗️ Architecture Overview

Crystal Grimoire uses a Flutter frontend and a Python (FastAPI) backend.

### Backend Architecture
- **Technology:** Python with FastAPI framework.
- **Server Logic:** `backend_server.py` located in the project root.
- **Database:** Firebase Firestore is used for data persistence. Communication is managed via the `firebase-admin` SDK.
  - **Service Account:** Requires `firebase-service-account.json` in the project root for admin access to Firebase services. See `FIREBASE_SETUP_GUIDE.md`.
- **API Key Management:** API keys for LLMs (Gemini, OpenAI, etc.) and other services are managed via environment variables, typically loaded from an `.env` file in the project root. See `docs/API_KEYS_CONFIGURATION.md`.
- **Data Synchronization:** Crystal data, including user-specific collections, is handled by the backend. See `CRYSTAL_DATA_SYNC_GUIDE.md` for details on data flow and Firestore indexing.

### Frontend Architecture
- **Technology:** Flutter.
- **Key Services:**
    - `BackendService` (`lib/services/backend_service.dart`): Handles all HTTP communication with the Python FastAPI backend. It uses an injected `http.Client` for testability.
    - `UnifiedDataService` (`lib/services/unified_data_service.dart`): Acts as a central service for managing application state, particularly for crystal data (which it sources from `BackendService`) and user profiles. It uses an injected `BackendService` instance.
- **Dependency Injection:** Core services like `BackendService` and `UnifiedDataService` are designed to use dependency injection for improved testability and modularity.

### Unified Data Models
- **UserProfile**: Central profile with birth chart and preferences
- **CrystalCollection**: Owned crystals with metadata and usage tracking
- **JournalEntry**: Mood tracking with astrological context
- **MoonRitualRecord**: Ritual practices linked to lunar cycles
- **HealingSessionLog**: Wellness tracking with crystal usage

### Feature Interconnections
```
🧑 User Profile ←→ 💎 Crystal Collection
    ↓                    ↓
🌙 Birth Chart      🧘 Healing Sessions
    ↓                    ↓
📅 Daily Horoscope  📓 Journal Entries
    ↓                    ↓
🤖 Personalized AI Guidance ← All Features Feed Into This
```

## 💳 Subscription Tiers

| Feature | Free | Premium ($9.99/mo) | Pro ($19.99/mo) | Founders ($199) |
|---------|------|-------------------|-----------------|-----------------|
| Daily Crystal IDs | 5 | 30 | Unlimited | Unlimited |
| Collection Size | 5 crystals | Unlimited | Unlimited | Unlimited |
| AI Model | Gemini | GPT-4 | Claude Opus | All Models |
| Marketplace | Browse only | Buy & Sell | Priority | Exclusive |
| Horoscopes | Daily | All types | Personalized | Deep Insights |
| Support | Community | Email | Priority | Direct |

## 🔧 Setup Requirements

This section provides a brief overview. For detailed instructions, please refer to the linked guides.

### 1. Firebase Project and Services Setup
- **Comprehensive Guide:** See [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)
- This guide covers:
    - Creating a Firebase project.
    - Enabling Authentication (Email/Password, Google, Apple) for the frontend.
    - Setting up Firestore Database and basic security rules for the backend.
    - Generating and placing the `firebase-service-account.json` key for the Python backend (must be in the project root).
    - Configuring FlutterFire for the frontend application.
- The `scripts/setup-firebase.sh` script may assist with some initial Firebase CLI configurations if available and up-to-date.

### 2. Stripe Configuration
- Create an account at [dashboard.stripe.com](https://dashboard.stripe.com).
- Add your subscription products and prices.
- Configure webhooks for payment events.
- For more details, see [docs/STRIPE_SETUP_GUIDE.md](docs/STRIPE_SETUP_GUIDE.md).

### 3. LLM and Other Backend API Keys
- The Python backend requires API keys for Large Language Models (LLMs) and potentially other services.
- **Comprehensive Guide:** See [docs/API_KEYS_CONFIGURATION.md](docs/API_KEYS_CONFIGURATION.md)
- This guide covers:
    - Which API keys are needed (e.g., `GEMINI_API_KEY`, `OPENAI_API_KEY`, `CLAUDE_API_KEY`, `PARSERATOR_API_KEY`).
    - How to obtain these keys.
    - How to set them up using an `.env` file in the project root for the Python backend.
- For specific LLM provider setup, you can also refer to [docs/LLM_API_SETUP_GUIDE.md](docs/LLM_API_SETUP_GUIDE.md).

### 4. Backend Environment Variables (`.env` file)
- The Python backend (`backend_server.py`) loads required API keys and configuration (like `PORT`, `ENVIRONMENT`) from an `.env` file located in the project root.
- Ensure this `.env` file is created by copying `.env.template` (if available and relevant for backend) or by following the template in [docs/API_KEYS_CONFIGURATION.md](docs/API_KEYS_CONFIGURATION.md).
- Example content for `.env`:
  ```env
  # LLM Keys
  GEMINI_API_KEY=your_gemini_key
  OPENAI_API_KEY=sk-your_openai_key
  # ... other keys as per docs/API_KEYS_CONFIGURATION.md

  # Backend settings
  PORT=8081
  ENVIRONMENT=development
  ```
- **Important:** Add your `.env` file and `firebase-service-account.json` to your `.gitignore` to prevent committing sensitive credentials.

### 5. Running the Python Backend Server
Once Firebase and API keys are configured:

1.  **Set up the Python environment (first time):**
    ```bash
    ./scripts/backend_setup.sh
    ```
    This script will:
    *   Check for Python 3.8+ and pip.
    *   Create a virtual environment named `.venv` in the project root.
    *   Install required Python dependencies from `requirements.txt`.
    *   Provide instructions to manually activate the virtual environment for subsequent sessions.

2.  **Run the backend server:**
    ```bash
    ./scripts/run_backend.sh
    ```
    This script will:
    *   Activate the `.venv` virtual environment.
    *   Start the FastAPI backend server using Uvicorn.
    *   Load environment variables from the `.env` file in the project root.
    *   Enable auto-reload, so changes to `backend_server.py` will restart the server.
    *   The server will typically be available at `http://localhost:8081` (or the `PORT` specified in your `.env` file).

    **Manual Activation (Alternative to `run_backend.sh` for subsequent runs):**
    If you prefer to run the server manually after the initial setup:
    ```bash
    # Activate the virtual environment (from project root)
    source .venv/bin/activate

    # Run uvicorn (from project root)
    uvicorn backend_server:app --reload --env-file .env

    # Deactivate when done
    deactivate
    ```

## 📱 Key Features

### 🔮 Crystal Identification
- AI-powered identification from photos
- Detailed metaphysical properties
- Chakra associations
- Personalized recommendations based on your zodiac

### 🌙 Astrology Integration
- Complete birth chart calculation
- Daily personalized horoscopes
- Crystal-zodiac compatibility
- Lunar cycle tracking

### 🧘 Healing & Meditation
- Guided crystal meditations
- Chakra balancing sessions
- Sound bath experiences
- Progress tracking

### 📓 Spiritual Journal
- Mood tracking with analysis
- Crystal usage logging
- Ritual documentation
- AI-powered insights

### 🛍️ Crystal Marketplace
- Buy/sell crystals
- Seller verification
- Secure payments via Stripe
- Community ratings

## 🛠️ Development

### Tech Stack
- **Frontend**: Flutter 3.10+ (Web)
- **Backend**: FastAPI (Python)
- **Database**: Firebase Firestore
- **Auth**: Firebase Authentication
- **Payments**: Stripe
- **AI**: OpenAI, Anthropic, Google
- **Hosting**: GitHub Pages + Cloud Run

### Project Structure
```
CrystalGrimoireBeta0.2/
├── lib/                    # Flutter app code
│   ├── models/            # Shared data models
│   ├── services/          # API and business logic
│   ├── screens/           # UI screens
│   └── widgets/           # Reusable components
# No separate backend/ directory for the main Python server code and requirements
├── backend_server.py      # Main Python FastAPI server
├── requirements.txt       # Python dependencies for the backend
├── tests/                 # Backend tests (pytest)
├── scripts/               # Setup, deployment, and utility scripts
├── docs/                  # Project documentation guides
└── web/                   # Web deployment files
```

### Running Tests
```bash
# Flutter tests
flutter test

# Backend tests (run from project root)
# Ensure FIRESTORE_EMULATOR_HOST is set for integration tests, see FIREBASE_SETUP_GUIDE.md
pytest tests/

# Integration tests (Flutter)
flutter drive --target=test_driver/app.dart
```
For detailed instructions on setting up the Firebase Emulator for backend integration testing, refer to the "Using Firebase Emulators" section in `FIREBASE_SETUP_GUIDE.md`.

## 🚀 Deployment

### Frontend (GitHub Pages)
```bash
flutter build web --release --base-href="/CrystalGrimoireBeta0.2/"
git add . && git commit -m "Deploy" && git push
```

### Backend (Cloud Run)
```bash
# Ensure you are in the project root directory
# (where backend_server.py, Dockerfile, etc. are located)
gcloud run deploy crystal-grimoire-api \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

## 📊 Monitoring & Analytics

- **Firebase Analytics**: User behavior tracking
- **Stripe Dashboard**: Revenue and subscription metrics
- **Cloud Logging**: Backend error monitoring
- **Performance Monitoring**: Load times and API latency

## 🤝 Contributing

This is a private repository. If you have access:

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request
5. Wait for review

## 📞 Support

- **Documentation**: See `/docs` folder
- **Issues**: GitHub Issues
- **Email**: support@crystalgrimoire.com
- **Discord**: [Join our community](#)

## 📜 License

Private and Proprietary. All rights reserved.

---

**🔮 Remember: This is a unified spiritual experience platform, not just an app. Every feature should enhance the user's metaphysical journey. ✨**


## Development Environment Setup

This project includes a script to help set up a consistent development environment. The script will attempt to install or guide you through installing necessary tools like:

*   Homebrew (macOS)
*   nvm (Node Version Manager) and Node.js (for Firebase Functions)
*   pyenv (Python Version Manager) and Python (if Python components are active)
*   Flutter SDK (checks installation)
*   Firebase CLI
*   Google Cloud CLI
*   GitHub CLI

It will also run `flutter pub get` and `npm install` for the `functions` directory.

**How to use the setup script:**

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd CrystalGrimoire-Production
    ```

2.  **Make the script executable (if not already):**
    Due to limitations in the automated environment that created this script, you might need to make it executable manually after pulling the changes:
    ```bash
    chmod +x scripts/setup_crystal_grimoire_env.sh
    ```

3.  **Run the script:**
    ```bash
    ./scripts/setup_crystal_grimoire_env.sh
    ```

4.  **Follow Prompts and Instructions:**
    The script will print information about what it's doing. You may be prompted for your password (for `sudo` commands if installing system packages like build dependencies on Linux) or to complete authentication steps for CLIs (Firebase, gcloud, gh) in your browser.

5.  **Restart Your Terminal:**
    After the script finishes, it's highly recommended to close and reopen your terminal window or source your shell's configuration file (e.g., `source ~/.zshrc` or `source ~/.bashrc`). This ensures that all PATH changes and new tool installations are correctly loaded into your environment.

6.  **Verify Installations:**
    You can verify the installations by checking the versions of the tools (e.g., `flutter --version`, `firebase --version`, `node --version`, `python --version`). Run `flutter doctor` to ensure your Flutter environment is healthy.

**Note on Python Setup:**
The Python environment setup (using `pyenv`) within the script is controlled by the `PYTHON_SETUP_ENABLED` variable at the top of the script. If you don't need Python for your work on this project, you can set it to `""` or comment it out before running the script.