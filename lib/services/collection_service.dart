import 'dart:convert';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crystal_collection.dart';
// import '../models/crystal.dart'; // Old model, not used directly here anymore
import '../models/unified_crystal_data.dart'; // For type reference
// import 'backend_service.dart'; // Assuming backend_service might be phased out or refactored

/// Service for managing the user's crystal collection
/// NOTE: Most crystal collection management is now intended to be handled by UnifiedDataService.
/// This service primarily handles local UsageLogs and provides some legacy collection-related methods
/// that currently operate on an empty or unmanaged collection.
class CollectionService {
  static const String _collectionKey = 'crystal_collection'; // Kept for potential legacy data or future use
  static const String _usageLogsKey = 'crystal_usage_logs';
  
  // _collection is intentionally not actively managed here.
  // Methods using it will operate on an empty list or as per their current logic
  // until full integration with UnifiedDataService.
  static List<CollectionEntry> _collection = [];
  static List<UsageLog> _usageLogs = [];
  static bool _isLoaded = false;

  /// Get the current collection - DEPRECATED: Use UnifiedDataService.crystalCollection
  static List<CollectionEntry> get collection {
    debugPrint("CollectionService.collection getter is deprecated. Use UnifiedDataService. This returns a local, likely empty, list.");
    return _collection; // Returning the local _collection for now for method structure
  }
  
  /// Get usage logs
  static List<UsageLog> get usageLogs => List.unmodifiable(_usageLogs);

  /// Initialize the collection service
  static Future<void> initialize() async {
    if (_isLoaded) return;
    
    final prefs = await SharedPreferences.getInstance();

    // Load usage logs (crystal collection is no longer loaded here)
    final logsJson = prefs.getString(_usageLogsKey);
    if (logsJson != null) {
      final List<dynamic> decoded = json.decode(logsJson);
      _usageLogs = decoded.map((e) => UsageLog.fromJson(e)).toList();
    }
    
    _isLoaded = true;
    
    // Sync with backend if authenticated - This was for its own collection, now removed.
    // if (BackendService.isAuthenticated) {
    //   await _syncWithBackend();
    // }
    debugPrint("CollectionService initialized (Usage Logs only). Crystal collection managed by UnifiedDataService.");
  }

  // /// Add a crystal to the collection - DEPRECATED: Use UnifiedDataService.addCrystal
  // static Future<CollectionEntry> addCrystal({
  //   required Crystal crystal,
  //   required String source,
  //   String? location,
  //   double? price,
  //   required String size,
  //   required String quality,
  //   List<String>? primaryUses,
  //   String? notes,
  //   List<String>? images,
  // }) async {
  //   throw UnimplementedError("CollectionService.addCrystal is deprecated. Use UnifiedDataService.");
  // }

  // /// Update a collection entry - DEPRECATED: Use UnifiedDataService.updateCrystal
  // static Future<void> updateEntry(CollectionEntry entry) async {
  //   throw UnimplementedError("CollectionService.updateEntry is deprecated. Use UnifiedDataService.");
  // }

  /// Record crystal usage
  static Future<UsageLog> recordUsage({
    required String collectionEntryId,
    required String purpose,
    String? intention,
    String? result,
    int? moodBefore,
    int? moodAfter,
    int? energyBefore,
    int? energyAfter,
  }) async {
    await initialize();
    
    // Create usage log
    final log = UsageLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      collectionEntryId: collectionEntryId,
      dateTime: DateTime.now(),
      purpose: purpose,
      intention: intention,
      result: result,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      energyBefore: energyBefore,
      energyAfter: energyAfter,
      moonPhase: MoonPhaseCalculator.getCurrentPhase(),
    );
    
    _usageLogs.add(log);
    
    // Update usage count
    // NOTE: This operates on the local _collection, which is not synced with UnifiedDataService.
    final entryIndex = _collection.indexWhere((e) => e.id == collectionEntryId);
    if (entryIndex != -1) {
      _collection[entryIndex] = _collection[entryIndex].recordUsage();
      // No _saveCollection() call here as it's deprecated for this service's direct management
    } else {
      debugPrint("CollectionService.recordUsage: Entry with id $collectionEntryId not found in local _collection.");
    }
    
    // await _saveCollection(); // Deprecated
    await _saveUsageLogs();
    
    return log;
  }

  /// Get collection statistics
  static CollectionStats getStats() {
    // NOTE: Operates on local _collection. For global stats, use UnifiedDataService.
    debugPrint("CollectionService.getStats: Generating stats from local _collection.");
    return CollectionStats.fromCollection(_collection, _usageLogs);
  }

  /// Get crystals by purpose
  static List<CollectionEntry> getCrystalsByPurpose(String purpose) {
    // NOTE: Operates on local _collection.
    return _collection.where((entry) => 
      entry.primaryUses.contains(purpose)
    ).toList();
  }

  /// Get crystals by chakra
  static List<CollectionEntry> getCrystalsByChakra(String chakra) {
    // NOTE: Operates on local _collection.
    // Needs to access UnifiedCrystalData for chakra information.
    return _collection.where((entry) {
      final primaryChakra = entry.crystalData.crystalCore.energyMapping.primaryChakra.toLowerCase();
      final secondaryChakras = entry.crystalData.crystalCore.energyMapping.secondaryChakras.map((c) => c.toLowerCase()).toList();
      return primaryChakra == chakra.toLowerCase() || secondaryChakras.contains(chakra.toLowerCase());
    }).toList();
  }

  /// Get favorite crystals
  static List<CollectionEntry> getFavorites() {
    // NOTE: Operates on local _collection.
    return _collection.where((entry) => entry.isFavorite).toList();
  }

  /// Get most used crystals
  static List<CollectionEntry> getMostUsed({int limit = 5}) {
    // NOTE: Operates on local _collection.
    final sorted = List<CollectionEntry>.from(_collection)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(limit).toList();
  }

  /// Get usage logs for a specific crystal
  static List<UsageLog> getUsageLogsForCrystal(String collectionEntryId) {
    return _usageLogs.where((log) => 
      log.collectionEntryId == collectionEntryId
    ).toList();
  }

  /// Toggle favorite status
  static Future<void> toggleFavorite(String entryId) async {
    // NOTE: Operates on local _collection.
    final index = _collection.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final entry = _collection[index];
      _collection[index] = entry.copyWith(isFavorite: !entry.isFavorite);
      // await _saveCollection(); // Deprecated
      debugPrint("CollectionService.toggleFavorite: Favorite status for entry $entryId toggled in local _collection. Not saved persistently by this service.");
    }
  }

  /// Search collection
  static List<CollectionEntry> searchCollection(String query) {
    // NOTE: Operates on local _collection.
    final lowercaseQuery = query.toLowerCase();
    return _collection.where((entry) {
      final core = entry.crystalData.crystalCore;
      final enrichment = entry.crystalData.automaticEnrichment;
      final name = core.identification.stoneType.toLowerCase();
      final description = (enrichment?.healingProperties ?? []).join(', ').toLowerCase(); // Example for description

      return name.contains(lowercaseQuery) ||
             description.contains(lowercaseQuery) ||
             entry.notes?.toLowerCase().contains(lowercaseQuery) == true ||
             entry.primaryUses.any((use) => use.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get AI recommendations context
  static Map<String, dynamic> getAIContext() {
    // NOTE: Uses local _collection for stats, usage, and preferences.
    debugPrint("CollectionService.getAIContext: Generating context from local _collection and _usageLogs.");
    final stats = getStats(); // Will use local _collection
    return {
      'collectionStats': stats.toAIContext(),
      'recentUsage': _getRecentUsageContext(), // Will use local _collection for entry details
      'preferences': _getUserPreferences(), // Will use local _collection
    };
  }

  /// Get recent usage context for AI
  static Map<String, dynamic> _getRecentUsageContext() {
    // NOTE: Uses local _collection to find entry details for logs.
    final recentLogs = _usageLogs.take(10).map((log) {
      final entry = _collection.firstWhere(
        (e) => e.id == log.collectionEntryId,
        // orElse: () => null, // Handle case where entry might not be in local _collection
      ); // This will throw if not found. Consider adding orElse.
      // If entry is not guaranteed to be in _collection, this needs robust handling.
      // For now, assuming it would be found if _collection was populated.
      return {
        'crystal': entry.crystalData.crystalCore.identification.stoneType,
        'purpose': log.purpose,
        'moodImprovement': log.moodAfter != null && log.moodBefore != null
            ? log.moodAfter! - log.moodBefore!
            : null,
        'energyImprovement': log.energyAfter != null && log.energyBefore != null
            ? log.energyAfter! - log.energyBefore!
            : null,
      };
    }).toList();
    
    return {
      'recentUsage': recentLogs,
      'totalUsageCount': _usageLogs.length,
    };
  }

  /// Get user preferences based on collection
  static Map<String, dynamic> _getUserPreferences() {
    final purposes = <String, int>{};
    final sizes = <String, int>{};
    final qualities = <String, int>{};
    
    for (final entry in _collection) {
      for (final purpose in entry.primaryUses) {
        purposes[purpose] = (purposes[purpose] ?? 0) + 1;
      }
      sizes[entry.size] = (sizes[entry.size] ?? 0) + 1;
      qualities[entry.quality] = (qualities[entry.quality] ?? 0) + 1;
    }
    
    return {
      'preferredPurposes': purposes,
      'preferredSizes': sizes,
      'preferredQualities': qualities,
    };
  }

  /// Save collection to local storage
  // static Future<void> _saveCollection() async {
  //   // Deprecated as collection is not managed here
  // }

  /// Save usage logs to local storage
  static Future<void> _saveUsageLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_usageLogs.map((e) => e.toJson()).toList());
    await prefs.setString(_usageLogsKey, json);
  }

  /// Sync with backend
  // static Future<void> _syncWithBackend() async {
  //   // Deprecated
  // }

  // /// Sync single entry to backend
  // static Future<void> _syncEntryToBackend(CollectionEntry entry) async {
  //   // Deprecated
  // }

  /// Clear all data (for logout)
  static Future<void> clear() async {
    // _collection.clear(); // Not managed here
    _usageLogs.clear();
    _isLoaded = false; // Resets loading state for usage logs
    
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(_collectionKey); // Collection key not used here anymore for loading
    await prefs.remove(_usageLogsKey);
    debugPrint("CollectionService data cleared (Usage Logs only).");
  }
}

/// Moon phase calculator
class MoonPhaseCalculator {
  static String getCurrentPhase() {
    final now = DateTime.now();
    final newMoon = DateTime(2025, 1, 29); // Known new moon date
    final daysSince = now.difference(newMoon).inDays;
    final phase = (daysSince % 29.5) / 29.5;
    
    if (phase < 0.0625) return '🌑 New Moon';
    if (phase < 0.1875) return '🌒 Waxing Crescent';
    if (phase < 0.3125) return '🌓 First Quarter';
    if (phase < 0.4375) return '🌔 Waxing Gibbous';
    if (phase < 0.5625) return '🌕 Full Moon';
    if (phase < 0.6875) return '🌖 Waning Gibbous';
    if (phase < 0.8125) return '🌗 Last Quarter';
    return '🌘 Waning Crescent';
  }
}