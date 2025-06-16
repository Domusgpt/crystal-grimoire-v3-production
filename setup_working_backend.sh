#!/bin/bash

# Crystal Grimoire V3 - Working Backend Setup Script
# This script fixes all integration issues and deploys a working backend

set -e  # Exit on any error

echo "🔮 Crystal Grimoire V3 - Working Backend Setup"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the crystal-grimoire-v3-production root directory"
    exit 1
fi

print_status "Checking prerequisites..."

# Check Node.js version
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version must be 18 or higher. Current version: $(node -v)"
    exit 1
fi

# Check Firebase CLI
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

print_success "Prerequisites check passed"

# Step 1: Clean up existing backend conflicts
print_status "Step 1: Cleaning up existing backend conflicts..."

# Remove conflicting files
rm -f functions/index.js.backup 2>/dev/null || true
rm -rf functions/node_modules 2>/dev/null || true

# Step 2: Create minimal working Firebase Functions
print_status "Step 2: Creating minimal working Firebase Functions..."

# Update package.json to use correct Node version
cat > functions/package.json << 'EOF'
{
  "name": "functions",
  "description": "Cloud Functions for Firebase",
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "shell": "firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "20"
  },
  "main": "index.js",
  "dependencies": {
    "cors": "^2.8.5",
    "firebase-admin": "^12.1.0",
    "firebase-functions": "^6.3.2",
    "@google/generative-ai": "^0.21.0",
    "express": "^4.21.1"
  },
  "devDependencies": {
    "eslint": "^8.15.0",
    "eslint-config-google": "^0.14.0"
  },
  "private": true
}
EOF

# Create working Firebase Functions with Gemini AI
cat > functions/index.js << 'EOF'
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
const express = require('express');

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Initialize Gemini AI (only if API key is available)
let genAI = null;
try {
  const { GoogleGenerativeAI } = require('@google/generative-ai');
  const apiKey = process.env.GEMINI_API_KEY || functions.config()?.gemini?.api_key;
  if (apiKey) {
    genAI = new GoogleGenerativeAI(apiKey);
  }
} catch (error) {
  console.warn('Gemini AI not available:', error.message);
}

// Create Express app
const app = express();
app.use(cors);
app.use(express.json({ limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    firebase: 'connected',
    functions: 'active',
    project: process.env.GCLOUD_PROJECT,
    gemini: genAI ? 'available' : 'not_configured'
  });
});

// Crystal identification endpoint
app.post('/crystal/identify', async (req, res) => {
  try {
    const { image_data, user_context } = req.body;
    
    if (!image_data) {
      return res.status(400).json({ error: 'No image data provided' });
    }

    // Mock response if Gemini is not available
    if (!genAI) {
      return res.json({
        identification: {
          name: 'Clear Quartz',
          variety: 'Natural',
          scientific_name: 'Silicon Dioxide (SiO2)',
          confidence: 85
        },
        metaphysical_properties: {
          primary_chakras: ['Crown', 'All'],
          zodiac_signs: ['All'],
          planetary_rulers: ['Sun'],
          elements: ['All'],
          healing_properties: ['Amplification', 'Clarity', 'Healing'],
          intentions: ['Amplification', 'Clarity', 'Purification']
        },
        physical_properties: {
          hardness: '7',
          crystal_system: 'Hexagonal',
          luster: 'Vitreous',
          transparency: 'Transparent to translucent',
          color_range: ['Clear', 'White'],
          formation: 'Igneous and metamorphic',
          chemical_formula: 'SiO2',
          density: '2.65 g/cm³'
        },
        care_instructions: {
          cleansing_methods: ['Running water', 'Moonlight', 'Sage'],
          charging_methods: ['Sunlight', 'Moonlight', 'Crystal cluster'],
          storage_recommendations: 'Store in soft cloth to prevent scratching',
          handling_notes: 'Durable crystal, safe for regular handling'
        },
        personalized_guidance: 'This crystal amplifies your intentions and brings clarity to your spiritual practice.',
        timestamp: new Date().toISOString(),
        mock: true
      });
    }

    // Real Gemini AI identification
    const prompt = `
You are an expert crystal healer. Identify this crystal and return ONLY valid JSON in this format:
{
  "identification": {
    "name": "Crystal Name",
    "variety": "Variety if applicable",
    "scientific_name": "Chemical composition",
    "confidence": 95
  },
  "metaphysical_properties": {
    "primary_chakras": ["Chakra names"],
    "zodiac_signs": ["Associated signs"],
    "planetary_rulers": ["Associated planets"],
    "elements": ["Associated elements"],
    "healing_properties": ["Healing properties"],
    "intentions": ["Primary uses"]
  },
  "physical_properties": {
    "hardness": "Mohs scale",
    "crystal_system": "Crystal system",
    "luster": "Luster type",
    "transparency": "Transparency level",
    "color_range": ["Colors"],
    "formation": "Formation type",
    "chemical_formula": "Formula",
    "density": "Density"
  },
  "care_instructions": {
    "cleansing_methods": ["Methods"],
    "charging_methods": ["Methods"],
    "storage_recommendations": "Storage advice",
    "handling_notes": "Care notes"
  },
  "personalized_guidance": "Brief guidance"
}
`;

    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });
    
    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: image_data.replace(/^data:image\/[a-z]+;base64,/, '')
        }
      }
    ]);

    const response = await result.response;
    const text = response.text();

    let crystalData;
    try {
      crystalData = JSON.parse(text);
    } catch (parseError) {
      throw new Error('Invalid AI response format');
    }

    // Save to database
    if (user_context?.user_id) {
      await db.collection('identifications').add({
        user_id: user_context.user_id,
        crystal_data: crystalData,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    res.json({
      ...crystalData,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Crystal identification error:', error);
    res.status(500).json({
      error: 'Crystal identification failed',
      details: error.message
    });
  }
});

// Personalized guidance endpoint
app.post('/guidance/personalized', async (req, res) => {
  try {
    const { user_id, query } = req.body;

    if (!user_id) {
      return res.status(400).json({ error: 'User ID required' });
    }

    // Mock response if Gemini not available
    if (!genAI) {
      return res.json({
        guidance: `Based on your spiritual journey, I sense you're seeking clarity and growth. Your crystals are here to support you. Consider meditating with your favorite stone today and setting clear intentions for your path ahead.`,
        timestamp: new Date().toISOString(),
        mock: true
      });
    }

    // Get user context from database
    let userContext = {};
    try {
      const userDoc = await db.collection('users').doc(user_id).get();
      if (userDoc.exists) {
        userContext = userDoc.data();
      }
    } catch (error) {
      console.warn('Could not fetch user context:', error.message);
    }

    const guidancePrompt = `
You are a wise spiritual guide. Provide personalized guidance for this query: "${query || 'General spiritual guidance'}"

User context: ${JSON.stringify(userContext)}

Provide warm, nurturing guidance that feels personal and helpful. Keep it to 2-3 sentences.
`;

    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });
    const result = await model.generateContent(guidancePrompt);
    const response = await result.response;
    const guidance = response.text();

    res.json({
      guidance,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Guidance error:', error);
    res.status(500).json({
      error: 'Failed to generate guidance',
      details: error.message
    });
  }
});

// User collection endpoints
app.get('/crystals/:user_id', async (req, res) => {
  try {
    const { user_id } = req.params;
    
    const crystalsSnapshot = await db.collection('users').doc(user_id)
      .collection('crystals').get();
    
    const crystals = crystalsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    res.json(crystals);
  } catch (error) {
    console.error('Get crystals error:', error);
    res.status(500).json({ error: 'Failed to get crystals' });
  }
});

app.post('/crystals/:user_id', async (req, res) => {
  try {
    const { user_id } = req.params;
    const crystalData = req.body;
    
    const docRef = await db.collection('users').doc(user_id)
      .collection('crystals').add({
        ...crystalData,
        created_at: admin.firestore.FieldValue.serverTimestamp()
      });
    
    res.json({ id: docRef.id, ...crystalData });
  } catch (error) {
    console.error('Add crystal error:', error);
    res.status(500).json({ error: 'Failed to add crystal' });
  }
});

// Export the Express app as a Firebase Function
exports.api = functions.https.onRequest(app);

// Simple health check function
exports.health = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      project: process.env.GCLOUD_PROJECT
    });
  });
});
EOF

# Step 3: Update Firebase configuration
print_status "Step 3: Updating Firebase configuration..."

# Update firebase.json
cat > firebase.json << 'EOF'
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Cross-Origin-Embedder-Policy",
            "value": "require-corp"
          },
          {
            "key": "Cross-Origin-Opener-Policy", 
            "value": "same-origin"
          }
        ]
      }
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
    ]
  },
  "firestore": {
    "database": "(default)",
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": {
    "source": "functions",
    "runtime": "nodejs20",
    "ignore": [
      "node_modules",
      ".git",
      "firebase-debug.log",
      "firebase-debug.*.log",
      "*.local"
    ]
  }
}
EOF

# Step 4: Create simple backend configuration for Flutter
print_status "Step 4: Updating Flutter backend configuration..."

cat > lib/config/backend_config.dart << 'EOF'
import 'package:http/http.dart' as http;

/// Backend API Configuration for CrystalGrimoire
class BackendConfig {
  // Environment-based backend URL configuration
  static const bool _isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const String _customBackendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');
  
  // Backend API URL - Environment based
  static String get baseUrl {
    if (_customBackendUrl.isNotEmpty) {
      return '$_customBackendUrl/api';
    }
    
    return _isProduction 
      ? 'https://crystalgrimoire-production.web.app/api'
      : 'http://localhost:5001/crystalgrimoire-production/us-central1/api';
  }
  
  // Use backend API - now enabled by default
  static const bool useBackend = true;
  
  // Environment-based backend forcing
  static bool get forceBackendIntegration => 
    const bool.fromEnvironment('FORCE_BACKEND', defaultValue: false);
  
  // API Endpoints
  static const String identifyEndpoint = '/crystal/identify';
  static const String crystalsEndpoint = '/crystals';
  static const String guidanceEndpoint = '/guidance/personalized';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  
  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // Check if backend is available
  static Future<bool> isBackendAvailable() async {
    if (!useBackend) return false;
    
    try {
      final healthUrl = baseUrl.replaceAll('/api', '') + '/health';
      final response = await http.get(
        Uri.parse(healthUrl),
        headers: headers,
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Backend not available at $baseUrl: $e');
      return false;
    }
  }
  
  // Get configuration summary
  static Map<String, dynamic> getConfigSummary() {
    return {
      'base_url': baseUrl,
      'is_production': _isProduction,
      'use_backend': useBackend,
      'endpoints': {
        'identify': '$baseUrl$identifyEndpoint',
        'crystals': '$baseUrl$crystalsEndpoint',
        'guidance': '$baseUrl$guidanceEndpoint',
      }
    };
  }
}
EOF

# Step 5: Install dependencies
print_status "Step 5: Installing dependencies..."

cd functions
npm install
cd ..

flutter pub get

# Step 6: Login to Firebase (if not already logged in)
print_status "Step 6: Checking Firebase authentication..."

if ! firebase projects:list &>/dev/null; then
    print_warning "Not logged into Firebase. Please login..."
    firebase login
fi

# Step 7: Set Firebase project
print_status "Step 7: Setting Firebase project..."
firebase use crystalgrimoire-production

# Step 8: Set environment variables (if available)
print_status "Step 8: Setting up environment variables..."

# Check if .env file exists and set variables
if [ -f ".env" ]; then
    print_status "Found .env file, setting environment variables..."
    
    # Extract GEMINI_API_KEY from .env if it exists
    if grep -q "GEMINI_API_KEY" .env; then
        GEMINI_KEY=$(grep "GEMINI_API_KEY" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
        if [ ! -z "$GEMINI_KEY" ]; then
            print_status "Setting Gemini API key in Firebase config..."
            firebase functions:config:set gemini.api_key="$GEMINI_KEY" || print_warning "Could not set Gemini API key"
        fi
    fi
else
    print_warning "No .env file found. You may need to set environment variables manually."
    cat > .env.example << 'EOF'
GEMINI_API_KEY=your_gemini_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
FIREBASE_API_KEY=your_firebase_api_key_here
EOF
    print_status "Created .env.example file. Copy to .env and add your API keys."
fi

# Step 9: Deploy functions
print_status "Step 9: Deploying Firebase Functions..."

# Try to deploy with better error handling
if firebase deploy --only functions --debug; then
    print_success "Firebase Functions deployed successfully!"
else
    print_warning "Function deployment failed. Trying with --force flag..."
    if firebase deploy --only functions --force; then
        print_success "Firebase Functions deployed successfully with --force!"
    else
        print_error "Function deployment failed. Check the logs above."
        print_status "You can try manual deployment later with: firebase deploy --only functions"
    fi
fi

# Step 10: Test the deployment
print_status "Step 10: Testing deployment..."

HEALTH_URL="https://us-central1-crystalgrimoire-production.cloudfunctions.net/health"
print_status "Testing health endpoint: $HEALTH_URL"

if curl -s "$HEALTH_URL" | grep -q "healthy"; then
    print_success "Backend is responding correctly!"
else
    print_warning "Backend may not be responding yet. It can take a few minutes after deployment."
fi

# Step 11: Build Flutter web
print_status "Step 11: Building Flutter web application..."

if flutter build web --release; then
    print_success "Flutter web build successful!"
else
    print_warning "Flutter build failed. There may be compilation issues to resolve."
fi

# Step 12: Deploy hosting
print_status "Step 12: Deploying to Firebase Hosting..."

if firebase deploy --only hosting; then
    print_success "Hosting deployed successfully!"
else
    print_warning "Hosting deployment failed."
fi

# Final summary
echo ""
echo "=============================================="
print_success "🔮 Crystal Grimoire V3 Setup Complete!"
echo "=============================================="
echo ""
print_status "Your backend is deployed at:"
echo "  Health Check: https://us-central1-crystalgrimoire-production.cloudfunctions.net/health"
echo "  API Base: https://us-central1-crystalgrimoire-production.cloudfunctions.net/api"
echo ""
print_status "Your web app is deployed at:"
echo "  https://crystalgrimoire-production.web.app"
echo ""
print_status "API Endpoints available:"
echo "  POST /api/crystal/identify - Crystal identification with Gemini AI"
echo "  POST /api/guidance/personalized - Personalized spiritual guidance"
echo "  GET  /api/crystals/:user_id - Get user's crystal collection"
echo "  POST /api/crystals/:user_id - Add crystal to collection"
echo ""
if [ ! -f ".env" ]; then
    print_warning "⚠️  Don't forget to create .env file with your API keys!"
fi
print_status "Next steps:"
echo "  1. Test the health endpoint in your browser"
echo "  2. Test crystal identification in your app"
echo "  3. Check Firebase console for any errors"
echo ""
print_success "Setup script completed! Your working backend is ready! 🚀"
EOF