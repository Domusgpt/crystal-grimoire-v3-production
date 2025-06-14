const functions = require('firebase-functions');

// Simple test function
exports.helloWorld = functions.https.onRequest((req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    message: '🔮 CrystalGrimoire V3 is LIVE!',
    timestamp: new Date().toISOString(),
    status: 'production-ready'
  });
});

// Health check function
exports.health = functions.https.onRequest((req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    firebase: 'connected',
    functions: 'active'
  });
});