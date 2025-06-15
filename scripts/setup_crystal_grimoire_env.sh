#!/bin/bash

# setup_crystal_grimoire_env.sh
#
# This script sets up the development environment for the Crystal Grimoire project.
# It attempts to be idempotent (safe to run multiple times).

# --- Configuration ---
NODE_VERSION_MAJOR="20" # Target Node.js v20.x (LTS)
PYTHON_VERSION_TARGET="3.10.12" # Example Python version, can be adjusted.
# Set to "" or comment out PYTHON_SETUP_ENABLED if Python is not needed for this project.
PYTHON_SETUP_ENABLED="true"

# --- Helper Functions ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

msg() {
  echo -e "\n\033[1;32mINFO:: $1\033[0m"
}

warn() {
  echo -e "\n\033[1;33mWARN:: $1\033[0m"
}

error_exit() {
  echo -e "\n\033[1;31mERROR:: $1\033[0m" >&2
  exit 1
}

# --- Detect OS ---
OS=""
if [[ "$(uname)" == "Darwin" ]]; then
  OS="macOS"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  OS="Linux"
else
  error_exit "Unsupported OS. This script supports macOS and Linux."
fi
msg "Detected OS: $OS"

# --- Prerequisites ---
msg "Checking for essential prerequisites (git, curl)..."
if ! command_exists git; then
  error_exit "Git not found. Please install Git: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
fi
if ! command_exists curl; then
  error_exit "curl not found. Please install curl."
fi

# --- Homebrew (macOS) ---
if [[ "$OS" == "macOS" ]]; then
  msg "Setting up Homebrew (for macOS)..."
  if ! command_exists brew; then
    msg "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
      error_exit "Homebrew installation failed."
    fi
    # Add Homebrew to PATH for current session (and recommend adding to .zprofile/.bash_profile)
    if [[ -x "/opt/homebrew/bin/brew" ]]; then # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
         msg "Added Homebrew to PATH. Consider adding to your .zprofile or .bash_profile."
    elif [[ -x "/usr/local/bin/brew" ]]; then # Intel Macs
        eval "$(/usr/local/bin/brew shellenv)"
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        msg "Added Homebrew to PATH. Consider adding to your .zprofile or .bash_profile."
    fi
  else
    msg "Homebrew already installed."
  fi
  msg "Updating Homebrew..."
  brew update
fi

# --- nvm and Node.js ---
msg "Setting up Node.js v$NODE_VERSION_MAJOR (via nvm)..."
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  msg "nvm not found. Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  if [ $? -ne 0 ]; then
    error_exit "nvm installation failed."
  fi
  # Source nvm for current session
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  msg "nvm installed. Please close and reopen your terminal, or source your shell profile (e.g., source ~/.zshrc)."
else
  msg "nvm already installed."
  # Source nvm if not already sourced
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

if ! command_exists node || ! node -v | grep -q "v$NODE_VERSION_MAJOR"; then
  msg "Installing Node.js v$NODE_VERSION_MAJOR..."
  nvm install $NODE_VERSION_MAJOR
  if [ $? -ne 0 ]; then
    error_exit "Node.js v$NODE_VERSION_MAJOR installation failed via nvm."
  fi
  nvm use $NODE_VERSION_MAJOR
  nvm alias default $NODE_VERSION_MAJOR
else
  msg "Node.js v$NODE_VERSION_MAJOR (or a compatible version) already installed and selected via nvm."
fi
msg "Current Node.js version: $(node -v)"
msg "Current npm version: $(npm -v)"


# --- Python (via pyenv) ---
if [[ "$PYTHON_SETUP_ENABLED" == "true" ]]; then
  msg "Setting up Python $PYTHON_VERSION_TARGET (via pyenv)..."
  if ! command_exists pyenv; then
    msg "pyenv not found. Installing pyenv..."
    if [[ "$OS" == "macOS" ]]; then
      if ! command_exists brew; then error_exit "Homebrew is required to install pyenv on macOS. Please run the script again to install Homebrew."; fi
      brew install pyenv
    elif [[ "$OS" == "Linux" ]]; then
      curl https://pyenv.run | bash
      # Add pyenv to PATH and shell config for Linux
      export PATH="$HOME/.pyenv/bin:$PATH"
      eval "$(pyenv init --path)"
      eval "$(pyenv virtualenv-init -)"
      echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc # Or .zshrc
      echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
      echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
      msg "pyenv installed. Please close and reopen your terminal or source your shell profile."
    fi
    if [ $? -ne 0 ] || ! command_exists pyenv; then
      error_exit "pyenv installation failed."
    fi
  else
    msg "pyenv already installed."
  fi

  # Ensure pyenv is initialized for the current session
  if [[ "$OS" == "Linux" ]]; then # macOS brew install handles this better
      export PATH="$HOME/.pyenv/bin:$PATH"
      eval "$(pyenv init --path)"
      eval "$(pyenv virtualenv-init -)"
  elif [[ "$OS" == "macOS" ]]; then
      if ! (echo $PATH | grep -q "$HOME/.pyenv/shims"); then
        eval "$(pyenv init --path)" # For current shell
      fi
      # Ensure shims are in path for future shells via .zprofile or .bash_profile
      # This is typically handled by `brew install pyenv` instructions but good to double check.
  fi

  # Install Python build dependencies
  msg "Ensuring Python build dependencies are installed..."
  if [[ "$OS" == "macOS" ]]; then
    # Handled by Homebrew's pyenv formula dependencies generally
    :
  elif [[ "$OS" == "Linux" ]]; then
    if command_exists apt-get; then
      sudo apt-get update -y > /dev/null
      sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git > /dev/null
    else
      warn "Cannot automatically install Python build dependencies on this Linux distribution. Please ensure they are installed for pyenv to build Python."
    fi
  fi

  PYENV_PYTHON_INSTALLED_VERSION=$(pyenv versions --bare | grep "^$PYTHON_VERSION_TARGET$")
  if [[ -z "$PYENV_PYTHON_INSTALLED_VERSION" ]]; then
    msg "Installing Python $PYTHON_VERSION_TARGET with pyenv... (This may take a while)"
    pyenv install $PYTHON_VERSION_TARGET
    if [ $? -ne 0 ]; then
      error_exit "Python $PYTHON_VERSION_TARGET installation failed via pyenv."
    fi
  else
    msg "Python $PYTHON_VERSION_TARGET already installed with pyenv."
  fi
  pyenv global $PYTHON_VERSION_TARGET
  msg "Set global Python version to $PYTHON_VERSION_TARGET via pyenv."
  msg "Current Python version: $(python --version)"
  msg "Current pip version: $(pip --version)"
fi


# --- Flutter SDK ---
msg "Checking for Flutter SDK..."
if ! command_exists flutter; then
  warn "Flutter SDK not found."
  warn "Please install Flutter by following the instructions at: https://flutter.dev/docs/get-started/install"
  warn "After installation, ensure flutter is in your PATH and run 'flutter doctor'."
else
  msg "Flutter SDK found. Current version: $(flutter --version | head -n 1)"
  msg "Running 'flutter doctor' to check Flutter setup..."
  flutter doctor
fi

# --- Firebase CLI ---
msg "Setting up Firebase CLI..."
if ! command_exists firebase; then
  msg "Firebase CLI not found. Installing firebase-tools globally via npm..."
  if ! command_exists npm; then error_exit "NPM is required to install Firebase CLI. nvm/Node.js setup might have failed."; fi
  npm install -g firebase-tools
  if [ $? -ne 0 ] || ! command_exists firebase; then
    error_exit "Firebase CLI installation failed."
  fi
else
  msg "Firebase CLI already installed."
fi
msg "Current Firebase CLI version: $(firebase --version)"
msg "To login: run 'firebase login'."
msg "To associate with a project: run 'firebase use <project_id>' in your project directory."

# --- Google Cloud CLI (gcloud) ---
msg "Setting up Google Cloud CLI..."
if ! command_exists gcloud; then
  msg "Google Cloud CLI not found. Installing gcloud..."
  if [[ "$OS" == "macOS" ]]; then
    if ! command_exists brew; then error_exit "Homebrew is required to install Google Cloud CLI on macOS."; fi
    brew install google-cloud-sdk --cask # Cask is often preferred for gcloud
    # Instructions for PATH are usually output by brew, or handled by cask.
    # Manual PATH addition if needed:
    # GCLOUD_SDK_PATH="$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    # echo "source $GCLOUD_SDK_PATH/path.bash.inc" >> ~/.zshrc # or .bashrc
    # echo "source $GCLOUD_SDK_PATH/completion.bash.inc" >> ~/.zshrc # or .bashrc
    msg "gcloud installed via Homebrew. You might need to restart your terminal or source your profile."
  elif [[ "$OS" == "Linux" ]]; then
    curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts
    # Add to PATH for current session and instruct for profile
    if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then
        source "$HOME/google-cloud-sdk/path.bash.inc"
        msg "Google Cloud SDK installed. Add '\$HOME/google-cloud-sdk/path.bash.inc' to your shell profile."
    fi
  fi
else
  msg "Google Cloud CLI already installed."
fi
msg "To login: run 'gcloud auth login'."
msg "To set project: run 'gcloud config set project YOUR_PROJECT_ID'."

# --- GitHub CLI (gh) ---
msg "Setting up GitHub CLI..."
if ! command_exists gh; then
  msg "GitHub CLI (gh) not found. Installing gh..."
  if [[ "$OS" == "macOS" ]]; then
    if ! command_exists brew; then error_exit "Homebrew is required to install GitHub CLI on macOS."; fi
    brew install gh
  elif [[ "$OS" == "Linux" ]];
    if command_exists apt-get; then
        (curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install gh -y) > /dev/null
    else
        warn "Cannot automatically install gh on this Linux distribution. Please see: https://github.com/cli/cli#installation"
    fi
  fi
  if ! command_exists gh; then # Check again after install attempt
    warn "GitHub CLI installation may have failed. Please check manually."
  fi
else
  msg "GitHub CLI (gh) already installed."
fi
msg "To login: run 'gh auth login'."

# --- Project Specific Dependencies ---
msg "Installing project-specific dependencies..."

# Flutter dependencies
if [ -f "pubspec.yaml" ]; then
  msg "Running 'flutter pub get'..."
  flutter pub get
else
  warn "pubspec.yaml not found in current directory. Skipping 'flutter pub get'."
fi

# Firebase Functions dependencies (Node modules)
if [ -d "functions" ] && [ -f "functions/package.json" ]; then
  msg "Installing dependencies for Firebase Functions (in ./functions directory)..."
  (cd functions && npm install) # Run in a subshell
  if [ $? -ne 0 ]; then
    warn "npm install in ./functions directory may have failed."
  fi
else
  warn "./functions/package.json not found. Skipping 'npm install' for Firebase Functions."
fi

# Python dependencies (if applicable and enabled)
if [[ "$PYTHON_SETUP_ENABLED" == "true" ]]; then
  if [ -f "requirements.txt" ]; then
    msg "Installing Python dependencies from requirements.txt..."
    pip install -r requirements.txt
  elif [ -f "functions/requirements.txt" ]; then
     msg "Installing Python dependencies from functions/requirements.txt..."
     (cd functions && pip install -r requirements.txt) # Run in a subshell
  else
    warn "No requirements.txt found in root or ./functions. Skipping Python dependency installation by pip."
  fi
fi

# --- Final Instructions & Summary ---
msg "Crystal Grimoire development environment setup script has finished."
msg "Summary of key tools and their expected setup:"
command_exists node && msg "- Node.js: $(node -v) (via nvm)"
command_exists npm && msg "- npm: $(npm -v)"
if [[ "$PYTHON_SETUP_ENABLED" == "true" ]]; then
  command_exists python && command_exists pip && msg "- Python: $(python --version), pip: $(pip --version) (via pyenv)"
fi
command_exists flutter && msg "- Flutter: $(flutter --version | head -n 1)"
command_exists firebase && msg "- Firebase CLI: $(firebase --version)"
command_exists gcloud && msg "- Google Cloud CLI: $(gcloud --version | head -n 1)"
command_exists gh && msg "- GitHub CLI: $(gh --version | head -n 1)"

warn "IMPORTANT: If this was the first time installing tools like nvm, pyenv, gcloud, or Homebrew, you MIGHT NEED TO CLOSE AND REOPEN YOUR TERMINAL or source your shell configuration file (e.g., 'source ~/.zshrc' or 'source ~/.bashrc') for all changes, especially PATH updates and command availability, to take full effect."
msg "Please also ensure you have completed any manual authentication steps for CLI tools (e.g., 'firebase login', 'gcloud auth login', 'gh auth login')."
msg "Run 'flutter doctor' again if you encountered any Flutter setup issues during the process."
