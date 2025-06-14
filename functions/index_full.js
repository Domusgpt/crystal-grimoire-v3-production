const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Crystal Identification Orchestrator
 * Triggers Firebase AI Logic extension when crystal image uploaded
 */
exports.processCrystalUpload = functions.storage.object().onFinalize(async (object) => {
  try {
    if (!object.name?.startsWith('crystal_uploads/')) return;
  
  const userId = object.name.split('/')[1];
  const imageUrl = `gs://${object.bucket}/${object.name}`;
  
  // Trigger AI Logic extension by creating document
  await db.collection('crystal_uploads').add({
    userId,
    imageUrl,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    status: 'processing'
  });
  
  console.log(`Crystal identification triggered for user ${userId}`);
  } catch (error) {
    console.error('Error in processCrystalUpload:', error);
  }
});

/**
 * Personalized AI Response Builder
 * Enhances AI Logic extension output with user context
 */
exports.enhanceAIResponse = functions.firestore
  .document('crystal_identifications/{docId}')
  .onCreate(async (snap, context) => {
    try {
    const data = snap.data();
    const userId = data.userId;
    
    // Get user profile and collection for personalization
    const [userDoc, crystalsSnap] = await Promise.all([
      db.collection('users').doc(userId).get(),
      db.collection('users').doc(userId).collection('crystals').get()
    ]);
    
    const userProfile = userDoc.data();
    const ownedCrystals = crystalsSnap.docs.map(doc => doc.data().name);
    
    // Build personalized context
    const personalizationContext = {
      birthChart: {
        sunSign: userProfile?.sunSign,
        moonSign: userProfile?.moonSign,
        ascendant: userProfile?.ascendant
      },
      collection: {
        ownedCrystals,
        totalCrystals: ownedCrystals.length,
        recentAcquisitions: ownedCrystals.slice(-3)
      },
      spiritualGoals: userProfile?.spiritualGoals || []
    };
    
    // Update with personalized guidance
    await snap.ref.update({
      personalizationContext,
      personalizedGuidance: generatePersonalizedGuidance(data.aiResponse, personalizationContext),
      enhancedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    } catch (error) {
      console.error('Error in enhanceAIResponse:', error);
    }
});

/**
 * Subscription Tier Manager
 * Works with Auth Custom Claims extension for access control
 */
exports.updateSubscriptionClaims = functions.firestore
  .document('customers/{userId}/subscriptions/{subscriptionId}')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const subscription = change.after.exists ? change.after.data() : null;
    
    let claims = { subscription_tier: 'free' };
    
    if (subscription?.status === 'active') {
      const priceId = subscription.price?.id;
      if (priceId?.includes('premium')) claims.subscription_tier = 'premium';
      if (priceId?.includes('pro')) claims.subscription_tier = 'pro';
      if (priceId?.includes('founders')) claims.subscription_tier = 'founders';
    }
    
    // Set custom claims for access control
    await admin.auth().setCustomUserClaims(userId, claims);
    
    // Update user document
    await db.collection('users').doc(userId).update({
      subscriptionTier: claims.subscription_tier,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    });
});

/**
 * Real-time Notification Orchestrator
 * Triggers FCM extension for user engagement
 */
exports.sendEngagementNotifications = functions.pubsub
  .schedule('every day 09:00')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const usersSnap = await db.collection('users').where('notificationsEnabled', '==', true).get();
    
    for (const userDoc of usersSnap.docs) {
      const userData = userDoc.data();
      
      // Create notification document (triggers FCM extension)
      await db.collection('notifications').add({
        userId: userDoc.id,
        type: 'daily_crystal_insight',
        title: 'Your Daily Crystal Guidance',
        body: `Today's energy calls for ${getDailyCrystalRecommendation(userData)}`,
        data: {
          screen: 'crystal_guidance',
          crystalName: getDailyCrystalRecommendation(userData)
        },
        scheduledFor: admin.firestore.FieldValue.serverTimestamp()
      });
    }
});

/**
 * Analytics Event Processor
 * Enhances BigQuery export with custom events
 */
exports.trackCustomEvents = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  
  const { eventType, properties } = data;
  const userId = context.auth.uid;
  
  // Create analytics document (auto-exported to BigQuery)
  await db.collection('analytics_events').add({
    userId,
    eventType,
    properties,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    userAgent: context.rawRequest.get('user-agent'),
    ip: context.rawRequest.ip
  });
  
  return { success: true };
});

// Helper functions
function generatePersonalizedGuidance(aiResponse, context) {
  const { birthChart, collection } = context;
  
  return `Based on your ${birthChart.sunSign} sun sign and your collection of ${collection.totalCrystals} crystals, 
    this ${aiResponse.name} will particularly resonate with your ${birthChart.moonSign} moon energy. 
    Consider pairing it with your ${collection.recentAcquisitions[0]} for enhanced spiritual work.`;
}

function getDailyCrystalRecommendation(userData) {
  const crystals = ['Amethyst', 'Clear Quartz', 'Rose Quartz', 'Citrine', 'Black Tourmaline'];
  const index = new Date().getDay() % crystals.length;
  return crystals[index];
}