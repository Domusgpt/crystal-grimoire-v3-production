#!/usr/bin/env node
// Simple test server to verify Node.js/Express works

const express = require('express');
const app = express();
const PORT = 3000;

app.get('/test', (req, res) => {
  res.json({
    status: 'working',
    message: 'Simple test server is running',
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🧪 Simple test server running on http://localhost:${PORT}`);
  console.log('✅ Test endpoint: http://localhost:3000/test');
});