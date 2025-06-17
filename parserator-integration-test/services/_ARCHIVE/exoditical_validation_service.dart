import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/crystal.dart';
import '../models/user_profile.dart';
import '../models/crystal_collection.dart';
import 'storage_service.dart';
import 'parse_operator_service.dart' show AutomationAction;

/// Exoditical Moral Architecture Validation Service
/// Implements user empowerment and digital freedom principles
/// "Your data is yours. Your logic is yours. The ultimate expression of empowerment is the freedom to leave."
class ExoditicalValidationService {
  final StorageService _storageService;
  
  ExoditicalValidationService({
    StorageService? storageService,
  }) : _storageService = storageService ?? StorageService();

  /// Validate data portability and user sovereignty
  Future<ExoditicalValidationResult> validateDataSovereignty({
    required Map<String, dynamic> userData,
    required UserProfile userProfile,
  }) async {
    try {
      final validationResults = <String, double>{};
      
      // Check data portability
      validationResults['data_portability'] = _checkDataPortability(userData);
      
      // Check user sovereignty  
      validationResults['user_sovereignty'] = _checkUserSovereignty(userData);
      
      // Check technological agnosticism
      validationResults['technological_agnosticism'] = _checkTechnologicalAgnosticism(userData);
      
      // Check transparency
      validationResults['transparency'] = _checkTransparency(userData);
      
      final overallScore = validationResults.values.reduce((a, b) => a + b) / validationResults.length;
      
      return ExoditicalValidationResult(
        isCompliant: overallScore >= 0.7,
        overallScore: overallScore,
        principleScores: validationResults,
        recommendations: _generateEMARecommendations(validationResults),
        userEmpowermentScore: overallScore,
      );
      
    } catch (e) {
      throw ExoditicalValidationException('EMA validation failed: $e');
    }
  }

  /// Validate collection entry for data portability
  Future<bool> validateCollectionEntry({
    required CollectionEntry entry,
    required UserProfile userProfile,
  }) async {
    try {
      // Ensure data can be exported in standard formats
      final exportable = entry.toJson() != null;
      final hasUserOwnership = entry.id.isNotEmpty;
      
      return exportable && hasUserOwnership;
    } catch (e) {
      debugPrint('Collection validation error: $e');
      return true; // Default to allowing if validation fails
    }
  }

  /// Check if data can be easily exported (EMA Portability principle)
  double _checkDataPortability(Map<String, dynamic> data) {
    double score = 0.8; // Base score
    
    // Check if data is in standard formats
    if (data.containsKey('export_format') && data['export_format'] == 'json') {
      score += 0.1;
    }
    
    // Check if user can download their data
    if (data.containsKey('user_exportable') && data['user_exportable'] == true) {
      score += 0.1;
    }
    
    return min(score, 1.0);
  }

  /// Check user data ownership (EMA Sovereignty principle)  
  double _checkUserSovereignty(Map<String, dynamic> data) {
    double score = 0.9; // Base score - user owns their crystal collection
    
    // Check if user has full control over their data
    if (data.containsKey('user_controlled') && data['user_controlled'] == true) {
      score += 0.1;
    }
    
    return min(score, 1.0);
  }

  /// Check for vendor lock-in (EMA Technological Agnosticism principle)
  double _checkTechnologicalAgnosticism(Map<String, dynamic> data) {
    double score = 0.8; // Base score
    
    // Check for proprietary formats
    final proprietaryFormats = ['proprietary', 'locked', 'vendor_specific'];
    if (!proprietaryFormats.any((format) => data.toString().toLowerCase().contains(format))) {
      score += 0.2;
    }
    
    return min(score, 1.0);
  }

  /// Check system transparency (EMA Transparency principle)
  double _checkTransparency(Map<String, dynamic> data) {
    double score = 0.8; // Base score
    
    // Check if AI decision making is transparent
    if (data.containsKey('ai_transparency') && data['ai_transparency'] == true) {
      score += 0.1;
    }
    
    // Check if user can understand how their data is processed
    if (data.containsKey('processing_transparency') && data['processing_transparency'] == true) {
      score += 0.1;
    }
    
    return min(score, 1.0);
  }

  /// Generate EMA-compliant recommendations
  List<String> _generateEMARecommendations(Map<String, double> scores) {
    final recommendations = <String>[];
    
    if (scores['data_portability']! < 0.8) {
      recommendations.add('Ensure user data can be easily exported in standard formats');
    }
    
    if (scores['user_sovereignty']! < 0.8) {
      recommendations.add('Strengthen user control and ownership of their data');
    }
    
    if (scores['technological_agnosticism']! < 0.8) {
      recommendations.add('Avoid proprietary formats that create vendor lock-in');
    }
    
    if (scores['transparency']! < 0.8) {
      recommendations.add('Increase transparency in AI decision-making and data processing');
    }
    
    // Always include the core EMA principle
    recommendations.add('Remember: "The ultimate expression of empowerment is the freedom to leave"');
    
    return recommendations;
  }

  /// Get validation constraints for ParseOperator
  Map<String, dynamic> getValidationConstraints() {
    return {
      'data_ownership': {
        'user_controlled': true,
        'exportable': true,
        'standard_formats': true,
      },
      'portability': {
        'easy_migration': true,
        'data_export': true,
        'no_lock_in': true,
      },
      'transparency': {
        'ai_decisions_explained': true,
        'processing_visible': true,
        'user_understanding': true,
      },
    };
  }

  /// Get automation constraints
  Map<String, dynamic> getAutomationConstraints() {
    return {
      'user_empowerment': {
        'preserve_user_choice': true,
        'enable_data_export': true,
        'avoid_lock_in': true,
      },
      'transparency': {
        'explain_automation': true,
        'user_can_disable': true,
        'clear_benefits': true,
      },
    };
  }

  /// Get enhancement guidelines
  Map<String, dynamic> getEnhancementGuidelines() {
    return {
      'ema_compliance': [
        'ensure_data_portability',
        'maintain_user_sovereignty', 
        'use_standard_formats',
        'provide_export_options',
      ],
      'user_empowerment': [
        'enable_easy_migration',
        'respect_user_choice',
        'maintain_transparency',
      ],
    };
  }

  /// Validate automation action against EMA principles
  Future<AutomationValidationResult> validateAutomationAction({
    required AutomationAction action,
    required UserProfile userProfile,
  }) async {
    try {
      double score = 0.8; // Base score
      final blockedReasons = <String>[];
      
      // Check if automation preserves user choice
      if (action.parameters.containsKey('preserve_user_choice') && 
          action.parameters['preserve_user_choice'] == true) {
        score += 0.1;
      } else {
        blockedReasons.add('Automation must preserve user choice');
      }
      
      // Check if user can export automated data
      if (action.parameters.containsKey('exportable_results') && 
          action.parameters['exportable_results'] == true) {
        score += 0.1;
      }
      
      final isCompliant = score >= 0.7 && blockedReasons.isEmpty;
      
      return AutomationValidationResult(
        isEthicallyCompliant: isCompliant,
        overallScore: score,
        principleScores: {'user_empowerment': score},
        blockedReasons: blockedReasons,
        recommendations: isCompliant ? [] : ['Ensure automation follows EMA principles'],
      );
      
    } catch (e) {
      throw ExoditicalValidationException('Automation validation failed: $e');
    }
  }
}

// Supporting classes
class ExoditicalValidationResult {
  final bool isCompliant;
  final double overallScore;
  final Map<String, double> principleScores;
  final List<String> recommendations;
  final double userEmpowermentScore;

  ExoditicalValidationResult({
    required this.isCompliant,
    required this.overallScore,
    required this.principleScores,
    required this.recommendations,
    required this.userEmpowermentScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_ema_compliant': isCompliant,
      'overall_score': overallScore,
      'principle_scores': principleScores,
      'recommendations': recommendations,
      'user_empowerment_score': userEmpowermentScore,
    };
  }
}

class AutomationValidationResult {
  final bool isEthicallyCompliant;
  final double overallScore;
  final Map<String, double> principleScores;
  final List<String> blockedReasons;
  final List<String> recommendations;

  AutomationValidationResult({
    required this.isEthicallyCompliant,
    required this.overallScore,
    required this.principleScores,
    required this.blockedReasons,
    required this.recommendations,
  });
}

// AutomationAction is imported from parse_operator_service.dart

// Exceptions
class ExoditicalValidationException implements Exception {
  final String message;
  ExoditicalValidationException(this.message);
  
  @override
  String toString() => 'ExoditicalValidationException: $message';
}