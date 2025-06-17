import 'package:flutter/material.dart';
// import 'crystal.dart'; // Old model, replaced by UnifiedCrystalData
import 'crystal_v2.dart' as v2; // May still be used by other parts or for conversion
import './unified_crystal_data.dart'; // New model

/// Represents a crystal in the user's collection
class CollectionEntry {
  final String id;
  final String userId;
  final UnifiedCrystalData crystalData; // Changed from 'crystal' to 'crystalData'
  final DateTime dateAdded;
  final String source; // Where/how acquired: "purchased", "gifted", "found", "inherited"
  final String? location; // Where acquired/found
  final double? price; // If purchased
  final String size; // "small", "medium", "large", "pocket", "specimen"
  final String quality; // "raw", "tumbled", "polished", "cluster", "point"
  final List<String> primaryUses; // "meditation", "healing", "protection", "manifestation"
  final int usageCount; // How many times used
  final double userRating; // 1-5 stars
  final String? notes; // Personal notes
  final List<String> images; // Multiple photos of their specific crystal
  final bool isActive; // Currently in use/displayed
  final bool isFavorite;
  final Map<String, dynamic> customProperties; // For future expansion

  CollectionEntry({
    required this.id,
    required this.userId,
    required this.crystalData, // Updated field name
    required this.dateAdded,
    required this.source,
    this.location,
    this.price,
    required this.size,
    required this.quality,
    required this.primaryUses,
    this.usageCount = 0,
    this.userRating = 0.0,
    this.notes,
    required this.images,
    this.isActive = true,
    this.isFavorite = false,
    Map<String, dynamic>? customProperties,
  }) : customProperties = customProperties ?? {};

  /// Create a new collection entry
  factory CollectionEntry.create({
    required String userId,
    required UnifiedCrystalData crystalData, // Updated type
    required String source,
    String? location,
    double? price,
    required String size,
    required String quality,
    List<String>? primaryUses,
    String? notes,
    List<String>? images,
  }) {
    return CollectionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      crystalData: crystalData, // Updated field
      dateAdded: DateTime.now(),
      source: source,
      location: location,
      price: price,
      size: size,
      quality: quality,
      primaryUses: primaryUses ?? [],
      images: images ?? [],
      notes: notes,
    );
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'crystalData': crystalData.toJson(), // Updated to use crystalData and its toJson
      'dateAdded': dateAdded.toIso8601String(),
      'source': source,
      'location': location,
      'price': price,
      'size': size,
      'quality': quality,
      'primaryUses': primaryUses,
      'usageCount': usageCount,
      'userRating': userRating,
      'notes': notes,
      'images': images,
      'isActive': isActive,
      'isFavorite': isFavorite,
      'customProperties': customProperties,
    };
  }

  /// Create from JSON
  factory CollectionEntry.fromJson(Map<String, dynamic> json) {
    return CollectionEntry(
      id: json['id'],
      userId: json['userId'],
      // Ensure null safety for fromJson, provide default empty map if null
      crystalData: UnifiedCrystalData.fromJson(json['crystalData'] as Map<String, dynamic>? ?? {}),
      dateAdded: DateTime.parse(json['dateAdded']),
      source: json['source'],
      location: json['location'],
      price: json['price']?.toDouble(),
      size: json['size'],
      quality: json['quality'],
      primaryUses: List<String>.from(json['primaryUses'] ?? []),
      usageCount: json['usageCount'] ?? 0,
      userRating: (json['userRating'] ?? 0.0).toDouble(),
      notes: json['notes'],
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      customProperties: json['customProperties'] ?? {},
    );
  }

  /// Update entry with new data
  CollectionEntry copyWith({
    int? usageCount,
    double? userRating,
    String? notes,
    List<String>? images,
    bool? isActive,
    bool? isFavorite,
    List<String>? primaryUses,
  }) {
    return CollectionEntry(
      id: id,
      userId: userId,
      crystalData: crystalData, // Keep current crystalData if not changing
      dateAdded: dateAdded,
      source: source,
      location: location,
      price: price,
      size: size,
      quality: quality,
      primaryUses: primaryUses ?? this.primaryUses,
      usageCount: usageCount ?? this.usageCount,
      userRating: userRating ?? this.userRating,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      customProperties: customProperties,
    );
  }

  /// Increment usage count
  CollectionEntry recordUsage() {
    return copyWith(usageCount: usageCount + 1);
  }
}

/// Crystal usage log entry (simplified journal)
class UsageLog {
  final String id;
  final String collectionEntryId;
  final DateTime dateTime;
  final String purpose; // "meditation", "healing", "protection", etc.
  final String? intention; // What user wanted to achieve
  final String? result; // Brief outcome note
  final int? moodBefore; // 1-10 scale
  final int? moodAfter; // 1-10 scale
  final int? energyBefore; // 1-10 scale
  final int? energyAfter; // 1-10 scale
  final String? moonPhase;
  
  UsageLog({
    required this.id,
    required this.collectionEntryId,
    required this.dateTime,
    required this.purpose,
    this.intention,
    this.result,
    this.moodBefore,
    this.moodAfter,
    this.energyBefore,
    this.energyAfter,
    this.moonPhase,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionEntryId': collectionEntryId,
      'dateTime': dateTime.toIso8601String(),
      'purpose': purpose,
      'intention': intention,
      'result': result,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'energyBefore': energyBefore,
      'energyAfter': energyAfter,
      'moonPhase': moonPhase,
    };
  }

  factory UsageLog.fromJson(Map<String, dynamic> json) {
    return UsageLog(
      id: json['id'],
      collectionEntryId: json['collectionEntryId'],
      dateTime: DateTime.parse(json['dateTime']),
      purpose: json['purpose'],
      intention: json['intention'],
      result: json['result'],
      moodBefore: json['moodBefore'],
      moodAfter: json['moodAfter'],
      energyBefore: json['energyBefore'],
      energyAfter: json['energyAfter'],
      moonPhase: json['moonPhase'],
    );
  }
}

/// Collection statistics for AI recommendations
class CollectionStats {
  final int totalCrystals;
  final Map<String, int> crystalsByType; // Type -> count
  final Map<String, int> crystalsByChakra; // Chakra -> count
  final Map<String, int> crystalsByPurpose; // Purpose -> count
  final List<String> mostUsedCrystals; // Top 5 by usage
  final List<String> favoriteCrystals; // User favorites
  // final Map<String, double> effectivenessRatings; // Crystal -> avg mood improvement - REMOVED for this task
  final DateTime lastUpdated;

  CollectionStats({
    required this.totalCrystals,
    required this.crystalsByType,
    required this.crystalsByChakra,
    required this.crystalsByPurpose,
    required this.mostUsedCrystals,
    required this.favoriteCrystals,
    // required this.effectivenessRatings, // REMOVED
    required this.lastUpdated,
  });

  /// Generate stats from collection
  factory CollectionStats.fromCollection(List<CollectionEntry> entries) { // Changed signature
    final crystalsByType = <String, int>{};
    final crystalsByChakra = <String, int>{};
    final crystalsByPurpose = <String, int>{};

    List<CollectionEntry> sortedByUsage = List.from(entries);
    sortedByUsage.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    final mostUsedCrystals = sortedByUsage
        .take(5)
        .map((e) => e.crystalData.name) // Assuming name is on crystalData or crystalData.crystalCore.identification.stoneType
        .toList();

    final favoriteCrystals = entries
        .where((e) => e.isFavorite)
        .take(5) // take top 5 or all if less than 5
        .map((e) => e.crystalData.name)
        .toList();

    // Analyze collection entries
    for (final entry in entries) {
      final ucd = entry.crystalData; // UnifiedCrystalData from CollectionEntry
      final core = ucd.crystalCore;
      final identification = core.identification;
      final energy = core.energyMapping;
      final enrichment = ucd.automaticEnrichment;

      // Count by type (using crystalFamily as "group/type")
      final type = identification.crystalFamily;
      if (type.isNotEmpty) {
        crystalsByType[type] = (crystalsByType[type] ?? 0) + 1;
      }

      // Count by chakra
      final List<String> entryChakras = [];
      if (energy.primaryChakra.isNotEmpty) {
        entryChakras.add(energy.primaryChakra.toLowerCase());
      }
      entryChakras.addAll(energy.secondaryChakras.map((c) => c.toLowerCase()));

      for (final chakra in entryChakras.toSet()) { // Use toSet() to count each chakra once per crystal
        if (chakra.isNotEmpty) {
          crystalsByChakra[chakra] = (crystalsByChakra[chakra] ?? 0) + 1;
        }
      }

      // Count by purpose (e.g., from healingProperties or usageSuggestions)
      final purposes = <String>{};
      enrichment?.healingProperties.forEach((p) => purposes.add(p.toLowerCase()));
      enrichment?.usageSuggestions.forEach((p) => purposes.add(p.toLowerCase()));
      // TODO: Consider if UserIntegration.intentionSettings should also contribute here
      for (final purpose in purposes) {
        crystalsByPurpose[purpose] = (crystalsByPurpose[purpose] ?? 0) + 1;
      }

      // Track usage - Not available on UnifiedCrystalData directly
      // if (identification.stoneType.isNotEmpty && userIntegration?.usageCount != null) {
      //   usageCount[identification.stoneType] = userIntegration!.usageCount!;
      // }

    }
    // Effectiveness ratings and direct UsageLog processing removed as per subtask.

    return CollectionStats(
      totalCrystals: entries.length,
      crystalsByType: crystalsByType,
      crystalsByChakra: crystalsByChakra,
      crystalsByPurpose: crystalsByPurpose,
      mostUsedCrystals: mostUsedCrystals,
      favoriteCrystals: favoriteCrystals,
      // effectivenessRatings: {}, // Removed
      lastUpdated: DateTime.now(),
    );
  }

  /// Convert to JSON for AI context
  Map<String, dynamic> toAIContext() {
    return {
      'totalCrystals': totalCrystals,
      'crystalTypes': crystalsByType,
      'chakraCoverage': crystalsByChakra,
      'primaryPurposes': crystalsByPurpose,
      'favorites': favoriteCrystals,
      'mostUsed': mostUsedCrystals, // Added mostUsedCrystals to context
      // 'mostEffective': effectivenessRatings.entries // Removed
      //     .where((e) => e.value > 0)
      //     .map((e) => '${e.key} (+${e.value.toStringAsFixed(1)} mood)')
      //     .toList(),
      'gaps': _identifyCollectionGaps(),
    };
  }

  /// Identify what's missing from collection
  List<String> _identifyCollectionGaps() {
    final gaps = <String>[];
    
    // Check chakra coverage
    const mainChakras = ['root', 'sacral', 'solar plexus', 'heart', 'throat', 'third eye', 'crown'];
    for (final chakra in mainChakras) {
      if (!crystalsByChakra.containsKey(chakra)) {
        gaps.add('No crystals for $chakra chakra');
      }
    }

    // Check essential purposes
    const essentialPurposes = ['protection', 'grounding', 'healing', 'meditation'];
    for (final purpose in essentialPurposes) {
      if (!crystalsByPurpose.containsKey(purpose)) {
        gaps.add('No crystals for $purpose');
      }
    }

    return gaps;
  }
}