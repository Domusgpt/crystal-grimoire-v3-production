const admin = require('firebase-admin');

// Test script to verify Firebase connection
async function testFirestore() {
  try {
    // Initialize Firebase Admin
    admin.initializeApp({
      projectId: 'crystalgrimoire-v3-production'
    });
    
    const db = admin.firestore();
    
    console.log('Testing Firestore connection...');
    
    // Test write
    await db.collection('test').doc('connection').set({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      message: 'Firebase connection test',
      status: 'working'
    });
    
    console.log('✅ Write test passed');
    
    // Test read
    const doc = await db.collection('test').doc('connection').get();
    if (doc.exists) {
      console.log('✅ Read test passed');
      console.log('Data:', doc.data());
    } else {
      console.log('❌ Read test failed - document not found');
    }
    
    // Test GenAI extension trigger
    console.log('Testing GenAI extension...');
    await db.collection('crystal_identifications').add({
      userId: 'test-user',
      imageUrl: 'gs://test-bucket/test-image.jpg',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      status: 'processing'
    });
    
    console.log('✅ GenAI extension trigger test sent');
    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Firebase test failed:', error);
    process.exit(1);
  }
}

testFirestore();