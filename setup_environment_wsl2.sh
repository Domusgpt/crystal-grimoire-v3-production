#!/bin/bash
# Crystal Grimoire V3 - WSL2 Environment Setup Script
# This script sets up everything needed for development and deployment

set -e  # Exit on any error

echo "🔮 Crystal Grimoire V3 WSL2 Environment Setup Starting..."
echo "=========================================================="

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
    
    # Install Node.js using NodeSource for WSL2
    print_status "Installing Node.js 20 LTS via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    if check_node_version; then
        print_success "Node.js $(node --version) installed successfully"
    else
        print_error "Node.js installation failed"
        exit 1
    fi
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
    print_warning "Flutter not found or version too old. Installing Flutter 3.22+..."
    
    # Download and install Flutter
    cd /tmp
    wget -O flutter_linux_3.22.0-stable.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz
    tar xf flutter_linux_3.22.0-stable.tar.xz
    sudo mv flutter /opt/
    
    # Add to PATH in bashrc
    if ! grep -q "/opt/flutter/bin" ~/.bashrc; then
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
        print_status "Added Flutter to PATH in ~/.bashrc"
    fi
    
    # Source for current session
    export PATH="$PATH:/opt/flutter/bin"
    
    if check_flutter_version; then
        print_success "Flutter installed successfully"
    else
        print_warning "Flutter installation may need manual PATH configuration"
    fi
fi

# Run Flutter doctor if Flutter is available
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
    print_warning "Firebase CLI not authenticated. You may need to run 'firebase login' later"
fi

print_section "5. GOOGLE CLOUD SDK SETUP"

# Check gcloud
if command_exists gcloud; then
    print_success "Google Cloud SDK is installed"
else
    print_status "Installing Google Cloud SDK..."
    
    # Add Google Cloud SDK repository
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-cli
    
    print_success "Google Cloud SDK installed"
fi

print_section "6. DEVELOPMENT TOOLS SETUP"

# Essential tools installation
print_status "Installing essential development tools..."
sudo apt-get update
sudo apt-get install -y \
    curl \
    wget \
    git \
    jq \
    zip \
    unzip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

print_success "Essential tools installed"

# GitHub CLI
if command_exists gh; then
    print_success "GitHub CLI is installed"
else
    print_status "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
    print_success "GitHub CLI installed"
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
firebase use crystalgrimoire-v3-production || print_warning "Firebase project not set (may need authentication)"

print_section "9. ENVIRONMENT VARIABLES SETUP"

# Check .env file
if [ -f ".env" ]; then
    print_success ".env file already exists"
else
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
firebase functions:config:set gemini.key="AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs" --project crystalgrimoire-v3-production || print_warning "Firebase config not set (may need authentication)"

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
    
    # analysis_options.yaml already exists, so we'll check it
    if [ -f "analysis_options.yaml" ]; then
        print_success "analysis_options.yaml already exists"
    fi
fi

print_section "13. CHROME INSTALLATION FOR FLUTTER WEB"

# Install Chrome for Flutter web development
if command_exists google-chrome; then
    print_success "Google Chrome is installed"
else
    print_status "Installing Google Chrome..."
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
    print_success "Google Chrome installed"
fi

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
    print_success "🎉 Crystal Grimoire V3 WSL2 environment setup completed successfully!"
else
    print_warning "⚠️  Setup completed with some issues. Please review errors above."
fi

echo ""
echo -e "${PURPLE}Next Steps:${NC}"
echo "1. Source your bashrc: source ~/.bashrc"
echo "2. Run 'firebase login' if not already authenticated"
echo "3. Review and update .env file with your API keys"
echo "4. Run './start_dev.sh' to start development environment"
echo "5. Run './build_production.sh' to build for production"
echo "6. Run './deploy_production.sh' to deploy to Firebase"
echo ""
echo -e "${GREEN}🔮 Happy coding with Crystal Grimoire V3! 🔮${NC}"
echo ""