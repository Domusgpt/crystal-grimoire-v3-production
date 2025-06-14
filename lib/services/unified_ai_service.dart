import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/crystal_collection.dart';
import '../services/collection_service_v2.dart';
import '../services/storage_service.dart';
import 'ai_service.dart';
import 'backend_service.dart';
import 'parse_operator_service_stub.dart';

/// Unified AI Service - Handles all AI-powered features
/// Crystal identification, spiritual guidance, personalized recommendations
class UnifiedAIService extends ChangeNotifier {
  final AIService _aiService;
  final StorageService _storageService;
  final CollectionServiceV2 _collectionService;
  final ParseOperatorService _parseOperatorService;
  UserProfile? _userProfile;
  
  bool _isLoading = false;
  String? _lastError;
  
  UnifiedAIService({
    required StorageService storageService,
    required CollectionServiceV2 collectionService,
    AIService? aiService,
    ParseOperatorService? parseOperatorService,
  }) : _storageService = storageService,
       _collectionService = collectionService,
       _aiService = aiService ?? AIService(),
       _parseOperatorService = parseOperatorService ?? ParseOperatorService() {
    _initializeServices();
    _collectionService.addListener(_onCollectionChanged);
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
      _userProfile = await _storageService.getOrCreateUserProfile();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Failed to initialize UnifiedAIService: $e');
    }
  }

  /// Handle collection changes
  void _onCollectionChanged() {
    notifyListeners();
  }

  /// Crystal identification using existing AI service
  Future<Map<String, dynamic>> identifyCrystal({
    required List<dynamic> images,
    Map<String, dynamic>? additionalContext,
  }) async {
    _setLoading(true);
    
    try {
      // Build personalized context
      final userContext = _getUserContext();
      final contextString = 'User Context: ${jsonEncode(userContext)}';
      
      // Use existing AI service for identification
      final result = await AIService.identifyCrystal(
        images: images.cast(),
        userContext: contextString,
      );
      
      // Convert CrystalIdentification to Map
      final resultMap = {
        'crystal': result.crystal?.toJson() ?? {},
        'confidence': result.confidence,
        'sessionId': result.sessionId,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Enhance with user context
      final enhancedResult = await _parseOperatorService.enhanceCrystalData(
        crystalData: resultMap,
        userProfile: userContext,
        collection: _collectionService.collection.map((e) => e.toJson()).toList(),
      );
      
      _lastError = null;
      return enhancedResult;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Crystal identification failed: $e');
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
    
    return {
      'user_id': _userProfile!.id,
      'subscription_tier': _userProfile!.subscriptionTier.name,
      'birth_chart': _userProfile!.birthChart?.toJson() ?? {},
      'owned_crystals': _collectionService.collection.map((c) => {
        'name': c.crystal.name,
        'type': c.quality,
        'usage_count': c.usageCount,
        'primary_uses': c.primaryUses,
        'is_favorite': c.isFavorite,
      }).toList(),
      'crystal_count': _collectionService.collection.length,
      'spiritual_preferences': _userProfile!.spiritualPreferences ?? {},
      'favorite_crystals': _collectionService.getFavorites().map((c) => c.crystal.name).toList(),
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
    _collectionService.removeListener(_onCollectionChanged);
    super.dispose();
  }
}