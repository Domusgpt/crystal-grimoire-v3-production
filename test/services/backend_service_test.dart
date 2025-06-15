import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Assuming models and services are in these locations
import 'package:crystal_grimoire/models/unified_crystal_data.dart';
import 'package:crystal_grimoire/services/backend_service.dart';
import 'package:crystal_grimoire/config/backend_config.dart';
import 'package:crystal_grimoire/services/platform_file.dart'; // For PlatformFile

// This will generate a mock_client.mocks.dart file by running build_runner
// For this exercise, I'll assume MockClient is available as if generated.
// To manually make it work without generation:
// class MockClient extends Mock implements http.Client {}
@GenerateMocks([http.Client])
import 'backend_service_test.mocks.dart'; // Import generated mocks

void main() {
  late MockClient mockClient;
  late BackendService backendService; // Instance of BackendService
  late Uri identifyUri;
  late Uri crystalsUri;
  late String baseUrl;


  setUp(() {
    mockClient = MockClient();
    backendService = BackendService(httpClient: mockClient); // Inject mock client

    baseUrl = BackendConfig.baseUrl;
    identifyUri = Uri.parse('$baseUrl${BackendConfig.identifyEndpoint}');
    crystalsUri = Uri.parse('$baseUrl${BackendConfig.crystalsEndpoint}');

    // Reset auth state for each test if necessary, or manage through specific tests
    // backendService.clearAuth();
  });

  // Helper to create sample UnifiedCrystalData JSON
  String sampleUnifiedCrystalDataJson(String id, String stoneType) {
    return jsonEncode({
      "crystal_core": {
        "id": id, "timestamp": DateTime.now().toIso8601String(), "confidence_score": 0.9,
        "visual_analysis": {"primary_color": "Blue", "secondary_colors": [], "transparency": "Transparent", "formation": "Point"},
        "identification": {"stone_type": stoneType, "crystal_family": "TestFamily", "variety": "TestVariety", "confidence": 0.95},
        "energy_mapping": {"primary_chakra": "Throat", "secondary_chakras": [], "chakra_number": 5, "vibration_level": "High"},
        "astrological_data": {"primary_signs": ["Gemini"], "compatible_signs": [], "planetary_ruler": "Mercury", "element": "Air"},
        "numerology": {"crystal_number": 1, "color_vibration": 1, "chakra_number": 5, "master_number": 7}
      },
      "user_integration": null,
      "automatic_enrichment": {"mineral_class": "TestClass"}
    });
  }


  group('BackendService identifyCrystal', () {
    final mockImageFile = MockPlatformFile(bytes: Uint8List.fromList([1,2,3]));

    test('returns UnifiedCrystalData on successful identification', () async {
      final crystalId = "test-crystal-id";
      final responseJson = sampleUnifiedCrystalDataJson(crystalId, "Amethyst");

      when(mockClient.post(
        identifyUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseJson, 200));

      final result = await backendService.identifyCrystal(images: [mockImageFile], userTextContext: "test context");

      expect(result, isA<UnifiedCrystalData>());
      expect(result.crystalCore.id, crystalId);
      expect(result.crystalCore.identification.stoneType, "Amethyst");
       final captured = verify(mockClient.post(
          identifyUri,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body')
      )).captured;
      expect(captured[0]['Content-Type'], 'application/json');
    });

    test('throws exception on API error (e.g., 500)', () async {
      when(mockClient.post(
        any, // Use any for URI if it might change slightly or to simplify
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Internal server error', 500));

      expect(() => backendService.identifyCrystal(images: [mockImageFile]), throwsException);
    });

     test('throws "Authentication required" on 401, clears auth', () async {
      backendService.setAuth("dummy_token", "dummy_user"); // Set some auth state
      expect(backendService.isAuthenticated, isTrue);

      when(mockClient.post(
        identifyUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'detail': 'Auth failed'}), 401));

      expect(() => backendService.identifyCrystal(images: [mockImageFile]),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Authentication required'))));
      expect(backendService.isAuthenticated, isFalse); // Auth should be cleared
    });

    test('correctly forms request body for identifyCrystal', () async {
        final mockImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final mockImage = MockPlatformFile(name: 'crystal.jpg', bytes: mockImageBytes);
        final expectedBase64Image = base64Encode(mockImageBytes);

        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(sampleUnifiedCrystalDataJson('id', 'type'), 200));

        await backendService.identifyCrystal(images: [mockImage], userTextContext: "purple shiny", sessionId: "session123");

        final captured = verify(mockClient.post(
           identifyUri,
           headers: captureAnyNamed('headers'),
           body: captureAnyNamed('body')
        )).captured;

        final headers = captured[0] as Map<String,String>;
        final body = jsonDecode(captured[1] as String);

        expect(headers['Content-Type'], 'application/json');
        expect(body['image_data'], expectedBase64Image);
        expect(body['user_context']['text_description'], "purple shiny");
        expect(body['user_context']['session_id'], "session123");
    });
  });

  group('BackendService Collection CRUD', () {
    final testCrystalId = "test-id-123";
    final crystalJson = sampleUnifiedCrystalDataJson(testCrystalId, "TestCrystal");
    final crystalDataInstance = UnifiedCrystalData.fromJson(jsonDecode(crystalJson));

    test('getUserCollection success returns List<UnifiedCrystalData>', () async {
      final responseListJson = jsonEncode([jsonDecode(crystalJson)]);
      final expectedUri = crystalsUri.replace(queryParameters: {'user_id': 'user123'});

      when(mockClient.get(
        expectedUri, // Test with a specific user_id
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(responseListJson, 200));

      final result = await backendService.getUserCollection(userId: 'user123');
      expect(result, isA<List<UnifiedCrystalData>>());
      expect(result.length, 1);
      expect(result.first.crystalCore.id, testCrystalId);
      verify(mockClient.get(expectedUri, headers: anyNamed('headers'))).called(1);
    });

    test('saveCrystal success returns UnifiedCrystalData and sends correct body/headers', () async {
       when(mockClient.post(
        crystalsUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(crystalJson, 201)); // HTTP 201 Created

      final result = await backendService.saveCrystal(crystalDataInstance);
      expect(result, isA<UnifiedCrystalData>());
      expect(result.crystalCore.id, testCrystalId);

      final captured = verify(mockClient.post(
        crystalsUri,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;
      expect(captured[0]['Content-Type'], 'application/json');
      expect(captured[1], jsonEncode(crystalDataInstance.toJson()));
    });

    test('updateCrystal success returns UnifiedCrystalData and sends correct body/headers', () async {
      final updatedData = UnifiedCrystalData.fromJson(jsonDecode(sampleUnifiedCrystalDataJson(testCrystalId, "UpdatedCrystal")));
      final expectedUri = Uri.parse('$baseUrl${BackendConfig.crystalsEndpoint}/$testCrystalId');

      when(mockClient.put(
        expectedUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(updatedData.toJson()), 200));

      final result = await backendService.updateCrystal(updatedData);
      expect(result.crystalCore.identification.stoneType, "UpdatedCrystal");

      final captured = verify(mockClient.put(
        expectedUri,
        headers: captureAnyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured;
      expect(captured[0]['Content-Type'], 'application/json');
      expect(captured[1], jsonEncode(updatedData.toJson()));
    });

    test('deleteCrystal success completes and calls correct URL', () async {
      final expectedUri = Uri.parse('$baseUrl${BackendConfig.crystalsEndpoint}/$testCrystalId');
      when(mockClient.delete(
        expectedUri,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'status': 'success', 'message': 'deleted'}), 200));

      await backendService.deleteCrystal(testCrystalId);
      verify(mockClient.delete(expectedUri, headers: anyNamed('headers'))).called(1);
    });

    test('deleteCrystal throws exception if backend status is not success', () async {
      final expectedUri = Uri.parse('$baseUrl${BackendConfig.crystalsEndpoint}/$testCrystalId');
      when(mockClient.delete(
        expectedUri,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'status': 'error', 'message': 'failed for reasons'}), 200));

      expect(() => backendService.deleteCrystal(testCrystalId), throwsException);
    });
  });

  group('Auth methods', () {
    test('setAuth updates isAuthenticated and currentUserId', () {
      expect(backendService.isAuthenticated, isFalse);
      expect(backendService.currentUserId, isNull);
      backendService.setAuth("test_token", "user_123");
      expect(backendService.isAuthenticated, isTrue);
      expect(backendService.currentUserId, "user_123");
    });

    test('clearAuth resets isAuthenticated and currentUserId', () {
      backendService.setAuth("test_token", "user_123");
      backendService.clearAuth();
      expect(backendService.isAuthenticated, isFalse);
      expect(backendService.currentUserId, isNull);
    });

    test('_headers includes auth token when authenticated', () {
      backendService.setAuth("test_token", "user_123");
      // Verify by making a call and capturing headers
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{}', 200));
      await backendService.getUserCollection(); // Make any call that uses _headers

      final captured = verify(mockClient.get(any, headers: captureAnyNamed('headers'))).captured;
      final capturedHeaders = captured.first as Map<String,String>;
      expect(capturedHeaders['Authorization'], 'Bearer test_token');
    });

     test('_headers does not include auth token when not authenticated', () async {
      backendService.clearAuth(); // Ensure no auth token
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{}', 200));
      await backendService.getUserCollection();

      final captured = verify(mockClient.get(any, headers: captureAnyNamed('headers'))).captured;
      final capturedHeaders = captured.first as Map<String,String>;
      expect(capturedHeaders['Authorization'], isNull);
    });
  });

  group('BackendService getUsageStats', () {
    test('getUsageStats success returns stats map', () async {
      backendService.setAuth("test_token", "user_stats_test");
      final statsResponseJson = jsonEncode({'total_identifications': 10, 'collection_size': 5});
      final expectedUri = Uri.parse('$baseUrl${BackendConfig.usageEndpoint}/user_stats_test');

      when(mockClient.get(expectedUri, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(statsResponseJson, 200));

      final result = await backendService.getUsageStats();

      expect(result, isA<Map<String, dynamic>>());
      expect(result['total_identifications'], 10);
      verify(mockClient.get(expectedUri, headers: captureAnyNamed('headers'))).called(1);
    });

    test('getUsageStats throws if not authenticated', () async {
      backendService.clearAuth();
      expect(() => backendService.getUsageStats(),
        throwsA(predicate((e) => e is Exception && e.toString().contains('Authentication required'))));
    });
  });

  group('BackendService getPersonalizedGuidance', () {
    final guidanceParams = {
      'guidanceType': 'daily_focus',
      'userProfile': {'sun_sign': 'Leo', 'mood': 'adventurous'},
      'customPrompt': 'What should I focus on today?'
    };
    final successResponseJson = jsonEncode({'guidance': 'Focus on creativity!', 'source': 'llm'});

    test('getPersonalizedGuidance success returns guidance map', () async {
      backendService.setAuth("test_token", "user_guidance_test");
      final expectedUri = Uri.parse('$baseUrl/spiritual/guidance');

      // Mocking httpClient.send for StreamedRequest
      when(mockClient.send(any)).thenAnswer((_) async {
        // Simulate a streamed response
        final responseStream = http.StreamedResponse(
          Stream.value(utf8.encode(successResponseJson)), // Stream the JSON string bytes
          200,
          headers: {'content-type': 'application/json'},
        );
        return responseStream;
      });

      final result = await backendService.getPersonalizedGuidance(
        guidanceType: guidanceParams['guidanceType'] as String,
        userProfile: guidanceParams['userProfile'] as Map<String, dynamic>,
        customPrompt: guidanceParams['customPrompt'] as String,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['guidance'], 'Focus on creativity!');

      final VerificationResult capturedRequest = verify(mockClient.send(captureAny)).captured.single;
      final http.StreamedRequest actualRequest = capturedRequest.invocation.positionalArguments.first;
      expect(actualRequest.url, expectedUri);
      // Further verification of multipart fields would require more complex argument matching or capturing if possible.
    });

    test('getPersonalizedGuidance returns fallback on API error', () async {
       when(mockClient.send(any)).thenAnswer((_) async {
        final responseStream = http.StreamedResponse(Stream.value(utf8.encode("error")), 500);
        return responseStream;
      });

      final result = await backendService.getPersonalizedGuidance(
        guidanceType: 'daily', userProfile: {}, customPrompt: 'help'
      );
      expect(result['source'], 'fallback');
      expect(result['guidance'], isNotEmpty);
    });
  });

  // TODO: Add more error case tests for CRUD operations (400, 404, 500)
}

// Helper PlatformFile mock if not using a full mocking solution for it
// Note: Mockito can also generate mocks for classes like PlatformFile if needed via @GenerateMocks
class MockPlatformFile extends Mock implements PlatformFile {
  @override
  final String name;
  @override
  final String? path;
  final Uint8List? _bytes;

  MockPlatformFile({this.name = 'mock.jpg', this.path, Uint8List? bytes}) : _bytes = bytes;

  @override
  Future<Uint8List> readAsBytes() {
    return Future.value(_bytes ?? Uint8List(0));
  }
}

// Add a helper extension to access the private _headers for testing purposes if absolutely necessary
// This is generally not recommended but can be a workaround for testing private getters.
// extension BackendServiceTestExtension on BackendService {
//   Map<String, String> getAuthHeadersForTestingOnly() => _headers;
// }
