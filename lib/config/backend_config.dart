import 'package:http/http.dart' as http;

/// Backend API Configuration for CrystalGrimoire
class BackendConfig {
  // Environment-based backend URL configuration
  static const bool _isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const String _customBackendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');
  
  // Backend API URL - Environment based
  static String get baseUrl {
    if (_customBackendUrl.isNotEmpty) {
      return '$_customBackendUrl/api';
    }
    
    return _isProduction 
      ? 'https://crystalgrimoire-production.web.app/api'
      : 'http://localhost:5001/crystalgrimoire-production/us-central1/api';
  }
  
  // Use backend API - now enabled by default
  static const bool useBackend = true;
  
  // Environment-based backend forcing
  static bool get forceBackendIntegration => 
    const bool.fromEnvironment('FORCE_BACKEND', defaultValue: false);
  
  // API Endpoints
  static const String identifyEndpoint = '/crystal/identify';
  static const String crystalsEndpoint = '/crystals';
  static const String guidanceEndpoint = '/guidance/personalized';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  
  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // Check if backend is available
  static Future<bool> isBackendAvailable() async {
    if (!useBackend) return false;
    
    try {
      final healthUrl = baseUrl.replaceAll('/api', '') + '/health';
      final response = await http.get(
        Uri.parse(healthUrl),
        headers: headers,
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Backend not available at $baseUrl: $e');
      return false;
    }
  }
  
  // Get configuration summary
  static Map<String, dynamic> getConfigSummary() {
    return {
      'base_url': baseUrl,
      'is_production': _isProduction,
      'use_backend': useBackend,
      'endpoints': {
        'identify': '$baseUrl$identifyEndpoint',
        'crystals': '$baseUrl$crystalsEndpoint',
        'guidance': '$baseUrl$guidanceEndpoint',
      }
    };
  }
}
