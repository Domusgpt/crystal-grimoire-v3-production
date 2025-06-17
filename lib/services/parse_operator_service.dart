import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Real ParseOperator Service - Actual Parserator API Integration
/// 
/// This service integrates with Paul's existing Parserator platform at:
/// https://app-5108296280.us-central1.run.app
/// 
/// Features:
/// - Two-stage Architect-Extractor pattern
/// - 70% cost reduction vs single-LLM approaches
/// - Multi-source validation
/// - Real-time enhancement
class ParseOperatorService {
  static const String _baseUrl = 'https://app-5108296280.us-central1.run.app';
  static const String _parseEndpoint = '/v1/parse';
  static const String _healthEndpoint = '/health';
  
  final String? _apiKey;
  final http.Client _httpClient;
  
  ParseOperatorService({
    String? apiKey,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client();

  /// Initialize and test connection
  Future<bool> initialize() async {
    try {
      final health = await checkHealth();
      if (health['status'] == 'healthy') {
        developer.log('✅ ParseOperator Service initialized successfully');
        return true;
      } else {
        developer.log('❌ ParseOperator Service health check failed: $health');
        return false;
      }
    } catch (e) {
      developer.log('🚨 ParseOperator Service initialization failed: $e');
      return false;
    }
  }

  /// Check Parserator API health
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl$_healthEndpoint'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'unhealthy',
          'error': 'HTTP ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Enhanced crystal data processing using Parserator
  Future<Map<String, dynamic>> enhanceCrystalData({
    required Map<String, dynamic> crystalData,
    required Map<String, dynamic> userProfile,
    required List<dynamic> collection,
  }) async {
    try {
      // Build enhanced crystal description
      final description = _buildCrystalDescription(crystalData, userProfile, collection);
      
      // Define comprehensive schema for crystal enhancement
      final schema = {
        'name': 'string',
        'scientific_name': 'string',
        'color': 'string',
        'crystal_system': 'string',
        'hardness': 'string',
        'primary_chakras': 'string_array',
        'secondary_chakras': 'string_array',
        'zodiac_signs': 'string_array',
        'planetary_rulers': 'string_array',
        'elements': 'string_array',
        'healing_properties': 'string_array',
        'metaphysical_uses': 'string_array',
        'emotional_benefits': 'string_array',
        'spiritual_purposes': 'string_array',
        'care_instructions': 'string_array',
        'formation': 'string',
        'origin_locations': 'string_array',
        'confidence_score': 'number',
        'personalized_guidance': 'string',
      };

      final result = await _callParserator(
        inputData: description,
        outputSchema: schema,
        instructions: 'Extract comprehensive crystal data with personalized guidance based on user profile and existing collection.',
      );

      if (result['success'] == true) {
        return _mergeWithOriginalData(crystalData, result['parsedData'], result['metadata']);
      } else {
        developer.log('❌ Parserator enhancement failed: ${result['error']}');
        return crystalData; // Return original data if enhancement fails
      }
    } catch (e) {
      developer.log('🚨 Crystal enhancement error: $e');
      return crystalData; // Graceful fallback
    }
  }

  /// Get personalized recommendations using Parserator
  Future<List<dynamic>> getPersonalizedRecommendations({
    required Map<String, dynamic> userProfile,
    required List<dynamic> collection,
  }) async {
    try {
      final profileDescription = _buildUserProfileDescription(userProfile, collection);
      
      final schema = {
        'recommendations': 'json_object',
        'reasoning': 'string',
        'confidence': 'number',
      };

      final result = await _callParserator(
        inputData: profileDescription,
        outputSchema: schema,
        instructions: 'Generate personalized crystal recommendations based on user profile, birth chart, and existing collection. Include reasoning for each recommendation.',
      );

      if (result['success'] == true && result['parsedData']['recommendations'] != null) {
        return _formatRecommendations(result['parsedData']['recommendations']);
      } else {
        return [];
      }
    } catch (e) {
      developer.log('🚨 Recommendations error: $e');
      return [];
    }
  }

  /// Process cross-feature automation using Parserator
  Future<CrossFeatureAutomationResult> processCrossFeatureAutomation({
    required String triggerEvent,
    required Map<String, dynamic> eventData,
    Map<String, dynamic>? userProfile,
    Map<String, dynamic>? context,
  }) async {
    try {
      final automationDescription = _buildAutomationDescription(
        triggerEvent, eventData, userProfile, context
      );
      
      final schema = {
        'automation_actions': 'json_object',
        'insights': 'json_object',
        'enhanced_entries': 'json_object',
        'recommendations': 'json_object',
        'confidence': 'number',
        'reasoning': 'string',
      };

      final result = await _callParserator(
        inputData: automationDescription,
        outputSchema: schema,
        instructions: 'Analyze the trigger event and generate intelligent automation suggestions for Crystal Grimoire features (healing, rituals, journal, collection).',
      );

      if (result['success'] == true) {
        return _buildAutomationResult(result['parsedData']);
      } else {
        return CrossFeatureAutomationResult(
          actions: [],
          insights: {},
          enhancedEntries: [],
          recommendations: [],
        );
      }
    } catch (e) {
      developer.log('🚨 Automation processing error: $e');
      return CrossFeatureAutomationResult(
        actions: [],
        insights: {},
        enhancedEntries: [],
        recommendations: [],
      );
    }
  }

  /// Enhance existing collection using Parserator
  Future<CrossFeatureAutomationResult> enhanceExistingCollection({
    required List<dynamic> collection,
    required dynamic userProfile,
    required EnhancementLevel level,
  }) async {
    try {
      final collectionDescription = _buildCollectionDescription(collection, userProfile, level);
      
      final schema = {
        'enhanced_crystals': 'json_object',
        'collection_insights': 'json_object', 
        'missing_elements': 'string_array',
        'optimization_suggestions': 'string_array',
        'synergy_analysis': 'json_object',
        'confidence': 'number',
      };

      final result = await _callParserator(
        inputData: collectionDescription,
        outputSchema: schema,
        instructions: 'Analyze the crystal collection and provide comprehensive enhancement suggestions, synergy analysis, and optimization recommendations.',
      );

      if (result['success'] == true) {
        return _buildCollectionEnhancementResult(result['parsedData'], collection);
      } else {
        return CrossFeatureAutomationResult(
          actions: [],
          insights: {},
          enhancedEntries: collection,
          recommendations: [],
        );
      }
    } catch (e) {
      developer.log('🚨 Collection enhancement error: $e');
      return CrossFeatureAutomationResult(
        actions: [],
        insights: {},
        enhancedEntries: collection,
        recommendations: [],
      );
    }
  }

  /// Core Parserator API call
  Future<Map<String, dynamic>> _callParserator({
    required String inputData,
    required Map<String, dynamic> outputSchema,
    String? instructions,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      
      // Add API key if available
      if (_apiKey != null && _apiKey!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_apiKey';
      }

      final body = {
        'inputData': inputData,
        'outputSchema': outputSchema,
      };
      
      if (instructions != null) {
        body['instructions'] = instructions;
      }

      developer.log('🔄 Calling Parserator API...');
      developer.log('📊 Schema: ${outputSchema.keys.join(', ')}');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl$_parseEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      developer.log('📈 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        developer.log('✅ Parserator success: ${result['metadata']['confidence']} confidence');
        return result;
      } else {
        developer.log('❌ Parserator error: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      developer.log('🚨 Parserator call exception: $e');
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  // Helper methods for building descriptions and processing results

  String _buildCrystalDescription(
    Map<String, dynamic> crystalData,
    Map<String, dynamic> userProfile,
    List<dynamic> collection,
  ) {
    final buffer = StringBuffer();
    
    // Crystal basic info
    buffer.writeln('Crystal Information:');
    if (crystalData['name'] != null) buffer.writeln('Name: ${crystalData['name']}');
    if (crystalData['color'] != null) buffer.writeln('Color: ${crystalData['color']}');
    if (crystalData['description'] != null) buffer.writeln('Description: ${crystalData['description']}');
    
    // User profile context
    buffer.writeln('\nUser Profile:');
    if (userProfile['birthDate'] != null) buffer.writeln('Birth Date: ${userProfile['birthDate']}');
    if (userProfile['sunSign'] != null) buffer.writeln('Sun Sign: ${userProfile['sunSign']}');
    if (userProfile['moonSign'] != null) buffer.writeln('Moon Sign: ${userProfile['moonSign']}');
    if (userProfile['spiritualGoals'] != null) buffer.writeln('Spiritual Goals: ${userProfile['spiritualGoals']}');
    
    // Collection context
    buffer.writeln('\nExisting Collection (${collection.length} crystals):');
    for (final crystal in collection.take(5)) {
      if (crystal['name'] != null) buffer.writeln('- ${crystal['name']}');
    }
    if (collection.length > 5) buffer.writeln('... and ${collection.length - 5} more crystals');
    
    return buffer.toString();
  }

  String _buildUserProfileDescription(
    Map<String, dynamic> userProfile,
    List<dynamic> collection,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('User Profile for Crystal Recommendations:');
    buffer.writeln('Birth Date: ${userProfile['birthDate'] ?? 'Not provided'}');
    buffer.writeln('Sun Sign: ${userProfile['sunSign'] ?? 'Unknown'}');
    buffer.writeln('Moon Sign: ${userProfile['moonSign'] ?? 'Unknown'}');
    buffer.writeln('Ascendant: ${userProfile['ascendant'] ?? 'Unknown'}');
    buffer.writeln('Spiritual Goals: ${userProfile['spiritualGoals'] ?? 'General spiritual growth'}');
    buffer.writeln('Experience Level: ${userProfile['experienceLevel'] ?? 'Beginner'}');
    
    buffer.writeln('\nCurrent Collection (${collection.length} crystals):');
    final crystalNames = collection
        .map((c) => c['name'] ?? 'Unknown')
        .where((name) => name != 'Unknown')
        .toList();
    buffer.writeln(crystalNames.join(', '));
    
    return buffer.toString();
  }

  String _buildAutomationDescription(
    String triggerEvent,
    Map<String, dynamic> eventData,
    Map<String, dynamic>? userProfile,
    Map<String, dynamic>? context,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Cross-Feature Automation Trigger:');
    buffer.writeln('Event: $triggerEvent');
    buffer.writeln('Event Data: ${jsonEncode(eventData)}');
    
    if (userProfile != null) {
      buffer.writeln('\nUser Profile: ${jsonEncode(userProfile)}');
    }
    
    if (context != null) {
      buffer.writeln('\nContext: ${jsonEncode(context)}');
    }
    
    buffer.writeln('\nAnalyze this event and suggest intelligent automation for:');
    buffer.writeln('- Crystal Healing sessions');
    buffer.writeln('- Moon Rituals');
    buffer.writeln('- Journal prompts');
    buffer.writeln('- Collection recommendations');
    buffer.writeln('- Cross-feature connections');
    
    return buffer.toString();
  }

  String _buildCollectionDescription(
    List<dynamic> collection,
    dynamic userProfile,
    EnhancementLevel level,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Crystal Collection Enhancement Analysis:');
    buffer.writeln('Enhancement Level: ${level.toString().split('.').last}');
    buffer.writeln('Collection Size: ${collection.length} crystals');
    
    buffer.writeln('\nCrystals in Collection:');
    for (final crystal in collection) {
      buffer.writeln('- ${crystal['name'] ?? 'Unknown'}: ${crystal['color'] ?? ''} ${crystal['description'] ?? ''}');
    }
    
    if (userProfile != null) {
      buffer.writeln('\nUser Profile: ${jsonEncode(userProfile)}');
    }
    
    return buffer.toString();
  }

  Map<String, dynamic> _mergeWithOriginalData(
    Map<String, dynamic> original,
    Map<String, dynamic> enhanced,
    Map<String, dynamic> metadata,
  ) {
    return {
      ...original,
      'parserator_enhanced': enhanced,
      'parserator_metadata': metadata,
      'enhancement_timestamp': DateTime.now().toIso8601String(),
      'confidence': metadata['confidence'] ?? 0.0,
    };
  }

  List<dynamic> _formatRecommendations(dynamic recommendations) {
    if (recommendations is Map) {
      return [recommendations];
    } else if (recommendations is List) {
      return recommendations;
    } else {
      return [];
    }
  }

  CrossFeatureAutomationResult _buildAutomationResult(Map<String, dynamic> data) {
    return CrossFeatureAutomationResult(
      actions: _parseAutomationActions(data['automation_actions']),
      insights: data['insights'] ?? {},
      enhancedEntries: _parseEnhancedEntries(data['enhanced_entries']),
      recommendations: _parseRecommendations(data['recommendations']),
    );
  }

  CrossFeatureAutomationResult _buildCollectionEnhancementResult(
    Map<String, dynamic> data,
    List<dynamic> originalCollection,
  ) {
    return CrossFeatureAutomationResult(
      actions: [],
      insights: data['collection_insights'] ?? {},
      enhancedEntries: _mergeEnhancedCrystals(originalCollection, data['enhanced_crystals']),
      recommendations: _parseOptimizationSuggestions(data['optimization_suggestions']),
    );
  }

  List<AutomationAction> _parseAutomationActions(dynamic actions) {
    // Parse automation actions from Parserator response
    if (actions is Map) {
      return actions.entries.map((entry) => AutomationAction(
        actionType: entry.key,
        featureTarget: entry.value['target'] ?? 'unknown',
        parameters: entry.value['parameters'] ?? {},
        confidence: (entry.value['confidence'] ?? 0.0).toDouble(),
      )).toList();
    }
    return [];
  }

  List<dynamic> _parseEnhancedEntries(dynamic entries) {
    if (entries is List) return entries;
    if (entries is Map) return [entries];
    return [];
  }

  List<dynamic> _parseRecommendations(dynamic recommendations) {
    if (recommendations is List) return recommendations;
    if (recommendations is Map) return [recommendations];
    return [];
  }

  List<dynamic> _mergeEnhancedCrystals(List<dynamic> original, dynamic enhanced) {
    // Merge original crystal data with Parserator enhancements
    return original.map((crystal) {
      if (enhanced is Map && enhanced[crystal['name']] != null) {
        return {
          ...crystal,
          'parserator_enhanced': enhanced[crystal['name']],
        };
      }
      return crystal;
    }).toList();
  }

  List<dynamic> _parseOptimizationSuggestions(dynamic suggestions) {
    if (suggestions is List) {
      return suggestions.map((s) => {'type': 'optimization', 'suggestion': s}).toList();
    }
    return [];
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Supporting classes
enum EnhancementLevel {
  basic,
  standard,
  premium,
}

class AutomationAction {
  final String actionType;
  final String featureTarget;
  final Map<String, dynamic> parameters;
  final double confidence;

  AutomationAction({
    required this.actionType,
    required this.featureTarget,
    required this.parameters,
    required this.confidence,
  });

  @override
  String toString() => 'AutomationAction(type: $actionType, target: $featureTarget, confidence: $confidence)';
}

class CrossFeatureAutomationResult {
  final List<AutomationAction> actions;
  final Map<String, dynamic> insights;
  final List<dynamic> enhancedEntries;
  final List<dynamic> recommendations;
  
  CrossFeatureAutomationResult({
    required this.actions,
    required this.insights,
    this.enhancedEntries = const [],
    this.recommendations = const [],
  });

  @override
  String toString() => 'CrossFeatureAutomationResult(actions: ${actions.length}, insights: ${insights.keys.length})';
}