import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../config/api_config.dart';
import '../config/backend_config.dart';
import '../models/crystal.dart'; // May become unused here if CrystalIdentification is fully removed
import '../models/user_profile.dart';
// import '../models/crystal_collection.dart'; // CollectionEntry is used for context building, might need to adapt or remove
// For identifyCrystal, UnifiedCrystalData is the new return type
import '../models/unified_crystal_data.dart';
import '../models/crystal_collection.dart'; // For CollectionEntry if still used in context building

// import 'cache_service.dart'; // To be removed
// import 'usage_tracker.dart'; // To be removed
import 'platform_file.dart';
import 'backend_service.dart';
import 'unified_llm_context_builder.dart'; // May be simplified if backend handles complex context

/// Supported AI providers
enum AIProvider {
  gemini,     // Google Gemini - FREE TIER with vision!
  openai,     // OpenAI GPT-4O
  claude,     // Anthropic Claude
  groq,       // Groq - Fast and cheap
  replicate,  // Replicate - Many models
}

/// Multi-provider AI service for crystal identification
class AIService {
  // Provider-specific endpoints
  static const Map<AIProvider, String> _endpoints = {
    AIProvider.gemini: 'https://generativelanguage.googleapis.com/v1beta/models/',
    AIProvider.openai: 'https://api.openai.com/v1/chat/completions',
    AIProvider.claude: 'https://api.anthropic.com/v1/messages',
    AIProvider.groq: 'https://api.groq.com/openai/v1/chat/completions',
    AIProvider.replicate: 'https://api.replicate.com/v1/predictions',
  };

  // Current provider (default to Gemini for free testing)
  // static AIProvider currentProvider = AIProvider.gemini; // No longer needed here
  
  // Prompts are now primarily managed by the backend.
  // static const String _premiumSpiritualAdvisorPrompt = '''...'''; // REMOVE
  // static const String _spiritualAdvisorPrompt = '''...'''; // REMOVE


  // /// Identify crystal using Firebase Multimodal GenAI Extension (PREFERRED METHOD) - COMMENT OUT
  // static Future<Map<String, dynamic>> identifyCrystalWithExtension({ ... }) async { ... }
  // static Future<Map<String, dynamic>> _waitForMultimodalExtensionResponse(DocumentReference docRef) async { ... }
  // static Future<String> _uploadImageToFirebaseStorage(PlatformFile imageFile) async { ... }

  // /// Build comprehensive user context for personalization - COMMENT OUT (BackendService builds its own context)
  // static Map<String, dynamic> _buildUserContext(...) { ... }
  // static String _extractSpiritualGoals(String? userContext) { ... }


  /// Identifies a crystal from images using the BackendService.
  /// The BackendService now encapsulates all AI provider logic and returns UnifiedCrystalData.
  static Future<UnifiedCrystalData> identifyCrystal({
    required List<PlatformFile> images,
    String? userContext, // This is the general text context from the user
    String? sessionId,
    // AIProvider? provider, // Provider selection is now backend's responsibility
    UserProfile? userProfile, // Used by BackendService to enrich its own user_context
    List<CollectionEntry>? crystalCollection, // Also used by BackendService for context
  }) async {
    try {
      // The BackendService.identifyCrystal method has been updated to accept
      // userTextContext (formerly userContext here) and will fetch userProfile related data (like birth chart)
      // from StorageService itself if needed, as seen in its implementation.
      // We just need to pass the basic user text and images.
      // SessionId can also be passed if available.

      // Note: The `userProfile` and `crystalCollection` parameters were used here to build `enhancedUserContext`.
      // BackendService.identifyCrystal now expects a simpler `userTextContext` and handles
      // fetching/building more detailed context (like astrological) on its own.
      // For this transition, we will pass the `userContext` string directly.
      // If `userProfile` or `crystalCollection` data is absolutely needed *by the backend* beyond what
      // `BackendService` already does (e.g. it expects a pre-compiled list of owned crystal names
      // that `BackendService` doesn't currently build), then `BackendService.identifyCrystal`'s
      // `user_context` map population would need to be adjusted, or this `AIService.identifyCrystal`
      // would need to prepare a specific part of that map.
      // Given current BackendService structure, only `userTextContext` and `sessionId` are directly used.

      print('🔮 AIService routing to BackendService.identifyCrystal');
      return await BackendService.identifyCrystal(
        images: images,
        userTextContext: userContext, // Pass the string context
        sessionId: sessionId,
        // userProfile and crystalCollection are not direct params to BackendService.identifyCrystal
        // BackendService.identifyCrystal creates its own context map including astrological data.
      );
    } catch (e) {
      // Consider if _handleError is still appropriate or if BackendService errors are sufficient
      print('AIService: Error calling BackendService.identifyCrystal: $e');
      throw _handleError(e); // Or a new error handler specific to this simplified flow
    }
  }

  // --- All direct AI call methods (_callGemini, _callOpenAI, _callGroq) should be removed ---
  // static Future<String> _callGemini(...) async { ... } // REMOVE
  // static Future<String> _callOpenAI(...) async { ... } // REMOVE
  // static Future<String> _callGroq(...) async { ... } // REMOVE
  // static AIProvider _selectOptimalProvider(...) { ... } // REMOVE

  // --- Helper methods for direct AI calls should be removed ---
  // static Future<String> _prepareImage(...) async { ... } // REMOVE (BackendService handles image prep if needed)
  // static Future<String> _generateImageHash(...) async { ... } // REMOVE (Caching is backend's concern)
  
  // --- Parsing logic for old CrystalIdentification model is removed ---
  // static CrystalIdentification _parseResponse(...) { ... } // REMOVE
  // static List<String> _extractChakras(...) { ... } // REMOVE
  // static List<String> _extractElements(...) { ... } // REMOVE
  // static List<String> _extractHealingProperties(...) { ... } // REMOVE

  static Exception _handleError(dynamic error) {
    // This error handler might need adjustment if errors from BackendService are already well-formed.
    print('🔮 AIService Handling error: $error');
    if (error is Exception) return error; // If already an Exception, just return it.

    // Basic error handling, can be expanded
    if (error.toString().contains('SocketException') || error.toString().contains('Network error')) {
      return Exception('Network error - please check your connection.');
    } else if (error.toString().contains('Authentication required')) {
      return Exception('Authentication failed. Please login again.');
    } else {
      return Exception('Crystal identification failed: ${error.toString()}');
    }
  }

  // /// Demo mode identification - REMOVE (Backend can have its own mock/demo if needed)
  // static CrystalIdentification _getDemoIdentification(...) { ... } // REMOVE
}