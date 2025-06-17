import 'package:flutter/foundation.dart';
import '../models/crystal.dart';
import '../models/crystal_collection.dart';
import '../models/journal_entry.dart';
import '../models/user_profile.dart';
import 'collection_service_v2.dart';
import 'firebase_service.dart';

/// Service that links all features together for seamless integration
class FeatureIntegrationService extends ChangeNotifier {
  final CollectionServiceV2 _collectionService;
  final FirebaseService _firebaseService;
  
  // Cross-feature data
  Map<String, List<String>> _crystalRecommendations = {};
  Map<String, double> _moodTrends = {};
  List<String> _recentActivities = [];
  
  FeatureIntegrationService({
    required CollectionServiceV2 collectionService,
    required FirebaseService firebaseService,
  }) : _collectionService = collectionService,
       _firebaseService = firebaseService {
    _setupListeners();
  }
  
  // Getters
  Map<String, List<String>> get crystalRecommendations => Map.unmodifiable(_crystalRecommendations);
  Map<String, double> get moodTrends => Map.unmodifiable(_moodTrends);
  List<String> get recentActivities => List.unmodifiable(_recentActivities);
  
  /// Setup listeners for cross-feature integration
  void _setupListeners() {
    _collectionService.addListener(_onCollectionChanged);
    _firebaseService.addListener(_onUserProfileChanged);
  }
  
  /// Handle collection changes and update related features
  void _onCollectionChanged() {
    _updateCrystalRecommendations();
    _analyzeCollectionPatterns();
    _addActivity('Updated crystal collection');
    notifyListeners();
  }
  
  /// Handle user profile changes
  void _onUserProfileChanged() {
    _updatePersonalizedRecommendations();
    notifyListeners();
  }
  
  /// Update crystal recommendations based on user's collection and needs
  void _updateCrystalRecommendations() {
    final collection = _collectionService.collection;
    final ownedCrystals = collection.map((e) => e.crystal.name.toLowerCase()).toSet();
    
    // Analyze chakra gaps
    final chakraCoverage = _analyzeChakraCoverage(collection);
    _crystalRecommendations['chakra_gaps'] = _getChakraGapRecommendations(chakraCoverage, ownedCrystals);
    
    // Analyze healing property gaps
    final healingCoverage = _analyzeHealingCoverage(collection);
    _crystalRecommendations['healing_gaps'] = _getHealingGapRecommendations(healingCoverage, ownedCrystals);
    
    // Analyze element balance
    final elementBalance = _analyzeElementBalance(collection);
    _crystalRecommendations['element_balance'] = _getElementBalanceRecommendations(elementBalance, ownedCrystals);
  }
  
  /// Update recommendations based on user's birth chart
  void _updatePersonalizedRecommendations() {
    final userProfile = _firebaseService.currentUserProfile;
    if (userProfile?.birthChart == null) return;
    
    final birthChart = userProfile!.birthChart!;
    final ownedCrystals = _collectionService.collection.map((e) => e.crystal.name.toLowerCase()).toSet();
    
    // Recommendations based on sun sign
    _crystalRecommendations['sun_sign'] = _getSunSignRecommendations(birthChart.sunSign.name, ownedCrystals);
    
    // Recommendations based on moon sign
    _crystalRecommendations['moon_sign'] = _getMoonSignRecommendations(birthChart.moonSign.name, ownedCrystals);
    
    // Recommendations based on dominant element (simplified)
    final dominantElement = _getDominantElement(birthChart);
    _crystalRecommendations['birth_element'] = _getElementRecommendations(dominantElement, ownedCrystals);
  }
  
  /// Analyze chakra coverage in collection
  Map<String, int> _analyzeChakraCoverage(List<CollectionEntry> collection) {
    final coverage = <String, int>{};
    final chakras = ['Root', 'Sacral', 'Solar Plexus', 'Heart', 'Throat', 'Third Eye', 'Crown'];
    
    for (final chakra in chakras) {
      coverage[chakra] = collection.where((entry) => 
        entry.crystal.chakras.contains(chakra)
      ).length;
    }
    
    return coverage;
  }
  
  /// Get recommendations for chakras with low coverage
  List<String> _getChakraGapRecommendations(Map<String, int> coverage, Set<String> ownedCrystals) {
    final recommendations = <String>[];
    final chakraCrystals = {
      'Root': ['Red Jasper', 'Hematite', 'Black Tourmaline'],
      'Sacral': ['Carnelian', 'Orange Calcite', 'Sunstone'],
      'Solar Plexus': ['Citrine', 'Yellow Jasper', 'Tiger\'s Eye'],
      'Heart': ['Rose Quartz', 'Green Aventurine', 'Emerald'],
      'Throat': ['Blue Lace Agate', 'Sodalite', 'Aquamarine'],
      'Third Eye': ['Amethyst', 'Lapis Lazuli', 'Fluorite'],
      'Crown': ['Clear Quartz', 'Selenite', 'Lepidolite'],
    };
    
    // Find chakras with 0 or 1 crystals
    coverage.forEach((chakra, count) {
      if (count <= 1) {
        final crystalsForChakra = chakraCrystals[chakra] ?? [];
        for (final crystal in crystalsForChakra) {
          if (!ownedCrystals.contains(crystal.toLowerCase()) && recommendations.length < 5) {
            recommendations.add(crystal);
          }
        }
      }
    });
    
    return recommendations;
  }
  
  /// Analyze healing property coverage
  Map<String, int> _analyzeHealingCoverage(List<CollectionEntry> collection) {
    final coverage = <String, int>{};
    final healingTypes = ['Protection', 'Love', 'Abundance', 'Healing', 'Intuition', 'Grounding', 'Clarity'];
    
    for (final type in healingTypes) {
      coverage[type] = collection.where((entry) => 
        entry.crystal.healingProperties.any((prop) => prop.toLowerCase().contains(type.toLowerCase()))
      ).length;
    }
    
    return coverage;
  }
  
  /// Get recommendations for healing properties with low coverage
  List<String> _getHealingGapRecommendations(Map<String, int> coverage, Set<String> ownedCrystals) {
    final recommendations = <String>[];
    final healingCrystals = {
      'Protection': ['Black Tourmaline', 'Obsidian', 'Smoky Quartz'],
      'Love': ['Rose Quartz', 'Rhodonite', 'Green Aventurine'],
      'Abundance': ['Citrine', 'Pyrite', 'Green Aventurine'],
      'Healing': ['Clear Quartz', 'Amethyst', 'Fluorite'],
      'Intuition': ['Moonstone', 'Labradorite', 'Amethyst'],
      'Grounding': ['Hematite', 'Red Jasper', 'Smoky Quartz'],
      'Clarity': ['Clear Quartz', 'Fluorite', 'Sodalite'],
    };
    
    coverage.forEach((healing, count) {
      if (count == 0) {
        final crystalsForHealing = healingCrystals[healing] ?? [];
        for (final crystal in crystalsForHealing) {
          if (!ownedCrystals.contains(crystal.toLowerCase()) && recommendations.length < 5) {
            recommendations.add(crystal);
          }
        }
      }
    });
    
    return recommendations;
  }
  
  /// Analyze element balance in collection
  Map<String, int> _analyzeElementBalance(List<CollectionEntry> collection) {
    final balance = <String, int>{};
    final elements = ['Earth', 'Water', 'Fire', 'Air'];
    
    for (final element in elements) {
      balance[element] = collection.where((entry) => 
        entry.crystal.elements.contains(element)
      ).length;
    }
    
    return balance;
  }
  
  /// Get recommendations for element balance
  List<String> _getElementBalanceRecommendations(Map<String, int> balance, Set<String> ownedCrystals) {
    final recommendations = <String>[];
    final elementCrystals = {
      'Earth': ['Hematite', 'Jasper', 'Moss Agate'],
      'Water': ['Moonstone', 'Aquamarine', 'Blue Lace Agate'],
      'Fire': ['Carnelian', 'Red Jasper', 'Sunstone'],
      'Air': ['Clear Quartz', 'Amethyst', 'Celestite'],
    };
    
    // Find the element with lowest count
    final minCount = balance.values.reduce((a, b) => a < b ? a : b);
    balance.forEach((element, count) {
      if (count == minCount) {
        final crystalsForElement = elementCrystals[element] ?? [];
        for (final crystal in crystalsForElement) {
          if (!ownedCrystals.contains(crystal.toLowerCase()) && recommendations.length < 3) {
            recommendations.add(crystal);
          }
        }
      }
    });
    
    return recommendations;
  }
  
  /// Get recommendations based on sun sign
  List<String> _getSunSignRecommendations(String sunSign, Set<String> ownedCrystals) {
    final sunSignCrystals = {
      'Aries': ['Carnelian', 'Red Jasper', 'Bloodstone'],
      'Taurus': ['Rose Quartz', 'Emerald', 'Malachite'],
      'Gemini': ['Agate', 'Citrine', 'Tiger\'s Eye'],
      'Cancer': ['Moonstone', 'Pearl', 'Labradorite'],
      'Leo': ['Sunstone', 'Citrine', 'Pyrite'],
      'Virgo': ['Moss Agate', 'Amazonite', 'Sapphire'],
      'Libra': ['Lapis Lazuli', 'Opal', 'Rose Quartz'],
      'Scorpio': ['Obsidian', 'Garnet', 'Malachite'],
      'Sagittarius': ['Turquoise', 'Sodalite', 'Azurite'],
      'Capricorn': ['Garnet', 'Hematite', 'Onyx'],
      'Aquarius': ['Amethyst', 'Aquamarine', 'Fluorite'],
      'Pisces': ['Amethyst', 'Moonstone', 'Aquamarine'],
    };
    
    final crystals = sunSignCrystals[sunSign] ?? [];
    return crystals.where((crystal) => !ownedCrystals.contains(crystal.toLowerCase())).take(3).toList();
  }
  
  /// Get recommendations based on moon sign
  List<String> _getMoonSignRecommendations(String moonSign, Set<String> ownedCrystals) {
    // Moon sign affects emotional needs
    final moonSignCrystals = {
      'Aries': ['Rose Quartz', 'Lepidolite', 'Blue Lace Agate'],
      'Taurus': ['Green Aventurine', 'Moss Agate', 'Emerald'],
      'Gemini': ['Fluorite', 'Sodalite', 'Clear Quartz'],
      'Cancer': ['Moonstone', 'Pearl', 'Selenite'],
      'Leo': ['Sunstone', 'Amber', 'Golden Calcite'],
      'Virgo': ['Amazonite', 'Moss Agate', 'Peridot'],
      'Libra': ['Rose Quartz', 'Pink Tourmaline', 'Opal'],
      'Scorpio': ['Labradorite', 'Obsidian', 'Moldavite'],
      'Sagittarius': ['Lapis Lazuli', 'Sodalite', 'Turquoise'],
      'Capricorn': ['Smoky Quartz', 'Hematite', 'Garnet'],
      'Aquarius': ['Amethyst', 'Aquamarine', 'Celestite'],
      'Pisces': ['Amethyst', 'Moonstone', 'Labradorite'],
    };
    
    final crystals = moonSignCrystals[moonSign] ?? [];
    return crystals.where((crystal) => !ownedCrystals.contains(crystal.toLowerCase())).take(2).toList();
  }
  
  /// Get dominant element from birth chart
  String _getDominantElement(dynamic birthChart) {
    final elements = <String, int>{};
    
    // Count elements from birth chart
    elements[birthChart.sunSign.element] = (elements[birthChart.sunSign.element] ?? 0) + 1;
    elements[birthChart.moonSign.element] = (elements[birthChart.moonSign.element] ?? 0) + 1;
    elements[birthChart.ascendant.element] = (elements[birthChart.ascendant.element] ?? 0) + 1;
    
    // Find dominant element
    String dominantElement = 'Earth';
    int maxCount = 0;
    elements.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantElement = element;
      }
    });
    
    return dominantElement;
  }
  
  /// Get recommendations based on dominant element
  List<String> _getElementRecommendations(String element, Set<String> ownedCrystals) {
    final elementCrystals = {
      'Fire': ['Carnelian', 'Red Jasper', 'Sunstone', 'Citrine'],
      'Earth': ['Hematite', 'Smoky Quartz', 'Moss Agate', 'Jasper'],
      'Air': ['Clear Quartz', 'Amethyst', 'Sodalite', 'Celestite'],
      'Water': ['Moonstone', 'Aquamarine', 'Blue Lace Agate', 'Labradorite'],
    };
    
    final crystals = elementCrystals[element] ?? [];
    return crystals.where((crystal) => !ownedCrystals.contains(crystal.toLowerCase())).take(2).toList();
  }
  
  /// Analyze collection patterns for insights
  void _analyzeCollectionPatterns() {
    final collection = _collectionService.collection;
    if (collection.isEmpty) return;
    
    // Analyze most used crystals
    final sortedByUsage = List<CollectionEntry>.from(collection)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    if (sortedByUsage.isNotEmpty) {
      final mostUsed = sortedByUsage.first;
      if (mostUsed.usageCount > 0) {
        _addActivity('Most used crystal: ${mostUsed.crystal.name} (${mostUsed.usageCount} uses)');
      }
    }
    
    // Analyze recent additions
    final recentlyAdded = collection.where((entry) => 
      DateTime.now().difference(entry.dateAdded).inDays <= 7
    ).length;
    
    if (recentlyAdded > 0) {
      _addActivity('Added $recentlyAdded new crystals this week');
    }
  }
  
  /// Add activity to recent activities list
  void _addActivity(String activity) {
    _recentActivities.insert(0, activity);
    if (_recentActivities.length > 10) {
      _recentActivities.removeLast();
    }
  }
  
  /// Log usage across features
  Future<void> logCrossFeatureUsage({
    required String feature,
    required String crystalId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    // Log usage in collection service
    await _collectionService.logUsage(
      crystalId,
      purpose: '$feature: $action',
      intention: metadata?['intention'],
      result: metadata?['result'],
      moodBefore: metadata?['mood_before'],
      moodAfter: metadata?['mood_after'],
    );
    
    // Add activity
    final entry = _collectionService.collection
        .where((e) => e.id == crystalId)
        .firstOrNull;
    
    if (entry == null) return;
    
    final crystal = entry.crystal;
    
    _addActivity('Used ${crystal.name} for $feature ($action)');
    
    // Update mood trends if mood data is available
    if (metadata?['mood_before'] != null && metadata?['mood_after'] != null) {
      final improvement = (metadata!['mood_after'] as int) - (metadata['mood_before'] as int);
      _moodTrends[crystal.name] = (_moodTrends[crystal.name] ?? 0) + improvement;
    }
    
    notifyListeners();
  }
  
  /// Get personalized guidance context
  Map<String, dynamic> getGuidanceContext() {
    final userProfile = _firebaseService.currentUserProfile;
    final collection = _collectionService.collection;
    
    return {
      'birth_chart': userProfile?.birthChart?.toJson(),
      'collection_size': collection.length,
      'favorite_crystals': collection.where((e) => e.isFavorite).map((e) => e.crystal.name).toList(),
      'most_used_crystals': collection
          .where((e) => e.usageCount > 0)
          .map((e) => {'name': e.crystal.name, 'usage_count': e.usageCount})
          .toList(),
      'chakra_coverage': _analyzeChakraCoverage(collection),
      'element_balance': _analyzeElementBalance(collection),
      'recommendations': _crystalRecommendations,
      'mood_trends': _moodTrends,
      'recent_activities': _recentActivities.take(5).toList(),
    };
  }
  
  /// Dispose and cleanup listeners
  @override
  void dispose() {
    _collectionService.removeListener(_onCollectionChanged);
    _firebaseService.removeListener(_onUserProfileChanged);
    super.dispose();
  }
}