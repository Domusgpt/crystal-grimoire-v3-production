import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';
import '../models/crystal.dart'; // Still used by getUserCollection, saveCrystal for now
import '../models/birth_chart.dart';
import '../models/crystal_collection.dart'; // Potentially for CrystalIdentification if kept
import '../models/unified_crystal_data.dart'; // New model
import 'platform_file.dart';
// StorageService is used by identifyCrystal to get BirthChart.
// If identifyCrystal becomes an instance method, it might need StorageService injected or accessed differently.
// For now, keeping StorageService.getBirthChart() as static, assuming it's okay for this refactor.
import 'storage_service.dart';

/// Service for communicating with the CrystalGrimoire backend
class BackendService {
  final http.Client _httpClient;
  String? _authToken;
  String? _userId;

  // Constructor
  BackendService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  // For testing purposes, allow setting a mock client after construction if needed, or use constructor.
  // Not ideal for production code but can bridge testing for now.
  http.Client get httpClient => _httpClient;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null;
  
  /// Get current user ID
  String? get currentUserId => _userId;
  
  /// Set authentication token
  void setAuth(String token, String userId) {
    _authToken = token;
    _userId = userId;
  }
  
  /// Clear authentication
  void clearAuth() {
    _authToken = null;
    _userId = null;
  }
  
  /// Get headers with auth if available
  Map<String, String> get _headers {
    final headers = Map<String, String>.from(BackendConfig.headers); // Create a new map from template
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
  
  /// Register a new user
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${BackendConfig.baseUrl.replaceAll('/api/v1', '')}/api/v1/auth/register'),
        // http.post from dart:http does not take Map<String,String> for body if headers indicate json,
        // but for x-www-form-urlencoded (default for http.post if Content-Type not set), Map is fine.
        // Assuming this endpoint expects form data or BackendConfig.headers doesn't set Content-Type to json.
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setAuth(data['access_token'], data['user_id']); // Now calls instance method
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
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${BackendConfig.baseUrl.replaceAll('/api/v1', '')}/api/v1/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setAuth(data['access_token'], data['user_id']); // Now calls instance method
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
      // if (!await BackendConfig.isBackendAvailable()) { // isBackendAvailable could be static or part of config
      //   throw Exception('Backend not available');
      // }
      // Assuming BackendConfig.isBackendAvailable() is handled by caller or is not critical for unit test logic of this method itself
      if (images.isEmpty) {
        throw Exception('At least one image is required for identification.');
      }

      final imageBytes = await images.first.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        'image_data': base64Image,
        'user_context': {'text_description': userTextContext},
      };
      
      final birthChartData = await StorageService.getBirthChart(); // Remains static call for now
      if (birthChartData != null) {
        final birthChart = BirthChart.fromJson(birthChartData);
        final spiritualContext = birthChart.getSpiritualContext();
        (requestBody['user_context'] as Map<String, dynamic>)['astrological_info'] = {
          'sun_sign': spiritualContext['sunSign'],
          'moon_sign': spiritualContext['moonSign'],
          'ascendant': spiritualContext['ascendant'],
        };
      }
      if (sessionId != null) {
         (requestBody['user_context'] as Map<String, dynamic>)['session_id'] = sessionId;
      }

      final client = http.Client();
      final headers = Map<String, String>.from(BackendConfig.headers)..addAll({'Content-Type': 'application/json'});
      
      final response = await client.post(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.identifyEndpoint}'),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(BackendConfig.uploadTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UnifiedCrystalData.fromJson(data);
      } else if (response.statusCode == 401) {
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
  Future<List<UnifiedCrystalData>> getUserCollection({String? userId}) async {
    if (userId != null && !this.isAuthenticated) {
      print("Fetching collection for specific user $userId, auth status: ${this.isAuthenticated}");
    } else if (userId == null && !this.isAuthenticated) {
      print("Fetching all public crystals, auth status: ${this.isAuthenticated}");
    }

    try {
      var uri = Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}');
      if (userId != null && userId.isNotEmpty) {
        uri = uri.replace(queryParameters: {'user_id': userId});
      }

      final response = await _httpClient.get( // Use instance client
        uri,
        headers: _headers, // Instance getter
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UnifiedCrystalData.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        clearAuth(); // Instance method
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
  Future<UnifiedCrystalData> saveCrystal(UnifiedCrystalData crystalData) async {
    if (!this.isAuthenticated) { // Instance getter
      throw Exception('Authentication required to save crystal.');
    }

    try {
      final response = await _httpClient.post( // Use instance client
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}'),
        headers: _headers..addAll({'Content-Type': 'application/json'}), // Instance getter
        body: jsonEncode(crystalData.toJson()),
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UnifiedCrystalData.fromJson(data);
      } else if (response.statusCode == 401) {
        clearAuth(); // Instance method
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
  Future<UnifiedCrystalData> updateCrystal(UnifiedCrystalData crystalData) async {
    if (!this.isAuthenticated) { // Instance getter
      throw Exception('Authentication required to update crystal.');
    }
    if (crystalData.crystalCore.id.isEmpty) {
      throw Exception('Crystal ID is required for updating.');
    }

    try {
      final response = await _httpClient.put( // Use instance client
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}/${crystalData.crystalCore.id}'),
        headers: _headers..addAll({'Content-Type': 'application/json'}), // Instance getter
        body: jsonEncode(crystalData.toJson()),
      ).timeout(BackendConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UnifiedCrystalData.fromJson(data);
      } else if (response.statusCode == 401) {
        clearAuth(); // Instance method
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
  Future<void> deleteCrystal(String crystalId) async {
    if (!this.isAuthenticated) { // Instance getter
      throw Exception('Authentication required to delete crystal.');
    }
    if (crystalId.isEmpty) {
      throw Exception('Crystal ID is required for deletion.');
    }

    try {
      final response = await _httpClient.delete( // Use instance client
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.crystalsEndpoint}/$crystalId'),
        headers: _headers, // Instance getter
      ).timeout(BackendConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] != 'success') {
            throw Exception(data['message'] ?? 'Failed to delete crystal on backend.');
        }
      } else if (response.statusCode == 401) {
        clearAuth(); // Instance method
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
  Future<Map<String, dynamic>> getUsageStats() async {
    if (!this.isAuthenticated || _userId == null) { // Use instance properties
      throw Exception('Authentication required');
    }
    
    try {
      final response = await _httpClient.get( // Use instance client
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.usageEndpoint}/$_userId'), // Use instance _userId
        headers: _headers, // Use instance headers
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        clearAuth(); // Use instance method
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load usage stats');
      }
    } catch (e) {
      throw Exception('Failed to get usage stats: $e');
    }
  }
  
  // /// Parse backend response into CrystalIdentification - Obsolete: Replaced by UnifiedCrystalData flow
  // static CrystalIdentification _parseBackendResponse(Map<String, dynamic> data) {
  //   final crystalData = data['crystal'];
    
  //   final crystal = Crystal(
  //     id: crystalData['id'],
  //     name: crystalData['name'],
  //     scientificName: crystalData['scientificName'] ?? '',
  //     group: 'Unknown',
  //     description: crystalData['description'] ?? '',
  //     chakras: List<String>.from(crystalData['chakras'] ?? []),
  //     elements: ['Earth'], // Default element
  //     properties: {
  //       'healing': List<String>.from(crystalData['healingProperties'] ?? []),
  //       'metaphysical': List<String>.from(crystalData['metaphysicalProperties'] ?? []),
  //       'hardness': crystalData['hardness'] ?? '',
  //       'formation': crystalData['formation'] ?? '',
  //     },
  //     careInstructions: crystalData['careInstructions'] ?? '',
  //   );
    
  //   return CrystalIdentification(
  //     sessionId: data['sessionId'],
  //     crystal: crystal,
  //     confidence: _parseConfidence(data['confidence']), // Would also need to make _parseConfidence instance or remove
  //     mysticalMessage: data['spiritualMessage'] ?? '',
  //     fullResponse: data['fullResponse'] ?? '',
  //     timestamp: DateTime.parse(data['timestamp']),
  //     needsMoreInfo: data['needsMoreInfo'] ?? false,
  //     suggestedAngles: List<String>.from(data['suggestedAngles'] ?? []),
  //     observedFeatures: List<String>.from(data['observedFeatures'] ?? []),
  //   );
  // }
  
  // /// Parse backend crystal data - Obsolete: Replaced by UnifiedCrystalData flow
  // static Crystal _parseBackendCrystal(Map<String, dynamic> data) {
  //   return Crystal(
  //     id: data['id'],
  //     name: data['crystal_name'],
  //     scientificName: '',
  //     group: 'Unknown',
  //     description: data['full_response'] ?? '',
  //     chakras: [],
  //     elements: [],
  //     properties: {},
  //     careInstructions: '',
  //   );
  // }
  
  /// Get personalized spiritual guidance using LLM integration
  static Future<Map<String, dynamic>> getPersonalizedGuidance({
    required String guidanceType,
    required Map<String, dynamic> userProfile, // Keep as Map for flexibility with JSON
    required String customPrompt,
  }) async {
    try {
      final uri = Uri.parse('${BackendConfig.baseUrl}/spiritual/guidance'); // Assuming this endpoint exists
      
      final client = http.Client();
      final headers = Map<String, String>.from(BackendConfig.headers);
      
      // Using MultipartRequest and then converting to StreamedRequest to send via client
      final multipartRequest = http.MultipartRequest('POST', uri);
      
      multipartRequest.headers.addAll(headers);

      multipartRequest.fields['guidance_type'] = guidanceType;
      multipartRequest.fields['user_profile'] = jsonEncode(userProfile);
      multipartRequest.fields['custom_prompt'] = customPrompt;
      
      print('🔮 Requesting personalized guidance: $guidanceType via static method');

      final streamedRequest = http.StreamedRequest(
        multipartRequest.method,
        multipartRequest.url,
      );
      streamedRequest.headers.addAll(multipartRequest.headers);
      
      multipartRequest.finalize().pipe(streamedRequest.sink).catchError((e) {
        print("Error piping request: $e");
        throw e;
      });

      final http.StreamedResponse streamedResponse = await client.send(streamedRequest)
          .timeout(BackendConfig.apiTimeout);
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
      return {
        'guidance': _getFallbackGuidance(guidanceType), // Static method call
        'source': 'fallback',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Fallback guidance when LLM service is unavailable
  static String _getFallbackGuidance(String guidanceType) { // Made static method
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
  // /// Parse confidence string to double - Obsolete: Part of _parseBackendResponse
  // static double _parseConfidence(dynamic confidence) {
  //   if (confidence is double) return confidence;
  //   if (confidence is int) return confidence.toDouble();
  //   if (confidence is String) {
  //     switch (confidence.toLowerCase()) {
  //       case 'high': return 0.9;
  //       case 'medium': return 0.7;
  //       case 'low': return 0.5;
  //       default: return 0.7;
  //     }
  //   }
  //   return 0.7;
  // }
}