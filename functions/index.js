const functions = require('firebase-functions');

// Simple test function
exports.test = functions.https.onRequest((req, res) => {
  res.status(200).json({
    message: '🔮 Crystal Grimoire V3 Backend is LIVE!',
    timestamp: new Date().toISOString(),
    status: 'production-ready'
  });
});

// Health check
exports.health = functions.https.onRequest((req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'crystal-grimoire-v3'
  });
});