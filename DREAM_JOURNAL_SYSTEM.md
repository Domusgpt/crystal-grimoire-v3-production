# Dream Journal System

## Overview
The Dream Journal System provides comprehensive dream tracking with crystal correlation analysis, astrological influences, and AI-powered interpretation. This system recognizes the profound connection between dreams, crystals placed near the bed, and lunar/planetary energies.

## System Location
**File Location**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireV3/DREAM_JOURNAL_SYSTEM.md`
**Working Directory**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireV3/`

## Core Dream Data Model

### Dream Entry Structure
```dart
class DreamEntry {
  final String id;
  final String userId;
  final DateTime dreamDate;
  final TimeOfDay sleepTime;
  final TimeOfDay wakeTime;
  final String title;
  final String content;
  final DreamType type;
  final LucidityLevel lucidity;
  final EmotionalTone emotionalTone;
  final List<String> themes;
  final List<String> symbols;
  final List<String> people;
  final List<String> locations;
  final List<Crystal> crystalsPresent;
  final MoonPhase moonPhase;
  final Map<String, double> planetaryPositions;
  final DreamClarity clarity;
  final List<String> colors;
  final String? interpretation;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Crystal correlations
  final Map<String, double> crystalInfluenceScores;
  final List<String> recommendedCrystals;
  
  // Recurring patterns
  final List<String> recurringElements;
  final String? seriesId; // Links dreams in a series
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'dreamDate': dreamDate.toIso8601String(),
    'sleepTime': '${sleepTime.hour}:${sleepTime.minute}',
    'wakeTime': '${wakeTime.hour}:${wakeTime.minute}',
    'title': title,
    'content': content,
    'type': type.toString(),
    'lucidity': lucidity.value,
    'emotionalTone': emotionalTone.toString(),
    'themes': themes,
    'symbols': symbols,
    'people': people,
    'locations': locations,
    'crystalsPresent': crystalsPresent.map((c) => c.id).toList(),
    'moonPhase': moonPhase.toString(),
    'planetaryPositions': planetaryPositions,
    'clarity': clarity.value,
    'colors': colors,
    'interpretation': interpretation,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'crystalInfluenceScores': crystalInfluenceScores,
    'recommendedCrystals': recommendedCrystals,
    'recurringElements': recurringElements,
    'seriesId': seriesId,
  };
}
```

### Dream Categories and Types
```dart
enum DreamType {
  normal('Normal Dream'),
  lucid('Lucid Dream'),
  nightmare('Nightmare'),
  recurring('Recurring Dream'),
  prophetic('Prophetic Dream'),
  healing('Healing Dream'),
  visitation('Visitation Dream'),
  astralProjection('Astral Projection'),
  symbolic('Symbolic Dream'),
  precognitive('Precognitive Dream');
  
  final String displayName;
  const DreamType(this.displayName);
}

enum LucidityLevel {
  none(0, 'No Lucidity'),
  slight(1, 'Slight Awareness'),
  moderate(2, 'Moderate Control'),
  high(3, 'High Control'),
  full(4, 'Full Lucidity');
  
  final int value;
  final String description;
  const LucidityLevel(this.value, this.description);
}

enum EmotionalTone {
  peaceful('Peaceful'),
  joyful('Joyful'),
  anxious('Anxious'),
  fearful('Fearful'),
  sad('Sad'),
  angry('Angry'),
  confused('Confused'),
  empowered('Empowered'),
  neutral('Neutral'),
  mixed('Mixed');
  
  final String displayName;
  const EmotionalTone(this.displayName);
}
```

## Crystal Dream Correlation Engine

### Crystal Influence Analysis
```dart
class CrystalDreamCorrelation {
  static Future<Map<Crystal, DreamInfluence>> analyzeCrystalInfluence({
    required DreamEntry dream,
    required List<Crystal> crystalsPresent,
  }) async {
    final influences = <Crystal, DreamInfluence>{};
    
    for (final crystal in crystalsPresent) {
      final influence = await _calculateCrystalInfluence(crystal, dream);
      influences[crystal] = influence;
    }
    
    return influences;
  }
  
  static Future<DreamInfluence> _calculateCrystalInfluence(
    Crystal crystal,
    DreamEntry dream
  ) async {
    double influenceScore = 0.0;
    final influences = <String>[];
    
    // Check if crystal properties match dream themes
    final crystalProperties = crystal.comprehensiveData.metaphysicalProperties;
    
    // Dream recall enhancement crystals
    if (_isDreamRecallCrystal(crystal)) {
      influenceScore += 0.3;
      influences.add('Enhanced dream recall');
    }
    
    // Lucid dreaming crystals
    if (_isLucidDreamingCrystal(crystal) && dream.lucidity.value > 0) {
      influenceScore += 0.4;
      influences.add('Promoted lucid awareness');
    }
    
    // Protection crystals for nightmares
    if (_isProtectionCrystal(crystal) && dream.type == DreamType.nightmare) {
      influenceScore += 0.2;
      influences.add('Provided protection (nightmare still occurred)');
    } else if (_isProtectionCrystal(crystal) && dream.type != DreamType.nightmare) {
      influenceScore += 0.5;
      influences.add('Successfully prevented nightmares');
    }
    
    // Prophetic/psychic crystals
    if (_isPsychicCrystal(crystal) && 
        [DreamType.prophetic, DreamType.precognitive].contains(dream.type)) {
      influenceScore += 0.6;
      influences.add('Enhanced prophetic abilities');
    }
    
    // Emotional influence based on crystal chakra
    final emotionalInfluence = _analyzeEmotionalInfluence(
      crystal.automationData.chakra.primary,
      dream.emotionalTone
    );
    influenceScore += emotionalInfluence.score;
    influences.add(emotionalInfluence.description);
    
    // Color correlation
    if (dream.colors.any((color) => 
        color.toLowerCase() == crystal.automationData.color.primary.toLowerCase())) {
      influenceScore += 0.2;
      influences.add('Crystal color appeared in dream');
    }
    
    return DreamInfluence(
      crystal: crystal,
      influenceScore: influenceScore.clamp(0.0, 1.0),
      influences: influences,
      recommendedPlacement: _getOptimalPlacement(crystal, dream),
    );
  }
  
  static bool _isDreamRecallCrystal(Crystal crystal) {
    final dreamRecallCrystals = [
      'Amethyst', 'Clear Quartz', 'Moonstone', 'Labradorite',
      'Azurite', 'Jade', 'Prehnite', 'Scolecite'
    ];
    
    return dreamRecallCrystals.any((name) => 
      crystal.identification.name.toLowerCase().contains(name.toLowerCase())
    );
  }
  
  static bool _isLucidDreamingCrystal(Crystal crystal) {
    final lucidCrystals = [
      'Moldavite', 'Herkimer Diamond', 'Ametrine', 'Lepidolite',
      'Blue Kyanite', 'Angelite', 'Celestite', 'Danburite'
    ];
    
    return lucidCrystals.any((name) => 
      crystal.identification.name.toLowerCase().contains(name.toLowerCase())
    );
  }
  
  static bool _isProtectionCrystal(Crystal crystal) {
    final protectionCrystals = [
      'Black Tourmaline', 'Obsidian', 'Smoky Quartz', 'Hematite',
      'Black Onyx', 'Shungite', 'Pyrite', 'Jet'
    ];
    
    return protectionCrystals.any((name) => 
      crystal.identification.name.toLowerCase().contains(name.toLowerCase())
    );
  }
}
```

### Dream Pattern Recognition
```dart
class DreamPatternAnalyzer {
  static Future<DreamPatterns> analyzePatterns({
    required String userId,
    required Duration timeframe,
  }) async {
    final dreams = await _getUserDreams(userId, timeframe);
    
    return DreamPatterns(
      recurringSymbols: _findRecurringSymbols(dreams),
      recurringThemes: _findRecurringThemes(dreams),
      crystalCorrelations: await _analyzeCrystalPatterns(dreams),
      lunarPatterns: _analyzeLunarPatterns(dreams),
      emotionalPatterns: _analyzeEmotionalPatterns(dreams),
      predictivePatterns: _findPredictivePatterns(dreams),
    );
  }
  
  static Map<String, RecurringPattern> _findRecurringSymbols(List<DreamEntry> dreams) {
    final symbolCount = <String, int>{};
    final symbolContexts = <String, List<String>>{};
    
    for (final dream in dreams) {
      for (final symbol in dream.symbols) {
        symbolCount[symbol] = (symbolCount[symbol] ?? 0) + 1;
        symbolContexts.putIfAbsent(symbol, () => []).add(dream.id);
      }
    }
    
    final patterns = <String, RecurringPattern>{};
    
    symbolCount.forEach((symbol, count) {
      if (count >= 3) { // Symbol appears in 3+ dreams
        patterns[symbol] = RecurringPattern(
          element: symbol,
          frequency: count,
          percentage: (count / dreams.length * 100),
          dreamIds: symbolContexts[symbol]!,
          significance: _calculateSymbolSignificance(symbol, count, dreams),
        );
      }
    });
    
    return patterns;
  }
  
  static Future<Map<Crystal, CrystalDreamPattern>> _analyzeCrystalPatterns(
    List<DreamEntry> dreams
  ) async {
    final crystalPatterns = <Crystal, CrystalDreamPattern>{};
    
    // Group dreams by crystals present
    final crystalDreams = <String, List<DreamEntry>>{};
    
    for (final dream in dreams) {
      for (final crystal in dream.crystalsPresent) {
        crystalDreams.putIfAbsent(crystal.id, () => []).add(dream);
      }
    }
    
    // Analyze patterns for each crystal
    for (final entry in crystalDreams.entries) {
      final crystalId = entry.key;
      final crystalDreamList = entry.value;
      
      if (crystalDreamList.length >= 2) {
        final crystal = crystalDreamList.first.crystalsPresent
          .firstWhere((c) => c.id == crystalId);
        
        crystalPatterns[crystal] = CrystalDreamPattern(
          crystal: crystal,
          dreamCount: crystalDreamList.length,
          averageLucidity: _calculateAverageLucidity(crystalDreamList),
          commonThemes: _extractCommonThemes(crystalDreamList),
          emotionalImpact: _analyzeEmotionalImpact(crystalDreamList),
          dreamTypeDistribution: _analyzeDreamTypes(crystalDreamList),
          effectiveness: _calculateCrystalEffectiveness(crystal, crystalDreamList),
        );
      }
    }
    
    return crystalPatterns;
  }
}
```

## AI-Powered Dream Interpretation

### Dream Interpretation Engine
```dart
class DreamInterpreter {
  static Future<DreamInterpretation> interpretDream({
    required DreamEntry dream,
    required UserProfile user,
    required List<DreamEntry> recentDreams,
  }) async {
    // Build comprehensive context
    final context = await _buildInterpretationContext(dream, user, recentDreams);
    
    // Generate interpretation using AI
    final prompt = _createInterpretationPrompt(dream, context);
    final interpretation = await AIService.generateDreamInterpretation(prompt);
    
    // Extract actionable insights
    final insights = _extractInsights(interpretation, dream, user);
    
    // Recommend crystals for future dreams
    final crystalRecommendations = await _recommendCrystals(dream, interpretation);
    
    return DreamInterpretation(
      dreamId: dream.id,
      interpretation: interpretation,
      symbols: _interpretSymbols(dream.symbols, context),
      personalInsights: insights,
      crystalRecommendations: crystalRecommendations,
      archetypes: _identifyArchetypes(dream),
      spiritualGuidance: _generateSpiritualGuidance(dream, user),
      actionSteps: _generateActionSteps(interpretation, insights),
      relatedDreams: _findRelatedDreams(dream, recentDreams),
    );
  }
  
  static String _createInterpretationPrompt(
    DreamEntry dream,
    Map<String, dynamic> context
  ) {
    return '''
    Interpret this dream using Jungian psychology, spiritual wisdom, and crystal healing knowledge.
    
    DREAMER PROFILE:
    - Birth Chart: ${context['birthChart']['sunSign']} Sun, ${context['birthChart']['moonSign']} Moon
    - Current Life Phase: ${context['currentLifePhase']}
    - Spiritual Goals: ${context['spiritualGoals']}
    
    DREAM DETAILS:
    - Date: ${dream.dreamDate} (${dream.moonPhase} moon)
    - Type: ${dream.type.displayName}
    - Lucidity: ${dream.lucidity.description}
    - Emotional Tone: ${dream.emotionalTone.displayName}
    
    DREAM CONTENT:
    ${dream.content}
    
    SYMBOLS PRESENT: ${dream.symbols.join(', ')}
    THEMES: ${dream.themes.join(', ')}
    COLORS: ${dream.colors.join(', ')}
    
    CRYSTALS NEAR BED: ${dream.crystalsPresent.map((c) => c.identification.name).join(', ')}
    
    RECENT PATTERNS:
    - Recurring symbols: ${context['recurringSymbols']}
    - Emotional trends: ${context['emotionalTrends']}
    
    Provide:
    1. Core interpretation of the dream's meaning
    2. Personal insights based on their birth chart
    3. Spiritual/psychological significance
    4. How the crystals present may have influenced the dream
    5. Actionable guidance for waking life
    6. Crystal recommendations for future dreams
    ''';
  }
  
  static Map<String, SymbolInterpretation> _interpretSymbols(
    List<String> symbols,
    Map<String, dynamic> context
  ) {
    final interpretations = <String, SymbolInterpretation>{};
    
    for (final symbol in symbols) {
      interpretations[symbol] = SymbolInterpretation(
        symbol: symbol,
        universalMeaning: SymbolDictionary.getUniversalMeaning(symbol),
        personalMeaning: _getPersonalMeaning(symbol, context),
        culturalContext: _getCulturalContext(symbol, context['culture']),
        spiritualSignificance: _getSpiritualSignificance(symbol),
        relatedCrystals: _getCrystalsForSymbol(symbol),
      );
    }
    
    return interpretations;
  }
}
```

### Symbol Dictionary
```dart
class SymbolDictionary {
  static const Map<String, UniversalSymbolMeaning> symbols = {
    'water': UniversalSymbolMeaning(
      element: 'water',
      meanings: [
        'Emotions and feelings',
        'The unconscious mind',
        'Purification and cleansing',
        'Flow and adaptability',
        'Spiritual rebirth'
      ],
      chakras: ['sacral', 'heart'],
      crystals: ['Aquamarine', 'Moonstone', 'Blue Lace Agate', 'Larimar'],
      jungianArchetype: 'The Unconscious, The Mother'
    ),
    
    'flying': UniversalSymbolMeaning(
      element: 'air',
      meanings: [
        'Freedom and liberation',
        'Rising above problems',
        'Spiritual ascension',
        'New perspectives',
        'Escaping limitations'
      ],
      chakras: ['throat', 'third_eye', 'crown'],
      crystals: ['Angelite', 'Celestite', 'Clear Quartz', 'Selenite'],
      jungianArchetype: 'The Self, Transcendence'
    ),
    
    'snake': UniversalSymbolMeaning(
      element: 'earth',
      meanings: [
        'Transformation and rebirth',
        'Hidden wisdom',
        'Healing and medicine',
        'Kundalini energy',
        'Primal life force'
      ],
      chakras: ['root', 'sacral'],
      crystals: ['Serpentine', 'Malachite', 'Snake Skin Agate', 'Shiva Lingam'],
      jungianArchetype: 'The Shadow, Transformation'
    ),
    
    'death': UniversalSymbolMeaning(
      element: 'all',
      meanings: [
        'End of a cycle',
        'Transformation',
        'Letting go of the old',
        'Spiritual rebirth',
        'Major life change'
      ],
      chakras: ['root', 'crown'],
      crystals: ['Black Obsidian', 'Apache Tear', 'Jet', 'Smoky Quartz'],
      jungianArchetype: 'Death and Rebirth, The Shadow'
    )
  };
  
  static String getUniversalMeaning(String symbol) {
    final symbolLower = symbol.toLowerCase();
    
    if (symbols.containsKey(symbolLower)) {
      return symbols[symbolLower]!.meanings.join('; ');
    }
    
    // Use AI for symbols not in dictionary
    return 'Unique personal symbol - requires individual interpretation';
  }
}
```

## Dream Journal Features

### Dream Entry Interface
```dart
class DreamJournalService {
  static Future<DreamEntry> createDreamEntry({
    required String userId,
    required DateTime dreamDate,
    required String content,
    required List<String> crystalIds,
    Map<String, dynamic>? additionalData,
  }) async {
    // Get current astrological data
    final moonPhase = MoonPhaseCalculator.getPhaseForDate(dreamDate);
    final planetaryPositions = await AstrologyService.getPlanetaryPositions(dreamDate);
    
    // Get crystals that were present
    final crystals = await _getCrystalsByIds(crystalIds);
    
    // Auto-extract dream elements using AI
    final extractedElements = await _extractDreamElements(content);
    
    // Create dream entry
    final dream = DreamEntry(
      id: Uuid().v4(),
      userId: userId,
      dreamDate: dreamDate,
      sleepTime: additionalData?['sleepTime'] ?? TimeOfDay(hour: 22, minute: 0),
      wakeTime: additionalData?['wakeTime'] ?? TimeOfDay(hour: 7, minute: 0),
      title: additionalData?['title'] ?? _generateTitle(content),
      content: content,
      type: additionalData?['type'] ?? DreamType.normal,
      lucidity: additionalData?['lucidity'] ?? LucidityLevel.none,
      emotionalTone: extractedElements.emotionalTone,
      themes: extractedElements.themes,
      symbols: extractedElements.symbols,
      people: extractedElements.people,
      locations: extractedElements.locations,
      crystalsPresent: crystals,
      moonPhase: moonPhase,
      planetaryPositions: planetaryPositions,
      clarity: additionalData?['clarity'] ?? DreamClarity.moderate,
      colors: extractedElements.colors,
      tags: additionalData?['tags'] ?? [],
      createdAt: DateTime.now(),
      crystalInfluenceScores: {},
      recommendedCrystals: [],
      recurringElements: [],
    );
    
    // Save to database
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('dreams')
      .doc(dream.id)
      .set(dream.toJson());
    
    // Analyze crystal influences
    final influences = await CrystalDreamCorrelation.analyzeCrystalInfluence(
      dream: dream,
      crystalsPresent: crystals,
    );
    
    // Update dream with analysis
    await _updateDreamWithAnalysis(dream.id, userId, influences);
    
    // Check for patterns
    await _checkForPatterns(userId, dream);
    
    return dream;
  }
  
  static Future<ExtractedDreamElements> _extractDreamElements(String content) async {
    final prompt = '''
    Extract the following elements from this dream narrative:
    1. Main themes (e.g., transformation, fear, love, journey)
    2. Symbols (e.g., water, animals, objects with significance)
    3. People (relationships: mother, friend, stranger, etc.)
    4. Locations (e.g., childhood home, forest, ocean)
    5. Colors mentioned or prominent
    6. Overall emotional tone
    
    Dream content: $content
    
    Return as structured JSON.
    ''';
    
    final response = await AIService.extractDreamElements(prompt);
    return ExtractedDreamElements.fromJson(response);
  }
}
```

### Dream Search and Filtering
```dart
class DreamSearchService {
  static Future<List<DreamEntry>> searchDreams({
    required String userId,
    String? searchTerm,
    List<String>? symbols,
    List<String>? themes,
    DateTimeRange? dateRange,
    List<DreamType>? types,
    List<String>? crystalIds,
    MoonPhase? moonPhase,
    EmotionalTone? emotionalTone,
    LucidityLevel? minLucidity,
  }) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('dreams');
    
    // Apply filters
    if (dateRange != null) {
      query = query
        .where('dreamDate', isGreaterThanOrEqualTo: dateRange.start.toIso8601String())
        .where('dreamDate', isLessThanOrEqualTo: dateRange.end.toIso8601String());
    }
    
    if (types != null && types.isNotEmpty) {
      query = query.where('type', whereIn: types.map((t) => t.toString()).toList());
    }
    
    if (moonPhase != null) {
      query = query.where('moonPhase', isEqualTo: moonPhase.toString());
    }
    
    if (emotionalTone != null) {
      query = query.where('emotionalTone', isEqualTo: emotionalTone.toString());
    }
    
    final querySnapshot = await query.get();
    var dreams = querySnapshot.docs.map((doc) => 
      DreamEntry.fromJson(doc.data())
    ).toList();
    
    // Client-side filtering for complex queries
    if (searchTerm != null && searchTerm.isNotEmpty) {
      dreams = dreams.where((dream) =>
        dream.content.toLowerCase().contains(searchTerm.toLowerCase()) ||
        dream.title.toLowerCase().contains(searchTerm.toLowerCase())
      ).toList();
    }
    
    if (symbols != null && symbols.isNotEmpty) {
      dreams = dreams.where((dream) =>
        symbols.any((symbol) => dream.symbols.contains(symbol))
      ).toList();
    }
    
    if (themes != null && themes.isNotEmpty) {
      dreams = dreams.where((dream) =>
        themes.any((theme) => dream.themes.contains(theme))
      ).toList();
    }
    
    if (crystalIds != null && crystalIds.isNotEmpty) {
      dreams = dreams.where((dream) =>
        crystalIds.any((id) => dream.crystalsPresent.any((c) => c.id == id))
      ).toList();
    }
    
    if (minLucidity != null) {
      dreams = dreams.where((dream) =>
        dream.lucidity.value >= minLucidity.value
      ).toList();
    }
    
    return dreams;
  }
}
```

### Dream Statistics and Insights
```dart
class DreamStatistics {
  static Future<DreamInsights> generateInsights({
    required String userId,
    required Duration timeframe,
  }) async {
    final dreams = await _getUserDreams(userId, timeframe);
    
    return DreamInsights(
      totalDreams: dreams.length,
      averageDreamsPerWeek: dreams.length / (timeframe.inDays / 7),
      
      // Dream type distribution
      dreamTypeDistribution: _calculateTypeDistribution(dreams),
      
      // Lucidity progression
      lucidityProgression: _analyzeLucidityProgression(dreams),
      averageLucidity: _calculateAverageLucidity(dreams),
      
      // Emotional patterns
      emotionalDistribution: _calculateEmotionalDistribution(dreams),
      emotionalTrends: _analyzeEmotionalTrends(dreams),
      
      // Crystal effectiveness
      crystalEffectiveness: await _analyzeCrystalEffectiveness(dreams),
      mostEffectiveCrystals: await _findMostEffectiveCrystals(dreams),
      
      // Symbol frequency
      topSymbols: _findTopSymbols(dreams),
      symbolEvolution: _analyzeSymbolEvolution(dreams),
      
      // Moon phase correlation
      moonPhaseDistribution: _analyzeMoonPhaseDistribution(dreams),
      mostActiveMoonPhase: _findMostActiveMoonPhase(dreams),
      
      // Predictive patterns
      predictiveDreams: _identifyPredictiveDreams(dreams),
      accuracyRate: await _calculatePredictiveAccuracy(dreams),
      
      // Recommendations
      recommendedCrystals: await _recommendCrystalsBasedOnPatterns(dreams),
      suggestedPractices: _suggestDreamPractices(dreams),
    );
  }
  
  static Map<DreamType, double> _calculateTypeDistribution(List<DreamEntry> dreams) {
    final distribution = <DreamType, int>{};
    
    for (final dream in dreams) {
      distribution[dream.type] = (distribution[dream.type] ?? 0) + 1;
    }
    
    return distribution.map((type, count) => 
      MapEntry(type, count / dreams.length * 100)
    );
  }
  
  static Future<Map<Crystal, double>> _analyzeCrystalEffectiveness(
    List<DreamEntry> dreams
  ) async {
    final effectiveness = <Crystal, List<double>>{};
    
    for (final dream in dreams) {
      for (final crystal in dream.crystalsPresent) {
        effectiveness.putIfAbsent(crystal, () => []);
        
        // Calculate effectiveness based on:
        // - Dream clarity
        // - Absence of nightmares
        // - Lucidity level
        // - Positive emotional tone
        double score = 0;
        
        score += dream.clarity.value / 5.0 * 0.3;
        score += dream.type != DreamType.nightmare ? 0.3 : 0;
        score += dream.lucidity.value / 4.0 * 0.2;
        score += _getEmotionalScore(dream.emotionalTone) * 0.2;
        
        effectiveness[crystal]!.add(score);
      }
    }
    
    // Calculate average effectiveness
    return effectiveness.map((crystal, scores) =>
      MapEntry(crystal, scores.reduce((a, b) => a + b) / scores.length)
    );
  }
}
```

## Integration with Other Systems

### Moon Phase Dream Correlation
```dart
class MoonPhaseDreamIntegration {
  static Map<MoonPhase, DreamCharacteristics> moonPhaseDreamPatterns = {
    MoonPhase.newMoon: DreamCharacteristics(
      commonThemes: ['New beginnings', 'Darkness', 'Hidden potential', 'Seeds'],
      recommendedCrystals: ['Black Moonstone', 'Labradorite', 'Black Obsidian'],
      typicalLucidity: LucidityLevel.slight,
      emotionalTendency: EmotionalTone.neutral,
      insights: 'Dreams often reveal what needs to be released or started anew'
    ),
    
    MoonPhase.fullMoon: DreamCharacteristics(
      commonThemes: ['Illumination', 'Revelation', 'Intensity', 'Culmination'],
      recommendedCrystals: ['Moonstone', 'Selenite', 'Clear Quartz'],
      typicalLucidity: LucidityLevel.high,
      emotionalTendency: EmotionalTone.mixed,
      insights: 'Heightened psychic activity; prophetic dreams more likely'
    ),
    
    MoonPhase.waxingCrescent: DreamCharacteristics(
      commonThemes: ['Growth', 'Intention', 'Building', 'Hope'],
      recommendedCrystals: ['Green Aventurine', 'Citrine', 'Prehnite'],
      typicalLucidity: LucidityLevel.moderate,
      emotionalTendency: EmotionalTone.joyful,
      insights: 'Dreams show path forward; pay attention to guidance'
    ),
    
    MoonPhase.waningCrescent: DreamCharacteristics(
      commonThemes: ['Release', 'Reflection', 'Wisdom', 'Rest'],
      recommendedCrystals: ['Amethyst', 'Lepidolite', 'Blue Chalcedony'],
      typicalLucidity: LucidityLevel.slight,
      emotionalTendency: EmotionalTone.peaceful,
      insights: 'Dreams process and integrate recent experiences'
    )
  };
  
  static Future<MoonDreamAnalysis> analyzeMoonInfluence(
    String userId,
    MoonPhase currentPhase
  ) async {
    final recentDreams = await _getDreamsForMoonPhase(userId, currentPhase);
    
    return MoonDreamAnalysis(
      moonPhase: currentPhase,
      dreamCount: recentDreams.length,
      averageLucidity: _calculateAverageLucidity(recentDreams),
      commonThemes: _extractCommonThemes(recentDreams),
      emotionalPattern: _analyzeEmotionalPattern(recentDreams),
      crystalRecommendations: moonPhaseDreamPatterns[currentPhase]!.recommendedCrystals,
      personalInsights: await _generatePersonalMoonInsights(userId, currentPhase, recentDreams),
    );
  }
}
```

### Birth Chart Dream Analysis
```dart
class AstrologicalDreamAnalysis {
  static Future<AstrologicalDreamProfile> createDreamProfile(
    String userId,
    BirthChart chart
  ) async {
    final dreams = await _getAllUserDreams(userId);
    
    return AstrologicalDreamProfile(
      // 12th house analysis (house of dreams/subconscious)
      twelfthHouseInfluence: _analyze12thHouse(chart),
      
      // Neptune aspects (planet of dreams)
      neptuneInfluence: _analyzeNeptuneAspects(chart),
      
      // Moon sign dream patterns
      moonSignPatterns: _getMoonSignDreamPatterns(chart.moonSign),
      
      // Typical dream themes by sun sign
      sunSignThemes: _getSunSignDreamThemes(chart.sunSign),
      
      // Recommended crystals based on chart
      astrologicalCrystals: _getAstrologicalDreamCrystals(chart),
      
      // Personal dream tendencies
      naturalDreamAbilities: _assessDreamAbilities(chart),
      
      // Best times for dream work
      optimalDreamTimes: _calculateOptimalDreamTimes(chart),
    );
  }
  
  static List<String> _getAstrologicalDreamCrystals(BirthChart chart) {
    final crystals = <String>[];
    
    // Based on moon sign
    final moonCrystals = {
      'aries': ['Red Jasper', 'Carnelian'],
      'taurus': ['Rose Quartz', 'Emerald'],
      'gemini': ['Agate', 'Citrine'],
      'cancer': ['Moonstone', 'Pearl'],
      'leo': ['Sunstone', 'Tiger\'s Eye'],
      'virgo': ['Moss Agate', 'Amazonite'],
      'libra': ['Lepidolite', 'Jade'],
      'scorpio': ['Obsidian', 'Malachite'],
      'sagittarius': ['Turquoise', 'Sodalite'],
      'capricorn': ['Garnet', 'Onyx'],
      'aquarius': ['Amethyst', 'Aquamarine'],
      'pisces': ['Fluorite', 'Labradorite']
    };
    
    crystals.addAll(moonCrystals[chart.moonSign.toLowerCase()] ?? []);
    
    // Add Neptune-ruled crystals if strong Neptune
    if (_hasStrongNeptune(chart)) {
      crystals.addAll(['Iolite', 'Celestite', 'Blue Lace Agate']);
    }
    
    // Add 12th house crystals
    crystals.add('Charoite'); // Universal 12th house stone
    
    return crystals.toSet().toList();
  }
}
```

## Premium Dream Features

### Advanced Dream Analysis
```dart
class PremiumDreamFeatures {
  static const Map<SubscriptionTier, DreamFeatures> tierFeatures = {
    SubscriptionTier.free: DreamFeatures(
      maxDreamsPerMonth: 10,
      basicInterpretation: true,
      aiInterpretation: false,
      patternRecognition: false,
      crystalCorrelation: 'basic',
      exportOptions: [],
      voiceRecording: false,
      imageAttachments: 0,
    ),
    
    SubscriptionTier.premium: DreamFeatures(
      maxDreamsPerMonth: 100,
      basicInterpretation: true,
      aiInterpretation: true,
      patternRecognition: true,
      crystalCorrelation: 'advanced',
      exportOptions: ['pdf', 'txt'],
      voiceRecording: true,
      imageAttachments: 3,
      additionalFeatures: [
        'Dream series tracking',
        'Lucid dream training',
        'Symbol dictionary access',
        'Monthly dream report'
      ]
    ),
    
    SubscriptionTier.pro: DreamFeatures(
      maxDreamsPerMonth: -1, // unlimited
      basicInterpretation: true,
      aiInterpretation: true,
      patternRecognition: true,
      crystalCorrelation: 'expert',
      exportOptions: ['pdf', 'txt', 'json', 'csv'],
      voiceRecording: true,
      imageAttachments: 10,
      additionalFeatures: [
        'All premium features',
        'Predictive dream analysis',
        'Professional dream consultation',
        'Dream artwork generation',
        'Advanced symbol analysis',
        'Jungian archetype mapping'
      ]
    ),
    
    SubscriptionTier.founders: DreamFeatures(
      maxDreamsPerMonth: -1,
      basicInterpretation: true,
      aiInterpretation: true,
      patternRecognition: true,
      crystalCorrelation: 'master',
      exportOptions: ['all formats'],
      voiceRecording: true,
      imageAttachments: -1, // unlimited
      additionalFeatures: [
        'All features',
        'Priority AI processing',
        'Custom dream categories',
        'Private dream sharing',
        'Dream workshop access',
        'Direct expert guidance'
      ]
    )
  };
}
```

This comprehensive Dream Journal System provides deep integration between dreams, crystals, astrology, and personal growth, creating a powerful tool for self-discovery and spiritual development.