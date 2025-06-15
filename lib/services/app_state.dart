import 'package:flutter/foundation.dart';
import '../models/crystal.dart';
import '../utils/model_converter.dart';
import 'usage_tracker.dart';
import 'cache_service.dart';
import 'collection_service_v2.dart';

/// Global app state management using Provider
class AppState extends ChangeNotifier {
  // User data
  String _subscriptionTier = 'free';
  bool _isFirstLaunch = true;
  bool _hasSeenOnboarding = false;
  
  // Collection service reference
  CollectionServiceV2? _collectionService;
  
  // Recent identifications
  final List<CrystalIdentification> _recentIdentifications = [];
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  String _loadingMessage = 'Connecting to the crystal realm...';
  
  // Usage tracking
  UsageStats? _usageStats;
  
  // Settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _preferredLanguage = 'en';
  
  // Feature integration data
  Map<String, int> _chakraCoverage = {};
  List<Crystal> _recommendedCrystals = [];
  
  // Getters
  String get subscriptionTier => _subscriptionTier;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  List<Crystal> get crystalCollection => _collectionService?.collection
      .map((entry) => ModelConverter.unifiedToCrystal(entry)).toList() ?? [];
  List<CrystalIdentification> get recentIdentifications => 
      List.unmodifiable(_recentIdentifications);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get loadingMessage => _loadingMessage;
  UsageStats? get usageStats => _usageStats;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  String get preferredLanguage => _preferredLanguage;
  Map<String, int> get chakraCoverage => Map.unmodifiable(_chakraCoverage);
  List<Crystal> get recommendedCrystals => List.unmodifiable(_recommendedCrystals);
  
  // Computed properties
  bool get isPremiumUser => _subscriptionTier != 'free';
  bool get canIdentify => _usageStats?.canIdentify ?? true;
  int get collectionCount => _collectionService?.collection.length ?? 0;
  Crystal? get favoritesCrystal => crystalCollection.isNotEmpty ? 
      crystalCollection.first : null;
  
  // Missing properties for HomeScreen
  List<Crystal> get userCrystals => crystalCollection;
  Map<String, int> get currentMonthUsage => {
    'identifications': _usageStats?.monthlyUsage ?? 0,
    'journal_entries': 0, // TODO: Implement journal tracking
  };
  int get monthlyLimit => _usageStats?.monthlyLimit ?? 10;
  
  /// Set collection service reference
  void setCollectionService(CollectionServiceV2 collectionService) {
    _collectionService = collectionService;
    // Listen to collection changes
    _collectionService?.addListener(() {
      notifyListeners();
    });
  }
  
  /// Initialize app state on startup
  Future<void> initialize() async {
    setLoading(true, 'Initializing Crystal Grimoire...');
    
    try {
      // Load user subscription tier
      _subscriptionTier = await UsageTracker.getCurrentSubscriptionTier();
      
      // Load usage statistics
      _usageStats = await UsageTracker.getUsageStats();
      
      // Load recent identifications
      await _loadRecentIdentifications();
      
      // Check first launch
      await _checkFirstLaunch();
      
      // Setup feature integration
      _setupFeatureIntegration();
      
      setLoading(false);
      
    } catch (e) {
      setError('Failed to initialize app: $e');
    }
  }
  
  /// Setup cross-feature integration
  void _setupFeatureIntegration() {
    // Link collection changes to other features
    _collectionService?.addListener(_onCollectionChanged);
  }
  
  /// Handle collection changes and update related features
  void _onCollectionChanged() {
    // Update chakra coverage when collection changes
    _updateChakraCoverage();
    
    // Update crystal recommendations
    _updateRecommendations();
    
    // Notify all dependent features
    notifyListeners();
  }
  
  /// Update chakra coverage based on collection
  void _updateChakraCoverage() {
    if (_collectionService == null) return;
    
    final collection = _collectionService!.collection;
    final chakras = ['Root', 'Sacral', 'Solar Plexus', 'Heart', 'Throat', 'Third Eye', 'Crown'];
    
    _chakraCoverage = {};
    for (final chakra in chakras) {
      final crystalsForChakra = collection.where((entry) => 
        entry.crystalCore.dynamicMetaphysicalProperties.primaryChakras.contains(chakra)
      ).length;
      _chakraCoverage[chakra] = crystalsForChakra;
    }
  }
  
  /// Update crystal recommendations based on collection and needs
  void _updateRecommendations() {
    if (_collectionService == null) return;
    
    // Update recommendations to exclude already owned crystals
    // This will be used by guidance and healing features
    notifyListeners();
  }
  
  /// Updates subscription tier
  Future<void> updateSubscriptionTier(String tier) async {
    _subscriptionTier = tier;
    await UsageTracker.updateSubscriptionTier(tier);
    _usageStats = await UsageTracker.getUsageStats();
    notifyListeners();
  }
  
  /// Adds a crystal to the collection
  Future<void> addCrystal(Crystal crystal) async {
    if (_collectionService != null) {
      final unifiedData = ModelConverter.crystalToUnified(crystal);
      await _collectionService!.addCrystal(unifiedData);
      // notifyListeners will be called automatically through the collection service listener
    }
  }
  
  /// Removes a crystal from the collection
  Future<void> removeCrystal(String crystalId) async {
    if (_collectionService != null) {
      await _collectionService!.removeCrystal(crystalId);
      // notifyListeners will be called automatically through the collection service listener
    }
  }
  
  /// Updates a crystal in the collection
  Future<void> updateCrystal(Crystal updatedCrystal) async {
    if (_collectionService != null) {
      // Update using collection service directly
      await _collectionService!.updateCrystal(ModelConverter.crystalToUnified(updatedCrystal));
      // notifyListeners will be called automatically through the collection service listener
    }
  }
  
  /// Adds a recent identification
  void addRecentIdentification(CrystalIdentification identification) {
    _recentIdentifications.insert(0, identification);
    
    // Keep only the most recent 20 identifications
    if (_recentIdentifications.length > 20) {
      _recentIdentifications.removeRange(20, _recentIdentifications.length);
    }
    
    _saveRecentIdentifications();
    notifyListeners();
  }
  
  /// Refreshes usage statistics
  Future<void> refreshUsageStats() async {
    _usageStats = await UsageTracker.getUsageStats();
    notifyListeners();
  }
  
  /// Increments usage for a specific feature
  Future<void> incrementUsage(String feature) async {
    try {
      await UsageTracker.incrementUsage(feature);
      _usageStats = await UsageTracker.getUsageStats();
      notifyListeners();
    } catch (e) {
      print('Failed to increment usage for $feature: $e');
    }
  }
  
  /// Sets loading state
  void setLoading(bool loading, [String? message]) {
    _isLoading = loading;
    if (message != null) {
      _loadingMessage = message;
    }
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Sets error state
  void setError(String error) {
    _isLoading = false;
    _errorMessage = error;
    notifyListeners();
  }
  
  /// Clears error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Marks onboarding as completed
  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    _isFirstLaunch = false;
    // Save to preferences
    notifyListeners();
  }
  
  /// Updates notification settings
  Future<void> updateNotificationSettings(bool enabled) async {
    _notificationsEnabled = enabled;
    // Save to preferences
    notifyListeners();
  }
  
  /// Updates sound settings
  Future<void> updateSoundSettings(bool enabled) async {
    _soundEnabled = enabled;
    // Save to preferences
    notifyListeners();
  }
  
  /// Updates preferred language
  Future<void> updateLanguage(String languageCode) async {
    _preferredLanguage = languageCode;
    // Save to preferences
    notifyListeners();
  }
  
  /// Gets crystals by category/type
  List<Crystal> getCrystalsByType(String type) {
    return crystalCollection
        .where((crystal) => crystal.name.toLowerCase().contains(type.toLowerCase()))
        .toList();
  }
  
  /// Gets crystals by chakra association
  List<Crystal> getCrystalsByChakra(ChakraAssociation chakra) {
    return crystalCollection
        .where((crystal) => crystal.chakras.contains(chakra))
        .toList();
  }
  
  /// Searches crystals by name or properties
  List<Crystal> searchCrystals(String query) {
    if (_collectionService != null) {
      final searchResults = _collectionService!.searchCrystals(query);
      return searchResults.map((entry) => ModelConverter.unifiedToCrystal(entry)).toList();
    }
    return [];
  }
  
  /// Gets cache statistics
  Future<CacheStats> getCacheStats() async {
    return await CacheService.getCacheStats();
  }
  
  /// Clears all cached data
  Future<void> clearCache() async {
    await CacheService.clearAllCache();
    notifyListeners();
  }
  
  // Private helper methods
  
  Future<void> _loadRecentIdentifications() async {
    // TODO: Load from local storage
  }
  
  Future<void> _saveRecentIdentifications() async {
    // TODO: Save to local storage
  }
  
  Future<void> _checkFirstLaunch() async {
    // TODO: Check SharedPreferences for first launch
    _isFirstLaunch = false; // For now
    _hasSeenOnboarding = true; // For now
  }
  
  // Model conversion methods are now handled by ModelConverter utility class
  // This provides a centralized, tested, and comprehensive conversion system
}

/// Extension methods for convenient access
extension AppStateExtensions on AppState {
  /// Checks if user can access premium features
  bool canAccessPremiumFeature(String featureName) {
    if (isPremiumUser) return true;
    
    // Free users might have preview access
    // This would be checked against UsageTracker
    return false;
  }
  
  /// Gets upgrade prompt message
  String? getUpgradePrompt() {
    if (isPremiumUser) return null;
    
    if (_usageStats != null && !_usageStats!.canIdentify) {
      return 'Unlock unlimited crystal identifications with Premium!';
    }
    
    if (collectionCount >= 5) {
      return 'Growing collection! Upgrade to Premium for unlimited storage and spiritual guidance.';
    }
    
    return null;
  }
  
  /// Formats usage stats for display
  String getUsageDescription() {
    if (_usageStats == null) return 'Loading...';
    
    if (isPremiumUser) {
      return 'Unlimited identifications • ${_usageStats!.tierDisplayName}';
    }
    
    final remaining = _usageStats!.remainingThisMonth;
    final total = _usageStats!.monthlyLimit;
    
    return '$remaining of $total identifications remaining this month';
  }
  
  /// Gets personalized greeting
  String getPersonalizedGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting;
    
    if (hour < 6) {
      timeGreeting = 'Good night';
    } else if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else if (hour < 21) {
      timeGreeting = 'Good evening';
    } else {
      timeGreeting = 'Good night';
    }
    
    if (collectionCount == 0) {
      return '$timeGreeting, beloved seeker! Ready to discover your first crystal?';
    } else if (collectionCount == 1) {
      return '$timeGreeting! Your crystal journey has begun beautifully.';
    } else {
      return '$timeGreeting, crystal keeper! Your collection of $collectionCount crystals awaits.';
    }
  }
}