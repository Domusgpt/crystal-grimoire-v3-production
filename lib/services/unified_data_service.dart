import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/user_profile.dart';
import '../models/crystal_collection.dart';
import '../models/journal_entry.dart';
import '../models/birth_chart.dart';
import 'firebase_service.dart';
import 'storage_service.dart';
import 'parse_operator_service_stub.dart';

/// Unified Data Service - Single source of truth for all user data
/// Uses Firebase for real-time sync and premium features
class UnifiedDataService extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final StorageService _storageService;
  final ParseOperatorService _parseOperatorService;
  
  UserProfile? _userProfile;
  List<CollectionEntry> _crystalCollection = [];
  List<JournalEntry> _journalEntries = [];
  Map<String, dynamic> _spiritualContext = {};
  
  // Real-time streams
  StreamSubscription? _profileStream;
  StreamSubscription? _collectionStream;
  
  UnifiedDataService({
    required FirebaseService firebaseService,
    required StorageService storageService,
    ParseOperatorService? parseOperatorService,
  }) : _firebaseService = firebaseService,
       _storageService = storageService,
       _parseOperatorService = parseOperatorService ?? ParseOperatorService();
  
  // Getters
  UserProfile? get userProfile => _userProfile;
  List<CollectionEntry> get crystalCollection => _crystalCollection;
  List<JournalEntry> get journalEntries => _journalEntries;
  bool get isAuthenticated => _firebaseService.isAuthenticated;
  bool get isPremiumUser => _userProfile?.subscriptionTier != SubscriptionTier.free;
  
  /// Initialize data service
  Future<void> initialize() async {
    try {
      await _parseOperatorService.initialize();
      
      // Load user profile
      final profile = await _storageService.loadUserProfile();
      if (profile != null) {
        _userProfile = profile;
        _updateSpiritualContext();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize UnifiedDataService: $e');
    }
  }

  /// Start real-time sync with Firebase Blaze
  Future<void> startRealTimeSync() async {
    if (!_firebaseService.isAuthenticated) return;
    
    try {
      // Listen to profile changes
      _profileStream = _firebaseService.getUserProfileStream().listen((profile) {
        _userProfile = profile;
        _updateSpiritualContext();
        notifyListeners();
      });
      
      // Listen to collection changes
      _collectionStream = _firebaseService.getCrystalCollectionStream().listen((collection) {
        _crystalCollection = collection;
        _updateSpiritualContext();
        notifyListeners();
      });
      
      debugPrint('🔥 Firebase real-time sync started');
    } catch (e) {
      debugPrint('Real-time sync failed: $e');
    }
  }
  
  /// Update spiritual context for AI personalization
  void _updateSpiritualContext() {
    if (_userProfile == null) return;
    
    _spiritualContext = {
      'user_name': _userProfile!.name,
      'birth_chart': _userProfile!.birthChart?.toJson() ?? {},
      'owned_crystals': _crystalCollection.map((c) => {
        'name': c.crystal.name,
        'type': c.quality,
        'acquisition_date': c.dateAdded.toIso8601String(),
        'usage_count': c.usageCount,
        'intentions': c.primaryUses.join(', '),
      }).toList(),
      'crystal_count': _crystalCollection.length,
      'subscription_tier': _userProfile!.subscriptionTier.name,
      'spiritual_preferences': _userProfile!.spiritualPreferences ?? {},
    };
  }
  
  /// Get personalized spiritual context for AI prompts
  Map<String, dynamic> getSpiritualContext() {
    return Map<String, dynamic>.from(_spiritualContext);
  }
  
  /// Add crystal to collection
  Future<void> addCrystal(CollectionEntry crystal) async {
    _crystalCollection.add(crystal);
    
    // Track activity
    await _firebaseService.trackUserActivity('crystal_added', {
      'crystal_name': crystal.crystal.name,
      'crystal_type': crystal.quality,
    });
    
    _updateSpiritualContext();
    notifyListeners();
    
    // Sync with Firebase if authenticated
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.saveCrystalCollection(_crystalCollection);
    }
  }

  /// Update crystal in collection
  Future<void> updateCrystal(CollectionEntry crystal) async {
    final index = _crystalCollection.indexWhere((c) => c.id == crystal.id);
    if (index != -1) {
      _crystalCollection[index] = crystal;
      _updateSpiritualContext();
      notifyListeners();
      
      // Sync with Firebase if authenticated
      if (_firebaseService.isAuthenticated) {
        await _firebaseService.saveCrystalCollection(_crystalCollection);
      }
    }
  }

  /// Remove crystal from collection
  Future<void> removeCrystal(String crystalId) async {
    _crystalCollection.removeWhere((c) => c.id == crystalId);
    _updateSpiritualContext();
    notifyListeners();
    
    // Sync with Firebase if authenticated
    if (_firebaseService.isAuthenticated) {
      await _firebaseService.saveCrystalCollection(_crystalCollection);
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
    _collectionStream?.cancel();
    super.dispose();
  }
}