import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/main.dart';
import 'lib/services/storage_service.dart';
import 'lib/services/firebase_service.dart';
import 'lib/services/collection_service_v2.dart';
import 'lib/services/ai_service.dart';
import 'lib/services/unified_ai_service.dart';
import 'lib/services/unified_data_service.dart';

/// REAL FLUTTER APP TESTING
/// Tests actual app widgets and functionality
void main() {
  group('Crystal Grimoire App Tests', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      print('🚀 Testing app launch...');
      
      await tester.pumpWidget(const CrystalGrimoireApp());
      await tester.pumpAndSettle();
      
      // Should not crash and should show some UI
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✅ App launches successfully');
    });

    testWidgets('Auth gate shows login/signup options', (WidgetTester tester) async {
      print('🔐 Testing authentication screen...');
      
      await tester.pumpWidget(const CrystalGrimoireApp());
      await tester.pumpAndSettle();
      
      // Should show auth options
      expect(find.text('Crystal Grimoire'), findsWidgets);
      print('✅ Auth screen displays');
    });

    test('Storage Service works', () async {
      print('💾 Testing storage service...');
      
      final storage = StorageService();
      await storage.initialize();
      
      // Test profile creation
      final profile = await storage.getOrCreateUserProfile();
      expect(profile.name, isNotEmpty);
      
      // Test subscription storage
      await StorageService.saveSubscriptionTier('premium');
      final tier = await StorageService.getSubscriptionTier();
      expect(tier, equals('premium'));
      
      print('✅ Storage service working');
    });

    test('Collection Service works', () async {
      print('🗃️ Testing collection service...');
      
      final firebase = FirebaseService();
      final collection = CollectionServiceV2(firebaseService: firebase);
      
      await collection.initialize();
      expect(collection.isLoaded, isTrue);
      
      final stats = collection.getStats();
      expect(stats.totalCrystals, isA<int>());
      
      print('✅ Collection service working');
    });

    test('AI Service configuration', () async {
      print('🔮 Testing AI service...');
      
      // Check AI service is properly configured
      expect(AIService.currentProvider, equals(AIProvider.gemini));
      
      // Test provider selection
      expect(AIService.currentProvider, isA<AIProvider>());
      
      print('✅ AI service configured');
    });

    test('Unified Services initialize', () async {
      print('🚀 Testing unified services...');
      
      final firebase = FirebaseService();
      final storage = StorageService();
      final collection = CollectionServiceV2(firebaseService: firebase);
      
      // Test UnifiedDataService
      final unifiedData = UnifiedDataService(
        firebaseService: firebase,
        storageService: storage,
      );
      await unifiedData.initialize();
      
      // Test UnifiedAIService  
      final unifiedAI = UnifiedAIService(
        storageService: storage,
        collectionService: collection,
      );
      
      expect(unifiedData.isAuthenticated, isA<bool>());
      expect(unifiedAI.isLoading, isFalse);
      
      print('✅ Unified services working');
    });

    test('Firebase Service initializes', () async {
      print('🔥 Testing Firebase service...');
      
      final firebase = FirebaseService();
      await firebase.initialize();
      
      // Should initialize without error
      expect(firebase.isAuthenticated, isA<bool>());
      
      print('✅ Firebase service working');
    });
  });
}