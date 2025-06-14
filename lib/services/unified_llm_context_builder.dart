import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/crystal_collection.dart';

/// Unified LLM Context Builder - Creates comprehensive user context for all LLM queries
/// Ensures every AI interaction includes user's birth chart, crystal collection, and personalization data
class UnifiedLLMContextBuilder {
  UnifiedLLMContextBuilder();

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
      // Get current astrological context (placeholder for now)
      final currentMoonPhase = _getCurrentMoonPhaseSimple();
      final spiritualContext = _extractSpiritualContext(userProfile.birthChart);
      
      // Build collection statistics
      final collectionStats = _buildCollectionStats(crystalCollection);
      
      // Build comprehensive context
      final context = {
        'user_profile': {
          'birth_chart': {
            'sun_sign': userProfile.birthChart?.sunSign.name ?? 'Unknown',
            'moon_sign': userProfile.birthChart?.moonSign.name ?? 'Unknown', 
            'rising_sign': userProfile.birthChart?.ascendant.name ?? 'Unknown',
            'birth_date': userProfile.birthDate?.toIso8601String(),
            'birth_time': userProfile.birthTime,
            'birth_location': userProfile.birthLocation,
            'spiritual_context': spiritualContext,
          },
          'spiritual_preferences': {
            'goals': userProfile.spiritualPreferences['goals'] ?? ['healing', 'growth', 'protection'],
            'experience_level': userProfile.spiritualPreferences['experience_level'] ?? 'intermediate',
            'preferred_practices': userProfile.spiritualPreferences['preferred_practices'] ?? ['meditation', 'crystal_healing'],
            'intentions': userProfile.spiritualPreferences['intentions'] ?? [],
          },
          'subscription_tier': userProfile.subscriptionTier.displayName,
        },
        'crystal_collection': {
          'total_crystals': crystalCollection.length,
          'collection_details': crystalCollection.map((entry) => {
            'name': entry.crystal.name,
            'type': entry.crystal.type,
            'acquisition_date': entry.dateAdded.toIso8601String(),
            'personal_notes': entry.notes ?? '',
            'intentions': entry.primaryUses,
            'usage_count': entry.usageCount,
            'last_used': 'Unknown', // CollectionEntry doesn't have lastUsed
            'metaphysical_properties': entry.crystal.metaphysicalProperties,
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
        prompt.writeln('- Owned Crystals:');
        for (final crystal in collectionDetails.take(10)) { // Limit to top 10 for prompt efficiency
          prompt.writeln('  • ${crystal['name']} - Purpose: ${crystal['intentions']} (Used ${crystal['usage_count']} times)');
        }
      }
      
      final favorites = collection['favorite_crystals'] as List<dynamic>?;
      if (favorites != null && favorites.isNotEmpty) {
        prompt.writeln('- Favorite Crystals: ${favorites.map((c) => c['name']).join(', ')}');
      }
      prompt.writeln('');
    }
    
    // Add spiritual preferences
    final spiritualPrefs = userProfile['spiritual_preferences'];
    if (spiritualPrefs != null) {
      prompt.writeln('SPIRITUAL PREFERENCES:');
      prompt.writeln('- Goals: ${(spiritualPrefs['goals'] as List<dynamic>?)?.join(', ') ?? 'healing, growth'}');
      prompt.writeln('- Experience Level: ${spiritualPrefs['experience_level']}');
      prompt.writeln('- Preferred Practices: ${(spiritualPrefs['preferred_practices'] as List<dynamic>?)?.join(', ') ?? 'meditation'}');
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
    prompt.writeln('');
    
    // Add response format instructions
    prompt.writeln('RESPONSE REQUIREMENTS:');
    prompt.writeln('- Reference user\'s specific crystals and astrological signs');
    prompt.writeln('- Provide actionable recommendations using their collection');
    prompt.writeln('- Include confidence levels and transparency about AI reasoning');
    prompt.writeln('- Maintain EMA principles of user empowerment and data ownership');
    prompt.writeln('- Format response for easy export and user control');
    
    return prompt.toString();
  }

  /// Simple moon phase calculation (placeholder)
  String _getCurrentMoonPhaseSimple() {
    // Simple approximation - in production would use proper lunar calculation
    final now = DateTime.now();
    final daysSinceNewMoon = (now.millisecondsSinceEpoch / (1000 * 60 * 60 * 24)) % 29.5;
    
    if (daysSinceNewMoon < 7.4) return 'Waxing Crescent';
    if (daysSinceNewMoon < 14.8) return 'Waxing Gibbous'; 
    if (daysSinceNewMoon < 22.1) return 'Waning Gibbous';
    return 'Waning Crescent';
  }

  /// Extract spiritual context from birth chart
  Map<String, dynamic> _extractSpiritualContext(dynamic birthChart) {
    if (birthChart == null) return {};
    
    return {
      'sun_element': birthChart.sunSign.element,
      'moon_element': birthChart.moonSign.element,
      'dominant_element': birthChart.sunSign.element, // Simplified
      'compatible_crystals': birthChart.sunSign.compatibleCrystals,
    };
  }

  /// Build collection statistics for analysis
  Map<String, dynamic> _buildCollectionStats(List<CollectionEntry> collection) {
    if (collection.isEmpty) return {'total': 0};
    
    final totalUsage = collection.fold<int>(0, (sum, entry) => sum + entry.usageCount);
    final averageUsage = totalUsage / collection.length;
    
    // Group by crystal type
    final typeDistribution = <String, int>{};
    for (final entry in collection) {
      final type = entry.crystal.type;
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
    final sorted = List<CollectionEntry>.from(collection)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return sorted.take(3).map((entry) => {
      'name': entry.crystal.name,
      'usage_count': entry.usageCount,
      'intentions': entry.primaryUses,
    }).toList();
  }

  /// Get recent acquisitions (last 30 days)
  List<Map<String, dynamic>> _getRecentAcquisitions(List<CollectionEntry> collection) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    return collection
      .where((entry) {
        return entry.dateAdded.isAfter(thirtyDaysAgo);
      })
      .map((entry) => {
        'name': entry.crystal.name,
        'acquisition_date': entry.dateAdded.toIso8601String(),
        'intentions': entry.primaryUses,
      })
      .toList();
  }

  /// Get most used crystals
  List<Map<String, dynamic>> _getMostUsedCrystals(List<CollectionEntry> collection) {
    final sorted = List<CollectionEntry>.from(collection)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return sorted.take(5).map((entry) => {
      'name': entry.crystal.name,
      'usage_count': entry.usageCount,
      'last_used': 'Unknown', // No lastUsed property in CollectionEntry
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
      instructions.writeln('7. For ${birthChart.sunSign.name} Sun: Focus on core identity and self-expression themes');
      instructions.writeln('8. For ${birthChart.moonSign.name} Moon: Address emotional and intuitive aspects');
      instructions.writeln('9. For ${birthChart.ascendant.name} Rising: Consider their outward approach and first impressions');
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
    final ownedCrystals = collection.map((entry) => entry.crystal.name.toLowerCase()).toSet();
    
    return {
      'owned_crystals': collection.map((entry) => entry.crystal.name).toList(),
      'available_for_recommendations': ownedCrystals.toList(),
      'recommendation_strategy': 'prioritize_owned_crystals',
      'suggest_new_crystals': 'only_if_needed_for_specific_goals',
    };
  }

  /// Get communication style based on user profile
  String _getCommunicationStyle(UserProfile userProfile) {
    final experienceLevel = userProfile.spiritualPreferences['experience_level'] ?? 'intermediate';
    
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
    if (userProfile.birthChart != null) score += 0.3;
    if (userProfile.birthDate != null) score += 0.1;
    if (userProfile.birthLocation != null) score += 0.1;
    
    // Collection richness
    if (collection.isNotEmpty) score += 0.2;
    if (collection.length >= 5) score += 0.1;
    if (collection.any((c) => c.usageCount > 0)) score += 0.1;
    
    // Profile completeness
    if (userProfile.spiritualPreferences['goals'] != null) score += 0.1;
    
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
          'sun_sign': userProfile.birthChart?.sunSign.name ?? 'Unknown',
          'moon_sign': userProfile.birthChart?.moonSign.name ?? 'Unknown',
        },
        'subscription_tier': userProfile.subscriptionTier.displayName,
      },
      'crystal_collection': {
        'total_crystals': collection.length,
        'crystal_names': collection.map((entry) => entry.crystal.name).take(5).toList(),
      },
      'current_context': {
        'query': query,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
  }
}