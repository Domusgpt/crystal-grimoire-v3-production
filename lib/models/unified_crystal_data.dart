import 'package:flutter/foundation.dart';
import 'crystal.dart';

// Corresponds to Pydantic model: VisualAnalysis
class VisualAnalysis {
  final String primaryColor;
  final List<String> secondaryColors;
  final String transparency;
  final String formation;
  final String? sizeEstimate;

  VisualAnalysis({
    required this.primaryColor,
    required this.secondaryColors,
    required this.transparency,
    required this.formation,
    this.sizeEstimate,
  });

  factory VisualAnalysis.fromJson(Map<String, dynamic> json) {
    return VisualAnalysis(
      primaryColor: json['primary_color'] as String? ?? 'Unknown',
      secondaryColors: List<String>.from(json['secondary_colors'] as List? ?? []),
      transparency: json['transparency'] as String? ?? 'Unknown',
      formation: json['formation'] as String? ?? 'Unknown',
      sizeEstimate: json['size_estimate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor,
      'secondary_colors': secondaryColors,
      'transparency': transparency,
      'formation': formation,
      'size_estimate': sizeEstimate,
    };
  }

  // Compatibility getters
  List<String> get colors => [primaryColor, ...secondaryColors];
}

// Corresponds to Pydantic model: Identification
class Identification {
  final String stoneType;
  final String crystalFamily;
  final String? variety;
  final double confidence;

  Identification({
    required this.stoneType,
    required this.crystalFamily,
    this.variety,
    required this.confidence,
  });

  factory Identification.fromJson(Map<String, dynamic> json) {
    return Identification(
      stoneType: json['stone_type'] as String? ?? 'Unknown',
      crystalFamily: json['crystal_family'] as String? ?? 'Unknown',
      variety: json['variety'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stone_type': stoneType,
      'crystal_family': crystalFamily,
      'variety': variety,
      'confidence': confidence,
    };
  }
}

// Corresponds to Pydantic model: EnergyMapping
class EnergyMapping {
  final String primaryChakra;
  final List<String> secondaryChakras;
  final int chakraNumber;
  final String? vibrationLevel;

  EnergyMapping({
    required this.primaryChakra,
    required this.secondaryChakras,
    required this.chakraNumber,
    this.vibrationLevel,
  });

  factory EnergyMapping.fromJson(Map<String, dynamic> json) {
    return EnergyMapping(
      primaryChakra: json['primary_chakra'] as String? ?? 'Unknown',
      secondaryChakras: List<String>.from(json['secondary_chakras'] as List? ?? []),
      chakraNumber: json['chakra_number'] as int? ?? 0,
      vibrationLevel: json['vibration_level'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_chakra': primaryChakra,
      'secondary_chakras': secondaryChakras,
      'chakra_number': chakraNumber,
      'vibration_level': vibrationLevel,
    };
  }

  // Compatibility getters
  List<String> get primaryChakras => [primaryChakra];
  List<String> get chakras => [primaryChakra, ...secondaryChakras];
}

// Corresponds to Pydantic model: AstrologicalData
class AstrologicalData {
  final List<String> primarySigns;
  final List<String> compatibleSigns;
  final String? planetaryRuler;
  final String? element;

  AstrologicalData({
    required this.primarySigns,
    required this.compatibleSigns,
    this.planetaryRuler,
    this.element,
  });

  factory AstrologicalData.fromJson(Map<String, dynamic> json) {
    return AstrologicalData(
      primarySigns: List<String>.from(json['primary_signs'] as List? ?? []),
      compatibleSigns: List<String>.from(json['compatible_signs'] as List? ?? []),
      planetaryRuler: json['planetary_ruler'] as String?,
      element: json['element'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_signs': primarySigns,
      'compatible_signs': compatibleSigns,
      'planetary_ruler': planetaryRuler,
      'element': element,
    };
  }

  // Compatibility getters
  List<String> get elementalAlignment => element != null ? [element!] : [];
}

// Corresponds to Pydantic model: NumerologyData
class NumerologyData {
  final int crystalNumber;
  final int colorVibration;
  final int chakraNumber;
  final int masterNumber;

  NumerologyData({
    required this.crystalNumber,
    required this.colorVibration,
    required this.chakraNumber,
    required this.masterNumber,
  });

  factory NumerologyData.fromJson(Map<String, dynamic> json) {
    return NumerologyData(
      crystalNumber: json['crystal_number'] as int? ?? 0,
      colorVibration: json['color_vibration'] as int? ?? 0,
      chakraNumber: json['chakra_number'] as int? ?? 0,
      masterNumber: json['master_number'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crystal_number': crystalNumber,
      'color_vibration': colorVibration,
      'chakra_number': chakraNumber,
      'master_number': masterNumber,
    };
  }
}

// Corresponds to Pydantic model: CrystalCore
class CrystalCore {
  final String id;
  final String timestamp;
  final double confidenceScore;
  final VisualAnalysis visualAnalysis;
  final Identification identification;
  final EnergyMapping energyMapping;
  final AstrologicalData astrologicalData;
  final NumerologyData numerology;

  CrystalCore({
    required this.id,
    required this.timestamp,
    required this.confidenceScore,
    required this.visualAnalysis,
    required this.identification,
    required this.energyMapping,
    required this.astrologicalData,
    required this.numerology,
  });

  factory CrystalCore.fromJson(Map<String, dynamic> json) {
    return CrystalCore(
      id: json['id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      visualAnalysis: VisualAnalysis.fromJson(json['visual_analysis'] as Map<String, dynamic>? ?? {}),
      identification: Identification.fromJson(json['identification'] as Map<String, dynamic>? ?? {}),
      energyMapping: EnergyMapping.fromJson(json['energy_mapping'] as Map<String, dynamic>? ?? {}),
      astrologicalData: AstrologicalData.fromJson(json['astrological_data'] as Map<String, dynamic>? ?? {}),
      numerology: NumerologyData.fromJson(json['numerology'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'confidence_score': confidenceScore,
      'visual_analysis': visualAnalysis.toJson(),
      'identification': identification.toJson(),
      'energy_mapping': energyMapping.toJson(),
      'astrological_data': astrologicalData.toJson(),
      'numerology': numerology.toJson(),
    };
  }

  // Compatibility getters
  VisualAnalysis get physicalProperties => visualAnalysis;
}

// Corresponds to Pydantic model: UserIntegration
class UserIntegration {
  final String? userId;
  final String? addedToCollection;
  final int? personalRating;
  final String? usageFrequency;
  final List<String> userExperiences;
  final List<String> intentionSettings;

  UserIntegration({
    this.userId,
    this.addedToCollection,
    this.personalRating,
    this.usageFrequency,
    required this.userExperiences,
    required this.intentionSettings,
  });

  factory UserIntegration.fromJson(Map<String, dynamic> json) {
    return UserIntegration(
      userId: json['user_id'] as String?,
      addedToCollection: json['added_to_collection'] as String?,
      personalRating: json['personal_rating'] as int?,
      usageFrequency: json['usage_frequency'] as String?,
      userExperiences: List<String>.from(json['user_experiences'] as List? ?? []),
      intentionSettings: List<String>.from(json['intention_settings'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'added_to_collection': addedToCollection,
      'personal_rating': personalRating,
      'usage_frequency': usageFrequency,
      'user_experiences': userExperiences,
      'intention_settings': intentionSettings,
    };
  }

  // Compatibility getters
  String? get personalNotes => userExperiences.isNotEmpty ? userExperiences.join('\n') : null;

  UserIntegration copyWith({
    String? userId,
    String? addedToCollection,
    int? personalRating,
    String? usageFrequency,
    List<String>? userExperiences,
    List<String>? intentionSettings,
  }) {
    return UserIntegration(
      userId: userId ?? this.userId,
      addedToCollection: addedToCollection ?? this.addedToCollection,
      personalRating: personalRating ?? this.personalRating,
      usageFrequency: usageFrequency ?? this.usageFrequency,
      userExperiences: userExperiences ?? this.userExperiences,
      intentionSettings: intentionSettings ?? this.intentionSettings,
    );
  }
}

// Corresponds to Pydantic model: AutomaticEnrichment
class AutomaticEnrichment {
  final String? crystalBibleReference;
  final List<String> healingProperties;
  final List<String> usageSuggestions;
  final List<String> careInstructions;
  final List<String> synergyCrystals;
  final String? mineralClass;

  AutomaticEnrichment({
    this.crystalBibleReference,
    required this.healingProperties,
    required this.usageSuggestions,
    required this.careInstructions,
    required this.synergyCrystals,
    this.mineralClass,
  });

  factory AutomaticEnrichment.fromJson(Map<String, dynamic> json) {
    return AutomaticEnrichment(
      crystalBibleReference: json['crystal_bible_reference'] as String?,
      healingProperties: List<String>.from(json['healing_properties'] as List? ?? []),
      usageSuggestions: List<String>.from(json['usage_suggestions'] as List? ?? []),
      careInstructions: List<String>.from(json['care_instructions'] as List? ?? []),
      synergyCrystals: List<String>.from(json['synergy_crystals'] as List? ?? []),
      mineralClass: json['mineral_class'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crystal_bible_reference': crystalBibleReference,
      'healing_properties': healingProperties,
      'usage_suggestions': usageSuggestions,
      'care_instructions': careInstructions,
      'synergy_crystals': synergyCrystals,
      'mineral_class': mineralClass,
    };
  }
}

// Corresponds to Pydantic model: UnifiedCrystalData
class UnifiedCrystalData {
  final CrystalCore crystalCore;
  final UserIntegration? userIntegration;
  final AutomaticEnrichment? automaticEnrichment;

  UnifiedCrystalData({
    required this.crystalCore,
    this.userIntegration,
    this.automaticEnrichment,
  });

  factory UnifiedCrystalData.fromJson(Map<String, dynamic> json) {
    return UnifiedCrystalData(
      crystalCore: CrystalCore.fromJson(json['crystal_core'] as Map<String, dynamic>? ?? {}),
      userIntegration: json['user_integration'] != null
          ? UserIntegration.fromJson(json['user_integration'] as Map<String, dynamic>)
          : null,
      automaticEnrichment: json['automatic_enrichment'] != null
          ? AutomaticEnrichment.fromJson(json['automatic_enrichment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'crystal_core': crystalCore.toJson(),
    };
    if (userIntegration != null) {
      map['user_integration'] = userIntegration!.toJson();
    }
    if (automaticEnrichment != null) {
      map['automatic_enrichment'] = automaticEnrichment!.toJson();
    }
    return map;
  }

  UnifiedCrystalData copyWith({
    CrystalCore? crystalCore,
    UserIntegration? userIntegration,
    AutomaticEnrichment? automaticEnrichment,
  }) {
    return UnifiedCrystalData(
      crystalCore: crystalCore ?? this.crystalCore,
      userIntegration: userIntegration ?? this.userIntegration,
      automaticEnrichment: automaticEnrichment ?? this.automaticEnrichment,
    );
  }

  // Convenience getters for backward compatibility
  String get id => crystalCore.id;
  String get name => crystalCore.identification.stoneType;
  EnergyMapping get metaphysicalProperties => crystalCore.energyMapping;
  double get confidence => crystalCore.confidenceScore;
  int get usageCount => userIntegration?.personalRating ?? 0;
  List<String> get intentions => userIntegration?.intentionSettings ?? [];
  
  // Legacy Crystal-like properties for compatibility
  List<String> get chakras => crystalCore.energyMapping.primaryChakras;
  List<String> get healingProperties => automaticEnrichment?.healingProperties ?? [];
  String get description => automaticEnrichment?.crystalBibleReference ?? '';
  
  // Additional compatibility getters
  String get crystalId => crystalCore.id;
  bool get isFavorite => userIntegration?.personalRating != null && userIntegration!.personalRating! >= 4;
  DateTime get dateAdded => DateTime.tryParse(crystalCore.timestamp) ?? DateTime.now();
  List<String> get primaryUses => automaticEnrichment?.usageSuggestions ?? [];
  
  // Create a legacy Crystal object for backward compatibility
  Crystal get crystal => Crystal(
    id: crystalCore.id,
    name: crystalCore.identification.stoneType,
    scientificName: crystalCore.identification.variety ?? '',
    group: crystalCore.identification.crystalFamily,
    description: automaticEnrichment?.crystalBibleReference ?? '',
    chakras: crystalCore.energyMapping.primaryChakras,
    elements: crystalCore.astrologicalData.elementalAlignment,
    properties: {
      'healing': automaticEnrichment?.healingProperties ?? [],
      'usage': automaticEnrichment?.usageSuggestions ?? [],
      'care': automaticEnrichment?.careInstructions ?? [],
    },
    careInstructions: (automaticEnrichment?.careInstructions ?? []).join(', '),
  );
}
