#!/bin/bash
# Firestore Setup Completion Commands

echo "🔮 Firestore Setup Completion Script"

# Step 1: Deploy Firestore rules and indexes
echo "📋 Deploying Firestore rules and indexes..."
firebase deploy --only firestore

# Step 2: Check extension status
echo "🔍 Checking extension status..."
firebase ext:list

# Step 3: If extensions still errored, redeploy them
echo "🔄 Redeploying extensions if needed..."
firebase deploy --only extensions

# Step 4: Test Firestore connection
echo "🧪 Testing Firestore connection..."
firebase firestore:indexes:list

# Step 5: Create test collection for Crystal AI
echo "🔮 Creating test data for Crystallis Codexicus..."
cat > test_crystal_data.json << EOF
{
  "userId": "test123",
  "imageUrl": "gs://crystalgrimoire-v3-production.appspot.com/test/amethyst.jpg",
  "userQuery": "What is this beautiful crystal?",
  "subscriptionTier": "pro",
  "timestamp": "2025-06-06T19:30:00Z",
  "status": "pending"
}
EOF

# Step 6: Deploy your custom Cloud Functions
echo "☁️ Deploying custom Cloud Functions..."
firebase deploy --only functions

echo "✅ Firestore setup complete!"
echo "🎯 Next: Test Crystallis Codexicus AI responses"