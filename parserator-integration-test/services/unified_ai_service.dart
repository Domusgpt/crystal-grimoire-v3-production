import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
// import '../models/crystal_collection.dart'; // CollectionEntry is no longer primary for collection
import '../models/unified_crystal_data.dart'; // Import new model
import '../services/collection_service_v2.dart';
import '../services/storage_service.dart';
import 'ai_service.dart';
import 'backend_service.dart';
import 'parse_operator_service_stub.dart';
import 'platform_file.dart'; // For PlatformFile type

/// Unified AI Service - Handles all AI-powered features
/// Crystal identification, spiritual guidance, personalized recommendations
class UnifiedAIService extends ChangeNotifier {
  // final AIService _aiService; // AIService now only has static methods
  final StorageService _storageService;
  final CollectionServiceV2 _collectionService; // Assumes this now holds List<UnifiedCrystalData>
  final ParseOperatorService _parseOperatorService;
  UserProfile? _userProfile;
  
  bool _isLoading = false;
  String? _lastError;
  
  UnifiedAIService({
    required StorageService storageService,
    required CollectionServiceV2 collectionService,
    // AIService? aiService, // AIService is static now
    ParseOperatorService? parseOperatorService,
  }) : _storageService = storageService,
       _collectionService = collectionService,
       // _aiService = aiService ?? AIService(),
       _parseOperatorService = parseOperatorService ?? ParseOperatorService() {
    _initializeServices();
    // Listen to collection service for changes if its collection state is important here
    // If UnifiedAIService mostly triggers actions rather than reflecting collection state,
    // direct listening might not be as critical as UnifiedDataService.
    _collectionService.addListener(_onCollectionOrProfileChanged);
  }

  bool _isInitialized = false;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  UserProfile? get userProfile => _userProfile;
  
  /// Initialize AI services
  Future<void> _initializeServices() async {
    if (_isInitialized) return;
    
    try {
      await _parseOperatorService.initialize();
      // Load profile, and collectionService should also be getting its data (from UDS)
      _userProfile = await _storageService.getOrCreateUserProfile();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Failed to initialize UnifiedAIService: $e');
    }
  }

  /// Handle collection or profile changes that might affect context
  void _onCollectionOrProfileChanged() {
    // This is called if CollectionServiceV2 notifies changes.
    // Or could listen to UnifiedDataService directly if profile also comes from there.
    // For now, just a generic notify if something it depends on changes.
    // If _getUserContext depends heavily on _userProfile from _storageService, ensure it's fresh.
    // This example assumes _userProfile is kept up-to-date separately if needed.
    notifyListeners();
  }

  /// Crystal identification using AIService (which now uses BackendService)
  Future<UnifiedCrystalData> identifyCrystal({
    required List<PlatformFile> images, // Changed from List<dynamic>
    Map<String, dynamic>? additionalContext, // This is the textual user context
  }) async {
    _setLoading(true);
    
    try {
      // AIService.identifyCrystal now expects userContext as a simple string.
      // The richer userProfile and crystalCollection context is built by BackendService.
      // The `additionalContext` here could be the `userTextContext`.
      String? userTextContext = additionalContext?['text_description'] as String? ?? additionalContext?.toString();

      final UnifiedCrystalData unifiedCrystalData = await AIService.identifyCrystal(
        images: images,
        userContext: userTextContext, // Pass the simple text context
        // userProfile and crystalCollection are not passed directly anymore here,
        // as BackendService handles its own context enrichment.
      );
      
      // The response from AIService (via BackendService) is already UnifiedCrystalData.
      // The old `enhanceCrystalData` from ParseOperatorService might be redundant
      // if the backend provides all necessary data, or it might operate on UnifiedCrystalData.
      
      // Assuming enhanceCrystalData is either removed or adapted for UnifiedCrystalData:
      // For now, let's assume the backend's UnifiedCrystalData is complete enough.
      // If enhancement is still needed:
      // final enhancedDataMap = await _parseOperatorService.enhanceCrystalData(
      //   crystalData: unifiedCrystalData.toJson(), // Convert to map if service expects map
      //   userProfile: _getUserContext(), // This context might be for ParseOperatorService
      //   collection: _collectionService.collection.map((e) => e.toJson()).toList(),
      // );
      // _lastError = null;
      // return UnifiedCrystalData.fromJson(enhancedDataMap); // If it returns a map
      
      _lastError = null;
      return unifiedCrystalData; // Return directly

    } catch (e) {
      _lastError = e.toString();
      debugPrint('UnifiedAIService: Crystal identification failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get personalized spiritual guidance
  Future<String> getPersonalizedGuidance({
    required String guidanceType,
    String? userQuery,
    Map<String, dynamic>? context,
  }) async {
    _setLoading(true);
    
    try {
      final userContext = _getUserContext();
      
      // Build context with user's birth chart and collection
      final fullContext = {
        'guidance_type': guidanceType,
        'user_query': userQuery ?? '',
        'user_context': userContext,
        ...?context,
      };
      
      // Use BackendService for personalized guidance
      final guidanceResult = await BackendService.getPersonalizedGuidance(
        guidanceType: guidanceType,
        userProfile: userContext,
        customPrompt: userQuery ?? 'Provide spiritual guidance based on my birth chart and crystal collection',
      );
      
      final guidance = guidanceResult['guidance'] ?? 'Unable to generate guidance at this time.';
      
      // Process cross-feature automation
      final automationResult = await _parseOperatorService.processCrossFeatureAutomation(
        triggerEvent: 'guidance_request',
        eventData: fullContext,
      );
      
      // Process automation actions
      for (final action in automationResult.actions) {
        await _processAutomationAction(action);
      }
      
      _lastError = null;
      return guidance;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Personalized guidance failed: $e');
      return 'Unable to generate guidance at this time. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Get crystal recommendations based on user's needs
  Future<List<Map<String, dynamic>>> getCrystalRecommendations({
    String? intention,
    String? chakra,
    String? situation,
  }) async {
    try {
      final userContext = _getUserContext();
      
      final recommendations = await _parseOperatorService.getPersonalizedRecommendations(
        userProfile: userContext,
        collection: _collectionService.collection.map((e) => e.toJson()).toList(),
      );
      
      return recommendations.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Failed to get crystal recommendations: $e');
      return [];
    }
  }

  /// Enhance user's existing collection with AI insights
  Future<void> enhanceExistingCollection() async {
    if (_userProfile == null) return;
    
    _setLoading(true);
    
    try {
      final enhancementResult = await _parseOperatorService.enhanceExistingCollection(
        collection: _collectionService.collection.map((e) => e.toJson()).toList(),
        userProfile: _userProfile!,
        level: EnhancementLevel.standard,
      );
      
      // Apply enhancements to collection
      if (enhancementResult.enhancedEntries.isNotEmpty) {
        debugPrint('Collection enhanced with ${enhancementResult.enhancedEntries.length} improvements');
      }
      
      // Process recommendations
      if (enhancementResult.recommendations.isNotEmpty) {
        debugPrint('Generated ${enhancementResult.recommendations.length} new recommendations');
      }
    } catch (e) {
      debugPrint('Failed to enhance collection: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get user context for AI personalization
  Map<String, dynamic> _getUserContext() {
    if (_userProfile == null) return {};
    
    // Now _collectionService.collection is List<UnifiedCrystalData>
    // Adapt mapping accordingly
    return {
      'user_id': _userProfile!.id,
      'subscription_tier': _userProfile!.subscriptionTier.name,
      'birth_chart': _userProfile!.birthChart?.toJson() ?? {},
      'owned_crystals': _collectionService.collection.map((ucd) {
        final core = ucd.crystalCore;
        final identification = core.identification;
        final userIntegration = ucd.userIntegration;
        return {
          'name': identification.stoneType,
          'type': identification.variety ?? identification.crystalFamily,
          // 'usage_count': userIntegration?.usageFrequency, // No direct usage_count
          'primary_uses': userIntegration?.intentionSettings,
          // 'is_favorite': userIntegration?.isFavorite, // Not in current UnifiedCrystalData.UserIntegration
        };
      }).toList(),
      'crystal_count': _collectionService.collection.length,
      'spiritual_preferences': _userProfile!.spiritualPreferences ?? {},
      // 'favorite_crystals': _collectionService.getFavorites().map((ucd) => ucd.crystalCore.identification.stoneType).toList(),
       // getFavorites also needs update
    };
  }

  /// Process automation actions from AI
  Future<void> _processAutomationAction(AutomationAction action) async {
    try {
      switch (action.actionType) {
        case 'crystal_suggestion':
          debugPrint('Crystal suggestion: ${action.parameters}');
          break;
        case 'healing_reminder':
          debugPrint('Healing reminder: ${action.parameters}');
          break;
        case 'ritual_recommendation':
          debugPrint('Ritual recommendation: ${action.parameters}');
          break;
        case 'journal_prompt':
          debugPrint('Journal prompt: ${action.parameters}');
          break;
        default:
          debugPrint('Unknown automation action: ${action.actionType}');
      }
    } catch (e) {
      debugPrint('Failed to process automation action: $e');
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storageService.saveUserProfile(profile);
    notifyListeners();
  }

  @override
  void dispose() {
    _collectionService.removeListener(_onCollectionOrProfileChanged);
    super.dispose();
  }
}