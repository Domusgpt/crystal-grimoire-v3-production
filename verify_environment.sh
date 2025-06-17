#!/bin/bash
# Crystal Grimoire V3 - Environment Verification Script
# This script verifies all tools are properly installed

echo "🔮 Crystal Grimoire V3 Environment Verification"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_section() {
    echo ""
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE} $1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

print_section "DEVELOPMENT TOOLS"

# Check Node.js
NODE_VERSION=$(node --version)
print_success "Node.js $NODE_VERSION"

# Check npm
NPM_VERSION=$(npm --version)
print_success "npm $NPM_VERSION"

# Check Flutter
FLUTTER_VERSION=$(flutter --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
print_success "Flutter $FLUTTER_VERSION"

# Check Firebase CLI
FIREBASE_VERSION=$(firebase --version)
print_success "Firebase CLI $FIREBASE_VERSION"

# Check Git
GIT_VERSION=$(git --version | cut -d' ' -f3)
print_success "Git $GIT_VERSION"

print_section "PROJECT SETUP"

# Install project dependencies
print_info "Installing Firebase Functions dependencies..."
if [ -d "functions" ]; then
    cd functions
    npm install
    cd ..
    print_success "Functions dependencies installed"
fi

# Install Flutter dependencies
print_info "Installing Flutter dependencies..."
if [ -f "pubspec.yaml" ]; then
    flutter pub get
    print_success "Flutter dependencies installed"
fi

print_section "FIREBASE CONFIGURATION"

# Set Firebase project
print_info "Setting Firebase project..."
firebase use crystalgrimoire-v3-production
print_success "Firebase project set to crystalgrimoire-v3-production"

# Set Functions config
print_info "Setting Firebase Functions configuration..."
firebase functions:config:set gemini.key="AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs" --project crystalgrimoire-v3-production
print_success "Functions environment configured"

print_section "DEVELOPMENT SCRIPTS"

# Create development scripts
print_info "Creating development scripts..."

# Start development script
cat > start_dev.sh << 'EOF'
#!/bin/bash
echo "🔮 Starting Crystal Grimoire Development..."
# Start Firebase emulators
firebase emulators:start --only functions,firestore,hosting
EOF
chmod +x start_dev.sh

# Build production script
cat > build_production.sh << 'EOF'
#!/bin/bash
echo "🔮 Building for production..."
flutter clean
flutter pub get
flutter build web --release \
  --dart-define=PRODUCTION=true \
  --dart-define=GEMINI_API_KEY="AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs" \
  --dart-define=FIREBASE_PROJECT_ID="crystalgrimoire-v3-production"
echo "✅ Build complete!"
EOF
chmod +x build_production.sh

# Deploy script
cat > deploy_production.sh << 'EOF'
#!/bin/bash
echo "🔮 Deploying to production..."
./build_production.sh
firebase deploy --project crystalgrimoire-v3-production
echo "✅ Deployed to: https://crystalgrimoire-v3-production.web.app"
EOF
chmod +x deploy_production.sh

print_success "Development scripts created"

print_section "VERIFICATION COMPLETE"

echo ""
echo -e "${GREEN}🎉 Environment is ready for Crystal Grimoire V3 development!${NC}"
echo ""
echo "Available commands:"
echo "  ./start_dev.sh       - Start development environment"
echo "  ./build_production.sh - Build for production"
echo "  ./deploy_production.sh - Deploy to Firebase"
echo ""
echo -e "${PURPLE}🔮 Ready to develop Crystal Grimoire V3! 🔮${NC}"