import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:crystal_grimoire/models/unified_crystal_data.dart';
import 'package:crystal_grimoire/models/user_profile.dart'; // For UserProfile, BirthChart
import 'package:crystal_grimoire/services/unified_data_service.dart';
import 'package:crystal_grimoire/services/backend_service.dart';
import 'package:crystal_grimoire/services/storage_service.dart';
import 'package:crystal_grimoire/services/firebase_service.dart'; // For auth state and profile stream

// Generate mocks for dependencies
@GenerateMocks([BackendService, StorageService, FirebaseService, UserProfile, BirthChart])
import 'unified_data_service_test.mocks.dart';

void main() {
  late UnifiedDataService unifiedDataService;
  late MockBackendService mockBackendService;
  late MockStorageService mockStorageService;
  late MockFirebaseService mockFirebaseService;

  // Helper to create sample UnifiedCrystalData JSON
  Map<String, dynamic> sampleCrystalJson(String id, String stoneType) {
    return {
      "crystal_core": {
        "id": id, "timestamp": DateTime.now().toIso8601String(), "confidence_score": 0.9,
        "visual_analysis": {"primary_color": "Blue", "secondary_colors": [], "transparency": "Transparent", "formation": "Point"},
        "identification": {"stone_type": stoneType, "crystal_family": "TestFamily", "variety": "TestVariety", "confidence": 0.95},
        "energy_mapping": {"primary_chakra": "Throat", "secondary_chakras": [], "chakra_number": 5, "vibration_level": "High"},
        "astrological_data": {"primary_signs": ["Gemini"], "compatible_signs": [], "planetary_ruler": "Mercury", "element": "Air"},
        "numerology": {"crystal_number": 1, "color_vibration": 1, "chakra_number": 5, "master_number": 7}
      },
      "user_integration": null,
      "automatic_enrichment": {"mineral_class": "TestClass"}
    };
  }

  UnifiedCrystalData sampleCrystalData(String id, String stoneType) {
    return UnifiedCrystalData.fromJson(sampleCrystalJson(id, stoneType));
  }

  setUp(() {
    mockBackendService = MockBackendService();
    mockStorageService = MockStorageService();
    mockFirebaseService = MockFirebaseService();

    // Provide default mock behaviors
    when(mockStorageService.loadUserProfile()).thenAnswer((_) async => null);
    when(mockFirebaseService.isAuthenticated).thenReturn(false);
    when(mockBackendService.getUserCollection()).thenAnswer((_) async => []); // Default to empty collection

    // Default behaviors for mockBackendService instance methods
    when(mockBackendService.isAuthenticated).thenReturn(false);
    when(mockBackendService.currentUserId).thenReturn(null);
    when(mockBackendService.getUserCollection(userId: anyNamed('userId'))).thenAnswer((_) async => []);
    when(mockBackendService.saveCrystal(any)).thenAnswer((realInvocation) async => realInvocation.positionalArguments.first as UnifiedCrystalData);
    when(mockBackendService.updateCrystal(any)).thenAnswer((realInvocation) async => realInvocation.positionalArguments.first as UnifiedCrystalData);
    when(mockBackendService.deleteCrystal(any)).thenAnswer((_) async => {});


    unifiedDataService = UnifiedDataService(
      firebaseService: mockFirebaseService,
      storageService: mockStorageService,
      backendService: mockBackendService, // Inject the mock
      // ParseOperatorService can be omitted if not central to the tested logic or a simple mock used
    );
  });

  group('Initialization', () {
    test('initializes with empty collection if not authenticated', () async {
      when(mockBackendService.isAuthenticated).thenReturn(false);
      when(mockBackendService.currentUserId).thenReturn(null);

      await unifiedDataService.initialize();

      expect(unifiedDataService.crystalCollection, isEmpty);
      // Verify that getUserCollection was NOT called with any user ID
      verifyNever(mockBackendService.getUserCollection(userId: anyNamed('userId')));
    });

    test('loads crystal collection from BackendService if authenticated', () async {
      final crystals = [sampleCrystalData("id1", "Testinite")];
      when(mockBackendService.isAuthenticated).thenReturn(true);
      when(mockBackendService.currentUserId).thenReturn("user123");
      when(mockBackendService.getUserCollection(userId: "user123")).thenAnswer((_) async => crystals);

      await unifiedDataService.initialize();

      expect(unifiedDataService.crystalCollection, crystals);
      verify(mockBackendService.getUserCollection(userId: "user123")).called(1);
    });
  });

  group('Crystal CRUD Operations', () {
    setUp(() {
        // Ensure authenticated state for CRUD tests
        when(mockBackendService.isAuthenticated).thenReturn(true);
        when(mockBackendService.currentUserId).thenReturn("user123_crud");
        // Reset collection for each test in this group to avoid interference
        unifiedDataService.crystalCollection.clear();
    });

    test('addCrystal calls BackendService.saveCrystal and updates collection', () async {
      final newCrystal = sampleCrystalData("newId", "Novaculite");
      // The UserIntegration part will be enriched by UnifiedDataService.addCrystal
      final expectedCrystalToSave = newCrystal.copyWith(
        userIntegration: UserIntegration(
            userId: "user123_crud",
            addedToCollection: anyNamed('addedToCollection'), // cannot easily predict this in expect
            intentionSettings: [], userExperiences: []
        )
      );
      final savedCrystalFromBackend = newCrystal.copyWith( // Simulate backend returning the saved obj
         userIntegration: UserIntegration(userId: "user123_crud", addedToCollection: DateTime.now().toIso8601String(), intentionSettings: [], userExperiences: [])
      );


      when(mockBackendService.saveCrystal(any)).thenAnswer((_) async => savedCrystalFromBackend);

      await unifiedDataService.addCrystal(newCrystal);

      expect(unifiedDataService.crystalCollection, contains(savedCrystalFromBackend));

      final captured = verify(mockBackendService.saveCrystal(captureAny)).captured;
      final UnifiedCrystalData capturedCrystal = captured.first;
      expect(capturedCrystal.crystalCore.id, "newId");
      expect(capturedCrystal.userIntegration?.userId, "user123_crud");
      expect(capturedCrystal.userIntegration?.addedToCollection, isNotNull);

      // verify(mockFirebaseService.trackUserActivity(any, any)).called(1); // If still used
    });

    test('updateCrystal calls BackendService.updateCrystal and updates item in collection', () async {
      final initialCrystal = sampleCrystalData("id1", "OldName");
      unifiedDataService.crystalCollection.add(initialCrystal);

      final updatedCrystalDataFromUI = sampleCrystalData("id1", "NewName");
       // Simulate what UDS's updateCrystal does if it enriches user_id
      final expectedCrystalToUpdate = updatedCrystalDataFromUI.copyWith(
        userIntegration: (updatedCrystalDataFromUI.userIntegration ?? UserIntegration(intentionSettings: [], userExperiences: []))
                            .copyWith(userId: "user123_crud")
      );


      when(mockBackendService.updateCrystal(any)).thenAnswer((_) async => expectedCrystalToUpdate);

      await unifiedDataService.updateCrystal(updatedCrystalDataFromUI);

      expect(unifiedDataService.crystalCollection.first.crystalCore.identification.stoneType, "NewName");
      verify(mockBackendService.updateCrystal(argThat(predicate<UnifiedCrystalData>((c) => c.crystalCore.id == "id1" && c.userIntegration?.userId == "user123_crud")))).called(1);
    });

    test('removeCrystal calls BackendService.deleteCrystal and removes item from collection', () async {
      final crystalId = "id1";
      final crystalToRemove = sampleCrystalData(crystalId, "Removite");
      unifiedDataService.crystalCollection.add(crystalToRemove);

      when(mockBackendService.deleteCrystal(crystalId)).thenAnswer((_) async => {});

      await unifiedDataService.removeCrystal(crystalId);

      expect(unifiedDataService.crystalCollection, isEmpty);
      verify(mockBackendService.deleteCrystal(crystalId)).called(1);
    });
  });

  group('_updateSpiritualContext', () {
    test('correctly maps UnifiedCrystalData to spiritual context', () {
      // Mock UserProfile
      final mockUserProfile = MockUserProfile();
      when(mockUserProfile.name).thenReturn('Test User');
      when(mockUserProfile.birthChart).thenReturn(null); // Or MockBirthChart
      when(mockUserProfile.subscriptionTier).thenReturn(SubscriptionTier.free);
      when(mockUserProfile.spiritualPreferences).thenReturn({});

      unifiedDataService.userProfile = mockUserProfile; // Manually set profile for test


      final crystal1 = sampleCrystalData("id1", "ContextCrystal1");
      // Use copyWith on UserIntegration if it's immutable and you have such an extension or method
      crystal1.userIntegration = UserIntegration(userId:"user1", addedToCollection: "2023-01-01T00:00:00Z", intentionSettings: ["peace"], userExperiences: []);

      final crystal2 = sampleCrystalData("id2", "ContextCrystal2");
      crystal2.userIntegration = UserIntegration(userId:"user1", addedToCollection: "2023-02-01T00:00:00Z", intentionSettings: ["clarity", "focus"], userExperiences: []);

      // unifiedDataService.userProfile = profile; // Manually set profile for test
      unifiedDataService.crystalCollection.addAll([crystal1, crystal2]);

      unifiedDataService.updateSpiritualContextInternal(); // Call internal method directly for isolated test

      final context = unifiedDataService.getSpiritualContext();

      expect(context['user_name'], 'Test User');
      expect(context['crystal_count'], 2);
      final ownedCrystals = context['owned_crystals'] as List;
      expect(ownedCrystals.length, 2);

      expect(ownedCrystals[0]['name'], "ContextCrystal1");
      expect(ownedCrystals[0]['acquisition_date'], "2023-01-01T00:00:00Z");
      expect(ownedCrystals[0]['intentions'], "peace");
      expect(ownedCrystals[0]['usage_count'], 0); // Default as per current mapping

      expect(ownedCrystals[1]['name'], "ContextCrystal2");
      expect(ownedCrystals[1]['intentions'], "clarity, focus");
    });
  });
}

// Helper extension for UserProfile if needed for testing private fields or copyWith
extension UserProfileTestExtension on UserProfile {
    UserProfile copyWithTest({String? id, String? name, String? email, SubscriptionTier? subscriptionTier, BirthChart? birthChart}) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      birthChart: birthChart ?? this.birthChart,
      // copy other fields
    );
  }
}

// Helper extension for UserIntegration if it's immutable and needs easy copying for tests
extension UserIntegrationTestExtension on UserIntegration {
  UserIntegration copyWith({
    String? userId,
    String? addedToCollection,
    // ... other fields
  }) {
    return UserIntegration(
      userId: userId ?? this.userId,
      addedToCollection: addedToCollection ?? this.addedToCollection,
      personalRating: this.personalRating,
      usageFrequency: this.usageFrequency,
      userExperiences: this.userExperiences,
      intentionSettings: this.intentionSettings,
    );
  }
}
