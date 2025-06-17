import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/crystal_collection.dart'; // Uses CollectionEntry with UnifiedCrystalData
import '../models/unified_crystal_data.dart'; // For direct type access if needed

// import 'dart:convert'; // Example: if it was here and unused, remove

import '../services/astrology_service.dart'; // Added import

/// Unified LLM Context Builder - Creates comprehensive user context for all LLM queries
/// Ensures every AI interaction includes user's birth chart, crystal collection, and personalization data
class UnifiedLLMContextBuilder {
  final AstrologyService astrologyService; // Added dependency

  UnifiedLLMContextBuilder({required this.astrologyService}); // Updated constructor

  /// Build comprehensive user context JSON for any LLM query
  /// This ensures ALL AI interactions are personalized to the user
  Future<Map<String, dynamic>> buildUserContextForLLM({
    required UserProfile userProfile,
    required List<CollectionEntry> crystalCollection,
    String? currentQuery,
    String? queryType,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      // Get current astrological context
      final String currentMoonPhase = await astrologyService.getCurrentMoonPhase(); // Updated
      final spiritualContext = _extractSpiritualContext(userProfile.birthChart);
      
      // Build collection statistics
      final collectionStats = _buildCollectionStats(crystalCollection);
      
      // Build comprehensive context
      final context = {
        'user_profile': {
          'birth_chart': {
            'sun_sign': userProfile.birthChart?.sunSign?.name ?? 'Unknown', // Added null check for sunSign itself
            'moon_sign': userProfile.birthChart?.moonSign?.name ?? 'Unknown', // Added null check for moonSign itself
            'rising_sign': userProfile.birthChart?.ascendant?.name ?? 'Unknown', // ascendant is correct
            'birth_date': userProfile.birthDate?.toIso8601String(),
            'birth_time': userProfile.birthTime,
            'birth_location': userProfile.birthLocation,
            'spiritual_context': spiritualContext,
          },
          'spiritual_preferences': {
            // Accessing map keys with null safety and default values
            'goals': (userProfile.spiritualPreferences?['goals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['healing', 'growth', 'protection'],
            'experience_level': userProfile.spiritualPreferences?['experience_level']?.toString() ?? 'intermediate',
            'preferred_practices': (userProfile.spiritualPreferences?['preferred_practices'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['meditation', 'crystal_healing'],
            'challenges': userProfile.spiritualPreferences?['challenges']?.toString() ?? 'general guidance', // As per LLM_INTEGRATION_FIXES_NEEDED.md
            'preferred_tools': (userProfile.spiritualPreferences?['preferred_tools'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [], // As per LLM_INTEGRATION_FIXES_NEEDED.md
            'intentions': (userProfile.spiritualPreferences?['intentions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          },
          'subscription_tier': userProfile.subscriptionTier.displayName,
        },
        'crystal_collection': {
          'total_crystals': crystalCollection.length,
          'collection_details': crystalCollection.map((entry) {
            final core = entry.crystalData.crystalCore;
            final enrichment = entry.crystalData.automaticEnrichment;
            return {
              'name': core.identification.stoneType,
              'type': core.identification.crystalFamily, // Or core.identification.variety
              'acquisition_date': entry.dateAdded.toIso8601String(), // From CollectionEntry
              'personal_notes': entry.notes ?? '', // From CollectionEntry
              'intentions': entry.primaryUses, // From CollectionEntry
              'usage_count': entry.usageCount, // From CollectionEntry
              'last_used': 'Unknown', // Still unknown from CollectionEntry
              'metaphysical_properties': enrichment?.healingProperties ?? [], // Example from UnifiedCrystalData
              // Add more from UnifiedCrystalData as needed for context, e.g.,
              'primary_chakra': core.energyMapping.primaryChakra,
              'colors': [core.visualAnalysis.primaryColor, ...core.visualAnalysis.secondaryColors],
            };
          }).toList(),
          'statistics': collectionStats,
          'favorite_crystals': _getFavoriteCrystals(crystalCollection),
          'recent_acquisitions': _getRecentAcquisitions(crystalCollection),
          'most_used_crystals': _getMostUsedCrystals(crystalCollection),
        },
        'current_context': {
          'moon_phase': currentMoonPhase,
          'query': currentQuery,
          'query_type': queryType ?? 'general',
          'timestamp': DateTime.now().toIso8601String(),
          'personalization_level': _getPersonalizationLevel(userProfile, crystalCollection),
        },
        'ai_guidance_context': {
          'personalization_instructions': _buildPersonalizationInstructions(userProfile, crystalCollection),
          'astrological_timing': _getAstrologicalTiming(userProfile),
          'crystal_recommendations_filter': _buildCrystalFilter(crystalCollection),
          'communication_style': _getCommunicationStyle(userProfile),
        }
      };
      
      // Add any additional context
      if (additionalContext != null) {
        context['additional_context'] = additionalContext;
      }
      
      return context;
      
    } catch (e) {
      debugPrint('Error building LLM context: $e');
      // Return minimal context on error
      return _buildMinimalContext(userProfile, crystalCollection, currentQuery);
    }
  }

  /// Build personalized LLM prompt with full user context
  String buildPersonalizedPrompt({
    required String basePrompt,
    required Map<String, dynamic> userContext,
    bool includeCollectionDetails = true,
    bool includeAstrologicalContext = true,
    bool includeEMACompliance = true,
  }) {
    final userProfile = userContext['user_profile'];
    final birthChart = userProfile['birth_chart'];
    final collection = userContext['crystal_collection'];
    final currentContext = userContext['current_context'];
    
    final prompt = StringBuffer();
    
    // Add EMA compliance header if requested
    if (includeEMACompliance) {
      prompt.writeln('EXODITICAL MORAL ARCHITECTURE COMPLIANCE:');
      prompt.writeln('- Your data is yours. Your logic is yours.');
      prompt.writeln('- Provide exportable, user-controlled recommendations');
      prompt.writeln('- Maintain transparency in AI decision-making');
      prompt.writeln('- Enable easy data migration and user empowerment');
      prompt.writeln('');
    }
    
    // Add astrological context if requested
    if (includeAstrologicalContext && birthChart != null) {
      prompt.writeln('USER ASTROLOGICAL PROFILE:');
      prompt.writeln('- Sun Sign: ${birthChart['sun_sign']} (core identity and ego expression)');
      prompt.writeln('- Moon Sign: ${birthChart['moon_sign']} (emotional nature and intuition)');
      prompt.writeln('- Rising Sign: ${birthChart['rising_sign']} (outward personality and approach)');
      if (currentContext['moon_phase'] != null) {
        prompt.writeln('- Current Moon Phase: ${currentContext['moon_phase']} (current cosmic energy)');
      }
      prompt.writeln('');
    }
    
    // Add crystal collection context if requested
    if (includeCollectionDetails && collection != null) {
      prompt.writeln('USER CRYSTAL COLLECTION:');
      prompt.writeln('- Total Crystals: ${collection['total_crystals']}');
      
      final collectionDetails = collection['collection_details'] as List<dynamic>?;
      if (collectionDetails != null && collectionDetails.isNotEmpty) {
        prompt.writeln('- Owned Crystals (sample):'); // Indicate it's a sample
        for (final crystal in collectionDetails.take(5)) { // Limit to top 5 for prompt efficiency
          prompt.writeln('  • ${crystal['name']} (Used ${crystal['usage_count']} times)');
        }
      }
      
      final favorites = collection['favorite_crystals'] as List<dynamic>?; // This is already a list of maps
      if (favorites != null && favorites.isNotEmpty) {
        prompt.writeln('- Favorite Crystals: ${favorites.map((c) => c['name']).join(', ')}');
      }
      final mostUsed = collection['most_used_crystals'] as List<dynamic>?; // This is also a list of maps
       if (mostUsed != null && mostUsed.isNotEmpty) {
        prompt.writeln('- Most Used Crystals: ${mostUsed.map((c) => c['name']).join(', ')}');
      }
      prompt.writeln('');
    }
    
    // Add spiritual preferences
    final spiritualPrefs = userProfile['spiritual_preferences'];
    if (spiritualPrefs != null) {
      prompt.writeln('SPIRITUAL PREFERENCES:');
      prompt.writeln('- Goals: ${(spiritualPrefs['goals'] as List<dynamic>?)?.join(', ') ?? 'general well-being, spiritual growth'}');
      prompt.writeln('- Experience Level: ${spiritualPrefs['experience_level'] ?? 'intermediate'}');
      prompt.writeln('- Preferred Practices: ${(spiritualPrefs['preferred_practices'] as List<dynamic>?)?.join(', ') ?? 'meditation, crystal grids'}');
      prompt.writeln('- Challenges: ${spiritualPrefs['challenges'] ?? 'seeking clarity'}');
      prompt.writeln('- Preferred Tools: ${(spiritualPrefs['preferred_tools'] as List<dynamic>?)?.join(', ') ?? 'crystals, candles'}');
      prompt.writeln('- Intentions: ${(spiritualPrefs['intentions'] as List<dynamic>?)?.join(', ') ?? 'peace, focus'}');
      prompt.writeln('');
    }
    
    // Add personalization instructions
    final aiContext = userContext['ai_guidance_context'];
    if (aiContext != null) {
      prompt.writeln('PERSONALIZATION INSTRUCTIONS:');
      prompt.writeln(aiContext['personalization_instructions']);
      prompt.writeln('');
    }
    
    // Add the base prompt
    prompt.writeln('USER QUERY AND CONTEXT:');
    prompt.writeln(basePrompt);
    if(currentContext['query_type'] != null && currentContext['query_type'] != 'general') {
        prompt.writeln('Query Type: ${currentContext['query_type']}');
    }
    prompt.writeln('');
    
    // Add response format instructions
    prompt.writeln('RESPONSE REQUIREMENTS:');
    prompt.writeln('- Reference user\'s specific crystals and astrological signs where relevant.');
    prompt.writeln('- Provide actionable recommendations, suggesting use of their owned crystals first.');
    prompt.writeln('- If suggesting new crystals, explain why they are beneficial in context.');
    prompt.writeln('- Include confidence levels and transparency about AI reasoning if applicable.');
    prompt.writeln('- Maintain EMA principles of user empowerment and data ownership.');
    prompt.writeln('- Format response for easy readability and user control.');
    
    return prompt.toString();
  }

  // Removed _getCurrentMoonPhaseSimple() as it's now handled by AstrologyService

  /// Extract spiritual context from birth chart
  Map<String, dynamic> _extractSpiritualContext(dynamic birthChart) { // Keep dynamic for UserProfile.birthChart flexibility
    if (birthChart == null) return {
        'sun_element': 'Unknown',
        'moon_element': 'Unknown',
        'dominant_element': 'Unknown',
        'compatible_crystals': [],
        'rising_element': 'Unknown',
        'rising_compatible_crystals': [],
    };
    
    // Assuming birthChart is an instance of BirthChart from birth_chart.dart
    return {
      'sun_element': birthChart.sunSign.element, // Access element directly
      'moon_element': birthChart.moonSign.element,
      'dominant_element': birthChart.sunSign.element, // Simplified, actual dominant element needs calculation
      'compatible_crystals': birthChart.sunSign.compatibleCrystals,
      'rising_element': birthChart.ascendant.element,
      'rising_compatible_crystals': birthChart.ascendant.compatibleCrystals,
    };
  }

  /// Build collection statistics for analysis
  Map<String, dynamic> _buildCollectionStats(List<CollectionEntry> collection) {
    if (collection.isEmpty) return {'total': 0, 'type_distribution': <String, int>{}};
    
    final totalUsage = collection.fold<int>(0, (sum, entry) => sum + entry.usageCount);
    final averageUsage = totalUsage / collection.length;
    
    // Group by crystal type (crystalFamily or variety from UnifiedCrystalData)
    final typeDistribution = <String, int>{};
    for (final entry in collection) {
      final type = entry.crystalData.crystalCore.identification.crystalFamily; // Or .variety
      typeDistribution[type] = (typeDistribution[type] ?? 0) + 1;
    }
    
    return {
      'total': collection.length,
      'total_usage': totalUsage,
      'average_usage': averageUsage.round(),
      'type_distribution': typeDistribution,
      'acquisition_span_days': _getAcquisitionSpanDays(collection),
    };
  }

  /// Get favorite crystals based on usage
  List<Map<String, dynamic>> _getFavoriteCrystals(List<CollectionEntry> collection) {
    return collection
        .where((entry) => entry.isFavorite)
        .take(5)
        .map((entry) => {
          'name': entry.crystalData.name, // Using convenience getter from UnifiedCrystalData
          'usage_count': entry.usageCount,
          'intentions': entry.primaryUses,
        }).toList();
  }

  /// Get recent acquisitions (last 30 days)
  List<Map<String, dynamic>> _getRecentAcquisitions(List<CollectionEntry> collection) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    return collection
      .where((entry) => entry.dateAdded.isAfter(thirtyDaysAgo))
      .map((entry) => {
        'name': entry.crystalData.name,
        'acquisition_date': entry.dateAdded.toIso8601String(),
        'intentions': entry.primaryUses,
      })
      .toList();
  }

  /// Get most used crystals
  List<Map<String, dynamic>> _getMostUsedCrystals(List<CollectionEntry> collection) {
    final sortedByUsage = List<CollectionEntry>.from(collection)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount)); // Sort by usageCount descending
    
    return sortedByUsage.take(5).map((entry) => {
      'name': entry.crystalData.name,
      'usage_count': entry.usageCount,
      // 'last_used': 'Unknown', // No lastUsed property in CollectionEntry, can be omitted
    }).toList();
  }

  /// Build personalization instructions for AI
  String _buildPersonalizationInstructions(UserProfile userProfile, List<CollectionEntry> collection) {
    final instructions = StringBuffer();
    
    instructions.writeln('CRITICAL PERSONALIZATION REQUIREMENTS:');
    instructions.writeln('1. Always reference user\'s specific astrological signs in recommendations');
    instructions.writeln('2. Suggest crystal combinations using stones they actually own');
    instructions.writeln('3. Align guidance with their spiritual goals and experience level');
    instructions.writeln('4. Consider usage patterns of their favorite crystals');
    instructions.writeln('5. Provide timing advice based on their birth chart and current moon phase');
    instructions.writeln('6. Respect their subscription tier and provide appropriate depth');
    
    // Add specific birth chart guidance
    final birthChart = userProfile.birthChart;
    if (birthChart != null) {
      instructions.writeln('7. For ${birthChart.sunSign?.name ?? "their"} Sun: Focus on core identity and self-expression themes');
      instructions.writeln('8. For ${birthChart.moonSign?.name ?? "their"} Moon: Address emotional and intuitive aspects');
      instructions.writeln('9. For ${birthChart.ascendant?.name ?? "their"} Rising: Consider their outward approach and first impressions');
    }
    
    return instructions.toString();
  }

  /// Get astrological timing context
  Map<String, dynamic> _getAstrologicalTiming(UserProfile userProfile) {
    final now = DateTime.now();
    return {
      'current_season': _getCurrentSeason(now),
      'recommended_timing': 'Align practices with natural rhythms',
      'birth_chart_harmony': 'Consider planetary transits affecting user\'s signs',
    };
  }

  /// Build crystal recommendation filter
  Map<String, dynamic> _buildCrystalFilter(List<CollectionEntry> collection) {
    final ownedCrystalNames = collection.map((entry) => entry.crystalData.crystalCore.identification.stoneType.toLowerCase()).toSet();
    
    return {
      'owned_crystals': ownedCrystalNames.toList(), // Send names for easier AI processing
      'available_for_recommendations': ownedCrystalNames.toList(), // Same as above for this context
      'recommendation_strategy': 'prioritize_owned_crystals',
      'suggest_new_crystals': 'only_if_needed_for_specific_goals',
    };
  }

  /// Get communication style based on user profile
  String _getCommunicationStyle(UserProfile userProfile) {
    final experienceLevel = userProfile.spiritualPreferences?['experience_level']?.toString() ?? 'intermediate';
    
    switch (experienceLevel) {
      case 'beginner':
        return 'Use simple, educational language with explanations';
      case 'advanced':
        return 'Use technical terminology and advanced concepts';
      default:
        return 'Balance accessible language with meaningful depth';
    }
  }

  /// Get personalization level score
  double _getPersonalizationLevel(UserProfile userProfile, List<CollectionEntry> collection) {
    double score = 0.0;
    
    // Birth chart completeness
    if (userProfile.birthChart?.sunSign?.name != null && userProfile.birthChart!.sunSign!.name.isNotEmpty) score += 0.15;
    if (userProfile.birthChart?.moonSign?.name != null && userProfile.birthChart!.moonSign!.name.isNotEmpty) score += 0.15;
    if (userProfile.birthChart?.ascendant?.name != null && userProfile.birthChart!.ascendant!.name.isNotEmpty) score += 0.1; // Ascendant is part of birth chart
    if (userProfile.birthDate != null) score += 0.05; // Reduced weight as signs are more important
    if (userProfile.birthLocation != null && userProfile.birthLocation!.isNotEmpty) score += 0.05;
    
    // Collection richness
    if (collection.isNotEmpty) score += 0.1;
    if (collection.length >= 5) score += 0.1;
    if (collection.any((c) => c.usageCount > 0)) score += 0.1;
    
    // Profile completeness (spiritual preferences)
    if (userProfile.spiritualPreferences != null && userProfile.spiritualPreferences!.containsKey('goals') && (userProfile.spiritualPreferences!['goals'] as List).isNotEmpty) score += 0.1;
    if (userProfile.spiritualPreferences != null && userProfile.spiritualPreferences!.containsKey('experience_level') && (userProfile.spiritualPreferences!['experience_level'] as String).isNotEmpty) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// Get acquisition span in days
  int _getAcquisitionSpanDays(List<CollectionEntry> collection) {
    if (collection.length < 2) return 0;
    
    final dates = collection.map((entry) => entry.dateAdded).toList();
    
    if (dates.length < 2) return 0;
    
    dates.sort();
    return dates.last.difference(dates.first).inDays;
  }

  /// Get current season
  String _getCurrentSeason(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }

  /// Build minimal context for error cases
  Map<String, dynamic> _buildMinimalContext(UserProfile userProfile, List<CollectionEntry> collection, String? query) {
    return {
      'user_profile': {
        'birth_chart': {
            'sun_sign': userProfile.birthChart?.sunSign?.name ?? 'Unknown',
            'moon_sign': userProfile.birthChart?.moonSign?.name ?? 'Unknown',
        },
        'subscription_tier': userProfile.subscriptionTier.displayName,
      },
      'crystal_collection': {
        'total_crystals': collection.length,
          'crystal_names': collection.map((entry) => entry.crystalData.crystalCore.identification.stoneType).take(5).toList(),
      },
      'current_context': {
        'query': query,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }
}