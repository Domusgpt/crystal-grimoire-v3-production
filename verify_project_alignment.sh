#!/bin/bash

echo "🔮 CRYSTAL GRIMOIRE V3 - PROJECT ALIGNMENT VERIFICATION"
echo "========================================================="

# Check Firebase project configuration
echo "📋 Checking Firebase project configuration..."
echo ""

echo "1. .firebaserc default project:"
grep "default" .firebaserc

echo ""
echo "2. Firebase Functions runtime (should be nodejs20):"
grep "runtime" firebase.json

echo ""
echo "3. Functions package.json Node version (should be 20):"
grep "node" functions/package.json

echo ""
echo "4. Flutter firebase_options.dart project ID:"
grep "projectId:" lib/firebase_options.dart | head -1

echo ""
echo "5. Expected endpoints:"
echo "   Frontend: https://crystalgrimoire-v3-production.web.app"
echo "   Backend: https://us-central1-crystalgrimoire-v3-production.cloudfunctions.net"
echo ""

# Test current Firebase project
echo "🔥 Current Firebase project:"
firebase projects:list 2>/dev/null | grep crystalgrimoire || echo "Not logged in or project not found"

echo ""
echo "✅ VERIFICATION COMPLETE"
echo ""
echo "🚀 To deploy with correct alignment:"
echo "   1. firebase use crystalgrimoire-v3-production"
echo "   2. flutter build web --release"
echo "   3. firebase deploy --only functions,hosting"
echo ""
echo "🔮 All project variables should now align to crystalgrimoire-v3-production!"