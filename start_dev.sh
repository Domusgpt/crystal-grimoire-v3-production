#!/bin/bash
# Start development environment
echo "🔮 Starting Crystal Grimoire Development Environment..."

# Start Firebase emulators in background
firebase emulators:start --only functions,firestore,hosting &
FIREBASE_PID=$!

# Start Flutter web development server
flutter run -d chrome --web-port 3000 &
FLUTTER_PID=$!

echo "✅ Development servers started!"
echo "- Flutter Web: http://localhost:3000"
echo "- Firebase Emulators: http://localhost:4000"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for interrupt
trap "kill $FIREBASE_PID $FLUTTER_PID 2>/dev/null; exit" INT
wait
