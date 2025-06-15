@echo off
REM Crystal Grimoire V3 Development Environment Setup Script for Windows
REM For Jules and other developers
REM Run as Administrator: setup-dev-environment.bat

echo 🔮 Crystal Grimoire V3 Development Environment Setup (Windows)
echo ==============================================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Running as Administrator
) else (
    echo ❌ Please run this script as Administrator
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo 📦 Installing Chocolatey (Windows package manager)...
where choco >nul 2>nul
if %errorLevel% == 0 (
    echo ℹ️  Chocolatey already installed
) else (
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    echo ✅ Chocolatey installed
)

echo.
echo 🔧 Installing prerequisites...
choco install -y git curl wget unzip 7zip

echo.
echo 🐦 Installing Flutter...
where flutter >nul 2>nul
if %errorLevel% == 0 (
    echo ℹ️  Flutter already installed
) else (
    choco install -y flutter
    echo ✅ Flutter installed
)

echo.
echo 🔥 Installing Firebase CLI...
where firebase >nul 2>nul
if %errorLevel% == 0 (
    echo ℹ️  Firebase CLI already installed
) else (
    npm install -g firebase-tools
    echo ✅ Firebase CLI installed
)

echo.
echo ☁️  Installing Google Cloud SDK...
where gcloud >nul 2>nul
if %errorLevel% == 0 (
    echo ℹ️  Google Cloud SDK already installed
) else (
    choco install -y gcloudsdk
    echo ✅ Google Cloud SDK installed
)

echo.
echo 🔍 Verifying installations...
echo.

REM Check Flutter
where flutter >nul 2>nul
if %errorLevel% == 0 (
    echo ✅ Flutter: 
    flutter --version | findstr "Flutter"
) else (
    echo ❌ Flutter not found
)

REM Check Firebase CLI
where firebase >nul 2>nul
if %errorLevel% == 0 (
    echo ✅ Firebase CLI:
    firebase --version
) else (
    echo ❌ Firebase CLI not found
)

REM Check Google Cloud SDK
where gcloud >nul 2>nul
if %errorLevel% == 0 (
    echo ✅ Google Cloud SDK:
    gcloud --version | findstr "Google Cloud SDK"
) else (
    echo ❌ Google Cloud SDK not found
)

REM Check Git
where git >nul 2>nul
if %errorLevel% == 0 (
    echo ✅ Git:
    git --version
) else (
    echo ❌ Git not found
)

echo.
echo 🔮 Running Flutter doctor...
where flutter >nul 2>nul
if %errorLevel% == 0 (
    flutter doctor
) else (
    echo ❌ Flutter not available, skipping doctor check
)

echo.
echo ==============================================================
echo 🎉 Development Environment Setup Complete!
echo.
echo 📋 Next Steps:
echo 1. Restart your Command Prompt or PowerShell
echo 2. Clone the repository: git clone https://github.com/Domusgpt/crystal-grimoire-v3-production.git
echo 3. Navigate to project: cd crystal-grimoire-v3-production
echo 4. Install dependencies: flutter pub get
echo 5. Login to Firebase: firebase login
echo 6. Login to Google Cloud: gcloud auth login
echo 7. Set Firebase project: firebase use crystalgrimoire-production
echo.
echo 🔧 Development Commands:
echo   flutter run -d chrome          # Run web app
echo   flutter build web --release    # Build for production
echo   firebase deploy --only hosting # Deploy to Firebase
echo   firebase deploy --only functions # Deploy backend functions
echo.
echo 📚 Documentation:
echo   Flutter: https://docs.flutter.dev/
echo   Firebase: https://firebase.google.com/docs
echo   Google Cloud: https://cloud.google.com/docs
echo.
echo 💬 For help, contact: phillips.paul.email@gmail.com
echo ==============================================================
pause