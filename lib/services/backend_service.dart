import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';
import '../models/crystal.dart'; // Still used by getUserCollection, saveCrystal for now
import '../models/birth_chart.dart';
import '../models/crystal_collection.dart'; // Potentially for CrystalIdentification if kept
import '../models/unified_crystal_data.dart'; // New model
import 'platform_file.dart';
import 'storage_service.dart';

/// Service for communicating with the CrystalGrimoire backend
class BackendService {
  static String? _authToken;
  static String? _userId;
  
  /// Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;
  
  /// Get current user ID
  static String? get currentUserId => _userId;
  
  /// Set authentication token
  static void setAuth(String token, String userId) {
    _authToken = token;
    _userId = userId;
  }
  
  /// Clear authentication
  static void clearAuth() {
    _authToken = null;
    _userId = null;
  }
  
  /// Get headers with auth if available
  static Map<String, String> get _headers {
    final headers = BackendConfig.headers;
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
  
  /// Register a new user
  static Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl.replaceAll('/api/v1', '')}/api/v1/auth/register'),
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setAuth(data['access_token'], data['user_id']);
        return {
          'success': true,
          'user_id': data['user_id'],
          'email': data['email'],
          'token': data['access_token'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
  
  /// Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl.replaceAll('/api/v1', '')}/api/v1/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setAuth(data['access_token'], data['user_id']);
        return {
          'success': true,
          'user_id': data['user_id'],
          'email': data['email'],
          'subscription_tier': data['subscription_tier'],
          'token': data['access_token'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
  
  /// Identify crystal using backend API
  static Future<UnifiedCrystalData> identifyCrystal({
    required List<PlatformFile> images, // Backend expects one image
    String? userTextContext, // General text from user
    String? sessionId, // Optional session ID
  }) async {
    try {
      if (!await BackendConfig.isBackendAvailable()) {
        throw Exception('Backend not available');
      }
      if (images.isEmpty) {
        throw Exception('At least one image is required for identification.');
      }

      // Backend expects a single base64 encoded image.
      final imageBytes = await images.first.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        'image_data': base64Image,
        'user_context': {
          'text_description': userTextContext,
          // sessionId is not directly part of user_context in Pydantic, but can be included if useful
        },
      };
      
      // Add birth chart context if available to user_context
      final birthChartData = await StorageService.getBirthChart();
      if (birthChartData != null) {
        final birthChart = BirthChart.fromJson(birthChartData);
        final spiritualContext = birthChart.getSpiritualContext();
        (requestBody['user_context'] as Map<String, dynamic>)['astrological_info'] = {
          'sun_sign': spiritualContext['sunSign'],
          'moon_sign': spiritualContext['moonSign'],
          'ascendant': spiritualContext['ascendant'],
          // 'dominant_elements': spiritualContext['dominantElements'], // Consider if this level of detail is needed
          // 'recommended_crystals': spiritualContext['recommendations'],
        };
      }
      if (sessionId != null) {
         (requestBody['user_context'] as Map<String, dynamic>)['session_id'] = sessionId;
      }


      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.identifyEndpoint}'),
        headers: _headers..addAll({'Content-Type': 'application/json'}), // Ensure correct content type
        body: jsonEncode(requestBody),
      ).timeout(BackendConfig.uploadTimeout); // Use uploadTimeout as it involves image data potentially
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UnifiedCrystalData.fromJson(data);
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required');
      } else if (response.statusCode == 429) { // Assuming 429 might still be used
        throw Exception('API limit reached or other restriction.');
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['detail'] ?? 'Identification failed with status ${response.statusCode}');
        } catch (e) { // If error body is not JSON or no detail
          throw Exception('Identification failed with status ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      // Log or handle different types of exceptions if necessary
      print('Error in identifyCrystal: $e');
      throw Exception('Backend crystal identification failed: $e');
    }
  }
  
  // /// Identify crystal anonymously (for testing without auth)
  // /// This method would need similar updates if kept, to use UnifiedCrystalData
  // /// and align with any changes to its corresponding backend endpoint.
  // static Future<CrystalIdentification> identifyCrystalAnonymous({
  //   required List<PlatformFile> images,
  //   String? userContext,
  //   String? sessionId,
  // }) async {
  //   try {
  //     final request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${BackendConfig.baseUrl}/crystal/identify-anonymous'),
  //     );
      
  //     // Add images
  //     for (int i = 0; i < images.length; i++) {
  //       final imageBytes = await images[i].readAsBytes();
  //       final imageFile = http.MultipartFile.fromBytes(
  //         'images',
  //         imageBytes,
  //         filename: images[i].name.isNotEmpty ? images[i].name : 'crystal_$i.jpg',
  //       );
  //       request.files.add(imageFile);
  //     }
      
  //     // Add other fields
  //     request.fields['description'] = userContext ?? '';
  //     if (sessionId != null) {
  //       request.fields['session_id'] = sessionId;
  //     }
      
  //     final streamedResponse = await request.send().timeout(BackendConfig.uploadTimeout);
  //     final response = await http.Response.fromStream(streamedResponse);
      
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return _parseBackendResponse(data);
  //     } else {
  //       final error = jsonDecode(response.body);
  //       throw Exception(error['detail'] ?? 'Identification failed');
  //     }
  //   } catch (e) {
  //     throw Exception('Anonymous crystal identification failed: $e');
  //   }
  // }
  
  /// Get user's crystal collection (now UnifiedCrystalData)
  static Future<List<UnifiedCrystalData>> getUserCollection() async {
    // Note: The backend GET /api/crystals does not filter by user_id yet.
    // This method will fetch all crystals.
    // Proper user filtering would require backend changes and passing user_id.
    if (!isAuthenticated) { // Still good practice to check, even if backend doesn't filter
      // throw Exception('Authentication required to view collection.');
      // Or allow fetching all public data if that's the design for /api/crystals
    }
    
    try {
      final response = await http.get(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}'), // GET /api/crystals
        headers: _headers,
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UnifiedCrystalData.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication potentially required or token expired.');
      } else {
         final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load crystal collection with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserCollection: $e');
      throw Exception('Failed to get user collection: $e');
    }
  }
  
  /// Save a new crystal to the collection (UnifiedCrystalData)
  static Future<UnifiedCrystalData> saveCrystal(UnifiedCrystalData crystalData) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required to save crystal.');
    }
    // Assuming crystalData.crystalCore.id is either pre-set for a specific reason
    // or the backend will generate one if it's empty (current backend uses provided ID).
    // If UserIntegration needs user_id, it should be set before calling this.
    // e.g., crystalData.userIntegration?.userId = _userId; (This requires UserIntegration to be mutable or reconstructed)

    try {
      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}'), // POST /api/crystals
        headers: _headers..addAll({'Content-Type': 'application/json'}),
        body: jsonEncode(crystalData.toJson()),
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200 || response.statusCode == 201) { // 201 for created
        final data = jsonDecode(response.body);
        return UnifiedCrystalData.fromJson(data);
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required or token expired.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to save crystal with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in saveCrystal: $e');
      throw Exception('Failed to save crystal: $e');
    }
  }

  /// Update an existing crystal in the collection (UnifiedCrystalData)
  static Future<UnifiedCrystalData> updateCrystal(UnifiedCrystalData crystalData) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required to update crystal.');
    }
    if (crystalData.crystalCore.id.isEmpty) {
      throw Exception('Crystal ID is required for updating.');
    }

    try {
      final response = await http.put(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}/${crystalData.crystalCore.id}'), // PUT /api/crystals/{crystal_id}
        headers: _headers..addAll({'Content-Type': 'application/json'}),
        body: jsonEncode(crystalData.toJson()),
      ).timeout(BackendConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UnifiedCrystalData.fromJson(data);
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required or token expired.');
      } else if (response.statusCode == 404) {
        throw Exception('Crystal not found for update.');
      }
       else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update crystal with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateCrystal: $e');
      throw Exception('Failed to update crystal: $e');
    }
  }

  /// Delete a crystal from the collection
  static Future<void> deleteCrystal(String crystalId) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required to delete crystal.');
    }
    if (crystalId.isEmpty) {
      throw Exception('Crystal ID is required for deletion.');
    }

    try {
      final response = await http.delete(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}/$crystalId'), // DELETE /api/crystals/{crystal_id}
        headers: _headers,
      ).timeout(BackendConfig.apiTimeout);

      if (response.statusCode == 200) { // Backend returns 200 with a success message
        final data = jsonDecode(response.body);
        if (data['status'] != 'success') {
            throw Exception(data['message'] ?? 'Failed to delete crystal on backend.');
        }
        // Successfully deleted
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required or token expired.');
      } else if (response.statusCode == 404) {
        throw Exception('Crystal not found for deletion.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete crystal with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteCrystal: $e');
      throw Exception('Failed to delete crystal: $e');
    }
  }
  
  /// Get usage statistics
  static Future<Map<String, dynamic>> getUsageStats() async {
    if (!isAuthenticated || _userId == null) {
      throw Exception('Authentication required');
    }
    
    try {
      final response = await http.get(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.usageEndpoint}/$_userId'),
        headers: _headers,
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load usage stats');
      }
    } catch (e) {
      throw Exception('Failed to get usage stats: $e');
    }
  }
  
  /// Parse backend response into CrystalIdentification
  static CrystalIdentification _parseBackendResponse(Map<String, dynamic> data) {
    final crystalData = data['crystal'];
    
    final crystal = Crystal(
      id: crystalData['id'],
      name: crystalData['name'],
      scientificName: crystalData['scientificName'] ?? '',
      group: 'Unknown',
      description: crystalData['description'] ?? '',
      chakras: List<String>.from(crystalData['chakras'] ?? []),
      elements: ['Earth'], // Default element
      properties: {
        'healing': List<String>.from(crystalData['healingProperties'] ?? []),
        'metaphysical': List<String>.from(crystalData['metaphysicalProperties'] ?? []),
        'hardness': crystalData['hardness'] ?? '',
        'formation': crystalData['formation'] ?? '',
      },
      careInstructions: crystalData['careInstructions'] ?? '',
    );
    
    return CrystalIdentification(
      sessionId: data['sessionId'],
      crystal: crystal,
      confidence: _parseConfidence(data['confidence']),
      mysticalMessage: data['spiritualMessage'] ?? '',
      fullResponse: data['fullResponse'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
      needsMoreInfo: data['needsMoreInfo'] ?? false,
      suggestedAngles: List<String>.from(data['suggestedAngles'] ?? []),
      observedFeatures: List<String>.from(data['observedFeatures'] ?? []),
    );
  }
  
  /// Parse backend crystal data
  static Crystal _parseBackendCrystal(Map<String, dynamic> data) {
    return Crystal(
      id: data['id'],
      name: data['crystal_name'],
      scientificName: '',
      group: 'Unknown',
      description: data['full_response'] ?? '',
      chakras: [],
      elements: [],
      properties: {},
      careInstructions: '',
    );
  }
  
  /// Get personalized spiritual guidance using LLM integration
  static Future<Map<String, dynamic>> getPersonalizedGuidance({
    required String guidanceType,
    required Map<String, dynamic> userProfile,
    required String customPrompt,
  }) async {
    try {
      final uri = Uri.parse('${BackendConfig.baseUrl}/spiritual/guidance');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      BackendConfig.headers.forEach((key, value) {
        request.headers[key] = value;
      });
      
      // Add form fields
      request.fields['guidance_type'] = guidanceType;
      request.fields['user_profile'] = jsonEncode(userProfile);
      request.fields['custom_prompt'] = customPrompt;
      
      print('🔮 Requesting personalized guidance: $guidanceType');
      
      final streamedResponse = await request.send().timeout(BackendConfig.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✨ Received personalized guidance');
        return data;
      } else {
        print('❌ Guidance request failed: ${response.statusCode}');
        throw Exception('Failed to get personalized guidance: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting personalized guidance: $e');
      // Return fallback guidance
      return {
        'guidance': _getFallbackGuidance(guidanceType),
        'source': 'fallback',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Fallback guidance when LLM service is unavailable
  static String _getFallbackGuidance(String guidanceType) {
    switch (guidanceType) {
      case 'daily':
        return "Beloved seeker, today is a perfect day to connect with your crystal allies. Hold your favorite crystal in meditation and set a clear intention for the day ahead. Trust your intuition to guide you.";
      case 'crystal_selection':
        return "Look within your collection and notice which crystal calls to you most strongly today. That crystal has a message for you - listen with your heart.";
      case 'chakra_balancing':
        return "Begin with grounding at your root chakra, then slowly work your way up, spending time with each energy center. Use crystals that resonate with each chakra's frequency.";
      case 'lunar_guidance':
        return "The moon's energy flows through all crystals. Tonight, place your stones under the night sky to absorb lunar vibrations and cleanse any stagnant energy.";
      default:
        return "Take time today to connect with your spiritual practice. Your crystals are here to support and guide you on your journey of growth and discovery.";
    }
  }

  /// Parse confidence string to double
  static double _parseConfidence(dynamic confidence) {
    if (confidence is double) return confidence;
    if (confidence is int) return confidence.toDouble();
    if (confidence is String) {
      switch (confidence.toLowerCase()) {
        case 'high': return 0.9;
        case 'medium': return 0.7;
        case 'low': return 0.5;
        default: return 0.7;
      }
    }
    return 0.7;
  }
}