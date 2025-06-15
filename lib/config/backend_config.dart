class BackendConfig {
  // Temporarily disable unified backend to get core app working
  static const bool useBackend = false;
  static const bool useUnifiedDataService = false;
  
  // API Configuration
  static const String baseUrl = 'https://crystalgrimoire-production.web.app';
  static const String apiVersion = 'v3';
  
  // API Endpoints
  static const String identifyEndpoint = '/api/crystal/identify';
  static const String crystalsEndpoint = '/api/crystals';
  static const String usageEndpoint = '/api/usage';
  static const String guidanceEndpoint = '/api/guidance';
  
  // HTTP Configuration
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  
  // Feature flags
  static const bool enableCrystalIdentification = true;
  static const bool enablePersonalizedGuidance = true;
  static const bool enableMoonRituals = true;
  static const bool enableCrystalHealing = true;
  
  // Development flags
  static const bool enableDebugLogging = true;
  static const bool enableOfflineMode = true;
}