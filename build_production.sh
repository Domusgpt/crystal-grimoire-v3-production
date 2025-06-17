#!/bin/bash
# Build for production deployment
echo "🔮 Building Crystal Grimoire for Production..."

# Clean previous builds
flutter clean
rm -rf build/

# Get dependencies
flutter pub get

# Build web app
flutter build web --release \
  --dart-define=PRODUCTION=true \
  --dart-define=GEMINI_API_KEY="AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs" \
  --dart-define=FIREBASE_PROJECT_ID="crystalgrimoire-v3-production"

echo "✅ Production build complete!"
echo "Ready to deploy with: firebase deploy"
