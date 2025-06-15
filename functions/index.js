const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });

// Simple health check function
exports.health = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      firebase: 'connected',
      functions: 'active',
      project: 'crystalgrimoire-production'
    });
  });
});

// API function for crystal identification and backend services
exports.api = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const path = req.path;
    const method = req.method;
    
    // Handle different API endpoints
    if (path === '/crystal/identify' && method === 'POST') {
      res.status(200).json({
        message: 'Crystal identification endpoint ready',
        timestamp: new Date().toISOString(),
        status: 'production-ready'
      });
    } else if (path === '/crystals' && method === 'GET') {
      res.status(200).json({
        message: 'Crystal collection endpoint ready',
        timestamp: new Date().toISOString(),
        crystals: []
      });
    } else {
      res.status(404).json({
        error: 'Endpoint not found',
        path: path,
        method: method
      });
    }
  });
});

// Hello world function for testing
exports.helloWorld = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    res.status(200).json({
      message: '🔮 CrystalGrimoire V3 is LIVE!',
      timestamp: new Date().toISOString(),
      status: 'production-ready'
    });
  });
});