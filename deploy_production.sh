#!/bin/bash
# Deploy to production
echo "🔮 Deploying Crystal Grimoire to Production..."

# Build first
./build_production.sh

# Deploy to Firebase
firebase deploy --project crystalgrimoire-v3-production

echo "✅ Deployment complete!"
echo "🌐 Live at: https://crystalgrimoire-v3-production.web.app"
