// Test Crystallis Codexicus AI Extension
// Run this after Firestore is set up

const admin = require('firebase-admin');

// Initialize Firebase Admin (if not already done)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function testCrystallisCodexicus() {
  console.log('🔮 Testing Crystallis Codexicus...');
  
  // Test data for Pro-tier user
  const testData = {
    userId: 'test_seeker_001',
    imageUrl: 'https://example.com/amethyst-crystal.jpg',
    userQuery: 'What wisdom does this sacred stone hold for my spiritual journey?',
    subscriptionTier: 'pro',
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    status: 'pending'
  };
  
  try {
    // Create test document in crystal_identifications collection
    const docRef = await db.collection('crystal_identifications').add(testData);
    console.log('✅ Test document created:', docRef.id);
    
    // Listen for AI response
    const unsubscribe = db.collection('crystal_identifications').doc(docRef.id)
      .onSnapshot((doc) => {
        const data = doc.data();
        if (data.output) {
          console.log('🎉 Crystallis Codexicus responded!');
          console.log('📜 Response:', data.output);
          
          // Check for Lumarian references and spiritual tone
          const response = data.output.toLowerCase();
          if (response.includes('lumarian') || response.includes('dimensional')) {
            console.log('✅ Lumarian lore detected!');
          }
          if (response.includes('sacred') || response.includes('spiritual')) {
            console.log('✅ Spiritual tone confirmed!');
          }
          if (response.includes('temporally incarcerated')) {
            console.log('✅ Ego-bound consciousness phrase found!');
          }
          
          unsubscribe();
        }
      });
    
    // Wait for response (timeout after 30 seconds)
    setTimeout(() => {
      console.log('⏰ Test timeout - check Firebase Console for results');
      unsubscribe();
    }, 30000);
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Test different subscription tiers
async function testTierFeatures() {
  console.log('🎯 Testing tier-based features...');
  
  const tiers = ['free', 'premium', 'pro', 'founders'];
  
  for (const tier of tiers) {
    const testData = {
      userId: `test_${tier}_user`,
      imageUrl: 'https://example.com/rose-quartz.jpg', 
      userQuery: 'How can this crystal help with my heart chakra?',
      subscriptionTier: tier,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      status: 'pending'
    };
    
    try {
      const docRef = await db.collection('crystal_identifications').add(testData);
      console.log(`✅ ${tier.toUpperCase()} tier test created:`, docRef.id);
    } catch (error) {
      console.error(`❌ ${tier} tier test failed:`, error);
    }
  }
}

// Run tests
console.log('🚀 Starting Crystallis Codexicus tests...');
testCrystallisCodexicus();
setTimeout(() => testTierFeatures(), 5000);

module.exports = { testCrystallisCodexicus, testTierFeatures };