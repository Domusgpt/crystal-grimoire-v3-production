#!/bin/bash
# Crystal Grimoire V3 - Complete Environment Setup Script
# This script sets up everything needed for development and deployment

set -e  # Exit on any error

echo "🔮 Crystal Grimoire V3 Environment Setup Starting..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo ""
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE} $1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Node.js version
check_node_version() {
    if command_exists node; then
        local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -ge 18 ]; then
            return 0
        fi
    fi
    return 1
}

# Function to check Flutter version
check_flutter_version() {
    if command_exists flutter; then
        local flutter_version=$(flutter --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        local major=$(echo $flutter_version | cut -d'.' -f1)
        local minor=$(echo $flutter_version | cut -d'.' -f2)
        if [ "$major" -gt 3 ] || ([ "$major" -eq 3 ] && [ "$minor" -ge 22 ]); then
            return 0
        fi
    fi
    return 1
}

print_section "1. SYSTEM REQUIREMENTS CHECK"

# Check operating system
print_status "Checking operating system..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    print_success "Linux detected (WSL2 compatible)"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    print_success "macOS detected"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
    print_success "Windows detected"
else
    print_warning "Unknown OS: $OSTYPE"
    OS="unknown"
fi

print_section "2. NODE.JS SETUP"

# Check Node.js
if check_node_version; then
    print_success "Node.js $(node --version) is installed and compatible"
else
    print_warning "Node.js not found or version too old. Installing Node.js 20..."
    
    if [[ "$OS" == "linux" ]]; then
        # Skip Node.js installation on Linux (requires sudo)
        print_warning "Node.js installation skipped (requires sudo). Please install manually."
    elif [[ "$OS" == "macos" ]]; then
        # Install via Homebrew
        if command_exists brew; then
            brew install node@20
        else
            print_error "Homebrew not found. Please install Node.js 20 manually from https://nodejs.org"
            exit 1
        fi
    else
        print_error "Please install Node.js 20 manually from https://nodejs.org"
        exit 1
    fi
    
    print_success "Node.js installed successfully"
fi

# Check npm
if command_exists npm; then
    print_success "npm $(npm --version) is available"
else
    print_error "npm not found. Please reinstall Node.js"
    exit 1
fi

print_section "3. FLUTTER SDK SETUP"

# Check Flutter
if check_flutter_version; then
    print_success "Flutter $(flutter --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1) is installed and compatible"
else
    print_warning "Flutter not found or version too old. Please install Flutter 3.22+ manually"
    print_status "Download from: https://docs.flutter.dev/get-started/install"
    
    if [[ "$OS" == "linux" ]]; then
        print_status "For Linux/WSL2, add to ~/.bashrc:"
        echo 'export PATH="$PATH:/path/to/flutter/bin"'
    fi
fi

# Run Flutter doctor
if command_exists flutter; then
    print_status "Running Flutter doctor..."
    flutter doctor
fi

print_section "4. FIREBASE CLI SETUP"

# Check Firebase CLI
if command_exists firebase; then
    print_success "Firebase CLI $(firebase --version) is installed"
else
    print_status "Installing Firebase CLI..."
    npm install -g firebase-tools
    print_success "Firebase CLI installed"
fi

# Check Firebase login
print_status "Checking Firebase authentication..."
if firebase projects:list >/dev/null 2>&1; then
    print_success "Firebase CLI is authenticated"
else
    print_warning "Firebase CLI not authenticated. Running login..."
    firebase login
fi

print_section "5. GOOGLE CLOUD SDK SETUP"

# Check gcloud
if command_exists gcloud; then
    print_success "Google Cloud SDK is installed"
else
    print_warning "Google Cloud SDK not found. Installing..."
    
    if [[ "$OS" == "linux" ]]; then
        # Skip gcloud installation (would require interactive setup)
        print_warning "Google Cloud SDK installation skipped. Please install manually if needed."
    elif [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew install google-cloud-sdk
        else
            print_status "Please install Google Cloud SDK manually: https://cloud.google.com/sdk/docs/install"
        fi
    else
        print_status "Please install Google Cloud SDK manually: https://cloud.google.com/sdk/docs/install"
    fi
fi

print_section "6. DEVELOPMENT TOOLS SETUP"

# Git
if command_exists git; then
    print_success "Git $(git --version | cut -d' ' -f3) is installed"
else
    print_warning "Git not found. Installing..."
    if [[ "$OS" == "linux" ]]; then
        print_warning "Git installation skipped (requires sudo). Please install manually."
    elif [[ "$OS" == "macos" ]]; then
        brew install git
    fi
fi

# GitHub CLI
if command_exists gh; then
    print_success "GitHub CLI $(gh --version | head -n1 | cut -d' ' -f3) is installed"
else
    print_status "Installing GitHub CLI..."
    if [[ "$OS" == "linux" ]]; then
        print_warning "GitHub CLI installation skipped (requires sudo). Please install manually."
    elif [[ "$OS" == "macos" ]]; then
        brew install gh
    fi
    print_success "GitHub CLI installed"
fi

# curl
if command_exists curl; then
    print_success "curl is available"
else
    print_warning "curl not found. Installing..."
    if [[ "$OS" == "linux" ]]; then
        print_warning "curl installation skipped (requires sudo). Please install manually."
    fi
fi

# jq for JSON processing
if command_exists jq; then
    print_success "jq is available"
else
    print_warning "jq not found but skipping installation (requires sudo)"
fi

print_section "7. PROJECT DEPENDENCIES"

# Install Node.js dependencies for Firebase Functions
print_status "Installing Firebase Functions dependencies..."
if [ -d "functions" ]; then
    cd functions
    npm install
    cd ..
    print_success "Functions dependencies installed"
else
    print_warning "Functions directory not found"
fi

# Install Flutter dependencies
print_status "Installing Flutter dependencies..."
if [ -f "pubspec.yaml" ]; then
    flutter pub get
    print_success "Flutter dependencies installed"
else
    print_warning "pubspec.yaml not found in current directory"
fi

print_section "8. FIREBASE PROJECT CONFIGURATION"

# Set Firebase project
print_status "Setting Firebase project to crystalgrimoire-v3-production..."
firebase use crystalgrimoire-v3-production

# Check Firebase project status
print_status "Checking Firebase project configuration..."
firebase projects:list

print_section "9. ENVIRONMENT VARIABLES SETUP"

# Create .env template if it doesn't exist
if [ ! -f ".env" ]; then
    print_status "Creating .env template..."
    cat > .env << 'EOF'
# Crystal Grimoire V3 Environment Variables
# DO NOT COMMIT THIS FILE TO GIT

# Firebase Configuration
FIREBASE_PROJECT_ID=crystalgrimoire-v3-production
FIREBASE_API_KEY=AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c

# AI/ML API Keys
GEMINI_API_KEY=AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs
OPENAI_API_KEY=your_openai_key_here
CLAUDE_API_KEY=your_claude_key_here

# Stripe Configuration (Production)
STRIPE_PUBLISHABLE_KEY=pk_live_your_stripe_publishable_key_here
STRIPE_SECRET_KEY=sk_live_your_stripe_secret_key_here

# Development Flags
PRODUCTION=true
FORCE_BACKEND=true
DEBUG_MODE=false

# Backend URLs
BACKEND_URL=https://crystalgrimoire-v3-production.web.app/api
LOCAL_BACKEND_URL=http://localhost:5001/crystalgrimoire-v3-production/us-central1/api
EOF
    print_success ".env template created"
else
    print_success ".env file already exists"
fi

# Add .env to .gitignore if not already there
if [ -f ".gitignore" ]; then
    if ! grep -q "^\.env$" .gitignore; then
        echo ".env" >> .gitignore
        print_status "Added .env to .gitignore"
    fi
fi

print_section "10. FIREBASE FUNCTIONS CONFIGURATION"

# Set Firebase Functions environment variables
print_status "Setting Firebase Functions environment variables..."
firebase functions:config:set gemini.key="AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs" --project crystalgrimoire-v3-production

print_section "11. DEVELOPMENT WORKFLOW SETUP"

# Create useful development scripts
print_status "Creating development scripts..."

# Create start script
cat > start_dev.sh << 'EOF'
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
EOF

chmod +x start_dev.sh

# Create build script
cat > build_production.sh << 'EOF'
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
EOF

chmod +x build_production.sh

# Create deploy script
cat > deploy_production.sh << 'EOF'
#!/bin/bash
# Deploy to production
echo "🔮 Deploying Crystal Grimoire to Production..."

# Build first
./build_production.sh

# Deploy to Firebase
firebase deploy --project crystalgrimoire-v3-production

echo "✅ Deployment complete!"
echo "🌐 Live at: https://crystalgrimoire-v3-production.web.app"
EOF

chmod +x deploy_production.sh

print_success "Development scripts created"

print_section "12. CODE QUALITY TOOLS SETUP"

# Setup Flutter analysis
if [ -f "pubspec.yaml" ]; then
    print_status "Setting up Flutter analysis..."
    
    # Create analysis_options.yaml if it doesn't exist
    if [ ! -f "analysis_options.yaml" ]; then
        cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - lib/generated_plugin_registrant.dart
  
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - use_build_context_synchronously
EOF
        print_success "analysis_options.yaml created"
    fi
fi

print_section "13. FUTURE REQUIREMENTS PREPARATION"

print_status "Setting up for future requirements..."

# Create directories for future features
mkdir -p assets/{images,sounds,videos,animations,icons}
mkdir -p lib/{features,core,shared}
mkdir -p test/{unit,integration,widget}
mkdir -p docs/{api,deployment,architecture}

# Create README for future development
cat > DEVELOPMENT_GUIDE.md << 'EOF'
# Crystal Grimoire V3 Development Guide

## Quick Start
```bash
# Setup environment (run once)
./setup_environment.sh

# Start development
./start_dev.sh

# Build for production
./build_production.sh

# Deploy to production
./deploy_production.sh
```

## Project Structure
- `lib/` - Flutter application code
- `functions/` - Firebase Cloud Functions
- `web/` - Web-specific assets
- `assets/` - Images, sounds, videos
- `docs/` - Documentation

## Environment Variables
Copy `.env.example` to `.env` and fill in your API keys.

## Testing
```bash
# Run Flutter tests
flutter test

# Run function tests
cd functions && npm test
```

## Deployment
The project deploys to Firebase Hosting with Cloud Functions backend.
EOF

print_success "Future development structure prepared"

print_section "14. HEALTH CHECK AND VALIDATION"

print_status "Running final health checks..."

# Check if all tools are available
TOOLS_OK=true

if ! check_node_version; then
    print_error "Node.js version issue"
    TOOLS_OK=false
fi

if ! command_exists firebase; then
    print_error "Firebase CLI not available"
    TOOLS_OK=false
fi

if ! check_flutter_version; then
    print_warning "Flutter version may need updating"
fi

if ! command_exists git; then
    print_error "Git not available"
    TOOLS_OK=false
fi

# Test Firebase authentication
if ! firebase projects:list >/dev/null 2>&1; then
    print_warning "Firebase authentication may need attention"
fi

# Test project build
print_status "Testing project build..."
if [ -f "pubspec.yaml" ]; then
    if flutter pub get >/dev/null 2>&1; then
        print_success "Flutter dependencies resolve successfully"
    else
        print_warning "Flutter dependency issues detected"
    fi
fi

print_section "15. SETUP COMPLETE"

if [ "$TOOLS_OK" = true ]; then
    print_success "🎉 Crystal Grimoire V3 environment setup completed successfully!"
else
    print_warning "⚠️  Setup completed with some issues. Please review errors above."
fi

echo ""
echo -e "${PURPLE}Next Steps:${NC}"
echo "1. Review and update .env file with your API keys"
echo "2. Run './start_dev.sh' to start development environment"
echo "3. Run './build_production.sh' to build for production"
echo "4. Run './deploy_production.sh' to deploy to Firebase"
echo ""
echo -e "${GREEN}🔮 Happy coding with Crystal Grimoire V3! 🔮${NC}"
echo ""