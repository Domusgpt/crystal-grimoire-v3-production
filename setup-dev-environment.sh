#!/bin/bash

# Crystal Grimoire V3 Development Environment Setup Script
# For Jules and other developers
# Run with: bash setup-dev-environment.sh

set -e  # Exit on any error

echo "🔮 Crystal Grimoire V3 Development Environment Setup"
echo "=================================================="
echo ""

# Detect operating system
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*|MINGW*|MSYS*) MACHINE=Windows;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "🖥️  Detected OS: $MACHINE"
echo ""

# Function to add to PATH if not already present
add_to_path() {
    local dir="$1"
    if [[ ":$PATH:" != *":$dir:"* ]]; then
        export PATH="$PATH:$dir"
        echo "export PATH=\"\$PATH:$dir\"" >> ~/.bashrc
        echo "✅ Added $dir to PATH"
    else
        echo "ℹ️  $dir already in PATH"
    fi
}

# Update package lists (Linux/Mac)
echo "📦 Updating package lists..."
if [[ "$MACHINE" == "Linux" ]]; then
    sudo apt update
elif [[ "$MACHINE" == "Mac" ]]; then
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
fi
echo "✅ Package lists updated"
echo ""

# Install prerequisites
echo "🔧 Installing prerequisites..."
if [[ "$MACHINE" == "Linux" ]]; then
    sudo apt install -y curl git unzip xz-utils zip libglu1-mesa wget
elif [[ "$MACHINE" == "Mac" ]]; then
    # Prerequisites usually available on Mac, but install git if needed
    if ! command -v git &> /dev/null; then
        brew install git
    fi
elif [[ "$MACHINE" == "Windows" ]]; then
    echo "⚠️  For Windows: Please ensure you have Git Bash, curl, and unzip installed"
    echo "   You can install Git for Windows from: https://git-scm.com/download/win"
fi
echo "✅ Prerequisites installed"
echo ""

# Download and install Flutter
echo "🐦 Installing Flutter..."
FLUTTER_VERSION="3.32.4"
if [[ "$MACHINE" == "Linux" ]]; then
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_VERSION-stable.tar.xz"
    FLUTTER_DIR="$HOME/flutter"
elif [[ "$MACHINE" == "Mac" ]]; then
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_$FLUTTER_VERSION-stable.zip"
    FLUTTER_DIR="$HOME/flutter"
elif [[ "$MACHINE" == "Windows" ]]; then
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$FLUTTER_VERSION-stable.zip"
    FLUTTER_DIR="$HOME/flutter"
fi

if [ ! -d "$FLUTTER_DIR" ]; then
    echo "📥 Downloading Flutter $FLUTTER_VERSION..."
    cd $HOME
    wget -O flutter.tar.xz "$FLUTTER_URL" || curl -o flutter.tar.xz "$FLUTTER_URL"
    
    if [[ "$FLUTTER_URL" == *".zip" ]]; then
        unzip flutter.tar.xz
    else
        tar xf flutter.tar.xz
    fi
    
    rm flutter.tar.xz
    echo "✅ Flutter downloaded and extracted"
else
    echo "ℹ️  Flutter already installed at $FLUTTER_DIR"
fi

# Add Flutter to PATH
add_to_path "$FLUTTER_DIR/bin"
echo ""

# Download and install Firebase CLI
echo "🔥 Installing Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    if [[ "$MACHINE" == "Linux" || "$MACHINE" == "Mac" ]]; then
        curl -sL https://firebase.tools | bash
    elif [[ "$MACHINE" == "Windows" ]]; then
        echo "⚠️  For Windows: Please install Firebase CLI manually:"
        echo "   npm install -g firebase-tools"
        echo "   Or download from: https://firebase.google.com/docs/cli"
    fi
    echo "✅ Firebase CLI installed"
else
    echo "ℹ️  Firebase CLI already installed"
fi
echo ""

# Download and install Google Cloud SDK
echo "☁️  Installing Google Cloud SDK..."
if ! command -v gcloud &> /dev/null; then
    if [[ "$MACHINE" == "Linux" ]]; then
        # Add Google Cloud SDK repository
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt update && sudo apt install -y google-cloud-cli
    elif [[ "$MACHINE" == "Mac" ]]; then
        brew install google-cloud-sdk
    elif [[ "$MACHINE" == "Windows" ]]; then
        echo "⚠️  For Windows: Please install Google Cloud SDK manually:"
        echo "   Download from: https://cloud.google.com/sdk/docs/install"
    fi
    echo "✅ Google Cloud SDK installed"
else
    echo "ℹ️  Google Cloud SDK already installed"
fi
echo ""

# Verify installations
echo "🔍 Verifying installations..."
echo ""

# Check Flutter
if command -v flutter &> /dev/null; then
    echo "✅ Flutter: $(flutter --version | head -n1)"
else
    echo "❌ Flutter not found in PATH"
fi

# Check Firebase CLI
if command -v firebase &> /dev/null; then
    echo "✅ Firebase CLI: $(firebase --version)"
else
    echo "❌ Firebase CLI not found"
fi

# Check Google Cloud SDK
if command -v gcloud &> /dev/null; then
    echo "✅ Google Cloud SDK: $(gcloud --version | head -n1)"
else
    echo "❌ Google Cloud SDK not found"
fi

# Check Git
if command -v git &> /dev/null; then
    echo "✅ Git: $(git --version)"
else
    echo "❌ Git not found"
fi

echo ""
echo "🔮 Running Flutter doctor..."
if command -v flutter &> /dev/null; then
    flutter doctor
else
    echo "❌ Flutter not available, skipping doctor check"
fi

echo ""
echo "=================================================="
echo "🎉 Development Environment Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Restart your terminal or run: source ~/.bashrc"
echo "2. Clone the repository: git clone https://github.com/Domusgpt/crystal-grimoire-v3-production.git"
echo "3. Navigate to project: cd crystal-grimoire-v3-production"
echo "4. Install dependencies: flutter pub get"
echo "5. Login to Firebase: firebase login"
echo "6. Login to Google Cloud: gcloud auth login"
echo "7. Set Firebase project: firebase use crystalgrimoire-production"
echo ""
echo "🔧 Development Commands:"
echo "  flutter run -d chrome          # Run web app"
echo "  flutter build web --release    # Build for production"
echo "  firebase deploy --only hosting # Deploy to Firebase"
echo "  firebase deploy --only functions # Deploy backend functions"
echo ""
echo "📚 Documentation:"
echo "  Flutter: https://docs.flutter.dev/"
echo "  Firebase: https://firebase.google.com/docs"
echo "  Google Cloud: https://cloud.google.com/docs"
echo ""
echo "💬 For help, contact: phillips.paul.email@gmail.com"
echo "=================================================="