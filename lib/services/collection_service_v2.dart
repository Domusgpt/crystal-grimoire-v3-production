import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../models/crystal_collection.dart'; // Replaced by UnifiedCrystalData
import '../models/unified_crystal_data.dart';
import '../models/collection_models.dart';
import 'unified_data_service.dart';

/// Production-ready Collection Service with proper instance management
/// This service should now primarily interact with UnifiedDataService for crystal data.
class CollectionServiceV2 extends ChangeNotifier {
  static const String _usageLogsKey = 'crystal_usage_logs_v2';
  
  final UnifiedDataService _unifiedDataService; // Primary source for crystal data
  
  List<UnifiedCrystalData> _collection = []; // Changed type
  List<UsageLog> _usageLogs = [];
  bool _isLoaded = false;
  bool _isSyncing = false; // Syncing concept might change
  String? _lastError;
  
  CollectionServiceV2({
    required UnifiedDataService unifiedDataService,
  }) : _unifiedDataService = unifiedDataService {
    // Listen to UnifiedDataService for changes to the crystal collection
    _unifiedDataService.addListener(_onUnifiedDataServiceChanged);
    _loadInitialData(); // Load initial data including collection from UDS
  }

  void _onUnifiedDataServiceChanged() {
    // Update local collection if it has changed in UnifiedDataService
    if (!listEquals(_collection, _unifiedDataService.crystalCollection)) {
      _collection = List<UnifiedCrystalData>.from(_unifiedDataService.crystalCollection);
      // Potentially save to local cache if desired: await _saveToLocal();
      notifyListeners();
    }
  }

  void _loadInitialData() {
     _collection = List<UnifiedCrystalData>.from(_unifiedDataService.crystalCollection);
     // Usage logs are still loaded from local
  }
  
  /// Get the current collection
  List<UnifiedCrystalData> get collection => List.unmodifiable(_collection); // Changed type
  
  /// Get usage logs
  List<UsageLog> get usageLogs => List.unmodifiable(_usageLogs);
  
  /// Check if service is loaded
  bool get isLoaded => _isLoaded;
  
  /// Check if syncing with backend
  bool get isSyncing => _isSyncing;
  
  /// Get last error
  String? get lastError => _lastError;
  
  /// Initialize the collection service
  Future<void> initialize() async {
    if (_isLoaded) return;
    
    try {
      // Collection is already loaded from UnifiedDataService in constructor or via listener
      // Load usage logs locally
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_usageLogsKey);
      if (logsJson != null) {
        final List<dynamic> decoded = json.decode(logsJson);
        _usageLogs = decoded.map((e) => UsageLog.fromJson(e)).toList();
      }
      _isLoaded = true; // Mark as loaded for usage logs and initial setup
      notifyListeners(); // Notify for usage logs or initial state

    } catch (e) {
      _lastError = e.toString();
      debugPrint("Error initializing CollectionServiceV2: $e");
      notifyListeners();
    }
  }
  
  // /// Load collection from local storage - DEPRECATED for crystal collection
  // Future<void> _loadFromLocal() async { ... }
  
  /// Save usage logs to local storage (crystal collection not saved here directly)
  Future<void> _saveUsageLogsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = json.encode(_usageLogs.map((e) => e.toJson()).toList());
    await prefs.setString(_usageLogsKey, logsJson);
  }
  
  /// Add a crystal to the collection - delegates to UnifiedDataService
  /// This method's signature might need to change to accept UnifiedCrystalData directly,
  /// or it constructs UnifiedCrystalData from parameters.
  /// For now, assuming it receives a pre-constructed UnifiedCrystalData.
  Future<void> addCrystal(UnifiedCrystalData crystalData) async {
    try {
      await _unifiedDataService.addCrystal(crystalData);
      // _collection is updated via listener _onUnifiedDataServiceChanged
      // No need to call notifyListeners() here if listener handles it.
    } catch (e) {
      _lastError = "Failed to add crystal: $e";
      debugPrint(_lastError);
      notifyListeners(); // Notify about the error
      throw e; // Rethrow for UI to handle
    }
  }
  
  /// Update a crystal in the collection - delegates to UnifiedDataService
  Future<void> updateCrystal(UnifiedCrystalData crystalData) async {
     try {
      await _unifiedDataService.updateCrystal(crystalData);
      // _collection is updated via listener
    } catch (e) {
      _lastError = "Failed to update crystal: $e";
      debugPrint(_lastError);
      notifyListeners();
      throw e;
    }
  }
  
  /// Remove a crystal from the collection - delegates to UnifiedDataService
  Future<void> removeCrystal(String crystalId) async {
    try {
      await _unifiedDataService.removeCrystal(crystalId);
      // _collection is updated via listener
    } catch (e) {
      _lastError = "Failed to remove crystal: $e";
      debugPrint(_lastError);
      notifyListeners();
      throw e;
    }
  }
  
  /// Log crystal usage - (Manages _usageLogs locally)
  Future<void> logUsage(String entryId, {
    required String purpose,
    String? intention,
    String? result,
    int? moodBefore,
    int? moodAfter,
    int? energyBefore,
    int? energyAfter,
    String? moonPhase,
  }) async {
    final now = DateTime.now();
    final log = UsageLog(
      id: now.millisecondsSinceEpoch.toString(),
      timestamp: now,
      action: purpose,
      metadata: {
        'intention': intention,
        'result': result,
        'moodBefore': moodBefore,
        'moodAfter': moodAfter,
        'energyBefore': energyBefore,
        'energyAfter': energyAfter,
        'moonPhase': moonPhase,
      },
      collectionEntryId: entryId,
      dateTime: now,
      purpose: purpose,
      intention: intention,
      result: result,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      energyBefore: energyBefore,
      energyAfter: energyAfter,
      moonPhase: moonPhase,
    );
    
    _usageLogs.add(log);
    
    // Update usage count
    final index = _collection.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final entry = _collection[index];
      _collection[index] = entry.copyWith(
        usageCount: entry.usageCount + 1,
      );
    }
    
    await _saveUsageLogsToLocal();
    notifyListeners();
  }
  
  /// Get crystals by chakra
  List<UnifiedCrystalData> getCrystalsByChakra(String chakra) {
    return _collection.where((ucd) =>
      ucd.crystalCore.energyMapping.primaryChakra == chakra ||
      ucd.crystalCore.energyMapping.secondaryChakras.contains(chakra)
    ).toList();
  }
  
  /// Get crystals by purpose (matching healing_properties or usage_suggestions)
  List<UnifiedCrystalData> getCrystalsByPurpose(String purpose) {
    final lowerPurpose = purpose.toLowerCase();
    return _collection.where((ucd) {
      final inHealing = ucd.automaticEnrichment?.healingProperties
              .any((prop) => prop.toLowerCase().contains(lowerPurpose)) ?? false;
      final inSuggestions = ucd.automaticEnrichment?.usageSuggestions
              .any((sugg) => sugg.toLowerCase().contains(lowerPurpose)) ?? false;
      return inHealing || inSuggestions;
    }).toList();
  }
  
  /// Get crystals by element
  List<UnifiedCrystalData> getCrystalsByElement(String element) {
    final lowerElement = element.toLowerCase();
    return _collection.where((ucd) =>
      ucd.crystalCore.astrologicalData.element?.toLowerCase() == lowerElement
    ).toList();
  }
  
  /// Get favorite crystals - NOTE: UnifiedCrystalData doesn't have isFavorite directly.
  /// This would need to be part of UserIntegration or managed differently.
  /// For now, returning empty or assuming a way to filter if UserIntegration had it.
  List<UnifiedCrystalData> getFavorites() {
    // return _collection.where((ucd) => ucd.userIntegration?.isFavorite ?? false).toList();
    debugPrint("getFavorites: isFavorite not directly in UnifiedCrystalData.userIntegration. Returning empty.");
    return [];
  }
  
  /// Get recently used crystals - NOTE: This relies on usage logs.
  /// The logic for mapping usage logs to UnifiedCrystalData might need adjustment.
  List<UnifiedCrystalData> getRecentlyUsed({int limit = 5}) {
    // Map to store last used date for each crystal
    final lastUsedMap = <String, DateTime>{};
    
    // Find the most recent usage for each crystal
    for (final log in _usageLogs) {
      final currentDate = lastUsedMap[log.collectionEntryId];
      if (currentDate == null || log.dateTime.isAfter(currentDate)) {
        lastUsedMap[log.collectionEntryId] = log.dateTime;
      }
    }
    
    // Sort collection by last used date
    final entriesWithUsage = _collection
        .where((e) => lastUsedMap.containsKey(e.id))
        .toList()
      ..sort((a, b) => 
        lastUsedMap[b.id]!.compareTo(lastUsedMap[a.id]!));
    
    return entriesWithUsage.take(limit).toList();
  }
  
  /// Get last used date for a specific crystal
  DateTime? getLastUsedDate(String entryId) {
    final logs = _usageLogs.where((log) => log.collectionEntryId == entryId);
    if (logs.isEmpty) return null;
    
    return logs
        .map((log) => log.dateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
  
  /// Get collection statistics
  CollectionStats getStats() {
    return CollectionStats.fromCollection(_collection, _usageLogs);
  }
  
  /// Search crystals
  List<UnifiedCrystalData> searchCrystals(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _collection.where((entry) {
      return entry.crystalCore.identification.stoneType.toLowerCase().contains(lowercaseQuery) ||
             entry.crystalCore.identification.crystalFamily.toLowerCase().contains(lowercaseQuery) ||
             (entry.userIntegration?.userExperiences.any((exp) => exp.toLowerCase().contains(lowercaseQuery)) ?? false);
    }).toList();
  }
  
  /// Sync with backend
  // Future<void> syncWithBackend() async { ... } // DEPRECATED - Handled by UnifiedDataService via BackendService
  
  // /// Sync single entry to backend
  // Future<void> _syncEntryToBackend(CollectionEntry entry) async { ... } // DEPRECATED
  
  // /// Delete entry from backend
  // Future<void> _deleteFromBackend(String entryId) async { ... } // DEPRECATED
  
  /// Export collection data (now using UnifiedCrystalData)
  Map<String, dynamic> exportCollection() {
    return {
      'version': '2.0',
      'exported_at': DateTime.now().toIso8601String(),
      'collection': _collection.map((e) => e.toJson()).toList(),
      'usage_logs': _usageLogs.map((e) => e.toJson()).toList(),
      'stats': getStats().toAIContext(),
    };
  }
  
  /// Import collection data
  Future<void> importCollection(Map<String, dynamic> data) async {
    // This import function would need careful consideration if it's importing
    // into the new backend-driven system. It might involve calling
    // UnifiedDataService.addCrystal for each entry.
    // For now, keeping local import for usage logs if any.
    if (data['version'] != '2.0') { // Assuming UnifiedCrystalData export would use a new version or format
      throw Exception('Incompatible collection version for UnifiedCrystalData import.');
    }

    final List<dynamic> logsData = data['usage_logs'] ?? [];
    // _collection = collectionData.map((e) => UnifiedCrystalData.fromJson(e)).toList(); // This would bypass UDS
    _usageLogs = logsData.map((e) => UsageLog.fromJson(e)).toList();
    
    await _saveUsageLogsToLocal();
    notifyListeners();
    
    // Handle importing crystals through UnifiedDataService to ensure backend sync.
    final List<dynamic> collectionData = data['collection'] ?? [];
    if (collectionData.isNotEmpty) {
       debugPrint("Collection import: Importing ${collectionData.length} crystals via UnifiedDataService.");
       for (var crystalJson in collectionData) {
         try {
           await _unifiedDataService.addCrystal(UnifiedCrystalData.fromJson(crystalJson));
         } catch (e) {
           debugPrint("Error importing a crystal: $e");
         }
       }
    }
  }
  
  // /// Update an existing entry - DEPRECATED: Use updateCrystal(UnifiedCrystalData data)
  // Future<void> updateEntry(CollectionEntry entry) async { ... }

  /// Clear all data
  Future<void> clearAll() async {
    // Clear crystal collection via UnifiedDataService
    if (_collection.isNotEmpty) {
       debugPrint("CollectionServiceV2.clearAll: Clearing ${_collection.length} crystals via UnifiedDataService.");
       for (final crystal in List.from(_collection)) {
         try {
           await _unifiedDataService.removeCrystal(crystal.id);
         } catch (e) {
           debugPrint("Error removing crystal ${crystal.id}: $e");
         }
       }
    }
    
    // Clear usage logs locally
    _usageLogs.clear();
    await _saveUsageLogsToLocal();
    notifyListeners();
  }

  @override
  void dispose() {
    _unifiedDataService.removeListener(_onUnifiedDataServiceChanged);
    super.dispose();
  }
}