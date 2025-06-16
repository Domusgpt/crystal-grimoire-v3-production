#!/bin/bash

# JULES ONE-COMMAND SETUP - CRYSTAL GRIMOIRE V3 PRODUCTION
# Run this single command to get everything working

echo "🔮 CRYSTAL GRIMOIRE V3 - ONE COMMAND SETUP FOR JULES 🔮"

# Install everything and deploy
curl -fsSL https://raw.githubusercontent.com/Domusgpt/crystal-grimoire-v3-production/main/JULES_COMPLETE_SETUP.sh | bash

# Quick deployment after setup
cd crystal-grimoire-v3-production

echo ""
echo "🚀 QUICK DEPLOYMENT COMMANDS FOR JULES:"
echo "======================================="
echo ""
echo "# 1. Login to Firebase:"
echo "firebase login"
echo ""
echo "# 2. Set project:"
echo "firebase use crystalgrimoire-v3-production"
echo ""
echo "# 3. Deploy backend:"
echo "firebase deploy --only functions"
echo ""
echo "# 4. Build and deploy frontend:"
echo "flutter build web --release"
echo "firebase deploy --only hosting"
echo ""
echo "✅ RESULTS:"
echo "Frontend: https://crystalgrimoire-production.web.app"
echo "Backend: https://us-central1-crystalgrimoire-v3-production.cloudfunctions.net/api/health"
echo ""
echo "🔮 Beautiful mystical UI + Professional backend ready!"