import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../models/crystal_collection.dart'; // Replaced by UnifiedCrystalData
import '../models/crystal.dart'; // May still be used if methods construct UnifiedCrystalData from it
import '../models/unified_crystal_data.dart';
import '../models/collection_models.dart';
import '../models/journal_entry.dart'; // Added import for JournalEntry
import 'backend_service.dart'; // May not be directly used if all calls go via UnifiedDataService
import 'firebase_service.dart'; // May still be used for non-crystal things or auth status
import 'unified_data_service.dart';

/// Production-ready Collection Service with proper instance management
/// This service should now primarily interact with UnifiedDataService for crystal data.
class CollectionServiceV2 extends ChangeNotifier {
  static const String _collectionKey = 'crystal_collection_v2'; // Potentially for caching if desired
  static const String _usageLogsKey = 'crystal_usage_logs_v2';
  
  final UnifiedDataService _unifiedDataService; // Primary source for crystal data
  final BackendService _backendService; // Added for journal operations
  final FirebaseService? _firebaseService; // For other operations or auth status
  
  List<UnifiedCrystalData> _collection = []; // Changed type
  List<UsageLog> _usageLogs = [];
  bool _isLoaded = false;
  bool _isSyncing = false; // Syncing concept might change
  String? _lastError;
  
  CollectionServiceV2({
    required UnifiedDataService unifiedDataService,
    required BackendService backendService, // Added
    FirebaseService? firebaseService, // Keep if needed for other things
  }) : _unifiedDataService = unifiedDataService,
       _backendService = backendService, // Added
       _firebaseService = firebaseService {
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
    final log = UsageLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      collectionEntryId: entryId,
      dateTime: DateTime.now(),
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
    
    // Update usage count on CollectionEntry
    // This part assumes CollectionEntry itself still tracks usageCount, which it does.
    // The UnifiedCrystalData does not have usageCount.
    // If the intention was to update usageCount on a UnifiedCrystalData instance,
    // that would require adding usageCount to UserIntegration or similar.
    // For now, this local _collection holds UnifiedCrystalData, which doesn't have a direct usageCount.
    // The `CollectionEntry` model (if that's what _collection was supposed to be) does.
    // Given _collection is List<UnifiedCrystalData>, this `copyWith` does not exist.

    // TODO: Revisit usage count management. UnifiedCrystalData does not have a usageCount.
    // If usage count needs to be tracked per crystal, it should be part of UserIntegration
    // or managed in a separate data structure that links UnifiedCrystalData.id to its usage.
    // For now, removing the direct update attempt on _collection which is List<UnifiedCrystalData>.
    // The UsageLog itself records an instance of usage.
    
    // final index = _collection.indexWhere((e) => e.crystalCore.id == entryId); // Assuming entryId is UCD.id
    // if (index != -1) {
    //   // This logic is flawed as UnifiedCrystalData has no copyWith for usageCount.
    //   // final entry = _collection[index];
    //   // _collection[index] = entry.copyWith(usageCount: entry.usageCount + 1);
    // }

    await _saveUsageLogsToLocal(); // Save usage logs
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
    // TODO: Add 'isFavorite' to UserIntegration in UnifiedCrystalData model if this feature is needed.
    // For now, returning an empty list as UnifiedCrystalData.userIntegration does not have isFavorite.
    debugPrint("getFavorites: 'isFavorite' field not available in UnifiedCrystalData.userIntegration. Returning empty list.");
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
    // Pass the UCD list to fromCollection, which now expects List<UnifiedCrystalData>
    return CollectionStats.fromCollection(_collection, _usageLogs);
  }
  
  /// Search crystals
  List<UnifiedCrystalData> searchCrystals(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _collection.where((ucd) {
      final core = ucd.crystalCore;
      final enrichment = ucd.automaticEnrichment;
      final userIntegration = ucd.userIntegration;

      bool nameMatch = core.identification.stoneType.toLowerCase().contains(lowercaseQuery);
      bool familyMatch = core.identification.crystalFamily.toLowerCase().contains(lowercaseQuery);

      List<String> searchableEnrichment = [];
      if (enrichment?.healingProperties != null) {
        searchableEnrichment.addAll(enrichment!.healingProperties);
      }
      if (enrichment?.usageSuggestions != null) {
        searchableEnrichment.addAll(enrichment!.usageSuggestions);
      }
      bool enrichmentMatch = searchableEnrichment.any((prop) => prop.toLowerCase().contains(lowercaseQuery));

      // Assuming personalNotes is a field in UserIntegration
      bool notesMatch = userIntegration?.personalNotes?.toLowerCase().contains(lowercaseQuery) ?? false;
      // If searching userExperiences instead/additionally:
      // bool experiencesMatch = userIntegration?.userExperiences.any((exp) => exp.toLowerCase().contains(lowercaseQuery)) ?? false;

      return nameMatch || familyMatch || enrichmentMatch || notesMatch;
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
    
    // await _saveToLocal(); // Only save usage logs
    await _saveUsageLogsToLocal();
    notifyListeners();
    
    // TODO: Handle importing crystals through UnifiedDataService to ensure backend sync.
    final List<dynamic> collectionData = data['collection'] ?? [];
    if (collectionData.isNotEmpty) {
       debugPrint("Collection import: Crystal data needs to be imported via UnifiedDataService.addCrystal loop.");
       // for (var crystalJson in collectionData) {
       //   try {
       //     await _unifiedDataService.addCrystal(UnifiedCrystalData.fromJson(crystalJson));
       //   } catch (e) {
       //     debugPrint("Error importing a crystal: $e");
       //   }
       // }
    }
  }
  
  // /// Update an existing entry - DEPRECATED: Use updateCrystal(UnifiedCrystalData data)
  // Future<void> updateEntry(CollectionEntry entry) async { ... }

  /// Clear all data
  Future<void> clearAll() async {
    // _collection.clear(); // Managed by UnifiedDataService, which should handle its own clearing
    // To clear via UDS, one might loop and call removeCrystal, or UDS provides a clearAllCrystals method.
    // For now, this service will clear its own state that it directly controls (usage logs).
    if (_collection.isNotEmpty) {
       debugPrint("CollectionServiceV2.clearAll: To clear crystal collection, call methods on UnifiedDataService.");
       // This ensures backend is also cleared.
       // For safety, this method will NOT iterate and delete via UDS unless explicitly designed to.
       // It will clear its local copy, which will be repopulated from UDS on next listen.
       _collection = [];
    }
    _usageLogs.clear();
    // await _saveToLocal(); // Only save usage logs
    await _saveUsageLogsToLocal();
    notifyListeners();
  }

  @override
  void dispose() {
    _unifiedDataService.removeListener(_onUnifiedDataServiceChanged);
    super.dispose();
  }

  // Journal Entry Stubs
  Future<List<JournalEntry>> loadJournalEntries() async {
    try {
      final List<dynamic> responseData = await _backendService.getJournalEntries();
      return responseData.map((data) => JournalEntry.fromJson(data as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Error loading journal entries in CollectionServiceV2: $e");
      // Optionally set _lastError and notifyListeners if this service manages global error state
      // For now, rethrow to let UI handle specific errors.
      throw Exception('Failed to load journal entries: $e');
    }
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    try {
      // Assuming backend returns the saved entry, possibly with a server-generated ID or timestamps
      // If backend returns the created entry, we could do:
      // final Map<String, dynamic> responseData = await _backendService.saveJournalEntry(entry.toJson());
      // return JournalEntry.fromJson(responseData); // If method signature was Future<JournalEntry>
      await _backendService.saveJournalEntry(entry.toJson());
      // No return needed for Future<void>
    } catch (e) {
      debugPrint("Error saving journal entry in CollectionServiceV2: $e");
      throw Exception('Failed to save journal entry: $e');
    }
  }

  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _backendService.deleteJournalEntry(entryId);
    } catch (e) {
      debugPrint("Error deleting journal entry in CollectionServiceV2: $e");
      throw Exception('Failed to delete journal entry: $e');
    }
  }

  Future<JournalEntry> updateJournalEntry(JournalEntry entry) async {
    try {
      final Map<String, dynamic> responseData = await _backendService.updateJournalEntry(entry.id, entry.toJson());
      return JournalEntry.fromJson(responseData);
    } catch (e) {
      debugPrint("Error updating journal entry in CollectionServiceV2: $e");
      throw Exception('Failed to update journal entry: $e');
    }
  }

  Future<List<CollectionEntry>> loadUserOwnedCrystals() async {
    await Future.delayed(const Duration(milliseconds: 50));
    debugPrint("loadUserOwnedCrystals called (stub) - returning sample CollectionEntry list");
    // This uses the CollectionEntry model from lib/models/collection_models.dart
    return [
      CollectionEntry(
        id: 'owned_amethyst_001', // This is CollectionEntry's own ID in the user's collection
        crystalId: 'amethyst_crystal_type_id', // This refers to the general crystal type ID
        name: 'Amethyst (Stub)',
        addedDate: DateTime.now().subtract(const Duration(days: 10)),
        properties: {'color': 'Purple', 'source': 'Stubland', 'size': 'Medium'}
      ),
      CollectionEntry(
        id: 'owned_citrine_002',
        crystalId: 'citrine_crystal_type_id',
        name: 'Citrine (Stub)',
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
        properties: {'color': 'Yellow', 'source': 'Stubville', 'size': 'Small'}
      ),
      CollectionEntry(
        id: 'owned_rosequartz_003',
        crystalId: 'rosequartz_crystal_type_id',
        name: 'Rose Quartz (Stub)',
        addedDate: DateTime.now().subtract(const Duration(days: 20)),
        properties: {'color': 'Pink', 'source': 'Stubtopia', 'size': 'Large'}
      ),
       CollectionEntry(
        id: 'owned_clearquartz_004',
        crystalId: 'clearquartz_crystal_type_id',
        name: 'Clear Quartz (Stub)',
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
        properties: {'color': 'Clear', 'source': 'Stublantis', 'size': 'Medium'}
      ),
    ];
  }
}