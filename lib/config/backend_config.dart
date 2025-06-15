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
      : 'http://localhost:8081/api';
  }
  
  // Use backend API if available, otherwise use direct AI
  static const bool useBackend = false; // Temporarily disabled for deployment
  
  // Environment-based backend forcing
  static bool get forceBackendIntegration => 
    const bool.fromEnvironment('FORCE_BACKEND', defaultValue: false);
  
  // API Endpoints
  static const String identifyEndpoint = '/crystal/identify'; // POST for UnifiedCrystalData
  static const String crystalsEndpoint = '/crystals'; // Base for CRUD UnifiedCrystalData
  // Old endpoints, potentially to be removed or refactored if CollectionEntry is fully deprecated
  static const String oldCollectionEndpoint = '/crystal/collection';
  static const String oldSaveEndpoint = '/crystal/save';
  static const String usageEndpoint = '/usage';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  
  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    // Add auth headers when implemented
  };
  
  // Check if backend is available
  static Future<bool> isBackendAvailable() async {
    if (!useBackend) return false;
    
    try {
      final healthUrl = baseUrl.replaceAll('/api', '/health');
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
      'custom_backend_url': _customBackendUrl.isNotEmpty ? 'configured' : 'not_set',
      'use_backend': useBackend,
      'force_backend': forceBackendIntegration,
      'endpoints': {
        'identify': '$baseUrl$identifyEndpoint',
        'crystals': '$baseUrl$crystalsEndpoint',
        'old_collection': '$baseUrl$oldCollectionEndpoint',
        'old_save': '$baseUrl$oldSaveEndpoint',
        'usage': '$baseUrl$usageEndpoint',
      }
    };
  }
}