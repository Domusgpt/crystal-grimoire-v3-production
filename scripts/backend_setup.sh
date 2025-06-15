#!/bin/bash

# Crystal Grimoire Backend Setup Script

echo "🚀 Starting Crystal Grimoire Backend Setup..."

# --- Configuration ---
VENV_NAME=".venv" # Name of the virtual environment directory
PYTHON_CMD="python3" # Command to run Python 3
MIN_PYTHON_VERSION="3.8" # Minimum required Python version
REQUIREMENTS_FILE="requirements.txt" # Path to requirements file (project root)

# --- Helper Functions ---
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

version_ge() {
    # Compares two version strings (e.g., 3.8.10 and 3.8)
    # Returns true if $1 >= $2
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

echo_info() {
    echo "INFO: $1"
}

echo_success() {
    echo "✅ SUCCESS: $1"
}

echo_warning() {
    echo "⚠️ WARNING: $1"
}

echo_error() {
    echo "❌ ERROR: $1" >&2
    exit 1
}

# --- Pre-flight Checks ---
echo_info "Checking prerequisites..."

# 1. Check Python 3
if ! command_exists $PYTHON_CMD; then
    echo_error "$PYTHON_CMD is not installed or not in PATH. Please install Python $MIN_PYTHON_VERSION or higher."
fi

PYTHON_VERSION=$($PYTHON_CMD -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
if ! version_ge "$PYTHON_VERSION" "$MIN_PYTHON_VERSION"; then
    echo_error "Python version $PYTHON_VERSION is installed. Version $MIN_PYTHON_VERSION or higher is required."
fi
echo_info "Python version $PYTHON_VERSION found."

# 2. Check pip
if ! $PYTHON_CMD -m pip --version >/dev/null 2>&1; then
    echo_error "pip for $PYTHON_CMD is not available. Please ensure pip is installed."
fi
echo_info "pip is available."

# --- Setup Steps ---

# Project root is the current directory where backend_server.py resides
PROJECT_ROOT=$(pwd)
echo_info "Project root identified as: $PROJECT_ROOT"

# 1. Create Virtual Environment if it doesn't exist
VENV_PATH="$PROJECT_ROOT/$VENV_NAME"
if [ ! -d "$VENV_PATH" ]; then
    echo_info "Creating virtual environment at $VENV_PATH..."
    $PYTHON_CMD -m venv "$VENV_PATH"
    if [ $? -ne 0 ]; then
        echo_error "Failed to create virtual environment."
    fi
    echo_success "Virtual environment created."
else
    echo_info "Virtual environment already exists at $VENV_PATH."
fi

# 2. Activate Virtual Environment (for this script's session)
# Note: This activates it for the current script. User needs to activate manually for their shell.
echo_info "Activating virtual environment for dependency installation..."
source "$VENV_PATH/bin/activate"
if [ $? -ne 0 ]; then
    echo_error "Failed to activate virtual environment. Please check the path: $VENV_PATH/bin/activate"
fi

# 3. Install Dependencies
if [ ! -f "$PROJECT_ROOT/$REQUIREMENTS_FILE" ]; then
    echo_error "$REQUIREMENTS_FILE not found in $PROJECT_ROOT."
fi

echo_info "Installing dependencies from $REQUIREMENTS_FILE..."
$PYTHON_CMD -m pip install --upgrade pip # Upgrade pip first
$PYTHON_CMD -m pip install -r "$PROJECT_ROOT/$REQUIREMENTS_FILE"
if [ $? -ne 0 ]; then
    # Deactivate venv before exiting on error
    deactivate
    echo_error "Failed to install dependencies from $REQUIREMENTS_FILE."
fi
echo_success "Dependencies installed successfully."

# Deactivate venv after script finishes its operations
deactivate

# --- Completion Message ---
echo_success "Backend setup completed!"
echo ""
echo_info "To activate the virtual environment in your current terminal session, run:"
echo "  source $VENV_NAME/bin/activate"
echo ""
echo_info "To run the backend server (after activating the venv), use the run_backend.sh script:"
echo "  ./scripts/run_backend.sh"
echo ""
echo_info "Make sure you have created a '.env' file in the project root with your API keys."
echo_info "Refer to 'docs/API_KEYS_CONFIGURATION.md' for details."
echo_info "Also ensure 'firebase-service-account.json' is in the project root."
echo_info "Refer to 'FIREBASE_SETUP_GUIDE.md' for Firebase setup."

exit 0
