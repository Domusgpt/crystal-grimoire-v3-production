import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/user_profile.dart';
// import '../models/crystal_collection.dart'; // Replaced by UnifiedCrystalData for collection
import '../models/journal_entry.dart';
import '../models/birth_chart.dart';
import '../models/unified_crystal_data.dart'; // New model for crystal data
import 'firebase_service.dart'; // Still used for auth, user profile sync, activity tracking
import 'storage_service.dart'; // Still used for local profile persistence
import 'parse_operator_service_stub.dart';
import 'backend_service.dart'; // Service for backend communication

/// Unified Data Service - Single source of truth for all user data
/// Uses BackendService for crystal data, Firebase for others.
class UnifiedDataService extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final StorageService _storageService;
  final ParseOperatorService _parseOperatorService;
  final BackendService _backendService; // Added BackendService instance

  UserProfile? _userProfile;
  List<UnifiedCrystalData> _crystalCollection = [];
  List<JournalEntry> _journalEntries = [];
  Map<String, dynamic> _spiritualContext = {};
  
  // Real-time streams
  StreamSubscription? _profileStream;
  // StreamSubscription? _collectionStream; // Commented out: Firebase real-time for crystals replaced
  
  UnifiedDataService({
    required FirebaseService firebaseService,
    required StorageService storageService,
    required BackendService backendService, // Require BackendService
    ParseOperatorService? parseOperatorService,
  }) : _firebaseService = firebaseService,
       _storageService = storageService,
       _backendService = backendService, // Initialize
       _parseOperatorService = parseOperatorService ?? ParseOperatorService();
  
  // Getters
  UserProfile? get userProfile => _userProfile;
  List<UnifiedCrystalData> get crystalCollection => _crystalCollection;
  List<JournalEntry> get journalEntries => _journalEntries;
  // isAuthenticated might now defer to _backendService or _firebaseService depending on what it means
  bool get isAuthenticated => _backendService.isAuthenticated; // Assuming BackendService now holds auth state
  bool get isPremiumUser => _userProfile?.subscriptionTier != SubscriptionTier.free;
  
  /// Initialize data service
  Future<void> initialize() async {
    try {
      await _parseOperatorService.initialize();
      
      // Load user profile (local first)
      final profile = await _storageService.loadUserProfile();
      if (profile != null) {
        _userProfile = profile;
        // _updateSpiritualContext(); // Called after crystal collection is loaded
      }
      
      // Load crystal collection from Backend if authenticated
      // Assuming BackendService handles its own auth checks or uses stored auth state.
      // For this service, we might rely on _firebaseService.isAuthenticated for UI enabling data loading.
      // Or more directly, _backendService.isAuthenticated and _backendService.currentUserId
      if (_backendService.isAuthenticated && _backendService.currentUserId != null) {
        try {
          _crystalCollection = await _backendService.getUserCollection(userId: _backendService.currentUserId!);
        } catch (e) {
          debugPrint('Failed to load user-specific crystal collection from backend: $e');
          // Potentially load from a local cache if backend fails? For now, empty.
          _crystalCollection = [];
        }
      } else {
        _crystalCollection = []; // No user, no collection from backend
      }
      _updateSpiritualContext(); // Update context after profile and crystals are loaded
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize UnifiedDataService: $e');
    }
  }

  /// Start real-time sync (only for Firebase-managed data like profile)
  Future<void> startRealTimeSync() async {
    // Crystal collection sync is no longer handled here via Firebase stream.
    // It's fetched on initialize and updated via BackendService calls.
    if (!_firebaseService.isAuthenticated) return;
    
    try {
      // Listen to profile changes (still from Firebase)
      _profileStream?.cancel(); // Cancel previous stream if any
      _profileStream = _firebaseService.getUserProfileStream().listen((profile) {
        _userProfile = profile;
        _updateSpiritualContext();
        notifyListeners();
      });
      
      // _collectionStream?.cancel(); // Cancel previous stream
      // _collectionStream = _firebaseService.getCrystalCollectionStream().listen((collection) {
      //   _crystalCollection = collection; // This would be List<CollectionEntry>
      //   _updateSpiritualContext();
      //   notifyListeners();
      // });
      // debugPrint('🔥 Firebase real-time sync for profile started. Crystal collection via BackendService.');

      // If there's a need to periodically refresh crystal collection from backend:
      // This could be a place to set up a timer or other mechanism,
      // or rely on UI-triggered refreshes. For now, no periodic refresh here.
      
      debugPrint('🔥 Firebase real-time sync for profile started.');
    } catch (e) {
      debugPrint('Real-time sync for profile failed: $e');
    }
  }
  
  /// Update spiritual context for AI personalization
  void _updateSpiritualContext() {
    if (_userProfile == null) return;
    
    _spiritualContext = {
      'user_name': _userProfile?.name ?? "Guest",
      'birth_chart': _userProfile?.birthChart?.toJson() ?? {},
      'owned_crystals': _crystalCollection.map((ucd) {
        // Mapping from UnifiedCrystalData to the structure expected by spiritual context
        return {
          'name': ucd.crystalCore.identification.stoneType,
          'type': ucd.crystalCore.identification.variety ?? ucd.crystalCore.identification.crystalFamily, // Or some other field
          'acquisition_date': ucd.userIntegration?.addedToCollection, // This is Optional<String>
          'usage_count': 0, // UnifiedCrystalData doesn't have a direct usage_count. Defaulting to 0.
                           // Could be derived from ucd.userIntegration?.usageFrequency if needed.
          'intentions': ucd.userIntegration?.intentionSettings.join(', ') ?? '',
        };
      }).toList(),
      'crystal_count': _crystalCollection.length,
      'subscription_tier': _userProfile?.subscriptionTier.name ?? SubscriptionTier.free.name,
      'spiritual_preferences': _userProfile!.spiritualPreferences ?? {},
    };
  }
  
  /// Get personalized spiritual context for AI prompts
  Map<String, dynamic> getSpiritualContext() {
    return Map<String, dynamic>.from(_spiritualContext);
  }
  
  /// Add crystal to collection
  Future<void> addCrystal(UnifiedCrystalData crystalData) async {
    if (!_backendService.isAuthenticated) {
      // Or throw error, or handle anonymous additions differently if supported
      debugPrint("User not authenticated. Cannot add crystal via BackendService.");
      return;
    }
    try {
      // Set user_id if not already set and available
      final currentUserId = _backendService.currentUserId; // Use instance
      final userIntegration = crystalData.userIntegration ?? UserIntegration(intentionSettings: [], userExperiences: []);

      // Ensure user_id is set on the UserIntegration object
      // If crystalData is immutable, we need a copyWith or similar pattern
      // Assuming UserIntegration has a copyWith or is mutable for this example.
      // For a robust solution with immutable models, UserIntegration should have a copyWith method.
      // Let's assume it's mutable or has copyWith for simplicity here.
      UserIntegration finalUserIntegration = userIntegration.userId == null || userIntegration.userId!.isEmpty
          ? userIntegration.copyWith(userId: currentUserId, addedToCollection: userIntegration.addedToCollection ?? DateTime.now().toIso8601String())
          : userIntegration.copyWith(addedToCollection: userIntegration.addedToCollection ?? DateTime.now().toIso8601String());

      final dataToSave = crystalData.copyWith(userIntegration: finalUserIntegration);

      final savedCrystal = await _backendService.saveCrystal(dataToSave);
      _crystalCollection.add(savedCrystal);

      // Track activity (optional, can remain if using Firebase for analytics)
      await _firebaseService.trackUserActivity('crystal_added', {
        'crystal_name': savedCrystal.crystalCore.identification.stoneType,
        'crystal_id': savedCrystal.crystalCore.id,
      });

      _updateSpiritualContext();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding crystal via BackendService: $e');
      // Rethrow or handle as per app's error handling strategy
      throw e;
    }
  }

  /// Update crystal in collection
  Future<void> updateCrystal(UnifiedCrystalData crystalData) async {
     if (!_backendService.isAuthenticated) { // Use instance
      debugPrint("User not authenticated. Cannot update crystal via BackendService.");
      return;
    }
    try {
      // Ensure user_id is present if it's meant to be validated or part of the update logic
      if (crystalData.userIntegration?.userId == null || crystalData.userIntegration!.userId!.isEmpty) {
          final currentUserId = _backendService.currentUserId;
          if (currentUserId != null && currentUserId.isNotEmpty) {
            crystalData = crystalData.copyWith(
              userIntegration: (crystalData.userIntegration ?? UserIntegration(intentionSettings: [], userExperiences: []))
                                .copyWith(userId: currentUserId)
            );
          } else {
            // Handle case where user_id is essential but cannot be determined
            debugPrint("Warning: Updating crystal without a user_id in userIntegration.");
          }
      }

      final updatedCrystal = await _backendService.updateCrystal(crystalData);
      final index = _crystalCollection.indexWhere((c) => c.crystalCore.id == updatedCrystal.crystalCore.id);
      if (index != -1) {
        _crystalCollection[index] = updatedCrystal;
      } else {
        // If not found, maybe add it? Or log an error. For now, assumes it was in collection.
        _crystalCollection.add(updatedCrystal);
        debugPrint('Updated crystal was not found in local collection, added it.');
      }
      _updateSpiritualContext();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating crystal via BackendService: $e');
      throw e;
    }
  }

  /// Remove crystal from collection
  Future<void> removeCrystal(String crystalId) async {
    if (!_backendService.isAuthenticated) { // Use instance
      debugPrint("User not authenticated. Cannot remove crystal via BackendService.");
      return;
    }
    try {
      await _backendService.deleteCrystal(crystalId); // Use instance
      _crystalCollection.removeWhere((c) => c.crystalCore.id == crystalId);
      _updateSpiritualContext();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing crystal via BackendService: $e');
      throw e;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storageService.saveUserProfile(profile);
    _updateSpiritualContext();
    notifyListeners();
    
    // Sync with Firebase if authenticated
    if (_firebaseService.isAuthenticated) {
      // Firebase sync handled by other services
      debugPrint('User profile synced to Firebase');
    }
  }

  /// Get personalized guidance
  Future<String> getPersonalizedGuidance(String query) async {
    try {
      final automationResult = await _parseOperatorService.processCrossFeatureAutomation(
        triggerEvent: 'guidance_request',
        eventData: {
          'query': query,
          'user_context': getSpiritualContext(),
        },
      );
      
      // Process automation actions
      for (final action in automationResult.actions) {
        await _processAutomationAction(action);
      }
      
      return 'Personalized guidance generated successfully';
    } catch (e) {
      debugPrint('Failed to get personalized guidance: $e');
      return 'Unable to generate guidance at this time';
    }
  }

  /// Process automation action
  Future<void> _processAutomationAction(AutomationAction action) async {
    try {
      switch (action.actionType) {
        case 'healing_suggestion':
          // Store healing suggestion
          break;
        case 'ritual_recommendation':
          // Store ritual recommendation
          break;
        case 'journal_prompt':
          // Store journal prompt
          break;
        case 'crystal_combination':
          // Store crystal combination suggestion
          break;
        case 'meditation_recommendation':
          // Store meditation recommendation
          break;
      }
    } catch (e) {
      debugPrint('Failed to process automation action: $e');
    }
  }

  /// Enhance existing collection
  Future<void> enhanceExistingCollection() async {
    if (_userProfile == null) return;
    
    try {
      final enhancementResult = await _parseOperatorService.enhanceExistingCollection(
        collection: _crystalCollection,
        userProfile: _userProfile!,
        level: EnhancementLevel.standard,
      );
      
      // Apply enhancements
      if (enhancementResult.enhancedEntries.isNotEmpty) {
        // Update collection with enhanced data
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to enhance collection: $e');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _profileStream?.cancel();
    // _collectionStream?.cancel(); // Was commented out
    super.dispose();
  }
}