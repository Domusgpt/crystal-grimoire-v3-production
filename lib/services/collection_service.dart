import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crystal_collection.dart';
import '../models/crystal.dart';
import 'backend_service.dart';

/// Service for managing the user's crystal collection
class CollectionService {
  static const String _collectionKey = 'crystal_collection';
  static const String _usageLogsKey = 'crystal_usage_logs';
  
  // static List<CollectionEntry> _collection = []; // Managed by UnifiedDataService
  static List<UsageLog> _usageLogs = []; // Usage logs can remain managed here if not part of backend
  static bool _isLoaded = false;

  /// Get the current collection - DEPRECATED: Use UnifiedDataService.crystalCollection
  static List<CollectionEntry> get collection {
    // This getter is problematic as UnifiedDataService holds UnifiedCrystalData.
    // For now, returning an empty list or throwing error to indicate deprecation.
    debugPrint("CollectionService.collection getter is deprecated. Use UnifiedDataService.");
    return [];
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
    final entryIndex = _collection.indexWhere((e) => e.id == collectionEntryId);
    if (entryIndex != -1) {
      _collection[entryIndex] = _collection[entryIndex].recordUsage();
    }
    
    await _saveCollection();
    await _saveUsageLogs();
    
    return log;
  }

  /// Get collection statistics
  static CollectionStats getStats() {
    return CollectionStats.fromCollection(_collection, _usageLogs);
  }

  /// Get crystals by purpose
  static List<CollectionEntry> getCrystalsByPurpose(String purpose) {
    return _collection.where((entry) => 
      entry.primaryUses.contains(purpose)
    ).toList();
  }

  /// Get crystals by chakra
  static List<CollectionEntry> getCrystalsByChakra(String chakra) {
    return _collection.where((entry) => 
      entry.crystal.chakras.contains(chakra)
    ).toList();
  }

  /// Get favorite crystals
  static List<CollectionEntry> getFavorites() {
    return _collection.where((entry) => entry.isFavorite).toList();
  }

  /// Get most used crystals
  static List<CollectionEntry> getMostUsed({int limit = 5}) {
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
    final index = _collection.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final entry = _collection[index];
      _collection[index] = entry.copyWith(isFavorite: !entry.isFavorite);
      await _saveCollection();
    }
  }

  /// Search collection
  static List<CollectionEntry> searchCollection(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _collection.where((entry) {
      return entry.crystal.name.toLowerCase().contains(lowercaseQuery) ||
             entry.crystal.description.toLowerCase().contains(lowercaseQuery) ||
             entry.notes?.toLowerCase().contains(lowercaseQuery) == true ||
             entry.primaryUses.any((use) => use.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get AI recommendations context
  static Map<String, dynamic> getAIContext() {
    final stats = getStats();
    return {
      'collectionStats': stats.toAIContext(),
      'recentUsage': _getRecentUsageContext(),
      'preferences': _getUserPreferences(),
    };
  }

  /// Get recent usage context for AI
  static Map<String, dynamic> _getRecentUsageContext() {
    final recentLogs = _usageLogs.take(10).map((log) {
      final entry = _collection.firstWhere((e) => e.id == log.collectionEntryId);
      return {
        'crystal': entry.crystal.name,
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