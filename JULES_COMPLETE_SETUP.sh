#!/bin/bash

# JULES COMPLETE SETUP SCRIPT FOR CRYSTAL GRIMOIRE V3 PRODUCTION
# This script sets up Flutter, Dart, Firebase, and Google Cloud for the project

echo "🔮 CRYSTAL GRIMOIRE V3 PRODUCTION - COMPLETE SETUP FOR JULES 🔮"
echo "============================================================"

# Step 1: Clone the repository and checkout shared-core branch
echo "📥 Step 1: Cloning repository and switching to shared-core branch..."
git clone https://github.com/Domusgpt/crystal-grimoire-v3-production.git
cd crystal-grimoire-v3-production
git checkout shared-core

# Step 2: Install Flutter (if not already installed)
echo "🎯 Step 2: Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable ~/flutter
    export PATH="$PATH:~/flutter/bin"
    echo 'export PATH="$PATH:~/flutter/bin"' >> ~/.bashrc
fi

# Step 3: Configure Flutter for web
echo "🌐 Step 3: Configuring Flutter for web..."
flutter channel stable
flutter upgrade
flutter config --enable-web
flutter doctor

# Step 4: Install project dependencies
echo "📦 Step 4: Installing Flutter/Dart dependencies..."
flutter pub get

# Step 5: Install Firebase CLI
echo "🔥 Step 5: Installing Firebase CLI..."
npm install -g firebase-tools

# Step 6: Install Firebase Functions dependencies
echo "⚡ Step 6: Installing Firebase Functions dependencies..."
cd functions
npm install
cd ..

# Step 7: Firebase configuration
echo "🔐 Step 7: Setting up Firebase configuration..."
cat > firebase_config.txt << 'EOF'
FIREBASE PROJECT CONFIGURATION:
==============================
Project ID: crystalgrimoire-v3-production
Project Name: crystalgrimoire-v3-production
Default GCP Resource Location: us-central1

Web App Configuration:
{
  apiKey: "AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c",
  authDomain: "crystalgrimoire-v3-production.firebaseapp.com",
  projectId: "crystalgrimoire-v3-production",
  storageBucket: "crystalgrimoire-v3-production.appspot.com",
  messagingSenderId: "1077070194300",
  appId: "1:1077070194300:web:eb4fc5b69fb9c51c96f5eb",
  measurementId: "G-B2QJY94ZQ9"
}

Service Account (for backend):
- Project: crystalgrimoire-v3-production
- Service Account Email: firebase-adminsdk-xxxxx@crystalgrimoire-v3-production.iam.gserviceaccount.com
EOF

# Step 8: Create environment variables file
echo "🔑 Step 8: Creating environment configuration..."
cat > .env << 'EOF'
# Firebase Configuration
FIREBASE_PROJECT_ID=crystalgrimoire-v3-production
FIREBASE_API_KEY=AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c
FIREBASE_AUTH_DOMAIN=crystalgrimoire-v3-production.firebaseapp.com
FIREBASE_STORAGE_BUCKET=crystalgrimoire-v3-production.appspot.com
FIREBASE_MESSAGING_SENDER_ID=1077070194300
FIREBASE_APP_ID=1:1077070194300:web:eb4fc5b69fb9c51c96f5eb

# API Keys (NEED TO BE ADDED)
GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE
OPENAI_API_KEY=YOUR_OPENAI_API_KEY_HERE
STRIPE_PUBLISHABLE_KEY=YOUR_STRIPE_PUB_KEY_HERE
STRIPE_SECRET_KEY=YOUR_STRIPE_SECRET_KEY_HERE

# Backend Configuration
BACKEND_URL=https://us-central1-crystalgrimoire-v3-production.cloudfunctions.net
NODE_ENV=production
EOF

# Step 9: Login to Firebase
echo "🔐 Step 9: Firebase authentication..."
echo "Please run: firebase login"
echo "After login, run: firebase use crystalgrimoire-v3-production"

# Step 10: Create deployment script
echo "🚀 Step 10: Creating deployment script..."
cat > deploy.sh << 'EOF'
#!/bin/bash
echo "🔮 Deploying Crystal Grimoire V3..."

# Build Flutter web app
echo "Building Flutter web app..."
flutter build web --release

# Deploy Firebase Functions
echo "Deploying Firebase Functions..."
firebase deploy --only functions

# Deploy to Firebase Hosting
echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "🌐 Frontend: https://crystalgrimoire-v3-production.web.app"
echo "🔥 Backend API: https://us-central1-crystalgrimoire-v3-production.cloudfunctions.net/api/health"
EOF

chmod +x deploy.sh

# Step 11: Create local development script
echo "💻 Step 11: Creating local development script..."
cat > run_local.sh << 'EOF'
#!/bin/bash
echo "🔮 Running Crystal Grimoire locally..."

# Start Firebase emulators in background
echo "Starting Firebase emulators..."
firebase emulators:start --only functions &
EMULATOR_PID=$!

# Wait for emulators to start
sleep 5

# Run Flutter web app
echo "Starting Flutter web app..."
flutter run -d chrome

# Clean up emulators on exit
trap "kill $EMULATOR_PID" EXIT
EOF

chmod +x run_local.sh

# Step 12: Final instructions
echo ""
echo "✅ SETUP COMPLETE! Next steps for Jules:"
echo "========================================"
echo ""
echo "1. Login to Firebase:"
echo "   firebase login"
echo ""
echo "2. Select the project:"
echo "   firebase use crystalgrimoire-v3-production"
echo ""
echo "3. Deploy everything:"
echo "   ./deploy.sh"
echo ""
echo "4. Or run locally:"
echo "   ./run_local.sh"
echo ""
echo "📁 Project Structure:"
echo "- /lib - Flutter/Dart frontend code"
echo "- /functions - Firebase Functions backend"
echo "- /web - Web assets"
echo ""
echo "🔑 IMPORTANT: Add these API keys to .env file:"
echo "- GEMINI_API_KEY (for crystal identification)"
echo "- STRIPE keys (for payments)"
echo ""
echo "🔮 Beautiful mystical UI is ready!"
echo "⚡ Professional backend with UnifiedCrystalData is ready!"
echo "🚀 Everything is configured for production deployment!"