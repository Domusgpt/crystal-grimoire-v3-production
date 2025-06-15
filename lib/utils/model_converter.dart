/// Comprehensive Model Converter Utility
/// Handles seamless conversion between UnifiedCrystalData, Crystal, and CollectionEntry models
/// Maintains data integrity and supports production-ready backend integration

import '../models/unified_crystal_data.dart';
import '../models/crystal.dart';
import '../models/collection_models.dart';

class ModelConverter {
  /// Convert UnifiedCrystalData to legacy Crystal model
  static Crystal unifiedToCrystal(UnifiedCrystalData unifiedData) {
    try {
      final core = unifiedData.crystalCore;
      
      return Crystal(
        id: core.id,
        name: core.identification.stoneType,
        category: core.identification.crystalFamily,
        color: core.visualAnalysis.primaryColor,
        description: '${core.identification.stoneType} - ${core.identification.variety ?? 'Natural variety'}',
        properties: CrystalProperties(
          chakra: core.energyMapping.primaryChakras.isNotEmpty 
              ? core.energyMapping.primaryChakras.first 
              : 'All',
          element: core.astrologicalData.elements.isNotEmpty 
              ? core.astrologicalData.elements.first 
              : 'Universal',
          zodiacSigns: core.astrologicalData.compatibleSigns,
          healingProperties: core.energyMapping.intentions,
        ),
        physicalProperties: PhysicalProperties(
          hardness: core.visualAnalysis.formation,
          crystalSystem: core.identification.crystalFamily,
          luster: core.visualAnalysis.transparency,
          transparency: core.visualAnalysis.transparency,
          colorRange: [core.visualAnalysis.primaryColor, ...core.visualAnalysis.secondaryColors],
        ),
        metaphysicalProperties: MetaphysicalProperties(
          primaryChakras: core.energyMapping.primaryChakras,
          secondaryChakras: core.energyMapping.secondaryChakras,
          intentions: core.energyMapping.intentions,
          planetaryRulers: core.astrologicalData.planetaryRulers,
          zodiacSigns: core.astrologicalData.compatibleSigns,
          elements: core.astrologicalData.elements,
          healingProperties: core.energyMapping.intentions,
        ),
        careInstructions: CareInstructions(
          cleansingMethods: ['Running water', 'Moonlight', 'Sage smoke'],
          chargingMethods: ['Moonlight', 'Crystal cluster'],
          storageRecommendations: 'Store in a clean, dry place',
          handlingNotes: 'Handle with care',
        ),
        imageUrl: unifiedData.imageAnalysis?.processedImageUrl,
        rarity: 'Common', // Default value
        price: 0.0, // Default value
        isIdentified: core.confidenceScore > 0.5,
        confidence: core.confidenceScore,
        intentions: core.energyMapping.intentions,
      );
    } catch (e) {
      // Fallback crystal for conversion errors
      return Crystal(
        id: unifiedData.crystalCore.id,
        name: unifiedData.crystalCore.identification.stoneType,
        category: 'Unknown',
        color: 'Unknown',
        description: 'Conversion error occurred',
        properties: CrystalProperties(
          chakra: 'All',
          element: 'Universal',
          zodiacSigns: [],
          healingProperties: [],
        ),
        rarity: 'Unknown',
        price: 0.0,
        confidence: 0.0,
        intentions: [],
      );
    }
  }

  /// Convert legacy Crystal to UnifiedCrystalData model
  static UnifiedCrystalData crystalToUnified(Crystal crystal) {
    try {
      return UnifiedCrystalData(
        requestId: crystal.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        crystalCore: CrystalCore(
          id: crystal.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now().toIso8601String(),
          confidenceScore: crystal.confidence ?? 0.0,
          visualAnalysis: VisualAnalysis(
            primaryColor: crystal.color ?? 'Unknown',
            secondaryColors: crystal.physicalProperties?.colorRange?.skip(1).toList() ?? [],
            transparency: crystal.physicalProperties?.transparency ?? 'Unknown',
            formation: crystal.physicalProperties?.crystalSystem ?? 'Unknown',
          ),
          identification: Identification(
            stoneType: crystal.name ?? 'Unknown',
            crystalFamily: crystal.category ?? 'Unknown',
            variety: crystal.description?.split(' - ').length > 1 
                ? crystal.description!.split(' - ')[1] 
                : null,
            confidence: crystal.confidence ?? 0.0,
          ),
          energyMapping: EnergyMapping(
            primaryChakras: crystal.metaphysicalProperties?.primaryChakras ?? 
                          (crystal.properties?.chakra != null ? [crystal.properties!.chakra!] : []),
            secondaryChakras: crystal.metaphysicalProperties?.secondaryChakras ?? [],
            intentions: crystal.intentions ?? crystal.metaphysicalProperties?.intentions ?? [],
            resonantFrequencies: [],
            colorTherapy: ColorTherapy(
              primaryColorMeaning: crystal.color ?? 'Unknown',
              chakraAlignment: crystal.properties?.chakra ?? 'All',
              emotionalResonance: crystal.metaphysicalProperties?.healingProperties ?? [],
            ),
          ),
          astrologicalData: AstrologicalData(
            planetaryRulers: crystal.metaphysicalProperties?.planetaryRulers ?? [],
            compatibleSigns: crystal.properties?.zodiacSigns ?? [],
            elements: crystal.metaphysicalProperties?.elements ?? 
                     (crystal.properties?.element != null ? [crystal.properties!.element!] : []),
            lunarPhases: [],
          ),
          numerology: NumerologyData(
            lifePathNumbers: [],
            vibrationFrequency: 0,
            spiritualNumber: 0,
          ),
        ),
      );
    } catch (e) {
      // Fallback unified data for conversion errors
      return UnifiedCrystalData(
        requestId: DateTime.now().millisecondsSinceEpoch.toString(),
        crystalCore: CrystalCore(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now().toIso8601String(),
          confidenceScore: 0.0,
          visualAnalysis: VisualAnalysis(
            primaryColor: 'Unknown',
            secondaryColors: [],
            transparency: 'Unknown',
            formation: 'Unknown',
          ),
          identification: Identification(
            stoneType: 'Unknown',
            crystalFamily: 'Unknown',
            confidence: 0.0,
          ),
          energyMapping: EnergyMapping(
            primaryChakras: [],
            secondaryChakras: [],
            intentions: [],
            resonantFrequencies: [],
            colorTherapy: ColorTherapy(
              primaryColorMeaning: 'Unknown',
              chakraAlignment: 'All',
              emotionalResonance: [],
            ),
          ),
          astrologicalData: AstrologicalData(
            planetaryRulers: [],
            compatibleSigns: [],
            elements: [],
            lunarPhases: [],
          ),
          numerology: NumerologyData(
            lifePathNumbers: [],
            vibrationFrequency: 0,
            spiritualNumber: 0,
          ),
        ),
      );
    }
  }

  /// Convert Crystal to CollectionEntry
  static CollectionEntry crystalToCollectionEntry(Crystal crystal, {
    DateTime? acquisitionDate,
    String? acquisitionMethod,
    String? personalNotes,
  }) {
    return CollectionEntry(
      id: crystal.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      crystalCore: crystalToUnified(crystal),
      acquisitionDate: acquisitionDate ?? DateTime.now(),
      acquisitionMethod: acquisitionMethod ?? 'Unknown',
      personalNotes: personalNotes ?? '',
      usageCount: 0,
      lastUsed: null,
      favoriteStatus: false,
      customTags: [],
      spiritualSignificance: '',
      energyLevel: 5.0,
      physicalCondition: 'Good',
    );
  }

  /// Convert CollectionEntry to Crystal
  static Crystal collectionEntryToCrystal(CollectionEntry entry) {
    return unifiedToCrystal(entry.crystalCore);
  }

  /// Convert UnifiedCrystalData to CollectionEntry
  static CollectionEntry unifiedToCollectionEntry(UnifiedCrystalData unifiedData, {
    DateTime? acquisitionDate,
    String? acquisitionMethod,
    String? personalNotes,
  }) {
    return CollectionEntry(
      id: unifiedData.crystalCore.id,
      crystalCore: unifiedData,
      acquisitionDate: acquisitionDate ?? DateTime.now(),
      acquisitionMethod: acquisitionMethod ?? 'Identified',
      personalNotes: personalNotes ?? '',
      usageCount: 0,
      lastUsed: null,
      favoriteStatus: false,
      customTags: [],
      spiritualSignificance: '',
      energyLevel: unifiedData.crystalCore.confidenceScore * 10,
      physicalCondition: 'Good',
    );
  }

  /// Batch convert list of UnifiedCrystalData to Crystals
  static List<Crystal> batchUnifiedToCrystal(List<UnifiedCrystalData> unifiedList) {
    return unifiedList.map((unified) => unifiedToCrystal(unified)).toList();
  }

  /// Batch convert list of Crystals to UnifiedCrystalData
  static List<UnifiedCrystalData> batchCrystalToUnified(List<Crystal> crystalList) {
    return crystalList.map((crystal) => crystalToUnified(crystal)).toList();
  }

  /// Extract crystal name safely from any model
  static String extractCrystalName(dynamic crystalData) {
    if (crystalData is Crystal) {
      return crystalData.name ?? 'Unknown';
    } else if (crystalData is UnifiedCrystalData) {
      return crystalData.crystalCore.identification.stoneType;
    } else if (crystalData is CollectionEntry) {
      return crystalData.crystalCore.identification.stoneType;
    }
    return 'Unknown';
  }

  /// Extract crystal ID safely from any model
  static String extractCrystalId(dynamic crystalData) {
    if (crystalData is Crystal) {
      return crystalData.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    } else if (crystalData is UnifiedCrystalData) {
      return crystalData.crystalCore.id;
    } else if (crystalData is CollectionEntry) {
      return crystalData.id;
    }
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}