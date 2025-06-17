# 🔮 Crystal Grimoire V3 - Modern Node.js Production

**Modern Node.js 20+ Crystal Grimoire backend with enhanced performance and features**

## 🚀 Quick Start for Jules

### Option 1: Automated Setup (Recommended)
```bash
./jules-setup.sh
```

### Option 2: Manual Setup
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## ✨ Modern Features

### 🔥 Performance Enhancements
- **Node.js 20+** - Latest runtime with performance improvements
- **Modern JavaScript** - Optional chaining, nullish coalescing, async/await
- **Built-in Performance Monitoring** - Request timing and metrics
- **Optimized Dependencies** - Minimal, fast loading packages

### 🧠 AI-Powered Features
- **Gemini 2.0 Flash** - Latest AI model for crystal identification
- **Enhanced Mock Responses** - Perfect fallbacks when AI unavailable
- **Personalized Guidance** - Context-aware spiritual advice
- **Smart Error Handling** - Graceful degradation

### 🔮 Crystal Grimoire API

#### Health Check
```bash
GET /health
```
Returns comprehensive system status with modern Node.js feature detection.

#### Crystal Identification
```bash
POST /api/crystal/identify
{
  "image_data": "base64_image_string",
  "user_context": { "user_id": "user123" }
}
```

#### Personalized Guidance
```bash
POST /api/guidance/personalized
{
  "user_id": "user123",
  "query": "How should I use crystals for meditation?",
  "guidance_type": "meditation"
}
```

#### Collection Management
```bash
GET /api/crystals/user123     # Get user's crystals
POST /api/crystals/user123    # Add crystal to collection
```

#### Moon Phase
```bash
GET /api/moon/current         # Current lunar phase
```

## 🏗️ Architecture

### Modern Node.js Stack
```
┌─────────────────┐
│   Flutter App   │ (Frontend)
└─────────┬───────┘
          │ HTTPS
┌─────────▼───────┐
│ Firebase Funcs  │ (Node.js 20)
│  Modern Backend │
└─────────┬───────┘
          │
┌─────────▼───────┐
│   Firestore     │ (Database)
└─────────────────┘
```

### Dependencies
```json
{
  "firebase-functions": "^6.3.2",
  "firebase-admin": "^12.1.0", 
  "@google/generative-ai": "^0.21.0",
  "cors": "^2.8.5",
  "express": "^4.21.1"
}
```

## 🧪 Testing

### Local Development
```bash
# Start Firebase emulator
npm run serve

# Test health endpoint
curl http://localhost:5001/crystalgrimoire-production/us-central1/health
```

### Production Testing
```bash
# Test deployed backend
curl https://us-central1-crystalgrimoire-production.cloudfunctions.net/health
```

## 📊 Performance Features

### Built-in Monitoring
- **Request Timing** - Automatic performance tracking
- **Modern Array Operations** - Optimized data processing
- **Memory Efficient** - Minimal memory footprint
- **Fast Cold Starts** - Optimized for serverless

### Modern JavaScript
```javascript
// Optional chaining
const value = config?.api?.key ?? 'default';

// Modern async patterns
const results = await Promise.allSettled(requests);

// Performance API
const start = performance.now();
// ... operations
const duration = performance.now() - start;
```

## 🔧 Configuration

### Environment Variables
```bash
# Set Gemini API key
firebase functions:config:set gemini.api_key="your_key_here"

# Or use environment variable
export GEMINI_API_KEY="your_key_here"
```

### Firebase Configuration
```json
{
  "functions": {
    "source": "functions",
    "runtime": "nodejs20",
    "ignore": ["node_modules", ".git"]
  }
}
```

## 🎯 Production Ready

### Features
✅ **Modern Node.js 20+** runtime  
✅ **Enhanced error handling** with graceful fallbacks  
✅ **Performance monitoring** built-in  
✅ **Comprehensive logging** for debugging  
✅ **CORS enabled** for web apps  
✅ **Rate limiting** resistant  
✅ **Auto-scaling** serverless functions  

### Security
✅ **Input validation** on all endpoints  
✅ **Error sanitization** prevents data leaks  
✅ **Authentication ready** for user context  
✅ **HTTPS only** communication  

## 📱 Frontend Integration

### Flutter Configuration
```dart
// lib/config/backend_config.dart
class BackendConfig {
  static const bool useBackend = true;
  static String get baseUrl => 
    'https://us-central1-crystalgrimoire-production.cloudfunctions.net/api';
}
```

### API Usage
```dart
// Crystal identification
final response = await http.post(
  Uri.parse('${BackendConfig.baseUrl}/crystal/identify'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'image_data': base64Image,
    'user_context': {'user_id': userId}
  }),
);
```

## 🔍 Debugging

### Logs
```bash
# View function logs
firebase functions:log

# Real-time logs
firebase functions:log --follow
```

### Health Diagnostics
The `/health` endpoint provides comprehensive diagnostics:
- Node.js version and features
- AI availability status
- Performance metrics
- Database connectivity
- Modern feature detection

## 🚀 Deployment

### Automated (Recommended)
```bash
./jules-setup.sh
```

### Manual
```bash
# Install dependencies
cd functions && npm install && cd ..

# Deploy functions
firebase deploy --only functions

# Deploy everything
firebase deploy
```

### Verification
1. **Health Check**: Visit `/health` endpoint
2. **Function List**: `firebase functions:list`
3. **Test API**: Try crystal identification
4. **Check Logs**: `firebase functions:log`

## 🎉 Success Indicators

✅ Health endpoint returns Node.js 20+ version  
✅ Modern features detection shows `true`  
✅ Crystal identification returns enhanced mock data  
✅ Performance metrics show sub-100ms response times  
✅ All endpoints respond with proper CORS headers  
✅ Firebase console shows successful deployments  

**Your modern Crystal Grimoire backend is ready for production! 🚀**