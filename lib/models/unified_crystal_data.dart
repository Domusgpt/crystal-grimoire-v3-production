
// Core model classes required for unified data architecture
class MetaphysicalProperties {
  final List<String> primaryChakras;
  final List<String> secondaryChakras;
  final List<String> intentions;
  final List<String> planetaryRulers;
  final List<String> zodiacSigns;
  final List<String> elements;
  final List<String> healingProperties;

  MetaphysicalProperties({
    required this.primaryChakras,
    required this.secondaryChakras,
    required this.intentions,
    required this.planetaryRulers,
    required this.zodiacSigns,
    required this.elements,
    required this.healingProperties,
  });

  factory MetaphysicalProperties.fromJson(Map<String, dynamic> json) {
    return MetaphysicalProperties(
      primaryChakras: List<String>.from(json['primary_chakras'] ?? []),
      secondaryChakras: List<String>.from(json['secondary_chakras'] ?? []),
      intentions: List<String>.from(json['intentions'] ?? []),
      planetaryRulers: List<String>.from(json['planetary_rulers'] ?? []),
      zodiacSigns: List<String>.from(json['zodiac_signs'] ?? []),
      elements: List<String>.from(json['elements'] ?? []),
      healingProperties: List<String>.from(json['healing_properties'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_chakras': primaryChakras,
      'secondary_chakras': secondaryChakras,
      'intentions': intentions,
      'planetary_rulers': planetaryRulers,
      'zodiac_signs': zodiacSigns,
      'elements': elements,
      'healing_properties': healingProperties,
    };
  }
}

class PhysicalProperties {
  final String? hardness;
  final String? crystalSystem;
  final String? luster;
  final double? density;
  final String? chemicalFormula;
  final String? fracture;
  final String? streak;
  final String? habit;

  PhysicalProperties({
    this.hardness,
    this.crystalSystem,
    this.luster,
    this.density,
    this.chemicalFormula,
    this.fracture,
    this.streak,
    this.habit,
  });

  factory PhysicalProperties.fromJson(Map<String, dynamic> json) {
    return PhysicalProperties(
      hardness: json['hardness'] as String?,
      crystalSystem: json['crystal_system'] as String?,
      luster: json['luster'] as String?,
      density: (json['density'] as num?)?.toDouble(),
      chemicalFormula: json['chemical_formula'] as String?,
      fracture: json['fracture'] as String?,
      streak: json['streak'] as String?,
      habit: json['habit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hardness': hardness,
      'crystal_system': crystalSystem,
      'luster': luster,
      'density': density,
      'chemical_formula': chemicalFormula,
      'fracture': fracture,
      'streak': streak,
      'habit': habit,
    };
  }
}

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
  // Additional properties for compatibility
  final List<String> primaryChakras;
  final List<String> intentions;

  EnergyMapping({
    required this.primaryChakra,
    required this.secondaryChakras,
    required this.chakraNumber,
    this.vibrationLevel,
    List<String>? primaryChakras,
    List<String>? intentions,
  }) : primaryChakras = primaryChakras ?? [primaryChakra],
       intentions = intentions ?? [];

  factory EnergyMapping.fromJson(Map<String, dynamic> json) {
    return EnergyMapping(
      primaryChakra: json['primary_chakra'] as String? ?? 'Unknown',
      secondaryChakras: List<String>.from(json['secondary_chakras'] as List? ?? []),
      chakraNumber: json['chakra_number'] as int? ?? 0,
      vibrationLevel: json['vibration_level'] as String?,
      primaryChakras: List<String>.from(json['primary_chakras'] as List? ?? [json['primary_chakra'] ?? 'Unknown']),
      intentions: List<String>.from(json['intentions'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_chakra': primaryChakra,
      'secondary_chakras': secondaryChakras,
      'chakra_number': chakraNumber,
      'vibration_level': vibrationLevel,
      'primary_chakras': primaryChakras,
      'intentions': intentions,
    };
  }
}

// Corresponds to Pydantic model: AstrologicalData
class AstrologicalData {
  final List<String> primarySigns;
  final List<String> compatibleSigns;
  final String? planetaryRuler;
  final String? element;
  // Additional properties for compatibility
  final List<String> planetaryRulers;
  final List<String> elements;

  AstrologicalData({
    required this.primarySigns,
    required this.compatibleSigns,
    this.planetaryRuler,
    this.element,
    List<String>? planetaryRulers,
    List<String>? elements,
  }) : planetaryRulers = planetaryRulers ?? (planetaryRuler != null ? [planetaryRuler] : []),
       elements = elements ?? (element != null ? [element] : []);

  factory AstrologicalData.fromJson(Map<String, dynamic> json) {
    return AstrologicalData(
      primarySigns: List<String>.from(json['primary_signs'] as List? ?? []),
      compatibleSigns: List<String>.from(json['compatible_signs'] as List? ?? []),
      planetaryRuler: json['planetary_ruler'] as String?,
      element: json['element'] as String?,
      planetaryRulers: List<String>.from(json['planetary_rulers'] as List? ?? (json['planetary_ruler'] != null ? [json['planetary_ruler']] : [])),
      elements: List<String>.from(json['elements'] as List? ?? (json['element'] != null ? [json['element']] : [])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_signs': primarySigns,
      'compatible_signs': compatibleSigns,
      'planetary_ruler': planetaryRuler,
      'element': element,
      'planetary_rulers': planetaryRulers,
      'elements': elements,
    };
  }
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
  final PhysicalProperties? physicalProperties;
  final MetaphysicalProperties? metaphysicalProperties;

  CrystalCore({
    required this.id,
    required this.timestamp,
    required this.confidenceScore,
    required this.visualAnalysis,
    required this.identification,
    required this.energyMapping,
    required this.astrologicalData,
    required this.numerology,
    this.physicalProperties,
    this.metaphysicalProperties,
  });

  // Dynamic getter for metaphysical properties
  MetaphysicalProperties get dynamicMetaphysicalProperties {
    return metaphysicalProperties ?? MetaphysicalProperties(
      primaryChakras: energyMapping.primaryChakras,
      secondaryChakras: energyMapping.secondaryChakras,
      intentions: energyMapping.intentions,
      planetaryRulers: astrologicalData.planetaryRulers,
      zodiacSigns: astrologicalData.compatibleSigns,
      elements: astrologicalData.elements,
      healingProperties: energyMapping.intentions,
    );
  }

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
      physicalProperties: json['physical_properties'] != null
          ? PhysicalProperties.fromJson(json['physical_properties'] as Map<String, dynamic>)
          : null,
      metaphysicalProperties: json['metaphysical_properties'] != null
          ? MetaphysicalProperties.fromJson(json['metaphysical_properties'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'timestamp': timestamp,
      'confidence_score': confidenceScore,
      'visual_analysis': visualAnalysis.toJson(),
      'identification': identification.toJson(),
      'energy_mapping': energyMapping.toJson(),
      'astrological_data': astrologicalData.toJson(),
      'numerology': numerology.toJson(),
    };
    if (physicalProperties != null) {
      json['physical_properties'] = physicalProperties!.toJson();
    }
    if (metaphysicalProperties != null) {
      json['metaphysical_properties'] = metaphysicalProperties!.toJson();
    }
    return json;
  }
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
  
  // Convenience getters for common operations
  String get id => crystalCore.id;
  int get usageCount => userIntegration?.personalRating ?? 0;

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
    int? usageCount,
  }) {
    UserIntegration? updatedUserIntegration = userIntegration ?? this.userIntegration;
    if (usageCount != null && updatedUserIntegration != null) {
      updatedUserIntegration = updatedUserIntegration.copyWith(
        personalRating: usageCount,
      );
    }
    
    return UnifiedCrystalData(
      crystalCore: crystalCore ?? this.crystalCore,
      userIntegration: updatedUserIntegration,
      automaticEnrichment: automaticEnrichment ?? this.automaticEnrichment,
    );
  }
}
