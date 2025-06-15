// Collection-related models for compatibility

class UsageLog {
  final String id;
  final DateTime timestamp;
  final String action;
  final Map<String, dynamic> metadata;
  // Additional properties for crystal usage tracking
  final String collectionEntryId;
  final DateTime dateTime;
  final String purpose;
  final String? intention;
  final String? result;
  final int? moodBefore;
  final int? moodAfter;
  final int? energyBefore;
  final int? energyAfter;
  final String? moonPhase;

  UsageLog({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.metadata,
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

  factory UsageLog.fromJson(Map<String, dynamic> json) {
    return UsageLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: json['action'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      collectionEntryId: json['collectionEntryId'] as String? ?? json['collection_entry_id'] as String? ?? '',
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime'] as String) : DateTime.parse(json['timestamp'] as String),
      purpose: json['purpose'] as String? ?? json['action'] as String? ?? 'general',
      intention: json['intention'] as String?,
      result: json['result'] as String?,
      moodBefore: json['moodBefore'] as int? ?? json['mood_before'] as int?,
      moodAfter: json['moodAfter'] as int? ?? json['mood_after'] as int?,
      energyBefore: json['energyBefore'] as int? ?? json['energy_before'] as int?,
      energyAfter: json['energyAfter'] as int? ?? json['energy_after'] as int?,
      moonPhase: json['moonPhase'] as String? ?? json['moon_phase'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'metadata': metadata,
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
}

class CollectionStats {
  final int totalCrystals;
  final int totalUsage;
  final Map<String, int> chakraCount;
  final Map<String, int> colorCount;

  CollectionStats({
    required this.totalCrystals,
    required this.totalUsage,
    required this.chakraCount,
    required this.colorCount,
  });
  
  // Factory constructor for creating stats from collection and usage logs
  factory CollectionStats.fromCollection(List<dynamic> collection, List<UsageLog> usageLogs) {
    final chakraCount = <String, int>{};
    final colorCount = <String, int>{};
    
    // Process collection items (assuming they have chakra and color data)
    for (final item in collection) {
      // This is a simplified implementation - adjust based on actual data structure
      if (item is Map<String, dynamic>) {
        final chakras = item['chakras'] as List<String>? ?? [];
        final colors = item['colors'] as List<String>? ?? [];
        
        for (final chakra in chakras) {
          chakraCount[chakra] = (chakraCount[chakra] ?? 0) + 1;
        }
        
        for (final color in colors) {
          colorCount[color] = (colorCount[color] ?? 0) + 1;
        }
      }
    }
    
    return CollectionStats(
      totalCrystals: collection.length,
      totalUsage: usageLogs.length,
      chakraCount: chakraCount,
      colorCount: colorCount,
    );
  }

  factory CollectionStats.fromJson(Map<String, dynamic> json) {
    return CollectionStats(
      totalCrystals: json['totalCrystals'] as int,
      totalUsage: json['totalUsage'] as int,
      chakraCount: Map<String, int>.from(json['chakraCount'] as Map),
      colorCount: Map<String, int>.from(json['colorCount'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCrystals': totalCrystals,
      'totalUsage': totalUsage,
      'chakraCount': chakraCount,
      'colorCount': colorCount,
    };
  }
  
  // Convert to AI-friendly context format
  Map<String, dynamic> toAIContext() {
    return {
      'collection_size': totalCrystals,
      'total_usage': totalUsage,
      'chakra_distribution': chakraCount,
      'color_distribution': colorCount,
      'most_used_chakra': chakraCount.entries.isEmpty ? 'none' : 
          chakraCount.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      'most_common_color': colorCount.entries.isEmpty ? 'none' : 
          colorCount.entries.reduce((a, b) => a.value > b.value ? a : b).key,
    };
  }
}

class CollectionEntry {
  final String id;
  final String crystalId;
  final String name;
  final DateTime addedDate;
  final Map<String, dynamic> properties;
  // Additional properties for compatibility
  final dynamic crystal; // Can be Crystal or UnifiedCrystalData
  final String? notes;
  final int usageCount;

  CollectionEntry({
    required this.id,
    required this.crystalId,
    required this.name,
    required this.addedDate,
    required this.properties,
    this.crystal,
    this.notes,
    this.usageCount = 0,
  });

  factory CollectionEntry.fromJson(Map<String, dynamic> json) {
    return CollectionEntry(
      id: json['id'] as String,
      crystalId: json['crystalId'] as String,
      name: json['name'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String),
      properties: json['properties'] as Map<String, dynamic>,
      crystal: json['crystal'], // Will be processed separately based on type
      notes: json['notes'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'crystalId': crystalId,
      'name': name,
      'addedDate': addedDate.toIso8601String(),
      'properties': properties,
      'usageCount': usageCount,
    };
    if (notes != null) {
      json['notes'] = notes!;
    }
    if (crystal != null) {
      json['crystal'] = crystal is Map ? crystal : (crystal as dynamic).toJson();
    }
    return json;
  }
  
  CollectionEntry copyWith({
    String? id,
    String? crystalId,
    String? name,
    DateTime? addedDate,
    Map<String, dynamic>? properties,
    dynamic crystal,
    String? notes,
    int? usageCount,
  }) {
    return CollectionEntry(
      id: id ?? this.id,
      crystalId: crystalId ?? this.crystalId,
      name: name ?? this.name,
      addedDate: addedDate ?? this.addedDate,
      properties: properties ?? this.properties,
      crystal: crystal ?? this.crystal,
      notes: notes ?? this.notes,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}

// Extension methods for crystal collection operations
extension CollectionEntryExtensions on CollectionEntry {
  bool get isFavorite => properties['favorite'] == true;
  
  DateTime? get lastUsed => properties['lastUsed'] != null 
      ? DateTime.tryParse(properties['lastUsed'] as String)
      : null;
      
  List<String> get tags => List<String>.from(properties['tags'] ?? []);
  
  String get category => properties['category'] as String? ?? 'Unknown';
}