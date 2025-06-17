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
