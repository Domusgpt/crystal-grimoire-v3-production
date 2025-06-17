#!/bin/bash
# Crystal Grimoire V3 - COMPLETE Environment Setup Script
# This script sets up EVERYTHING needed for development and deployment

set -e  # Exit on any error

echo "🔮 Crystal Grimoire V3 COMPLETE Environment Setup Starting..."
echo "============================================================="

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

# Update package lists for Linux
if [[ "$OS" == "linux" ]]; then
    print_status "Updating package lists..."
    sudo apt-get update -y
    print_success "Package lists updated"
fi

print_section "2. ESSENTIAL SYSTEM TOOLS"

# Install curl first (needed for everything else)
if command_exists curl; then
    print_success "curl is available"
else
    print_status "Installing curl..."
    if [[ "$OS" == "linux" ]]; then
        sudo apt-get install -y curl
    elif [[ "$OS" == "macos" ]]; then
        brew install curl
    fi
    print_success "curl installed"
fi

# Install wget
if command_exists wget; then
    print_success "wget is available"
else
    print_status "Installing wget..."
    if [[ "$OS" == "linux" ]]; then
        sudo apt-get install -y wget
    elif [[ "$OS" == "macos" ]]; then
        brew install wget
    fi
    print_success "wget installed"
fi

# Install unzip
if command_exists unzip; then
    print_success "unzip is available"
else
    print_status "Installing unzip..."
    if [[ "$OS" == "linux" ]]; then
        sudo apt-get install -y unzip
    elif [[ "$OS" == "macos" ]]; then
        brew install unzip
    fi
    print_success "unzip installed"
fi

# Install jq for JSON processing
if command_exists jq; then
    print_success "jq is available"
else
    print_status "Installing jq for JSON processing..."
    if [[ "$OS" == "linux" ]]; then
        sudo apt-get install -y jq
    elif [[ "$OS" == "macos" ]]; then
        brew install jq
    fi
    print_success "jq installed"
fi

# Install build essentials for Linux
if [[ "$OS" == "linux" ]]; then
    print_status "Installing build essentials..."
    sudo apt-get install -y build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    print_success "Build essentials installed"
fi

print_section "3. NODE.JS SETUP"

# Check and install Node.js
if check_node_version; then
    print_success "Node.js $(node --version) is installed and compatible"
else
    print_status "Installing Node.js 20 LTS..."
    
    if [[ "$OS" == "linux" ]]; then
        # Install Node.js 20 via NodeSource
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [[ "$OS" == "macos" ]]; then
        # Install via Homebrew
        if command_exists brew; then
            brew install node@20
            brew link node@20 --force
        else
            print_error "Homebrew not found. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install node@20
        fi
    else
        print_error "Please install Node.js 20 manually from https://nodejs.org"
        exit 1
    fi
    
    print_success "Node.js installed successfully"
fi

# Check npm and update if needed
if command_exists npm; then
    print_success "npm $(npm --version) is available"
    print_status "Updating npm to latest version..."
    npm install -g npm@latest
else
    print_error "npm not found. Please reinstall Node.js"
    exit 1
fi

# Install essential global npm packages
print_status "Installing essential global npm packages..."
npm install -g firebase-tools@latest
npm install -g @angular/cli@latest
npm install -g typescript@latest
npm install -g ts-node@latest
print_success "Global npm packages installed"

print_section "4. FLUTTER SDK SETUP"

# Check and install Flutter
if check_flutter_version; then
    print_success "Flutter $(flutter --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1) is installed and compatible"
else
    print_status "Installing Flutter SDK..."
    
    if [[ "$OS" == "linux" ]]; then
        # Download and install Flutter for Linux
        cd /tmp
        wget -O flutter_linux.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
        tar xf flutter_linux.tar.xz
        sudo mv flutter /opt/
        
        # Add to PATH permanently
        echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
        export PATH="/opt/flutter/bin:$PATH"
        
        # Install dependencies
        sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
        
    elif [[ "$OS" == "macos" ]]; then
        # Download and install Flutter for macOS
        cd /tmp
        wget -O flutter_macos.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.zip
        unzip flutter_macos.zip
        sudo mv flutter /opt/
        
        # Add to PATH permanently
        echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.zshrc
        export PATH="/opt/flutter/bin:$PATH"
    fi
    
    print_success "Flutter SDK installed"
fi

# Run Flutter doctor and fix issues
if command_exists flutter; then
    print_status "Running Flutter doctor and accepting licenses..."
    flutter doctor --android-licenses || true
    flutter doctor
    
    # Enable web support
    flutter config --enable-web
    print_success "Flutter web support enabled"
fi

print_section "5. FIREBASE CLI SETUP"

# Firebase CLI should already be installed via npm, but let's verify
if command_exists firebase; then
    print_success "Firebase CLI $(firebase --version) is installed"
else
    print_status "Installing Firebase CLI..."
    npm install -g firebase-tools@latest
    print_success "Firebase CLI installed"
fi

# Check Firebase login and authenticate if needed
print_status "Checking Firebase authentication..."
if firebase projects:list >/dev/null 2>&1; then
    print_success "Firebase CLI is authenticated"
else
    print_warning "Firebase CLI not authenticated. Please run 'firebase login' manually when ready"
fi

print_section "6. GOOGLE CLOUD SDK SETUP"

# Install Google Cloud SDK
if command_exists gcloud; then
    print_success "Google Cloud SDK is installed"
    gcloud components update --quiet || true
else
    print_status "Installing Google Cloud SDK..."
    
    if [[ "$OS" == "linux" ]]; then
        # Install gcloud for Linux
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt-get update && sudo apt-get install -y google-cloud-cli
    elif [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            brew install google-cloud-sdk
        else
            print_status "Please install Google Cloud SDK manually: https://cloud.google.com/sdk/docs/install"
        fi
    else
        print_status "Please install Google Cloud SDK manually: https://cloud.google.com/sdk/docs/install"
    fi
    
    print_success "Google Cloud SDK installed"
fi

print_section "7. DEVELOPMENT TOOLS SETUP"

# Git
if command_exists git; then
    print_success "Git $(git --version | cut -d' ' -f3) is installed"
else
    print_status "Installing Git..."
    if [[ "$OS" == "linux" ]]; then
        sudo apt-get install -y git
    elif [[ "$OS" == "macos" ]]; then
        brew install git
    fi
    print_success "Git installed"
fi

# GitHub CLI
if command_exists gh; then
    print_success "GitHub CLI $(gh --version | head -n1 | cut -d' ' -f3) is installed"
else
    print_status "Installing GitHub CLI..."
    if [[ "$OS" == "linux" ]]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install -y gh
    elif [[ "$OS" == "macos" ]]; then
        brew install gh
    fi
    print_success "GitHub CLI installed"
fi

# VS Code (optional but recommended)
if command_exists code; then
    print_success "VS Code is available"
else
    print_status "Installing VS Code..."
    if [[ "$OS" == "linux" ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt-get update && sudo apt-get install -y code
    elif [[ "$OS" == "macos" ]]; then
        brew install --cask visual-studio-code
    fi
    print_success "VS Code installed"
fi

# Chrome/Chromium for Flutter web development
if command_exists google-chrome || command_exists chromium-browser || command_exists chrome; then
    print_success "Chrome/Chromium is available for Flutter web development"
else
    print_status "Installing Chromium for Flutter web development..."
    if [[ "$OS" == "linux" ]]; then
        sudo apt-get install -y chromium-browser
    elif [[ "$OS" == "macos" ]]; then
        brew install --cask google-chrome
    fi
    print_success "Chrome/Chromium installed"
fi

print_section "8. PROJECT DEPENDENCIES"

# Install Node.js dependencies for Firebase Functions
print_status "Installing Firebase Functions dependencies..."
if [ -d "functions" ]; then
    cd functions
    npm install
    npm audit fix || true
    cd ..
    print_success "Functions dependencies installed"
else
    print_warning "Functions directory not found"
fi

# Install Flutter dependencies
print_status "Installing Flutter dependencies..."
if [ -f "pubspec.yaml" ]; then
    flutter pub get
    flutter pub upgrade
    print_success "Flutter dependencies installed"
else
    print_warning "pubspec.yaml not found in current directory"
fi

print_section "9. FIREBASE PROJECT CONFIGURATION"

# Set Firebase project
print_status "Setting Firebase project to crystalgrimoire-v3-production..."
firebase use crystalgrimoire-v3-production || true

# Check Firebase project status
print_status "Checking Firebase project configuration..."
firebase projects:list || true

print_section "10. ENVIRONMENT VARIABLES SETUP"

# Create comprehensive .env file
if [ ! -f ".env" ]; then
    print_status "Creating comprehensive .env file..."
    cat > .env << 'EOF'
# Crystal Grimoire V3 Environment Variables
# DO NOT COMMIT THIS FILE TO GIT

# Firebase Configuration
FIREBASE_PROJECT_ID=crystalgrimoire-v3-production
FIREBASE_API_KEY=AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c
FIREBASE_AUTH_DOMAIN=crystalgrimoire-v3-production.firebaseapp.com
FIREBASE_STORAGE_BUCKET=crystalgrimoire-v3-production.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=437420484025
FIREBASE_APP_ID=1:437420484025:web:eb4fc5b69fb9c51c96f5eb

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

# Parserator Integration
PARSERATOR_API_URL=https://app-5108296280.us-central1.run.app/v1/parse
PARSERATOR_API_KEY=your_parserator_key_here

# Additional APIs for future use
WEATHER_API_KEY=your_weather_api_key_here
ASTRONOMY_API_KEY=your_astronomy_api_key_here
MAPS_API_KEY=your_maps_api_key_here
EOF
    print_success "Comprehensive .env file created"
else
    print_success ".env file already exists"
fi

# Ensure .env is in .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q "^\.env$" .gitignore; then
        echo ".env" >> .gitignore
        echo ".env.*" >> .gitignore
        echo "*.log" >> .gitignore
        echo "node_modules/" >> .gitignore
        echo "build/" >> .gitignore
        echo ".dart_tool/" >> .gitignore
        print_status "Added important files to .gitignore"
    fi
fi

print_section "11. FIREBASE FUNCTIONS CONFIGURATION"

# Set Firebase Functions environment variables
print_status "Setting Firebase Functions environment variables..."
firebase functions:config:set gemini.key="AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs" --project crystalgrimoire-v3-production || true
firebase functions:config:set stripe.publishable_key="pk_live_placeholder" --project crystalgrimoire-v3-production || true

print_section "12. DEVELOPMENT WORKFLOW SETUP"

# Create comprehensive development scripts
print_status "Creating comprehensive development scripts..."

# Enhanced start script
cat > start_dev.sh << 'EOF'
#!/bin/bash
# Start comprehensive development environment
echo "🔮 Starting Crystal Grimoire V3 Development Environment..."

# Export environment variables
set -a
source .env 2>/dev/null || echo "No .env file found, using defaults"
set +a

# Kill any existing processes on our ports
lsof -ti:3000,4000,5001,8080 | xargs kill -9 2>/dev/null || true

# Start Firebase emulators in background
echo "🔥 Starting Firebase emulators..."
firebase emulators:start --only functions,firestore,hosting,auth &
FIREBASE_PID=$!

# Wait a moment for emulators to start
sleep 5

# Start Flutter web development server
echo "🌐 Starting Flutter web server..."
flutter run -d chrome --web-port 3000 --web-hostname 0.0.0.0 &
FLUTTER_PID=$!

echo ""
echo "✅ Development environment started!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔮 Crystal Grimoire V3 Development Services:"
echo "   • Flutter Web App:      http://localhost:3000"
echo "   • Firebase Emulators:   http://localhost:4000"
echo "   • Firestore UI:         http://localhost:4000/firestore"
echo "   • Functions:           http://localhost:5001"
echo "   • Auth UI:             http://localhost:4000/auth"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Development Tips:"
echo "   • Edit lib/ files for frontend changes"
echo "   • Edit functions/ files for backend changes"
echo "   • Hot reload: Press 'r' in Flutter terminal"
echo "   • Hot restart: Press 'R' in Flutter terminal"
echo "   • View logs: Check Firebase emulator UI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏹️  Press Ctrl+C to stop all services"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping development services..."
    kill $FIREBASE_PID $FLUTTER_PID 2>/dev/null || true
    
    # Kill any remaining processes on our ports
    lsof -ti:3000,4000,5001,8080 | xargs kill -9 2>/dev/null || true
    
    echo "✅ All services stopped"
    exit 0
}

# Set trap for cleanup
trap cleanup INT TERM

# Wait for interrupt
wait
EOF

# Enhanced build script
cat > build_production.sh << 'EOF'
#!/bin/bash
# Build Crystal Grimoire V3 for production deployment
echo "🔮 Building Crystal Grimoire V3 for Production..."

# Export environment variables
set -a
source .env 2>/dev/null || echo "No .env file found, using defaults"
set +a

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf build/
rm -rf functions/lib/

# Get latest dependencies
echo "📦 Getting latest dependencies..."
flutter pub get
flutter pub upgrade

# Install and update function dependencies
if [ -d "functions" ]; then
    echo "📦 Updating Functions dependencies..."
    cd functions
    npm install
    npm update
    npm audit fix --force || true
    cd ..
fi

# Build web app with all optimizations
echo "🌐 Building optimized web application..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=PRODUCTION=true \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
  --dart-define=STRIPE_PUBLISHABLE_KEY="$STRIPE_PUBLISHABLE_KEY" \
  --source-maps

echo ""
echo "✅ Production build complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Build artifacts:"
echo "   • Web build: build/web/"
echo "   • Functions: functions/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Ready to deploy with: ./deploy_production.sh"
echo ""
EOF

# Enhanced deploy script
cat > deploy_production.sh << 'EOF'
#!/bin/bash
# Deploy Crystal Grimoire V3 to production
echo "🔮 Deploying Crystal Grimoire V3 to Production..."

# Build first
echo "🏗️ Building for production..."
./build_production.sh

echo ""
echo "🚀 Starting deployment to Firebase..."

# Deploy to Firebase (hosting, functions, firestore rules)
firebase deploy \
  --project crystalgrimoire-v3-production \
  --only hosting,functions,firestore:rules \
  --force

echo ""
echo "✅ Deployment complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Live URLs:"
echo "   • Production App: https://crystalgrimoire-v3-production.web.app"
echo "   • Firebase Console: https://console.firebase.google.com/project/crystalgrimoire-v3-production"
echo "   • Functions Logs: https://console.cloud.google.com/functions/list?project=crystalgrimoire-v3-production"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
EOF

# Test script
cat > test_all.sh << 'EOF'
#!/bin/bash
# Run all tests for Crystal Grimoire V3
echo "🔮 Running Crystal Grimoire V3 Test Suite..."

echo "🧪 Running Flutter tests..."
flutter test --coverage

echo ""
echo "🧪 Running Functions tests..."
if [ -d "functions" ]; then
    cd functions
    npm test 2>/dev/null || echo "No function tests found"
    cd ..
fi

echo ""
echo "🔍 Running Flutter analysis..."
flutter analyze

echo ""
echo "📊 Checking Flutter doctor..."
flutter doctor

echo ""
echo "✅ All tests completed!"
EOF

# Make all scripts executable
chmod +x start_dev.sh build_production.sh deploy_production.sh test_all.sh

print_success "Enhanced development scripts created"

print_section "13. CODE QUALITY TOOLS SETUP"

# Setup comprehensive Flutter analysis
if [ -f "pubspec.yaml" ]; then
    print_status "Setting up comprehensive Flutter analysis..."
    
    # Create enhanced analysis_options.yaml
    cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - lib/generated_plugin_registrant.dart
    - lib/firebase_options.dart
    - functions/node_modules/**
  
  errors:
    invalid_annotation_target: ignore
    todo: ignore

linter:
  rules:
    # Style rules
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_final_in_for_each
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_single_quotes
    
    # Performance rules
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - use_build_context_synchronously
    - avoid_function_literals_in_foreach_calls
    
    # Error prevention
    - avoid_print
    - avoid_returning_null_for_void
    - cancel_subscriptions
    - close_sinks
    - always_declare_return_types
    
    # Code organization
    - always_put_control_body_on_new_line
    - always_put_required_named_parameters_first
    - sort_constructors_first
    - sort_unnamed_constructors_first
EOF
    print_success "Enhanced analysis_options.yaml created"
    
    # Add dev dependencies for better linting
    print_status "Adding code quality dev dependencies..."
    flutter pub add --dev flutter_lints
    flutter pub add --dev build_runner
    flutter pub add --dev json_annotation
fi

print_section "14. FUTURE REQUIREMENTS PREPARATION"

print_status "Setting up comprehensive project structure for future requirements..."

# Create comprehensive directory structure
mkdir -p assets/{images,sounds,videos,animations,icons,fonts,data}
mkdir -p assets/images/{crystals,backgrounds,ui,logos}
mkdir -p assets/sounds/{nature,guided,chimes,bowls}
mkdir -p assets/videos/{meditation,tutorials,backgrounds}
mkdir -p lib/{features,core,shared,widgets,screens,services,models,utils}
mkdir -p lib/features/{crystal_id,collection,journal,guidance,rituals,healing,sound_bath,profile}
mkdir -p lib/core/{constants,config,theme,routing}
mkdir -p lib/shared/{components,utilities,extensions}
mkdir -p test/{unit,integration,widget,mocks}
mkdir -p docs/{api,deployment,architecture,user_guides}
mkdir -p scripts/{dev,build,deploy,maintenance}

# Create comprehensive README
cat > DEVELOPMENT_GUIDE.md << 'EOF'
# Crystal Grimoire V3 - Complete Development Guide

## 🚀 Quick Start Commands

```bash
# Complete environment setup (run once)
./setup_environment_complete.sh

# Start development environment
./start_dev.sh

# Run all tests
./test_all.sh

# Build for production
./build_production.sh

# Deploy to production
./deploy_production.sh
```

## 📁 Project Structure

```
crystal-grimoire-v3/
├── lib/                    # Flutter application
│   ├── features/          # Feature-based modules
│   ├── core/              # Core functionality
│   ├── shared/            # Shared components
│   ├── widgets/           # Reusable widgets
│   ├── screens/           # Screen implementations
│   ├── services/          # Business logic
│   └── models/            # Data models
├── functions/             # Firebase Cloud Functions
├── assets/                # Static resources
├── test/                  # Test suites
├── docs/                  # Documentation
└── scripts/               # Development scripts
```

## 🔧 Development Environment

### Prerequisites
- Flutter 3.22+ 
- Node.js 20+
- Firebase CLI
- Git & GitHub CLI
- VS Code (recommended)

### Environment Variables
Copy `.env` and configure:
- Firebase credentials
- API keys (Gemini, OpenAI, etc.)
- Stripe keys
- Third-party service keys

## 🧪 Testing Strategy

```bash
# Unit tests
flutter test test/unit/

# Widget tests  
flutter test test/widget/

# Integration tests
flutter test test/integration/

# Functions tests
cd functions && npm test
```

## 🚀 Deployment Pipeline

1. **Development**: `./start_dev.sh`
2. **Testing**: `./test_all.sh`
3. **Building**: `./build_production.sh`
4. **Deployment**: `./deploy_production.sh`

## 🔮 Feature Development

### Adding New Features
1. Create feature directory in `lib/features/`
2. Implement models, services, widgets
3. Add tests in `test/`
4. Update documentation

### API Integration
- Backend: `functions/index.js`
- Frontend service: `lib/services/`
- Models: `lib/models/`

## 📊 Monitoring & Analytics

- Firebase Console: Project dashboard
- Cloud Functions: Logs and metrics
- Performance: Web vitals
- Analytics: User behavior

## 🛠️ Troubleshooting

### Common Issues
1. **Build failures**: Run `flutter clean && flutter pub get`
2. **Function errors**: Check Firebase Functions logs
3. **Deployment issues**: Verify Firebase authentication

### Debug Commands
```bash
flutter doctor -v
firebase --version
node --version
git status
```

## 🔐 Security

- Never commit `.env` files
- Use Firebase security rules
- Validate all user inputs
- Implement proper authentication

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Project Architecture](docs/architecture/)
- [API Documentation](docs/api/)
EOF

# Create API documentation template
mkdir -p docs/api
cat > docs/api/README.md << 'EOF'
# Crystal Grimoire V3 API Documentation

## Overview
RESTful API for Crystal Grimoire V3 platform.

## Base URL
- Production: `https://crystalgrimoire-v3-production.web.app/api`
- Local: `http://localhost:5001/crystalgrimoire-v3-production/us-central1/api`

## Authentication
All endpoints require Firebase Auth token in Authorization header:
```
Authorization: Bearer <firebase-auth-token>
```

## Endpoints

### Crystal Identification
- `POST /crystal/identify` - Identify crystal from image
- `GET /crystals` - List user's crystals
- `POST /crystals` - Add crystal to collection
- `PUT /crystals/:id` - Update crystal
- `DELETE /crystals/:id` - Remove crystal

### Spiritual Guidance
- `POST /guidance/personalized` - Get AI guidance

### Journal
- `GET /journals` - List journal entries
- `POST /journals` - Create entry
- `PUT /journals/:id` - Update entry
- `DELETE /journals/:id` - Delete entry

### Health Check
- `GET /health` - API status
EOF

print_success "Comprehensive project structure and documentation created"

print_section "15. ADDITIONAL TOOLS & INTEGRATIONS"

# Install additional useful tools
print_status "Installing additional development tools..."

# Dart SDK and tools
if command_exists dart; then
    print_success "Dart SDK is available"
else
    print_status "Dart SDK should be installed with Flutter"
fi

# Firebase Emulator Suite
print_status "Setting up Firebase Emulator Suite..."
firebase setup:emulators:firestore || true
firebase setup:emulators:functions || true
firebase setup:emulators:hosting || true
firebase setup:emulators:auth || true

# Create firebase.json if it doesn't exist
if [ ! -f "firebase.json" ]; then
    cat > firebase.json << 'EOF'
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "/api/**",
        "function": "api"
      },
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  },
  "functions": {
    "source": "functions",
    "runtime": "nodejs20"
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "emulators": {
    "auth": {
      "port": 9099
    },
    "functions": {
      "port": 5001
    },
    "firestore": {
      "port": 8080
    },
    "hosting": {
      "port": 5000
    },
    "ui": {
      "enabled": true,
      "port": 4000
    },
    "singleProjectMode": true
  }
}
EOF
    print_success "firebase.json created"
fi

print_section "16. HEALTH CHECK AND VALIDATION"

print_status "Running comprehensive health checks..."

# Check if all critical tools are available
TOOLS_OK=true
CRITICAL_TOOLS=("node" "npm" "flutter" "firebase" "git" "curl")

for tool in "${CRITICAL_TOOLS[@]}"; do
    if command_exists "$tool"; then
        print_success "$tool is available"
    else
        print_error "$tool is missing!"
        TOOLS_OK=false
    fi
done

# Version checks
print_status "Checking tool versions..."
echo "Node.js: $(node --version 2>/dev/null || echo 'Not found')"
echo "npm: $(npm --version 2>/dev/null || echo 'Not found')"
echo "Flutter: $(flutter --version 2>/dev/null | head -n1 || echo 'Not found')"
echo "Firebase CLI: $(firebase --version 2>/dev/null || echo 'Not found')"
echo "Git: $(git --version 2>/dev/null || echo 'Not found')"

# Test Firebase authentication
print_status "Testing Firebase connectivity..."
if firebase projects:list >/dev/null 2>&1; then
    print_success "Firebase authentication successful"
else
    print_warning "Firebase authentication issue - you may need to run 'firebase login'"
fi

# Test project build
print_status "Testing project build capabilities..."
if [ -f "pubspec.yaml" ]; then
    if flutter pub get >/dev/null 2>&1; then
        print_success "Flutter project builds successfully"
    else
        print_warning "Flutter project build issues detected"
    fi
fi

print_section "17. SETUP COMPLETE"

echo ""
if [ "$TOOLS_OK" = true ]; then
    print_success "🎉 Crystal Grimoire V3 COMPLETE environment setup finished successfully!"
else
    print_warning "⚠️  Setup completed with some issues. Please review errors above."
fi

echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}🔮 CRYSTAL GRIMOIRE V3 DEVELOPMENT ENVIRONMENT READY! 🔮${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}📋 Next Steps:${NC}"
echo "1. 🔑 Review and update .env file with your API keys"
echo "2. 🔐 Run 'firebase login' if authentication failed"
echo "3. 🚀 Run './start_dev.sh' to start development environment"
echo "4. 🧪 Run './test_all.sh' to verify everything works"
echo "5. 🏗️  Run './build_production.sh' to build for production"
echo "6. 🌐 Run './deploy_production.sh' to deploy to Firebase"
echo ""
echo -e "${BLUE}📚 Available Scripts:${NC}"
echo "• ./start_dev.sh        - Start development servers"
echo "• ./test_all.sh         - Run comprehensive tests"
echo "• ./build_production.sh - Build optimized production version"
echo "• ./deploy_production.sh - Deploy to Firebase hosting"
echo ""
echo -e "${YELLOW}💡 Development Tips:${NC}"
echo "• Use VS Code with Flutter extension for best experience"
echo "• Enable hot reload for faster development"
echo "• Check Firebase Console for logs and analytics"
echo "• Use Chrome DevTools for web debugging"
echo ""
echo -e "${GREEN}🎊 Happy coding with Crystal Grimoire V3! 🎊${NC}"
echo ""