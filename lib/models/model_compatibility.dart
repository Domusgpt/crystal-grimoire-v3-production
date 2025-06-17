// Temporary compatibility layer for model mismatches
import 'unified_crystal_data.dart';

extension UnifiedCrystalDataCompatibility on UnifiedCrystalData {
  // Legacy compatibility getters
  List<String> get primaryUses => userIntegration?.intentionSettings ?? [];
  
  // Mock metaphysical properties for backward compatibility
  dynamic get metaphysicalProperties => _MockMetaphysicalProperties(this);
}

extension CrystalCoreCompatibility on CrystalCore {
  // Legacy compatibility getter
  dynamic get metaphysicalProperties => _MockMetaphysicalProperties2(this);
}

class _MockMetaphysicalProperties {
  final UnifiedCrystalData crystal;
  _MockMetaphysicalProperties(this.crystal);
  
  List<String> get primaryChakras => [crystal.crystalCore.energyMapping.primaryChakra];
}

class _MockMetaphysicalProperties2 {
  final CrystalCore core;
  _MockMetaphysicalProperties2(this.core);
  
  List<String> get primaryChakras => [core.energyMapping.primaryChakra];
}

extension UserIntegrationCompatibility on UserIntegration {
  String? get personalNotes => userExperiences.isNotEmpty ? userExperiences.first : null;
}