// lib/models/personalized_guidance_result.dart

class PersonalizedGuidanceResult {
  final String userFacingGuidance;
  final Map<String, dynamic> backendStructuredData;
  final String? sessionId;

  PersonalizedGuidanceResult({
    required this.userFacingGuidance,
    required this.backendStructuredData,
    this.sessionId,
  });

  factory PersonalizedGuidanceResult.fromJson(Map<String, dynamic> json) {
    return PersonalizedGuidanceResult(
      userFacingGuidance: json['user_facing_guidance'] as String? ?? 'Sorry, guidance is currently unavailable.',
      backendStructuredData: json['backend_structured_data'] as Map<String, dynamic>? ?? {},
      sessionId: json['sessionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_facing_guidance': userFacingGuidance,
      'backend_structured_data': backendStructuredData,
      'sessionId': sessionId,
    };
  }
}

// It might also be beneficial to define a class for the backendStructuredData if its structure is firm.
// For example:
// class BackendGuidanceData {
//   final List<String> mentionedCrystalIds;
//   final List<String> keyThemes;
//   final List<String> suggestedPractices;
//   final String sentiment;

//   BackendGuidanceData({
//     this.mentionedCrystalIds = const [],
//     this.keyThemes = const [],
//     this.suggestedPractices = const [],
//     this.sentiment = '',
//   });

//   factory BackendGuidanceData.fromJson(Map<String, dynamic> json) {
//     return BackendGuidanceData(
//       mentionedCrystalIds: List<String>.from(json['mentioned_crystals_ids'] ?? []),
//       keyThemes: List<String>.from(json['key_themes'] ?? []),
//       suggestedPractices: List<String>.from(json['suggested_practices'] ?? []),
//       sentiment: json['sentiment'] as String? ?? '',
//     );
//   }
// }
// And then PersonalizedGuidanceResult.backendStructuredData could be of type BackendGuidanceData.
// For now, keeping it as Map<String, dynamic> is simpler until the backend data structure is fully tested with Gemini.
