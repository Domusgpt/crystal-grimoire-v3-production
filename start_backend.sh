#!/bin/bash
# Start Crystal Grimoire V3 Backend with Firestore Emulator

cd "/mnt/c/Users/millz/Desktop/CrystalGrimoireV3"

echo "🔮 Starting Crystal Grimoire V3 Backend..."

# Set emulator environment
export FIRESTORE_EMULATOR_HOST=localhost:8082

# Start the backend
echo "🚀 Starting Enhanced Backend..."
node unified_backend_enhanced.js