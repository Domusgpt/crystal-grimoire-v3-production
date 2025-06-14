# Email System

## Overview
The Email System provides comprehensive automated communication for Crystal Grimoire users through Firebase's firestore-send-email extension. This system handles transactional emails, marketing communications, and personalized notifications based on user activity and crystal interactions.

## Firebase Extension Configuration

### Extension Details
- **Extension**: `firebase/firestore-send-email@0.2.3`
- **Status**: ✅ Installed and Configured
- **Collection**: `mail`
- **SMTP Provider**: Gmail SMTP

### Configuration Settings
```json
{
  "firestore_instance": "(default)",
  "collection": "mail", 
  "smtp_connection_uri": "smtps://smtp.gmail.com:465",
  "default_from": "Crystal Grimoire <phillips.paul.email@gmail.com>",
  "default_reply_to": "noreply@crystalgrimoire.com",
  "users_collection": "users",
  "templates_collection": "email_templates"
}
```

## Gmail OAuth2 Setup

### Required Credentials
```env
# Gmail OAuth2 Configuration
GMAIL_CLIENT_ID=your-oauth-client-id.apps.googleusercontent.com
GMAIL_CLIENT_SECRET=your-oauth-client-secret
GMAIL_REFRESH_TOKEN=your-refresh-token
SMTP_PASSWORD=your-app-password
```

### Setup Process
1. **Google Cloud Console**:
   - Enable Gmail API
   - Create OAuth 2.0 credentials
   - Configure consent screen

2. **Generate Refresh Token**:
```bash
# Use OAuth playground or custom script
curl -d "client_id=${CLIENT_ID}" \
     -d "client_secret=${CLIENT_SECRET}" \
     -d "refresh_token=${REFRESH_TOKEN}" \
     -d "grant_type=refresh_token" \
     https://oauth2.googleapis.com/token
```

3. **Firebase Configuration**:
```bash
firebase ext:configure firestore-send-email
# Set OAuth credentials in Secret Manager
```

## Email Templates

### Welcome Series
```javascript
// 1. Welcome Email
const welcomeEmail = {
  subject: "Welcome to Crystal Grimoire ✨",
  template: "welcome",
  data: {
    userName: "{{user.displayName}}",
    crystalLimit: "{{subscription.crystalLimit}}",
    features: "{{subscription.features}}",
    gettingStartedUrl: "https://crystalgrimoire.com/getting-started"
  },
  html: `
    <h1>Welcome to Crystal Grimoire, {{userName}}! ✨</h1>
    <p>Your journey into the mystical world of crystals begins now.</p>
    
    <div class="feature-box">
      <h3>Your {{subscriptionTier}} Account Includes:</h3>
      <ul>
        <li>Identify up to {{crystalLimit}} crystals</li>
        <li>{{features.length}} premium features</li>
        <li>Personalized crystal recommendations</li>
      </ul>
    </div>
    
    <a href="{{gettingStartedUrl}}" class="cta-button">Start Identifying Crystals</a>
  `
}

// 2. First Crystal Identification
const firstCrystalEmail = {
  subject: "🔮 Your First Crystal Has Been Identified!",
  template: "first_crystal",
  trigger: "after crystal identification when user.stats.crystalsIdentified === 1",
  data: {
    crystalName: "{{crystal.identification.name}}",
    confidence: "{{crystal.identification.confidence}}",
    chakra: "{{crystal.automation_data.chakra.primary}}",
    zodiac: "{{crystal.automation_data.zodiac.primary_signs}}",
    imageUrl: "{{crystal.images.medium}}"
  }
}
```

### Transactional Emails

#### Crystal Identification Results
```javascript
const crystalIdentifiedEmail = {
  subject: "✨ {{crystalName}} Identified with {{confidence}}% Confidence",
  template: "crystal_identified",
  data: {
    crystalName: string,
    confidence: number,
    chakra: string,
    zodiac: string[],
    healingProperties: string[],
    imageUrl: string,
    personalizedInsight: string,
    nextSteps: string[]
  },
  html: `
    <div class="crystal-result">
      <img src="{{imageUrl}}" alt="{{crystalName}}" class="crystal-image"/>
      <h2>{{crystalName}}</h2>
      <div class="confidence-badge">{{confidence}}% Match</div>
      
      <div class="metaphysical-grid">
        <div class="chakra-info">
          <h3>Primary Chakra</h3>
          <span class="chakra-{{chakra}}">{{chakra | capitalize}}</span>
        </div>
        
        <div class="zodiac-info">
          <h3>Zodiac Compatibility</h3>
          <div class="zodiac-signs">
            {{#each zodiac}}
            <span class="zodiac-{{this}}">{{this | capitalize}}</span>
            {{/each}}
          </div>
        </div>
      </div>
      
      <div class="personalized-section">
        <h3>Personalized for You</h3>
        <p>{{personalizedInsight}}</p>
      </div>
      
      <div class="next-steps">
        <h3>Suggested Next Steps</h3>
        <ul>
          {{#each nextSteps}}
          <li>{{this}}</li>
          {{/each}}
        </ul>
      </div>
    </div>
  `
}
```

#### Subscription Management
```javascript
const subscriptionEmails = {
  upgrade_confirmation: {
    subject: "🎉 Welcome to Crystal Grimoire {{newTier | capitalize}}!",
    data: {
      newTier: string,
      newFeatures: string[],
      newLimits: object,
      billingInfo: object
    }
  },
  
  payment_failed: {
    subject: "⚠️ Payment Issue - Action Required",
    data: {
      amount: number,
      nextAttempt: Date,
      updatePaymentUrl: string
    }
  },
  
  subscription_cancelled: {
    subject: "We're sorry to see you go 💔",
    data: {
      accessUntil: Date,
      reactivateUrl: string,
      feedbackUrl: string
    }
  }
}
```

### Engagement & Retention

#### Weekly Crystal Insights
```javascript
const weeklyInsightsEmail = {
  subject: "🌙 Your Weekly Crystal Guidance - {{currentDate}}",
  schedule: "every Sunday at 6PM user timezone",
  template: "weekly_insights",
  data: {
    userName: string,
    weeklyHoroscope: string,
    recommendedCrystal: object,
    collectionInsights: object,
    upcomingMoonPhase: object,
    personalizedRituals: object[]
  },
  html: `
    <div class="weekly-insights">
      <h1>Your Weekly Crystal Guidance</h1>
      
      <div class="horoscope-section">
        <h2>This Week's Energy</h2>
        <p>{{weeklyHoroscope}}</p>
      </div>
      
      <div class="crystal-spotlight">
        <h2>Featured Crystal from Your Collection</h2>
        <img src="{{recommendedCrystal.imageUrl}}" alt="{{recommendedCrystal.name}}"/>
        <h3>{{recommendedCrystal.name}}</h3>
        <p>{{recommendedCrystal.weeklyGuidance}}</p>
      </div>
      
      <div class="moon-phase">
        <h2>Upcoming: {{upcomingMoonPhase.name}}</h2>
        <p>{{upcomingMoonPhase.ritualSuggestion}}</p>
      </div>
    </div>
  `
}
```

#### Collection Milestone Emails
```javascript
const milestoneEmails = {
  collection_milestones: [
    {
      trigger: "crystalCount === 5",
      subject: "🏆 You've collected 5 crystals!",
      reward: "unlock_crystal_pairing_feature"
    },
    {
      trigger: "crystalCount === 25", 
      subject: "✨ Crystal Collector Achievement Unlocked!",
      reward: "premium_feature_trial"
    },
    {
      trigger: "allChakrasCovered === true",
      subject: "🌈 Chakra Mastery - Complete Balance Achieved!",
      reward: "exclusive_healing_guide"
    }
  ]
}
```

## Automated Email Triggers

### User Journey Automation
```javascript
const emailAutomation = {
  // Day 0: Sign up
  welcome_series: {
    day_0: "welcome_email",
    day_1: "getting_started_guide", 
    day_3: "first_crystal_reminder",
    day_7: "feature_discovery",
    day_14: "subscription_upgrade_offer"
  },
  
  // Activity-based triggers
  crystal_identification: {
    immediate: "identification_results",
    after_24h: "crystal_care_tips",
    after_week: "pairing_suggestions"
  },
  
  // Subscription lifecycle
  subscription_events: {
    trial_ending: "upgrade_reminder",
    payment_failed: "billing_issue_alert",
    subscription_renewed: "thank_you_renewal"
  },
  
  // Re-engagement campaigns
  inactive_users: {
    after_7_days: "we_miss_you",
    after_30_days: "special_offer",
    after_90_days: "final_attempt"
  }
}
```

### Personalization Engine Integration
```javascript
const personalizedEmails = {
  content_personalization: {
    birth_chart_integration: {
      sun_sign: "Tailor horoscope content",
      moon_sign: "Emotional crystal recommendations", 
      rising_sign: "Public persona crystal suggestions"
    },
    
    collection_analysis: {
      chakra_gaps: "Suggest missing chakra crystals",
      color_preferences: "Highlight similar colored stones",
      zodiac_alignment: "Recommend compatible crystals"
    },
    
    usage_patterns: {
      meditation_frequency: "Meditation crystal suggestions",
      healing_sessions: "Therapeutic crystal guidance",
      ritual_participation: "Moon phase notifications"
    }
  }
}
```

## Email API Integration

### Sending Emails
```dart
class EmailService {
  static Future<void> sendEmail({
    required String template,
    required String userId,
    required Map<String, dynamic> data,
    String? customSubject,
  }) async {
    final user = await FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final emailDoc = {
      'to': user.email,
      'template': {
        'name': template,
        'data': {
          ...data,
          'userName': user.displayName ?? 'Crystal Explorer',
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        }
      }
    };
    
    if (customSubject != null) {
      emailDoc['subject'] = customSubject;
    }
    
    await FirebaseFirestore.instance
      .collection('mail')
      .add(emailDoc);
  }
  
  // Send crystal identification email
  static Future<void> sendCrystalIdentificationEmail(
    String userId, 
    CrystalIdentificationResult result
  ) async {
    await sendEmail(
      template: 'crystal_identified',
      userId: userId,
      data: {
        'crystalName': result.identification.name,
        'confidence': result.identification.confidence,
        'chakra': result.automation_data.chakra.primary,
        'zodiac': result.automation_data.zodiac.primarySigns,
        'healingProperties': result.comprehensive_data.metaphysical_properties,
        'imageUrl': result.images.medium,
        'personalizedInsight': await _generatePersonalizedInsight(userId, result),
      }
    );
  }
}
```

### Email Status Tracking
```dart
class EmailStatusTracker {
  static Stream<EmailStatus> trackEmailStatus(String emailId) {
    return FirebaseFirestore.instance
      .collection('mail')
      .doc(emailId)
      .snapshots()
      .map((doc) {
        final data = doc.data();
        return EmailStatus(
          id: doc.id,
          status: data?['delivery']?['state'] ?? 'pending',
          sentAt: data?['delivery']?['startTime'],
          deliveredAt: data?['delivery']?['endTime'],
          error: data?['delivery']?['error'],
        );
      });
  }
  
  static Future<List<EmailStatus>> getUserEmailHistory(String userId) async {
    final query = await FirebaseFirestore.instance
      .collection('mail')
      .where('template.data.userId', isEqualTo: userId)
      .orderBy('delivery.startTime', descending: true)
      .limit(50)
      .get();
      
    return query.docs.map((doc) => EmailStatus.fromFirestore(doc)).toList();
  }
}
```

## Email Analytics

### Performance Metrics
```javascript
const emailAnalytics = {
  delivery_metrics: {
    delivery_rate: "Percentage of emails successfully delivered",
    open_rate: "Percentage of emails opened",
    click_rate: "Percentage of emails with clicks",
    unsubscribe_rate: "Percentage of unsubscribes"
  },
  
  template_performance: {
    welcome_series: {
      open_rate: "85%",
      click_rate: "45%",
      conversion_rate: "12%"
    },
    crystal_identified: {
      open_rate: "92%", 
      click_rate: "67%",
      app_return_rate: "78%"
    }
  },
  
  user_engagement: {
    email_preferences: "Track user email settings",
    response_tracking: "Monitor user actions after emails",
    lifecycle_analysis: "Email impact on user retention"
  }
}
```

### A/B Testing Framework
```dart
class EmailABTesting {
  static Future<String> getEmailVariant(String template, String userId) async {
    final userHash = userId.hashCode % 100;
    
    final experiments = await FirebaseFirestore.instance
      .collection('email_experiments')
      .where('template', isEqualTo: template)
      .where('active', isEqualTo: true)
      .get();
    
    for (final experiment in experiments.docs) {
      final data = experiment.data();
      final splitPercentage = data['split_percentage'] as int;
      
      if (userHash < splitPercentage) {
        return data['variant_a'] as String;
      } else {
        return data['variant_b'] as String;
      }
    }
    
    return template; // Default template
  }
}
```

## Privacy & Compliance

### GDPR Compliance
```dart
class EmailPrivacyManager {
  static Future<void> updateEmailPreferences(
    String userId, 
    EmailPreferences preferences
  ) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
        'email_preferences': preferences.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });
  }
  
  static Future<void> unsubscribeUser(String userId, String reason) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
        'email_preferences.marketing': false,
        'email_preferences.notifications': false,
        'unsubscribe_reason': reason,
        'unsubscribed_at': FieldValue.serverTimestamp(),
      });
  }
  
  static Future<void> deleteUserEmailData(String userId) async {
    // Delete all emails for user (GDPR right to be forgotten)
    final batch = FirebaseFirestore.instance.batch();
    
    final emails = await FirebaseFirestore.instance
      .collection('mail')
      .where('template.data.userId', isEqualTo: userId)
      .get();
    
    for (final doc in emails.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
}
```

## Error Handling & Monitoring

### Email Failure Management
```dart
class EmailErrorHandler {
  static Future<void> handleEmailFailure(String emailId, String error) async {
    // Log error
    await FirebaseFirestore.instance
      .collection('email_errors')
      .add({
        'email_id': emailId,
        'error': error,
        'timestamp': FieldValue.serverTimestamp(),
        'retry_count': 0,
      });
    
    // Retry logic for transient errors
    if (_isRetriableError(error)) {
      await _scheduleRetry(emailId);
    }
  }
  
  static bool _isRetriableError(String error) {
    final retriableErrors = [
      'temporary failure',
      'rate limit',
      'server busy',
    ];
    
    return retriableErrors.any((e) => error.toLowerCase().contains(e));
  }
}
```

This comprehensive email system provides automated, personalized communication that enhances user engagement and drives retention throughout the Crystal Grimoire experience.