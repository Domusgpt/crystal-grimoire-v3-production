// Collection-related models for compatibility

class UsageLog {
  final String id;
  final DateTime timestamp;
  final String action;
  final Map<String, dynamic> metadata;
  final String? collectionEntryId;
  final DateTime? dateTime;

  UsageLog({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.metadata,
    this.collectionEntryId,
    this.dateTime,
  });

  factory UsageLog.fromJson(Map<String, dynamic> json) {
    return UsageLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: json['action'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      collectionEntryId: json['collectionEntryId'] as String?,
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'metadata': metadata,
      'collectionEntryId': collectionEntryId,
      'dateTime': dateTime?.toIso8601String(),
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
}

class CollectionEntry {
  final String id;
  final String crystalId;
  final String name;
  final DateTime addedDate;
  final Map<String, dynamic> properties;

  CollectionEntry({
    required this.id,
    required this.crystalId,
    required this.name,
    required this.addedDate,
    required this.properties,
  });

  factory CollectionEntry.fromJson(Map<String, dynamic> json) {
    return CollectionEntry(
      id: json['id'] as String,
      crystalId: json['crystalId'] as String,
      name: json['name'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String),
      properties: json['properties'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crystalId': crystalId,
      'name': name,
      'addedDate': addedDate.toIso8601String(),
      'properties': properties,
    };
  }
}