import 'package:flutter/material.dart';
import 'lib/models/user_profile.dart';
import 'lib/models/crystal_collection.dart';
import 'lib/models/crystal.dart';
import 'lib/models/birth_chart.dart';
import 'lib/services/unified_llm_context_builder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing UnifiedLLMContextBuilder');
  print('=' * 50);
  
  // Create sample user profile
  final birthChart = BirthChart.calculate(
    birthDate: DateTime(1990, 7, 15),
    birthTime: '14:30',
    birthLocation: 'New York, NY',
    latitude: 40.7128,
    longitude: -74.0060,
  );
  
  final userProfile = UserProfile(
    id: 'test_user',
    name: 'Test User',
    email: 'test@example.com',
    birthChart: birthChart,
    subscriptionTier: SubscriptionTier.premium,
    spiritualPreferences: {
      'goals': ['healing', 'meditation', 'protection'],
      'experience_level': 'intermediate',
      'preferred_practices': ['crystal_healing', 'meditation'],
      'intentions': ['peace', 'clarity'],
    },
    monthlyUsage: {},
    createdAt: DateTime.now(),
    lastActiveAt: DateTime.now(),
    isEmailVerified: true,
    settings: {},
    favoriteFeatures: [],
    customProperties: {},
  );
  
  // Create sample crystal collection
  final amethyst = Crystal(
    id: 'amethyst_1',
    name: 'Amethyst',
    scientificName: 'Silicon Dioxide',
    group: 'Quartz',
    description: 'Purple variety of quartz',
    metaphysicalProperties: ['Enhances intuition', 'Promotes calm'],
    healingProperties: ['Stress relief', 'Better sleep'],
    chakras: ['Third Eye', 'Crown'],
    elements: ['Water', 'Air'],
    properties: {},
    colorDescription: 'Purple',
    hardness: '7',
    formation: 'Igneous',
    careInstructions: 'Avoid direct sunlight',
    imageUrls: [],
    type: 'Quartz',
    color: 'Purple',
    imageUrl: '',
    planetaryRulers: ['Jupiter'],
    zodiacSigns: ['Pisces'],
    crystalSystem: 'Hexagonal',
    formations: ['Cluster'],
    chargingMethods: ['Moonlight'],
    cleansingMethods: ['Running water'],
    bestCombinations: ['Clear Quartz'],
    recommendedIntentions: ['Peace'],
    vibrationFrequency: 'High',
  );
  
  final roseQuartz = Crystal(
    id: 'rose_quartz_1',
    name: 'Rose Quartz',
    scientificName: 'Silicon Dioxide',
    group: 'Quartz',
    description: 'Pink variety of quartz',
    metaphysicalProperties: ['Promotes love', 'Emotional healing'],
    healingProperties: ['Heart healing', 'Self-love'],
    chakras: ['Heart'],
    elements: ['Water'],
    properties: {},
    colorDescription: 'Pink',
    hardness: '7',
    formation: 'Igneous',
    careInstructions: 'Safe for all cleansing',
    imageUrls: [],
    type: 'Quartz',
    color: 'Pink',
    imageUrl: '',
    planetaryRulers: ['Venus'],
    zodiacSigns: ['Taurus'],
    crystalSystem: 'Hexagonal',
    formations: ['Tumbled'],
    chargingMethods: ['Sunlight'],
    cleansingMethods: ['Salt water'],
    bestCombinations: ['Green Aventurine'],
    recommendedIntentions: ['Love'],
    vibrationFrequency: 'Medium',
  );
  
  final collection = [
    CollectionEntry(
      id: 'entry_1',
      userId: 'test_user',
      crystal: amethyst,
      dateAdded: DateTime.now().subtract(Duration(days: 30)),
      source: 'purchased',
      location: 'Crystal Shop NYC',
      price: 25.99,
      size: 'medium',
      quality: 'tumbled',
      primaryUses: ['meditation', 'sleep'],
      usageCount: 15,
      userRating: 5.0,
      notes: 'My favorite for meditation',
      images: [],
      isActive: true,
      isFavorite: true,
      customProperties: {},
    ),
    CollectionEntry(
      id: 'entry_2',
      userId: 'test_user',
      crystal: roseQuartz,
      dateAdded: DateTime.now().subtract(Duration(days: 10)),
      source: 'gifted',
      size: 'small',
      quality: 'raw',
      primaryUses: ['love', 'healing'],
      usageCount: 8,
      userRating: 4.5,
      notes: 'Gift from friend',
      images: [],
      isActive: true,
      isFavorite: false,
      customProperties: {},
    ),
  ];
  
  try {
    print('✅ Test 1: Creating context builder...');
    final contextBuilder = UnifiedLLMContextBuilder();
    
    print('✅ Test 2: Building user context...');
    final userContext = await contextBuilder.buildUserContextForLLM(
      userProfile: userProfile,
      crystalCollection: collection,
      currentQuery: 'Test crystal identification',
      queryType: 'identification',
    );
    
    print('✅ Test 3: Verifying context structure...');
    print('User Profile Keys: ${userContext['user_profile']?.keys}');
    print('Birth Chart: ${userContext['user_profile']?['birth_chart']}');
    print('Collection Size: ${userContext['crystal_collection']?['total_crystals']}');
    print('Favorite Crystals: ${userContext['crystal_collection']?['favorite_crystals']}');
    
    print('✅ Test 4: Building personalized prompt...');
    final personalizedPrompt = contextBuilder.buildPersonalizedPrompt(
      basePrompt: 'Identify this crystal and provide guidance',
      userContext: userContext,
      includeAstrologicalContext: true,
      includeCollectionDetails: true,
      includeEMACompliance: true,
    );
    
    print('✅ Test 5: Verifying prompt includes user data...');
    final promptLines = personalizedPrompt.split('\n');
    final hasAstrology = promptLines.any((line) => line.contains('Sun Sign') || line.contains('Moon Sign'));
    final hasCollection = promptLines.any((line) => line.contains('Amethyst') || line.contains('Rose Quartz'));
    final hasEMA = promptLines.any((line) => line.contains('EXODITICAL MORAL ARCHITECTURE'));
    
    print('   Includes Astrology: $hasAstrology');
    print('   Includes Collection: $hasCollection');
    print('   Includes EMA: $hasEMA');
    
    if (hasAstrology && hasCollection && hasEMA) {
      print('🎉 ALL TESTS PASSED! Context Builder is working correctly!');
      print('');
      print('Sample prompt preview:');
      print(personalizedPrompt.substring(0, 500) + '...');
    } else {
      print('❌ Tests failed - prompt missing required elements');
    }
    
  } catch (e, stackTrace) {
    print('❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
  }
}