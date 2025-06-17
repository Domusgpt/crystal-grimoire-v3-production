import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Real Parserator API Integration Test
class ParseOperatorService {
  static const String _apiUrl = 'https://app-5108296280.us-central1.run.app/v1/parse';
  
  // Test without API key first (check if it works anonymously)
  Future<Map<String, dynamic>> testParseCrystalData({
    required String crystalDescription,
    Map<String, dynamic>? customSchema,
  }) async {
    final outputSchema = customSchema ?? {
      'name': 'string',
      'color': 'string',
      'primary_use': 'string',
      'chakra': 'string',
      'confidence': 'number',
      'metaphysical_properties': 'string_array',
    };

    try {
      print('🧪 Testing Parserator API...');
      print('📡 URL: $_apiUrl');
      print('📝 Input: $crystalDescription');
      print('📊 Schema: $outputSchema');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputData': crystalDescription,
          'outputSchema': outputSchema,
        }),
      );

      print('📈 Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📄 Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ SUCCESS: Parserator returned data');
        print('🎯 Parsed Result: $result');
        return result;
      } else {
        print('❌ ERROR: Status ${response.statusCode}');
        print('📄 Error Body: ${response.body}');
        return {
          'error': 'API returned status ${response.statusCode}',
          'response': response.body,
        };
      }
    } catch (e) {
      print('🚨 EXCEPTION: $e');
      return {
        'error': 'Exception occurred: $e',
      };
    }
  }

  /// Test with API key if needed
  Future<Map<String, dynamic>> testWithApiKey({
    required String crystalDescription,
    required String apiKey,
  }) async {
    try {
      print('🔐 Testing with API key...');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'inputData': crystalDescription,
          'outputSchema': {
            'name': 'string',
            'color': 'string',
            'primary_use': 'string',
            'chakra': 'string',
            'healing_properties': 'string_array',
            'zodiac_signs': 'string_array',
          },
        }),
      );

      print('📈 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'API returned status ${response.statusCode}',
          'response': response.body,
        };
      }
    } catch (e) {
      return {
        'error': 'Exception occurred: $e',
      };
    }
  }

  /// Test health endpoint
  Future<Map<String, dynamic>> testHealthEndpoint() async {
    try {
      print('🏥 Testing health endpoint...');
      final response = await http.get(
        Uri.parse('https://app-5108296280.us-central1.run.app/health'),
      );

      print('📈 Health Status: ${response.statusCode}');
      print('📄 Health Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Health check failed'};
      }
    } catch (e) {
      return {'error': 'Health check exception: $e'};
    }
  }
}

/// Test runner
void main() async {
  final parserator = ParseOperatorService();
  
  print('🚀 Starting Parserator Integration Tests\n');

  // Test 1: Health check
  print('=' * 50);
  print('TEST 1: Health Check');
  print('=' * 50);
  final healthResult = await parserator.testHealthEndpoint();
  print('Health Result: $healthResult\n');

  // Test 2: Basic crystal parsing
  print('=' * 50);
  print('TEST 2: Basic Crystal Parsing');
  print('=' * 50);
  final basicResult = await parserator.testParseCrystalData(
    crystalDescription: 'Amethyst - Purple crystal used for meditation and spiritual clarity',
  );
  print('Basic Result: $basicResult\n');

  // Test 3: Complex crystal data
  print('=' * 50);
  print('TEST 3: Complex Crystal Data');
  print('=' * 50);
  final complexResult = await parserator.testParseCrystalData(
    crystalDescription: '''
    Clear Quartz Crystal
    - Color: Transparent to translucent white
    - Size: 3 inches tall
    - Formation: Natural point formation
    - Uses: Amplification, healing, meditation
    - Chakras: All chakras, especially Crown
    - Zodiac: All signs
    - Properties: Master healer, amplifies energy of other crystals
    ''',
    customSchema: {
      'name': 'string',
      'color': 'string',
      'size': 'string',
      'formation': 'string',
      'primary_uses': 'string_array',
      'chakras': 'string_array',
      'zodiac_signs': 'string_array',
      'properties': 'string_array',
      'confidence': 'number',
    },
  );
  print('Complex Result: $complexResult\n');

  print('🏁 Tests completed!');
}