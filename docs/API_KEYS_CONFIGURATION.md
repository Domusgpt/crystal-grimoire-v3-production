# API Keys and Backend Configuration Guide

This document outlines the necessary API keys and environment variables required to run the Crystal Grimoire Python backend (`backend_server.py`).

## Backend Environment Variables

The Python backend uses environment variables to configure API keys and other settings. For local development, these are typically managed using a `.env` file in the project root directory. The backend loads these variables using `python-dotenv`.

Create a file named `.env` in the root of the project:

```
CrystalGrimoireProject/
├── backend_server.py
├── .env                     <-- CREATE THIS FILE HERE
├── firebase-service-account.json
└── ...other files
```

### `.env` File Template

Copy the following template into your `.env` file and replace the placeholder values with your actual keys and settings.

```env
# --- LLM API Keys ---
# Obtain from Google AI Studio (https://makersuite.google.com/app/apikey) or Google Cloud Console
GEMINI_API_KEY=your_gemini_api_key_here

# Obtain from OpenAI Platform (https://platform.openai.com/api-keys)
OPENAI_API_KEY=sk-your_openai_api_key_here

# Obtain from Anthropic Console (https://console.anthropic.com)
CLAUDE_API_KEY=sk-ant-your_claude_api_key_here

# --- Parserator API Key (If used by the backend) ---
# Obtain from your Parserator service provider/dashboard
PARSERATOR_API_KEY=your_parserator_api_key_here

# --- Backend Server Configuration ---
# Port for the FastAPI backend server to run on
PORT=8081

# Environment mode (development, production)
# Affects CORS settings and potentially other behaviors
ENVIRONMENT=development

# --- Other API Keys (Add as needed by the backend) ---
# Example: YOUR_OTHER_SERVICE_API_KEY=xxxxxxxxxxxx
```

**Important Security Note:**
*   **DO NOT commit your actual `.env` file to your Git repository.** This file contains sensitive API keys.
*   Add `.env` to your `.gitignore` file:
    ```
    # .gitignore
    # ... other entries
    .env
    firebase-service-account.json
    ```

## Obtaining API Keys

### 1. LLM API Keys (`GEMINI_API_KEY`, `OPENAI_API_KEY`, `CLAUDE_API_KEY`)
   *   Refer to the `docs/LLM_API_SETUP_GUIDE.md` for detailed instructions on how to sign up for these services and generate API keys.
   *   **GEMINI_API_KEY**: From Google AI Studio or Google Cloud Console (Generative Language API).
   *   **OPENAI_API_KEY**: From OpenAI Platform.
   *   **CLAUDE_API_KEY**: From Anthropic Console.

### 2. Parserator API Key (`PARSERATOR_API_KEY`)
   *   If your backend integrates with a "Parserator" service (as indicated by `PARSERATOR_API_KEY` in `backend_server.py`), you will need to obtain this key from the dashboard or documentation of that specific service.
   *   If this service is not used, you can leave the variable commented out or empty, but the backend code might expect it.

## Backend Configuration Loading

The Python backend (`backend_server.py`) uses `os.getenv('YOUR_VARIABLE_NAME')` to load these values. The `python-dotenv` library, if used at the beginning of the script (e.g., `from dotenv import load_dotenv; load_dotenv()`), automatically loads variables from an `.env` file found in the current working directory into environment variables.

Ensure `backend_server.py` is run from the project root directory where the `.env` file is located for `python-dotenv` to find it automatically.

## Verifying Configuration

After setting up your `.env` file:
1.  Run `backend_server.py`.
2.  Check the console output for any error messages related to missing API keys or incorrect configuration.
3.  The backend server should log which API keys are configured (e.g., "Gemini API: configured").

By following this guide, you can properly configure the necessary API keys and settings for the Crystal Grimoire backend.
