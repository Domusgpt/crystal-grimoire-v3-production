#!/bin/bash

# Crystal Grimoire Backend Run Script

echo "🚀 Attempting to start Crystal Grimoire Backend Server..."

# --- Configuration ---
VENV_NAME=".venv" # Name of the virtual environment directory
PROJECT_ROOT=$(pwd) # Assumes script is run from project root, or can be cd .. from scripts
ENV_FILE=".env" # Path to the .env file, relative to PROJECT_ROOT
BACKEND_MODULE="backend_server" # Python module name (file name without .py)
APP_VARIABLE_NAME="app" # Variable name of the FastAPI app instance in the module

# Adjust PROJECT_ROOT if script is run from inside 'scripts' directory
if [[ "$(basename "$PWD")" == "scripts" ]]; then
    PROJECT_ROOT="$(dirname "$PWD")"
    echo "Adjusted PROJECT_ROOT to $PROJECT_ROOT as script is run from scripts/ directory."
fi

VENV_PATH="$PROJECT_ROOT/$VENV_NAME"
ENV_FILE_PATH="$PROJECT_ROOT/$ENV_FILE"

# --- Pre-run Checks ---
echo "INFO: Checking for virtual environment at $VENV_PATH..."
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ ERROR: Virtual environment '$VENV_NAME' not found in $PROJECT_ROOT."
    echo "Please run './scripts/backend_setup.sh' first to set up the backend environment."
    exit 1
fi
echo "INFO: Virtual environment found."

echo "INFO: Activating virtual environment..."
source "$VENV_PATH/bin/activate"
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Failed to activate virtual environment. Ensure it exists and is correctly set up."
    exit 1
fi
echo "INFO: Virtual environment activated."

# Check for .env file
if [ ! -f "$ENV_FILE_PATH" ]; then
    echo "⚠️ WARNING: '.env' file not found at $ENV_FILE_PATH."
    echo "The backend might not function correctly without required API keys and configurations."
    echo "Refer to 'docs/API_KEYS_CONFIGURATION.md' for setup instructions."
    # Optionally, exit if .env is strictly required:
    # exit 1
fi

# Check for firebase-service-account.json
if [ ! -f "$PROJECT_ROOT/firebase-service-account.json" ]; then
    echo "⚠️ WARNING: 'firebase-service-account.json' not found in $PROJECT_ROOT."
    echo "Firebase Admin SDK initialization will fail. The backend might not function correctly."
    echo "Refer to 'FIREBASE_SETUP_GUIDE.md' for setup instructions."
    # Optionally, exit if firebase-service-account.json is strictly required:
    # exit 1
fi


# --- Run Server ---
# Determine the port from .env file or use default
# This requires parsing the .env file or relying on uvicorn to pick up PORT from env after --env-file
# For simplicity, uvicorn with --env-file will handle PORT if set in .env,
# and backend_server.py has a default for PORT if not set.

echo "INFO: Starting Uvicorn server for $BACKEND_MODULE:$APP_VARIABLE_NAME..."
echo "INFO: Logs will be shown below. Press CTRL+C to stop the server."
echo "INFO: Ensure your .env file is correctly set up in $PROJECT_ROOT if not using system environment variables."

# Run uvicorn from the project root
# --env-file .env will load variables from .env in the current directory (PROJECT_ROOT)
# --reload enables auto-reloading on code changes, useful for development.
cd "$PROJECT_ROOT" || exit # Ensure we are in project root
uvicorn "$BACKEND_MODULE:$APP_VARIABLE_NAME" --reload --env-file "$ENV_FILE" --host 0.0.0.0
# If PORT is not picked up automatically by uvicorn via python-dotenv in the app,
# you might need to explicitly pass it:
# DEFAULT_PORT=8081
# APP_PORT=$(grep -E '^PORT=' $ENV_FILE_PATH | cut -d '=' -f2) || APP_PORT=$DEFAULT_PORT
# uvicorn "$BACKEND_MODULE:$APP_VARIABLE_NAME" --reload --env-file "$ENV_FILE_PATH" --port "$APP_PORT" --host 0.0.0.0


# Deactivate virtual environment when server is stopped (Ctrl+C)
# This might not always run if the script is killed abruptly.
trap 'deactivate_venv' INT TERM
deactivate_venv() {
    echo ""
    echo "INFO: Server stopped. Deactivating virtual environment..."
    deactivate
}

echo "INFO: Backend server script finished."
# Note: The script might not reach here if uvicorn runs indefinitely until Ctrl+C.
# The trap helps manage deactivation.
