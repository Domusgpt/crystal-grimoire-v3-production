# Stripe Payment System

## Overview
The Stripe Payment System handles all subscription management, payment processing, and revenue operations for Crystal Grimoire through Firebase's firestore-stripe-payments extension. This system supports the freemium model with multiple subscription tiers and secure payment processing.

## Firebase Extension Configuration

### Extension Details
- **Extension**: `stripe/firestore-stripe-payments@0.3.4` ✅ Installed
- **Status**: Production-ready with live Stripe keys
- **Security**: Restricted API keys with specific permissions

### Stripe Configuration
```env
# Live Stripe Keys (Production)
STRIPE_PUBLISHABLE_KEY=pk_live_51PMpy5P7RjgzZkITofdd9PKcjsMIWGPuaf7cUhNJImqq275D8k8z7tVoGPzrWvla5RUiF1tAAHsYu3qBVWWHVxym00JwtRER7t
STRIPE_SECRET_KEY=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

# Subscription Price IDs
STRIPE_PREMIUM_PRICE_ID=price_1RWLUuP7RjgzZkITg22yi41w
STRIPE_PRO_PRICE_ID=price_1RWLUvP7RjgzZkITm0kK5iJA
STRIPE_FOUNDERS_PRICE_ID=price_1RWLUvP7RjgzZkITCigXVDcH
```

## Subscription Tiers

### Free Tier (Default)
```javascript
const freeTier = {
  name: "Crystal Explorer",
  price: 0,
  features: {
    crystal_identifications: 10,
    collections: 1,
    basic_guidance: true,
    crystal_database: "basic",
    moon_phases: false,
    healing_sessions: false,
    dream_journal: false,
    sound_bath: false,
    expert_consultations: false,
    ads: true
  },
  limits: {
    crystals_per_month: 10,
    collections_max: 1,
    guidance_requests: 5,
    image_uploads: "1MB max"
  }
}
```

### Premium Tier ($9.99/month)
```javascript
const premiumTier = {
  name: "Crystal Mystic",
  price: 9.99,
  stripe_price_id: "price_1RWLUuP7RjgzZkITg22yi41w",
  features: {
    crystal_identifications: 100,
    collections: 10,
    advanced_guidance: true,
    crystal_database: "comprehensive",
    moon_phases: true,
    healing_sessions: true,
    dream_journal: true,
    sound_bath: "basic",
    expert_consultations: false,
    ads: false
  },
  limits: {
    crystals_per_month: 100,
    collections_max: 10,
    guidance_requests: 50,
    image_uploads: "5MB max"
  },
  exclusive_features: [
    "Moon ritual planner",
    "Personalized crystal healing sessions",
    "Dream journal with crystal correlations",
    "Basic sound bath frequencies"
  ]
}
```

### Pro Tier ($24.99/month)
```javascript
const proTier = {
  name: "Crystal Master",
  price: 24.99,
  stripe_price_id: "price_1RWLUvP7RjgzZkITm0kK5iJA",
  features: {
    crystal_identifications: 1000,
    collections: "unlimited",
    expert_guidance: true,
    crystal_database: "professional",
    moon_phases: true,
    healing_sessions: true,
    dream_journal: true,
    sound_bath: "advanced",
    expert_consultations: true,
    ads: false
  },
  limits: {
    crystals_per_month: 1000,
    collections_max: -1, // unlimited
    guidance_requests: 200,
    image_uploads: "25MB max"
  },
  exclusive_features: [
    "Bulk crystal identification",
    "Advanced healing protocol recommendations",
    "Professional-grade sound bath library",
    "Direct expert consultations (2 per month)",
    "Export collection data",
    "API access for developers"
  ]
}
```

### Founders Tier ($99.99/year)
```javascript
const foundersTier = {
  name: "Crystal Sage",
  price: 99.99,
  billing_cycle: "yearly",
  stripe_price_id: "price_1RWLUvP7RjgzZkITCigXVDcH",
  features: {
    crystal_identifications: "unlimited",
    collections: "unlimited",
    sage_guidance: true,
    crystal_database: "master",
    moon_phases: true,
    healing_sessions: true,
    dream_journal: true,
    sound_bath: "premium",
    expert_consultations: "unlimited",
    ads: false
  },
  limits: {
    crystals_per_month: -1, // unlimited
    collections_max: -1, // unlimited
    guidance_requests: -1, // unlimited
    image_uploads: "100MB max"
  },
  founder_exclusive: [
    "Lifetime features guarantee",
    "Early access to new features",
    "Direct developer support",
    "Custom crystal database contributions",
    "Sage-level AI guidance",
    "Premium sound healing library",
    "Unlimited expert consultations",
    "Special founder badge and perks"
  ]
}
```

## Stripe Dashboard Permissions

Based on the screenshot of your Stripe dashboard, the API key has these permissions:
- **Financial Connections**: None/Read ✅
- **All webhook**: View documentation ✅  
- **Webhook Endpoints**: None/Read/Write ✅
- **Stripe CLI permissions**: None/Write ✅
- **Payment Links**: None/Read/Write ✅
- **Terminal**: None/Read/Write ✅

## Payment Flow Implementation

### Subscription Creation
```dart
class StripePaymentService {
  static Future<String> createSubscription({
    required String userId,
    required String priceId,
    required String tier,
  }) async {
    try {
      // Create checkout session in Firestore
      final checkoutSession = await FirebaseFirestore.instance
        .collection('customers')
        .doc(userId)
        .collection('checkout_sessions')
        .add({
          'price': priceId,
          'success_url': 'https://crystalgrimoire.com/success?session_id={CHECKOUT_SESSION_ID}',
          'cancel_url': 'https://crystalgrimoire.com/cancel',
          'mode': 'subscription',
          'metadata': {
            'user_id': userId,
            'tier': tier,
            'upgrade_timestamp': FieldValue.serverTimestamp(),
          },
          'allow_promotion_codes': true,
          'billing_address_collection': 'required',
          'customer_email': FirebaseAuth.instance.currentUser?.email,
          'line_items': [
            {
              'price': priceId,
              'quantity': 1,
            }
          ],
          'subscription_data': {
            'metadata': {
              'user_id': userId,
              'tier': tier,
            }
          }
        });
      
      // Wait for Stripe to populate the checkout URL
      return await _waitForCheckoutUrl(checkoutSession.id);
      
    } catch (e) {
      print('Error creating subscription: $e');
      throw Exception('Failed to create subscription');
    }
  }
  
  static Future<String> _waitForCheckoutUrl(String sessionId) async {
    for (int i = 0; i < 30; i++) {
      await Future.delayed(Duration(seconds: 1));
      
      final session = await FirebaseFirestore.instance
        .collection('customers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('checkout_sessions')
        .doc(sessionId)
        .get();
      
      final url = session.data()?['url'];
      if (url != null) {
        return url as String;
      }
    }
    
    throw Exception('Checkout session URL not generated');
  }
}
```

### Subscription Management
```dart
class SubscriptionManager {
  static Future<SubscriptionStatus> getCurrentSubscription(String userId) async {
    final customer = await FirebaseFirestore.instance
      .collection('customers')
      .doc(userId)
      .get();
    
    final subscriptions = await FirebaseFirestore.instance
      .collection('customers')
      .doc(userId)
      .collection('subscriptions')
      .where('status', isEqualTo: 'active')
      .orderBy('created', descending: true)
      .limit(1)
      .get();
    
    if (subscriptions.docs.isEmpty) {
      return SubscriptionStatus.free();
    }
    
    final subscription = subscriptions.docs.first.data();
    return SubscriptionStatus.fromFirestore(subscription);
  }
  
  static Future<void> cancelSubscription(String userId) async {
    final subscriptions = await FirebaseFirestore.instance
      .collection('customers')
      .doc(userId)
      .collection('subscriptions')
      .where('status', isEqualTo: 'active')
      .get();
    
    for (final sub in subscriptions.docs) {
      await sub.reference.update({
        'cancel_at_period_end': true,
        'cancellation_reason': 'user_requested',
        'cancelled_at': FieldValue.serverTimestamp(),
      });
    }
  }
  
  static Future<void> reactivateSubscription(String userId) async {
    final subscriptions = await FirebaseFirestore.instance
      .collection('customers')
      .doc(userId)
      .collection('subscriptions')
      .where('cancel_at_period_end', isEqualTo: true)
      .get();
    
    for (final sub in subscriptions.docs) {
      await sub.reference.update({
        'cancel_at_period_end': false,
        'reactivated_at': FieldValue.serverTimestamp(),
      });
    }
  }
}
```

## Revenue Analytics

### Subscription Metrics
```javascript
const revenueAnalytics = {
  key_metrics: {
    mrr: "Monthly Recurring Revenue",
    arr: "Annual Recurring Revenue", 
    churn_rate: "Monthly customer churn percentage",
    ltv: "Customer Lifetime Value",
    cac: "Customer Acquisition Cost",
    upgrade_rate: "Free to paid conversion rate"
  },
  
  cohort_analysis: {
    monthly_cohorts: "Track subscription retention by signup month",
    tier_performance: "Compare performance across subscription tiers",
    geographic_analysis: "Revenue breakdown by region"
  },
  
  subscription_health: {
    active_subscriptions: "Current paying subscribers",
    trial_conversions: "Trial to paid conversion rates",
    upgrade_paths: "Most common upgrade journeys",
    cancellation_reasons: "Why users cancel subscriptions"
  }
}
```

### Revenue Tracking
```dart
class RevenueTracker {
  static Future<Map<String, dynamic>> getRevenueMetrics() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    // Get all active subscriptions
    final activeSubscriptions = await FirebaseFirestore.instance
      .collectionGroup('subscriptions')
      .where('status', isEqualTo: 'active')
      .get();
    
    // Calculate MRR
    double mrr = 0;
    final tierCounts = <String, int>{};
    
    for (final sub in activeSubscriptions.docs) {
      final data = sub.data();
      final priceId = data['price']?['id'];
      final amount = (data['price']?['unit_amount'] ?? 0) / 100; // Convert from cents
      
      mrr += amount;
      
      // Count by tier
      final tier = _getTierFromPriceId(priceId);
      tierCounts[tier] = (tierCounts[tier] ?? 0) + 1;
    }
    
    // Calculate ARR (assuming monthly subscriptions)
    final arr = mrr * 12;
    
    return {
      'mrr': mrr,
      'arr': arr,
      'active_subscribers': activeSubscriptions.docs.length,
      'tier_breakdown': tierCounts,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
  
  static String _getTierFromPriceId(String? priceId) {
    switch (priceId) {
      case 'price_1RWLUuP7RjgzZkITg22yi41w': return 'premium';
      case 'price_1RWLUvP7RjgzZkITm0kK5iJA': return 'pro';
      case 'price_1RWLUvP7RjgzZkITCigXVDcH': return 'founders';
      default: return 'free';
    }
  }
}
```

## Feature Access Control

### Subscription Validation
```dart
class SubscriptionGate {
  static Future<bool> hasFeatureAccess(String userId, String feature) async {
    final subscription = await SubscriptionManager.getCurrentSubscription(userId);
    
    switch (subscription.tier) {
      case 'free':
        return _freeFeatures.contains(feature);
      case 'premium':
        return _premiumFeatures.contains(feature);
      case 'pro':
        return _proFeatures.contains(feature);
      case 'founders':
        return _foundersFeatures.contains(feature);
      default:
        return _freeFeatures.contains(feature);
    }
  }
  
  static Future<bool> hasUsageRemaining(String userId, String usageType) async {
    final subscription = await SubscriptionManager.getCurrentSubscription(userId);
    final usage = await _getCurrentUsage(userId, usageType);
    
    final limit = _getUsageLimit(subscription.tier, usageType);
    if (limit == -1) return true; // Unlimited
    
    return usage < limit;
  }
  
  static Future<void> trackUsage(String userId, String usageType, {int amount = 1}) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('usage')
      .doc(_getCurrentMonth())
      .set({
        usageType: FieldValue.increment(amount),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
  }
}
```

### Upgrade Prompts
```dart
class UpgradePromptManager {
  static Future<void> showUpgradePrompt(BuildContext context, String feature) async {
    final currentTier = await SubscriptionManager.getCurrentSubscription(
      FirebaseAuth.instance.currentUser!.uid
    );
    
    final recommendedTier = _getMinimumTierForFeature(feature);
    
    showDialog(
      context: context,
      builder: (context) => UpgradeDialog(
        currentTier: currentTier.tier,
        recommendedTier: recommendedTier,
        feature: feature,
        benefits: _getTierBenefits(recommendedTier),
        onUpgrade: () => _initiateUpgrade(context, recommendedTier),
      ),
    );
  }
  
  static String _getMinimumTierForFeature(String feature) {
    if (_premiumFeatures.contains(feature)) return 'premium';
    if (_proFeatures.contains(feature)) return 'pro';
    if (_foundersFeatures.contains(feature)) return 'founders';
    return 'free';
  }
}
```

## Payment Error Handling

### Failed Payment Recovery
```dart
class PaymentErrorHandler {
  static Future<void> handlePaymentFailure(String userId, Map<String, dynamic> errorData) async {
    final errorType = errorData['type'] as String;
    final errorCode = errorData['code'] as String;
    
    switch (errorCode) {
      case 'card_declined':
        await _handleCardDeclined(userId, errorData);
        break;
      case 'insufficient_funds':
        await _handleInsufficientFunds(userId, errorData);
        break;
      case 'expired_card':
        await _handleExpiredCard(userId, errorData);
        break;
      default:
        await _handleGenericPaymentError(userId, errorData);
    }
  }
  
  static Future<void> _handleCardDeclined(String userId, Map<String, dynamic> errorData) async {
    // Send email notification
    await EmailService.sendEmail(
      template: 'payment_failed_card_declined',
      userId: userId,
      data: {
        'errorMessage': 'Your card was declined',
        'retryUrl': 'https://crystalgrimoire.com/billing/retry',
        'supportUrl': 'https://crystalgrimoire.com/support',
      }
    );
    
    // Schedule retry attempt in 3 days
    await _schedulePaymentRetry(userId, DateTime.now().add(Duration(days: 3)));
  }
  
  static Future<void> _schedulePaymentRetry(String userId, DateTime retryAt) async {
    await FirebaseFirestore.instance
      .collection('payment_retries')
      .add({
        'user_id': userId,
        'retry_at': Timestamp.fromDate(retryAt),
        'attempts': 0,
        'max_attempts': 3,
        'created_at': FieldValue.serverTimestamp(),
      });
  }
}
```

## Webhook Handling

### Stripe Webhook Events
```javascript
// Cloud Function to handle Stripe webhooks
const stripeWebhookHandler = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;
  
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.log(`Webhook signature verification failed.`, err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  
  switch (event.type) {
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object);
      break;
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object);
      break;
    case 'customer.subscription.deleted':
      await handleSubscriptionCancelled(event.data.object);
      break;
    case 'invoice.payment_failed':
      await handlePaymentFailed(event.data.object);
      break;
    case 'invoice.payment_succeeded':
      await handlePaymentSucceeded(event.data.object);
      break;
    default:
      console.log(`Unhandled event type ${event.type}`);
  }
  
  res.json({received: true});
});
```

## Security & Compliance

### PCI Compliance
- **No card data storage**: All payment processing handled by Stripe
- **HTTPS only**: All payment flows use secure connections
- **Token-based**: Frontend uses Stripe publishable keys only
- **Webhook verification**: All webhooks verified with signing secrets

### Fraud Prevention
```dart
class FraudPrevention {
  static Future<bool> validateSubscriptionAttempt(String userId, String priceId) async {
    // Check for rapid subscription changes
    final recentSubscriptions = await FirebaseFirestore.instance
      .collection('customers')
      .doc(userId)
      .collection('subscriptions')
      .where('created', isGreaterThan: Timestamp.fromDate(
        DateTime.now().subtract(Duration(hours: 24))
      ))
      .get();
    
    if (recentSubscriptions.docs.length > 3) {
      await _flagSuspiciousActivity(userId, 'rapid_subscription_changes');
      return false;
    }
    
    return true;
  }
}
```

This comprehensive Stripe payment system provides secure, scalable subscription management with robust error handling and revenue optimization features.