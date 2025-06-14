# Moon Rituals System

## Overview
The Moon Rituals System provides personalized lunar ceremony guidance based on moon phases, user's birth chart, and crystal collection. This system combines astronomical accuracy with metaphysical wisdom to create meaningful spiritual practices.

## Core Components

### Lunar Calendar Integration
```dart
class MoonPhaseCalculator {
  static const double LUNAR_CYCLE = 29.5305882; // days
  static const DateTime KNOWN_NEW_MOON = DateTime(2000, 1, 6, 18, 14); // Reference new moon
  
  static MoonPhase getCurrentPhase() {
    final now = DateTime.now().toUtc();
    final daysSinceNewMoon = now.difference(KNOWN_NEW_MOON).inDays % LUNAR_CYCLE;
    
    if (daysSinceNewMoon < 1.84566) return MoonPhase.newMoon;
    if (daysSinceNewMoon < 5.53699) return MoonPhase.waxingCrescent;
    if (daysSinceNewMoon < 9.22831) return MoonPhase.firstQuarter;
    if (daysSinceNewMoon < 12.91963) return MoonPhase.waxingGibbous;
    if (daysSinceNewMoon < 16.61096) return MoonPhase.fullMoon;
    if (daysSinceNewMoon < 20.30228) return MoonPhase.waningGibbous;
    if (daysSinceNewMoon < 23.99361) return MoonPhase.lastQuarter;
    return MoonPhase.waningCrescent;
  }
  
  static DateTime getNextPhase(MoonPhase phase) {
    final current = getCurrentPhase();
    final currentDays = _getPhaseDay(current);
    final targetDays = _getPhaseDay(phase);
    
    int daysToAdd;
    if (targetDays > currentDays) {
      daysToAdd = (targetDays - currentDays).round();
    } else {
      daysToAdd = (LUNAR_CYCLE - currentDays + targetDays).round();
    }
    
    return DateTime.now().add(Duration(days: daysToAdd));
  }
  
  static double _getPhaseDay(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon: return 0;
      case MoonPhase.waxingCrescent: return 3.69;
      case MoonPhase.firstQuarter: return 7.38;
      case MoonPhase.waxingGibbous: return 11.07;
      case MoonPhase.fullMoon: return 14.77;
      case MoonPhase.waningGibbous: return 18.46;
      case MoonPhase.lastQuarter: return 22.15;
      case MoonPhase.waningCrescent: return 25.84;
    }
  }
}
```

### Moon Phase Properties
```dart
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent
}

class MoonPhaseProperties {
  static Map<MoonPhase, Map<String, dynamic>> properties = {
    MoonPhase.newMoon: {
      'name': 'New Moon',
      'emoji': '🌑',
      'energy': 'Beginnings, Intention Setting, Planning',
      'chakra': 'Crown',
      'element': 'Air',
      'intention_focus': [
        'New beginnings',
        'Setting intentions',
        'Clearing energy',
        'Planning projects',
        'Seed planting (metaphorically)'
      ],
      'recommended_crystals': [
        'Clear Quartz',
        'Selenite',
        'Moonstone',
        'Labradorite',
        'Black Tourmaline'
      ],
      'ritual_duration': '20-30 minutes',
      'best_time': 'Sunset to midnight'
    },
    
    MoonPhase.waxingCrescent: {
      'name': 'Waxing Crescent',
      'emoji': '🌒',
      'energy': 'Growth, Building, Taking Action',
      'chakra': 'Sacral',
      'element': 'Water',
      'intention_focus': [
        'Taking first steps',
        'Building momentum',
        'Attracting opportunities',
        'Confidence building',
        'Creative expression'
      ],
      'recommended_crystals': [
        'Carnelian',
        'Citrine',
        'Orange Calcite',
        'Sunstone',
        'Tiger\'s Eye'
      ]
    },
    
    MoonPhase.firstQuarter: {
      'name': 'First Quarter',
      'emoji': '🌓',
      'energy': 'Action, Decision Making, Overcoming Obstacles',
      'chakra': 'Solar Plexus',
      'element': 'Fire',
      'intention_focus': [
        'Making decisions',
        'Taking action',
        'Overcoming challenges',
        'Building willpower',
        'Breaking through barriers'
      ],
      'recommended_crystals': [
        'Citrine',
        'Yellow Jasper',
        'Pyrite',
        'Golden Topaz',
        'Amber'
      ]
    },
    
    MoonPhase.waxingGibbous: {
      'name': 'Waxing Gibbous',
      'emoji': '🌔',
      'energy': 'Refinement, Adjustment, Perseverance',
      'chakra': 'Heart',
      'element': 'Earth',
      'intention_focus': [
        'Refining plans',
        'Making adjustments',
        'Staying committed',
        'Fine-tuning approach',
        'Patience and persistence'
      ],
      'recommended_crystals': [
        'Green Aventurine',
        'Rose Quartz',
        'Malachite',
        'Jade',
        'Prehnite'
      ]
    },
    
    MoonPhase.fullMoon: {
      'name': 'Full Moon',
      'emoji': '🌕',
      'energy': 'Culmination, Gratitude, Release, Power',
      'chakra': 'Crown',
      'element': 'All Elements',
      'intention_focus': [
        'Celebrating achievements',
        'Expressing gratitude',
        'Releasing what no longer serves',
        'Psychic enhancement',
        'Manifestation completion'
      ],
      'recommended_crystals': [
        'Selenite',
        'Clear Quartz',
        'Amethyst',
        'Moonstone',
        'Fluorite'
      ],
      'ritual_duration': '45-60 minutes',
      'best_time': 'Moonrise to midnight'
    },
    
    MoonPhase.waningGibbous: {
      'name': 'Waning Gibbous',
      'emoji': '🌖',
      'energy': 'Gratitude, Sharing Wisdom, Giving Back',
      'chakra': 'Throat',
      'element': 'Air',
      'intention_focus': [
        'Sharing knowledge',
        'Teaching others',
        'Expressing gratitude',
        'Mentoring',
        'Community service'
      ],
      'recommended_crystals': [
        'Blue Lace Agate',
        'Sodalite',
        'Aquamarine',
        'Turquoise',
        'Lapis Lazuli'
      ]
    },
    
    MoonPhase.lastQuarter: {
      'name': 'Last Quarter',
      'emoji': '🌗',
      'energy': 'Release, Forgiveness, Breaking Habits',
      'chakra': 'Solar Plexus',
      'element': 'Fire',
      'intention_focus': [
        'Releasing old patterns',
        'Forgiveness work',
        'Breaking bad habits',
        'Letting go',
        'Creating space for new'
      ],
      'recommended_crystals': [
        'Black Obsidian',
        'Smoky Quartz',
        'Apache Tear',
        'Hematite',
        'Black Tourmaline'
      ]
    },
    
    MoonPhase.waningCrescent: {
      'name': 'Waning Crescent',
      'emoji': '🌘',
      'energy': 'Rest, Reflection, Inner Wisdom',
      'chakra': 'Third Eye',
      'element': 'Water',
      'intention_focus': [
        'Rest and reflection',
        'Inner wisdom',
        'Spiritual connection',
        'Meditation',
        'Preparing for new cycle'
      ],
      'recommended_crystals': [
        'Amethyst',
        'Iolite',
        'Lepidolite',
        'Charoite',
        'Sugilite'
      ]
    }
  };
}
```

## Personalized Ritual Creation

### User-Specific Ritual Generation
```dart
class RitualPersonalizer {
  static Future<PersonalizedRitual> createRitual({
    required String userId,
    required MoonPhase phase,
    String? customIntention,
  }) async {
    final user = await UserService.getProfile(userId);
    final collection = await CollectionService.getUserCollection(userId);
    final phaseProperties = MoonPhaseProperties.properties[phase]!;
    
    // Get user's available crystals for this phase
    final availableCrystals = _getAvailableCrystals(
      collection, 
      phaseProperties['recommended_crystals']
    );
    
    // Create personalized intention based on birth chart
    final personalizedIntention = await _createPersonalizedIntention(
      user, 
      phase, 
      customIntention
    );
    
    // Generate ritual steps
    final ritualSteps = _generateRitualSteps(
      phase, 
      availableCrystals, 
      personalizedIntention,
      user.preferences
    );
    
    return PersonalizedRitual(
      id: Uuid().v4(),
      userId: userId,
      phase: phase,
      phaseProperties: phaseProperties,
      personalizedIntention: personalizedIntention,
      availableCrystals: availableCrystals,
      ritualSteps: ritualSteps,
      estimatedDuration: _calculateDuration(ritualSteps),
      createdAt: DateTime.now(),
    );
  }
  
  static List<Crystal> _getAvailableCrystals(
    CrystalCollection collection, 
    List<String> recommendedNames
  ) {
    return collection.crystals.where((crystal) {
      return recommendedNames.any((name) => 
        crystal.identification.name.toLowerCase().contains(name.toLowerCase()) ||
        crystal.identification.alternateNames.any((alt) => 
          name.toLowerCase().contains(alt.toLowerCase())
        )
      );
    }).toList();
  }
  
  static Future<String> _createPersonalizedIntention(
    UserProfile user, 
    MoonPhase phase, 
    String? customIntention
  ) async {
    if (customIntention != null) return customIntention;
    
    final birthChart = user.astrology;
    final phaseProperties = MoonPhaseProperties.properties[phase]!;
    
    // Use AI to create personalized intention
    final prompt = '''
    Create a personalized moon ritual intention for a ${birthChart.sunSign} sun, 
    ${birthChart.moonSign} moon, ${birthChart.ascendant} rising during the ${phase.name}.
    
    Phase Energy: ${phaseProperties['energy']}
    Phase Focus Areas: ${phaseProperties['intention_focus'].join(', ')}
    
    Make it personal, meaningful, and aligned with their astrological profile.
    Keep it concise (1-2 sentences).
    ''';
    
    return await AIService.generatePersonalizedContent(prompt);
  }
}
```

### Ritual Step Generation
```dart
class RitualStepGenerator {
  static List<RitualStep> generateSteps({
    required MoonPhase phase,
    required List<Crystal> availableCrystals,
    required String intention,
    required UserPreferences preferences,
  }) {
    final steps = <RitualStep>[];
    
    // 1. Preparation
    steps.add(RitualStep(
      type: RitualStepType.preparation,
      title: 'Sacred Space Preparation',
      description: 'Cleanse your space and gather your materials',
      duration: Duration(minutes: 5),
      instructions: [
        'Find a quiet space where you won\'t be disturbed',
        'Light a candle or incense if desired',
        'Arrange your crystals in front of you',
        'Take three deep breaths to center yourself'
      ],
      crystals: availableCrystals.take(3).toList(),
    ));
    
    // 2. Crystal Activation
    if (availableCrystals.isNotEmpty) {
      steps.add(RitualStep(
        type: RitualStepType.crystalActivation,
        title: 'Crystal Activation',
        description: 'Connect with your crystals\' energy',
        duration: Duration(minutes: 8),
        instructions: _getCrystalActivationSteps(availableCrystals, phase),
        crystals: availableCrystals,
      ));
    }
    
    // 3. Intention Setting
    steps.add(RitualStep(
      type: RitualStepType.intentionSetting,
      title: 'Intention Declaration',
      description: 'State your intention clearly',
      duration: Duration(minutes: 10),
      instructions: [
        'Hold your primary crystal in your hands',
        'Close your eyes and connect with the moon\'s energy',
        'Speak your intention aloud: "$intention"',
        'Visualize your intention manifesting',
        'Feel gratitude for what\'s coming'
      ],
      affirmation: _getPhaseAffirmation(phase),
    ));
    
    // 4. Meditation/Visualization
    steps.add(RitualStep(
      type: RitualStepType.meditation,
      title: '${phase.name} Meditation',
      description: 'Connect with the lunar energy',
      duration: Duration(minutes: 15),
      instructions: _getMeditationSteps(phase),
      guidedAudio: _getGuidedAudioUrl(phase),
    ));
    
    // 5. Gratitude & Closing
    steps.add(RitualStep(
      type: RitualStepType.closing,
      title: 'Gratitude & Closing',
      description: 'Express thanks and close the ritual',
      duration: Duration(minutes: 5),
      instructions: [
        'Express gratitude to the moon and your crystals',
        'Ground yourself by touching the earth or floor',
        'Blow out candles mindfully',
        'Store crystals in moonlight if possible'
      ],
    ));
    
    return steps;
  }
  
  static List<String> _getCrystalActivationSteps(List<Crystal> crystals, MoonPhase phase) {
    final primary = crystals.first;
    return [
      'Hold ${primary.identification.name} in your dominant hand',
      'Feel its weight and texture',
      'Set the intention to work with its ${primary.automationData.chakra.primary} chakra energy',
      'Visualize ${phase.name} light flowing into the crystal',
      'Place it on your ${primary.automationData.chakra.primary} chakra area',
    ];
  }
}
```

## Ritual Templates

### Template System
```dart
class RitualTemplates {
  static Map<String, RitualTemplate> templates = {
    'manifestation': RitualTemplate(
      name: 'Manifestation Ritual',
      description: 'Attract your desires during waxing moon phases',
      bestPhases: [MoonPhase.newMoon, MoonPhase.waxingCrescent, MoonPhase.firstQuarter],
      requiredCrystals: ['Clear Quartz', 'Citrine', 'Green Aventurine'],
      duration: Duration(minutes: 30),
      steps: [
        'Create manifestation board or written list',
        'Charge crystals with your desires',
        'Visualize goals as already achieved',
        'Express gratitude for manifestation'
      ]
    ),
    
    'release': RitualTemplate(
      name: 'Release Ritual',
      description: 'Let go of what no longer serves during waning phases',
      bestPhases: [MoonPhase.fullMoon, MoonPhase.waningGibbous, MoonPhase.lastQuarter],
      requiredCrystals: ['Black Obsidian', 'Selenite', 'Smoky Quartz'],
      duration: Duration(minutes: 25),
      steps: [
        'Write down what you want to release',
        'Use crystals to absorb negative energy',
        'Safely burn or bury the written release',
        'Cleanse crystals afterward'
      ]
    ),
    
    'healing': RitualTemplate(
      name: 'Healing Ritual',
      description: 'Promote emotional and spiritual healing',
      bestPhases: [MoonPhase.fullMoon, MoonPhase.waningGibbous],
      requiredCrystals: ['Rose Quartz', 'Amethyst', 'Green Aventurine'],
      duration: Duration(minutes: 40),
      steps: [
        'Create healing crystal grid',
        'Focus on areas needing healing',
        'Send love and light to those areas',
        'Affirm your wholeness and health'
      ]
    ),
    
    'protection': RitualTemplate(
      name: 'Protection Ritual',
      description: 'Create energetic boundaries and protection',
      bestPhases: [MoonPhase.newMoon, MoonPhase.lastQuarter],
      requiredCrystals: ['Black Tourmaline', 'Hematite', 'Obsidian'],
      duration: Duration(minutes: 20),
      steps: [
        'Create protective circle with crystals',
        'Visualize white light shield around you',
        'Set boundaries for your energy',
        'Carry protection stone with you'
      ]
    )
  };
}
```

## Moon Ritual Calendar

### Calendar Integration
```dart
class RitualCalendar {
  static Future<List<RitualEvent>> getUpcomingRituals(String userId) async {
    final events = <RitualEvent>[];
    final now = DateTime.now();
    
    // Get next 30 days of moon phases
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final phase = MoonPhaseCalculator.getPhaseForDate(date);
      
      // Check if this is a significant phase (new/full moon)
      if (_isSignificantPhase(phase)) {
        final ritual = await RitualPersonalizer.createRitual(
          userId: userId,
          phase: phase,
        );
        
        events.add(RitualEvent(
          date: date,
          phase: phase,
          ritual: ritual,
          isOptimal: true,
        ));
      }
    }
    
    // Add user's scheduled rituals
    final userRituals = await _getUserScheduledRituals(userId);
    events.addAll(userRituals);
    
    return events..sort((a, b) => a.date.compareTo(b.date));
  }
  
  static bool _isSignificantPhase(MoonPhase phase) {
    return [
      MoonPhase.newMoon,
      MoonPhase.firstQuarter, 
      MoonPhase.fullMoon,
      MoonPhase.lastQuarter
    ].contains(phase);
  }
}
```

### Reminder System
```dart
class RitualReminders {
  static Future<void> scheduleRitualReminders(String userId) async {
    final upcomingRituals = await RitualCalendar.getUpcomingRituals(userId);
    
    for (final event in upcomingRituals) {
      // Schedule notification 2 hours before optimal time
      final reminderTime = event.date.subtract(Duration(hours: 2));
      
      await NotificationService.scheduleNotification(
        id: '${userId}_ritual_${event.date.millisecondsSinceEpoch}',
        title: '🌙 ${event.phase.name} Ritual Time',
        body: 'Perfect energy for your ${event.ritual.personalizedIntention}',
        scheduledTime: reminderTime,
        payload: {
          'type': 'ritual_reminder',
          'ritual_id': event.ritual.id,
          'phase': event.phase.name,
        }
      );
    }
  }
  
  static Future<void> sendRitualEmail(String userId, RitualEvent event) async {
    await EmailService.sendEmail(
      template: 'ritual_reminder',
      userId: userId,
      data: {
        'phaseName': event.phase.name,
        'phaseEmoji': MoonPhaseProperties.properties[event.phase]!['emoji'],
        'intention': event.ritual.personalizedIntention,
        'crystals': event.ritual.availableCrystals.map((c) => c.identification.name).toList(),
        'duration': event.ritual.estimatedDuration.inMinutes,
        'optimalTime': event.date.toString(),
      }
    );
  }
}
```

## Ritual Tracking & Analytics

### Performance Tracking
```dart
class RitualTracker {
  static Future<void> startRitual(String userId, String ritualId) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('ritual_sessions')
      .add({
        'ritual_id': ritualId,
        'started_at': FieldValue.serverTimestamp(),
        'moon_phase': MoonPhaseCalculator.getCurrentPhase().name,
        'status': 'in_progress',
      });
  }
  
  static Future<void> completeRitual(
    String userId, 
    String sessionId, 
    RitualFeedback feedback
  ) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('ritual_sessions')
      .doc(sessionId)
      .update({
        'completed_at': FieldValue.serverTimestamp(),
        'status': 'completed',
        'duration': feedback.actualDuration.inMinutes,
        'experience_rating': feedback.experienceRating,
        'energy_before': feedback.energyBefore,
        'energy_after': feedback.energyAfter,
        'insights': feedback.insights,
        'crystals_used': feedback.crystalsUsed,
        'intention_clarity': feedback.intentionClarity,
      });
      
    // Update user statistics
    await _updateRitualStats(userId);
  }
  
  static Future<RitualAnalytics> getRitualAnalytics(String userId) async {
    final sessions = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('ritual_sessions')
      .where('status', isEqualTo: 'completed')
      .get();
    
    return RitualAnalytics.fromSessions(sessions.docs);
  }
}
```

## Integration with Other Systems

### Crystal Collection Integration
```dart
class RitualCrystalIntegration {
  static Future<List<Crystal>> getOptimalCrystalsForPhase(
    String userId, 
    MoonPhase phase
  ) async {
    final collection = await CollectionService.getUserCollection(userId);
    final phaseProperties = MoonPhaseProperties.properties[phase]!;
    final recommendedNames = phaseProperties['recommended_crystals'] as List<String>;
    
    // Filter user's crystals by phase recommendations
    final optimal = collection.crystals.where((crystal) {
      return recommendedNames.any((name) => 
        crystal.identification.name.toLowerCase().contains(name.toLowerCase())
      );
    }).toList();
    
    // If user doesn't have optimal crystals, suggest alternatives
    if (optimal.isEmpty) {
      return _suggestAlternativeCrystals(collection, phase);
    }
    
    return optimal;
  }
  
  static Future<void> trackCrystalUsageInRitual(
    String userId,
    List<String> crystalIds,
    String ritualId
  ) async {
    for (final crystalId in crystalIds) {
      await FirebaseFirestore.instance
        .collection('crystals')
        .doc(crystalId)
        .update({
          'user_data.usage_log.ritual_uses': FieldValue.increment(1),
          'user_data.usage_log.last_used': FieldValue.serverTimestamp(),
        });
    }
  }
}
```

This comprehensive Moon Rituals System provides personalized, astronomically-accurate lunar ceremonies that integrate with the user's crystal collection and astrological profile for meaningful spiritual practice.