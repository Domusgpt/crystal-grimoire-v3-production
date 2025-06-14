# Sound Bath System

## Overview
The Sound Bath System provides therapeutic audio experiences using crystal singing bowls, frequency healing, and binaural beats synchronized with the user's crystal collection and astrological profile. This system combines ancient sound healing wisdom with modern audio technology.

## System Location
**File Location**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireV3/SOUND_BATH_SYSTEM.md`
**Working Directory**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireV3/`

## Core Audio Architecture

### Frequency Healing Database
```dart
class HealingFrequencies {
  static const Map<String, FrequencyProfile> chakraFrequencies = {
    'root': FrequencyProfile(
      frequency: 396.0, // Hz
      note: 'UT',
      solfeggio: true,
      chakra: 'Root (Muladhara)',
      benefits: [
        'Releases fear and guilt',
        'Grounds energy',
        'Increases feeling of security',
        'Strengthens foundation'
      ],
      crystalResonance: ['Red Jasper', 'Hematite', 'Black Tourmaline'],
      binauralBeats: BinauralProfile(
        carrier: 396.0,
        beat: 8.0, // Alpha waves for grounding
        duration: Duration(minutes: 15)
      )
    ),
    
    'sacral': FrequencyProfile(
      frequency: 417.0,
      note: 'RE',
      solfeggio: true,
      chakra: 'Sacral (Svadhisthana)',
      benefits: [
        'Facilitates change',
        'Breaks negative patterns',
        'Enhances creativity',
        'Emotional balance'
      ],
      crystalResonance: ['Carnelian', 'Orange Calcite', 'Sunstone'],
      binauralBeats: BinauralProfile(
        carrier: 417.0,
        beat: 9.0, // Alpha waves for creativity
        duration: Duration(minutes: 15)
      )
    ),
    
    'solar_plexus': FrequencyProfile(
      frequency: 528.0,
      note: 'MI',
      solfeggio: true,
      chakra: 'Solar Plexus (Manipura)',
      benefits: [
        'DNA repair and transformation',
        'Increases confidence',
        'Enhances willpower',
        'Miracle frequency'
      ],
      crystalResonance: ['Citrine', 'Yellow Jasper', 'Tiger\'s Eye'],
      binauralBeats: BinauralProfile(
        carrier: 528.0,
        beat: 10.0, // Alpha waves for confidence
        duration: Duration(minutes: 15)
      )
    ),
    
    'heart': FrequencyProfile(
      frequency: 639.0,
      note: 'FA',
      solfeggio: true,
      chakra: 'Heart (Anahata)',
      benefits: [
        'Harmonizes relationships',
        'Opens heart to love',
        'Enhances communication',
        'Heals emotional wounds'
      ],
      crystalResonance: ['Rose Quartz', 'Green Aventurine', 'Malachite'],
      binauralBeats: BinauralProfile(
        carrier: 639.0,
        beat: 10.5, // Alpha/Beta bridge for heart opening
        duration: Duration(minutes: 20)
      )
    ),
    
    'throat': FrequencyProfile(
      frequency: 741.0,
      note: 'SOL',
      solfeggio: true,
      chakra: 'Throat (Vishuddha)',
      benefits: [
        'Awakens intuition',
        'Enhances expression',
        'Cleanses cells',
        'Promotes truth'
      ],
      crystalResonance: ['Blue Lace Agate', 'Sodalite', 'Aquamarine'],
      binauralBeats: BinauralProfile(
        carrier: 741.0,
        beat: 12.0, // Beta waves for expression
        duration: Duration(minutes: 15)
      )
    ),
    
    'third_eye': FrequencyProfile(
      frequency: 852.0,
      note: 'LA',
      solfeggio: true,
      chakra: 'Third Eye (Ajna)',
      benefits: [
        'Returns to spiritual order',
        'Enhances intuition',
        'Awakens psychic abilities',
        'Clarity of thought'
      ],
      crystalResonance: ['Amethyst', 'Fluorite', 'Lapis Lazuli'],
      binauralBeats: BinauralProfile(
        carrier: 852.0,
        beat: 7.0, // Theta waves for intuition
        duration: Duration(minutes: 20)
      )
    ),
    
    'crown': FrequencyProfile(
      frequency: 963.0,
      note: 'SI',
      solfeggio: true,
      chakra: 'Crown (Sahasrara)',
      benefits: [
        'Connection to divine',
        'Enlightenment',
        'Pure consciousness',
        'Spiritual awakening'
      ],
      crystalResonance: ['Clear Quartz', 'Selenite', 'Charoite'],
      binauralBeats: BinauralProfile(
        carrier: 963.0,
        beat: 4.0, // Theta waves for spiritual connection
        duration: Duration(minutes: 30)
      )
    )
  };
}
```

### Crystal Bowl Sound Generator
```dart
class CrystalBowlSynthesizer {
  static AudioStream generateBowlSound({
    required double frequency,
    required BowlType bowlType,
    required int duration,
    required double volume,
  }) {
    // Generate base tone with harmonics
    final fundamentalWave = SineWave(frequency: frequency, amplitude: volume * 0.6);
    final secondHarmonic = SineWave(frequency: frequency * 2, amplitude: volume * 0.2);
    final thirdHarmonic = SineWave(frequency: frequency * 3, amplitude: volume * 0.1);
    final fourthHarmonic = SineWave(frequency: frequency * 4, amplitude: volume * 0.05);
    
    // Add bowl characteristics
    final bowlResonance = _getBowlResonance(bowlType);
    final attackEnvelope = _getAttackEnvelope(bowlType);
    final decayEnvelope = _getDecayEnvelope(duration);
    
    // Combine waves
    final mixedWave = AudioMixer.combine([
      fundamentalWave,
      secondHarmonic,
      thirdHarmonic,
      fourthHarmonic
    ]);
    
    // Apply bowl characteristics
    final processedWave = mixedWave
      .applyResonance(bowlResonance)
      .applyEnvelope(attackEnvelope)
      .applyEnvelope(decayEnvelope);
    
    // Add subtle modulation for organic feel
    final modulation = LFO(frequency: 0.1, depth: 0.02);
    return processedWave.modulate(modulation);
  }
  
  static BowlResonance _getBowlResonance(BowlType type) {
    switch (type) {
      case BowlType.crystal:
        return BowlResonance(
          q: 50,
          warmth: 0.2,
          brightness: 0.8,
          sustain: 0.9
        );
      case BowlType.tibetan:
        return BowlResonance(
          q: 30,
          warmth: 0.7,
          brightness: 0.4,
          sustain: 0.7
        );
      case BowlType.alchemy:
        return BowlResonance(
          q: 60,
          warmth: 0.3,
          brightness: 0.9,
          sustain: 0.95
        );
    }
  }
}
```

### Binaural Beat Generator
```dart
class BinauralBeatGenerator {
  static AudioStream generateBinauralBeat({
    required double carrierFrequency,
    required double beatFrequency,
    required Duration duration,
    required BrainwaveState targetState,
  }) {
    // Generate left and right channel frequencies
    final leftFrequency = carrierFrequency - (beatFrequency / 2);
    final rightFrequency = carrierFrequency + (beatFrequency / 2);
    
    // Create sine waves for each ear
    final leftWave = SineWave(frequency: leftFrequency, amplitude: 0.5);
    final rightWave = SineWave(frequency: rightFrequency, amplitude: 0.5);
    
    // Apply fade in/out for comfort
    final fadeInTime = Duration(seconds: 5);
    final fadeOutTime = Duration(seconds: 5);
    
    final envelope = Envelope(
      attack: fadeInTime,
      sustain: duration - fadeInTime - fadeOutTime,
      release: fadeOutTime
    );
    
    // Create stereo audio
    return StereoAudio(
      left: leftWave.applyEnvelope(envelope),
      right: rightWave.applyEnvelope(envelope)
    );
  }
  
  static double getBeatFrequencyForState(BrainwaveState state) {
    switch (state) {
      case BrainwaveState.delta:
        return 2.0; // 0.5-4 Hz - Deep sleep, healing
      case BrainwaveState.theta:
        return 6.0; // 4-8 Hz - Meditation, intuition
      case BrainwaveState.alpha:
        return 10.0; // 8-13 Hz - Relaxation, creativity
      case BrainwaveState.beta:
        return 20.0; // 13-30 Hz - Focus, alertness
      case BrainwaveState.gamma:
        return 40.0; // 30-100 Hz - Peak performance
    }
  }
}
```

## Personalized Sound Bath Creation

### User-Specific Sound Bath Generator
```dart
class PersonalizedSoundBath {
  static Future<SoundBathSession> createSession({
    required String userId,
    required SoundBathIntention intention,
    required Duration duration,
    List<String>? preferredCrystals,
  }) async {
    final user = await UserService.getProfile(userId);
    final collection = await CollectionService.getUserCollection(userId);
    final birthChart = user.astrology;
    
    // Analyze user's energetic needs
    final energeticProfile = await _analyzeEnergeticNeeds(
      birthChart,
      intention,
      DateTime.now()
    );
    
    // Select optimal frequencies based on needs
    final selectedFrequencies = _selectFrequencies(
      energeticProfile,
      intention,
      duration
    );
    
    // Match crystals from user's collection
    final resonantCrystals = _matchResonantCrystals(
      collection,
      selectedFrequencies,
      preferredCrystals
    );
    
    // Generate audio layers
    final audioLayers = await _generateAudioLayers(
      selectedFrequencies,
      resonantCrystals,
      intention,
      duration
    );
    
    // Create guided meditation script
    final meditationScript = await _generateMeditationScript(
      user,
      intention,
      resonantCrystals,
      duration
    );
    
    return SoundBathSession(
      id: Uuid().v4(),
      userId: userId,
      intention: intention,
      duration: duration,
      frequencies: selectedFrequencies,
      crystals: resonantCrystals,
      audioLayers: audioLayers,
      meditationScript: meditationScript,
      energeticProfile: energeticProfile,
      createdAt: DateTime.now(),
    );
  }
  
  static Map<String, dynamic> _analyzeEnergeticNeeds(
    BirthChart chart,
    SoundBathIntention intention,
    DateTime currentTime
  ) {
    final needs = <String, dynamic>{};
    
    // Elemental balance analysis
    needs['elemental_balance'] = {
      'fire': chart.fireElements,
      'earth': chart.earthElements,
      'air': chart.airElements,
      'water': chart.waterElements,
      'dominant': chart.dominantElement,
      'lacking': chart.lackingElement
    };
    
    // Current planetary transits
    needs['current_transits'] = PlanetaryCalculator.getCurrentTransits(chart);
    
    // Chakra recommendations based on astrology
    needs['recommended_chakras'] = _getChakrasFromAstrology(chart);
    
    // Frequency needs based on intention
    needs['frequency_focus'] = _getFrequencyFocus(intention);
    
    return needs;
  }
  
  static List<String> _getChakrasFromAstrology(BirthChart chart) {
    final chakras = <String>[];
    
    // Sun sign chakra association
    final sunChakras = {
      'aries': ['root', 'solar_plexus'],
      'taurus': ['throat', 'heart'],
      'gemini': ['throat', 'third_eye'],
      'cancer': ['sacral', 'heart'],
      'leo': ['solar_plexus', 'heart'],
      'virgo': ['solar_plexus', 'throat'],
      'libra': ['heart', 'sacral'],
      'scorpio': ['sacral', 'root'],
      'sagittarius': ['solar_plexus', 'third_eye'],
      'capricorn': ['root', 'crown'],
      'aquarius': ['third_eye', 'crown'],
      'pisces': ['crown', 'third_eye']
    };
    
    chakras.addAll(sunChakras[chart.sunSign.toLowerCase()] ?? []);
    
    // Add moon sign emotional chakras
    if (['cancer', 'pisces', 'scorpio'].contains(chart.moonSign.toLowerCase())) {
      chakras.add('sacral');
      chakras.add('heart');
    }
    
    return chakras.toSet().toList();
  }
}
```

### Sound Bath Templates

#### Chakra Balancing Session
```dart
class ChakraBalancingSoundBath {
  static SoundBathTemplate template = SoundBathTemplate(
    name: 'Complete Chakra Balance',
    description: 'Journey through all seven chakras for complete energetic alignment',
    duration: Duration(minutes: 45),
    structure: [
      SoundBathSegment(
        chakra: 'root',
        duration: Duration(minutes: 6),
        frequencies: [396.0, 194.18],
        bowlType: BowlType.crystal,
        instructions: 'Ground your energy, feel roots extending into Earth'
      ),
      SoundBathSegment(
        chakra: 'sacral',
        duration: Duration(minutes: 6),
        frequencies: [417.0, 210.42],
        bowlType: BowlType.alchemy,
        instructions: 'Flow with creative energy, embrace emotional fluidity'
      ),
      SoundBathSegment(
        chakra: 'solar_plexus',
        duration: Duration(minutes: 6),
        frequencies: [528.0, 126.22],
        bowlType: BowlType.crystal,
        instructions: 'Ignite your inner fire, claim your personal power'
      ),
      SoundBathSegment(
        chakra: 'heart',
        duration: Duration(minutes: 7),
        frequencies: [639.0, 341.3],
        bowlType: BowlType.alchemy,
        instructions: 'Open to love, both giving and receiving'
      ),
      SoundBathSegment(
        chakra: 'throat',
        duration: Duration(minutes: 6),
        frequencies: [741.0, 141.27],
        bowlType: BowlType.crystal,
        instructions: 'Express your truth, communicate with clarity'
      ),
      SoundBathSegment(
        chakra: 'third_eye',
        duration: Duration(minutes: 7),
        frequencies: [852.0, 221.23],
        bowlType: BowlType.alchemy,
        instructions: 'Awaken intuition, see beyond the veil'
      ),
      SoundBathSegment(
        chakra: 'crown',
        duration: Duration(minutes: 7),
        frequencies: [963.0, 172.06],
        bowlType: BowlType.crystal,
        instructions: 'Connect with divine consciousness, experience unity'
      )
    ]
  );
}
```

#### Anxiety Relief Session
```dart
class AnxietyReliefSoundBath {
  static SoundBathTemplate template = SoundBathTemplate(
    name: 'Anxiety & Stress Relief',
    description: 'Calming frequencies to soothe the nervous system',
    duration: Duration(minutes: 30),
    structure: [
      SoundBathSegment(
        name: 'Grounding Phase',
        duration: Duration(minutes: 10),
        frequencies: [396.0, 174.0], // Root chakra + deep grounding
        binauralBeat: 8.0, // Alpha waves for calm
        bowlType: BowlType.tibetan,
        crystals: ['Black Tourmaline', 'Hematite', 'Smoky Quartz'],
        instructions: 'Release tension into the Earth, feel supported and safe'
      ),
      SoundBathSegment(
        name: 'Heart Opening',
        duration: Duration(minutes: 10),
        frequencies: [639.0, 528.0], // Heart + miracle frequency
        binauralBeat: 10.0, // Alpha waves
        bowlType: BowlType.alchemy,
        crystals: ['Rose Quartz', 'Lepidolite', 'Green Aventurine'],
        instructions: 'Soften the heart space, release emotional constriction'
      ),
      SoundBathSegment(
        name: 'Mental Clarity',
        duration: Duration(minutes: 10),
        frequencies: [852.0, 741.0], // Third eye + throat
        binauralBeat: 7.0, // Theta waves for deep calm
        bowlType: BowlType.crystal,
        crystals: ['Amethyst', 'Blue Lace Agate', 'Fluorite'],
        instructions: 'Clear mental fog, find peace in the present moment'
      )
    ]
  );
}
```

## Audio File Management

### Sound Library Structure
```dart
class SoundLibrary {
  static const Map<String, SoundAsset> soundAssets = {
    // Crystal bowl recordings
    'crystal_bowl_c': SoundAsset(
      path: 'assets/audio/bowls/crystal_c_note.mp3',
      frequency: 261.63,
      duration: Duration(minutes: 5),
      fileSize: '15MB',
      quality: AudioQuality.high,
      subscription: SubscriptionTier.free
    ),
    
    'crystal_bowl_d': SoundAsset(
      path: 'assets/audio/bowls/crystal_d_note.mp3',
      frequency: 293.66,
      duration: Duration(minutes: 5),
      fileSize: '15MB',
      quality: AudioQuality.high,
      subscription: SubscriptionTier.free
    ),
    
    // Nature sounds
    'ocean_waves': SoundAsset(
      path: 'assets/audio/nature/ocean_waves_loop.mp3',
      duration: Duration(minutes: 10),
      loopable: true,
      fileSize: '30MB',
      quality: AudioQuality.high,
      subscription: SubscriptionTier.premium
    ),
    
    'rain_forest': SoundAsset(
      path: 'assets/audio/nature/rain_forest_ambience.mp3',
      duration: Duration(minutes: 15),
      loopable: true,
      fileSize: '45MB',
      quality: AudioQuality.high,
      subscription: SubscriptionTier.premium
    ),
    
    // Guided meditations
    'chakra_journey': SoundAsset(
      path: 'assets/audio/guided/chakra_journey_full.mp3',
      duration: Duration(minutes: 45),
      narrator: 'Crystal Sage',
      fileSize: '135MB',
      quality: AudioQuality.premium,
      subscription: SubscriptionTier.pro
    ),
    
    // Binaural beats
    'theta_meditation': SoundAsset(
      path: 'assets/audio/binaural/theta_6hz_meditation.mp3',
      frequency: 200.0,
      beatFrequency: 6.0,
      duration: Duration(minutes: 30),
      fileSize: '90MB',
      quality: AudioQuality.high,
      subscription: SubscriptionTier.premium
    )
  };
}
```

### Audio Streaming Service
```dart
class AudioStreamingService {
  static Future<AudioPlayer> streamSoundBath({
    required SoundBathSession session,
    required AudioQuality quality,
  }) async {
    final player = AudioPlayer();
    
    // Check subscription tier for quality access
    final userTier = await SubscriptionManager.getCurrentTier(session.userId);
    final allowedQuality = _getMaxQualityForTier(userTier);
    final streamQuality = quality.index <= allowedQuality.index ? quality : allowedQuality;
    
    // Prepare audio layers
    final audioTracks = <AudioTrack>[];
    
    for (final layer in session.audioLayers) {
      final track = await _prepareAudioTrack(layer, streamQuality);
      audioTracks.add(track);
    }
    
    // Mix tracks with proper levels
    final mixedAudio = await AudioMixer.mixTracks(
      tracks: audioTracks,
      masterVolume: 0.8,
      crossfade: true
    );
    
    // Apply audio effects
    final processedAudio = await _applyAudioEffects(
      mixedAudio,
      session.intention
    );
    
    // Start streaming
    await player.setAudioSource(processedAudio);
    
    // Track usage for analytics
    await _trackSoundBathUsage(session);
    
    return player;
  }
  
  static Future<AudioSource> _applyAudioEffects(
    AudioSource audio,
    SoundBathIntention intention
  ) async {
    switch (intention.type) {
      case IntentionType.relaxation:
        return audio
          .applyReverb(ReverbPreset.cathedral)
          .applyLowPassFilter(cutoff: 2000);
          
      case IntentionType.energizing:
        return audio
          .applyCompression(ratio: 3.0)
          .applyHighShelf(frequency: 5000, gain: 3);
          
      case IntentionType.healing:
        return audio
          .applyReverb(ReverbPreset.hall)
          .applyWarmth(amount: 0.3);
          
      case IntentionType.meditation:
        return audio
          .applyReverb(ReverbPreset.chamber)
          .applySpatializer(width: 1.2);
    }
  }
}
```

## Sound Bath Session Tracking

### Session Analytics
```dart
class SoundBathAnalytics {
  static Future<void> trackSession({
    required String userId,
    required String sessionId,
    required SessionMetrics metrics,
  }) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('sound_bath_sessions')
      .doc(sessionId)
      .set({
        'started_at': metrics.startTime,
        'completed_at': metrics.endTime,
        'duration': metrics.actualDuration.inMinutes,
        'completion_rate': metrics.completionPercentage,
        'intention': metrics.intention.toMap(),
        'frequencies_used': metrics.frequenciesUsed,
        'crystals_present': metrics.crystalsPresent.map((c) => c.id).toList(),
        'user_feedback': {
          'stress_before': metrics.stressBefore,
          'stress_after': metrics.stressAfter,
          'mood_before': metrics.moodBefore,
          'mood_after': metrics.moodAfter,
          'effectiveness': metrics.effectivenessRating,
          'would_repeat': metrics.wouldRepeat
        },
        'audio_quality': metrics.audioQuality.toString(),
        'interruptions': metrics.interruptions,
        'favorite_segments': metrics.favoriteSegments,
      });
    
    // Update user statistics
    await _updateUserSoundBathStats(userId, metrics);
    
    // Track crystal resonance effectiveness
    for (final crystal in metrics.crystalsPresent) {
      await _updateCrystalResonanceData(crystal.id, metrics.effectivenessRating);
    }
  }
  
  static Future<SoundBathInsights> getUserInsights(String userId) async {
    final sessions = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('sound_bath_sessions')
      .orderBy('completed_at', descending: true)
      .limit(30)
      .get();
    
    return SoundBathInsights(
      totalSessions: sessions.docs.length,
      favoriteFrequencies: _analyzeFavoriteFrequencies(sessions.docs),
      mostEffectiveIntentions: _analyzeEffectiveIntentions(sessions.docs),
      optimalSessionLength: _calculateOptimalDuration(sessions.docs),
      stressReductionAverage: _calculateStressReduction(sessions.docs),
      recommendedSchedule: _generateScheduleRecommendation(sessions.docs),
    );
  }
}
```

## Integration with Other Systems

### Crystal Collection Integration
```dart
class SoundBathCrystalIntegration {
  static Future<List<Crystal>> getResonantCrystals({
    required String userId,
    required List<double> frequencies,
  }) async {
    final collection = await CollectionService.getUserCollection(userId);
    final resonantCrystals = <Crystal>[];
    
    for (final crystal in collection.crystals) {
      final resonanceScore = _calculateResonanceScore(crystal, frequencies);
      if (resonanceScore > 0.7) {
        resonantCrystals.add(crystal);
      }
    }
    
    // Sort by resonance score
    resonantCrystals.sort((a, b) => 
      _calculateResonanceScore(b, frequencies)
        .compareTo(_calculateResonanceScore(a, frequencies))
    );
    
    return resonantCrystals.take(5).toList();
  }
  
  static double _calculateResonanceScore(Crystal crystal, List<double> frequencies) {
    double score = 0.0;
    
    // Check chakra alignment
    final chakraFreqs = HealingFrequencies.chakraFrequencies;
    final crystalChakra = crystal.automationData.chakra.primary;
    
    if (chakraFreqs.containsKey(crystalChakra)) {
      final chakraFreq = chakraFreqs[crystalChakra]!.frequency;
      if (frequencies.contains(chakraFreq)) {
        score += 0.5;
      }
    }
    
    // Check color vibration alignment
    final colorFrequency = _getColorFrequency(crystal.automationData.color.primary);
    for (final freq in frequencies) {
      if ((freq - colorFrequency).abs() < 50) {
        score += 0.3;
      }
    }
    
    // Check metaphysical properties
    if (crystal.comprehensiveData.metaphysicalProperties.primaryPurpose
        .toLowerCase().contains('meditation') ||
        crystal.comprehensiveData.metaphysicalProperties.primaryPurpose
        .toLowerCase().contains('calm')) {
      score += 0.2;
    }
    
    return score.clamp(0.0, 1.0);
  }
}
```

### Moon Phase Sound Bath Optimization
```dart
class LunarSoundBathOptimizer {
  static Map<MoonPhase, SoundBathRecommendation> getOptimalSoundBath(
    String userId,
    MoonPhase currentPhase
  ) {
    final recommendations = <MoonPhase, SoundBathRecommendation>{
      MoonPhase.newMoon: SoundBathRecommendation(
        frequencies: [396.0, 417.0], // Root and sacral for new beginnings
        duration: Duration(minutes: 30),
        bestTime: 'Evening',
        intention: 'Setting intentions for the lunar cycle',
        crystals: ['Clear Quartz', 'Black Tourmaline', 'Selenite']
      ),
      
      MoonPhase.fullMoon: SoundBathRecommendation(
        frequencies: [639.0, 852.0, 963.0], // Heart, third eye, crown
        duration: Duration(minutes: 45),
        bestTime: 'Midnight',
        intention: 'Release and spiritual connection',
        crystals: ['Moonstone', 'Selenite', 'Clear Quartz']
      ),
      
      MoonPhase.firstQuarter: SoundBathRecommendation(
        frequencies: [528.0, 741.0], // Solar plexus and throat
        duration: Duration(minutes: 25),
        bestTime: 'Afternoon',
        intention: 'Taking action on intentions',
        crystals: ['Citrine', 'Tiger\'s Eye', 'Carnelian']
      ),
      
      MoonPhase.lastQuarter: SoundBathRecommendation(
        frequencies: [396.0, 639.0], // Root and heart for release
        duration: Duration(minutes: 35),
        bestTime: 'Dawn',
        intention: 'Letting go and forgiveness',
        crystals: ['Smoky Quartz', 'Rose Quartz', 'Black Obsidian']
      )
    };
    
    return recommendations;
  }
}
```

## Premium Sound Bath Features

### Advanced Audio Processing
```dart
class PremiumSoundFeatures {
  static const Map<SubscriptionTier, SoundBathFeatures> tierFeatures = {
    SubscriptionTier.free: SoundBathFeatures(
      maxDuration: Duration(minutes: 15),
      audioQuality: AudioQuality.standard,
      availableBowls: ['crystal_c', 'crystal_g'],
      binauralBeats: false,
      guidedMeditations: false,
      customMixing: false,
      offlineDownload: false,
      adsEnabled: true
    ),
    
    SubscriptionTier.premium: SoundBathFeatures(
      maxDuration: Duration(minutes: 45),
      audioQuality: AudioQuality.high,
      availableBowls: BowlLibrary.allBowls,
      binauralBeats: true,
      guidedMeditations: true,
      customMixing: true,
      offlineDownload: true,
      adsEnabled: false
    ),
    
    SubscriptionTier.pro: SoundBathFeatures(
      maxDuration: Duration(minutes: 120),
      audioQuality: AudioQuality.lossless,
      availableBowls: BowlLibrary.allBowls,
      binauralBeats: true,
      guidedMeditations: true,
      customMixing: true,
      offlineDownload: true,
      adsEnabled: false,
      exclusiveContent: [
        'Master healer sessions',
        'Advanced frequency combinations',
        'Personalized AI compositions',
        'Live sound bath access'
      ]
    ),
    
    SubscriptionTier.founders: SoundBathFeatures(
      maxDuration: Duration(hours: 4),
      audioQuality: AudioQuality.studio,
      availableBowls: BowlLibrary.allBowls,
      binauralBeats: true,
      guidedMeditations: true,
      customMixing: true,
      offlineDownload: true,
      adsEnabled: false,
      exclusiveContent: [
        'All pro features',
        'Direct sound healer consultations',
        'Custom frequency requests',
        'Early access to new sounds',
        'Contribution to sound library'
      ]
    )
  };
}
```

This comprehensive Sound Bath System provides therapeutic audio experiences that integrate with the user's crystal collection, astrological profile, and current energetic needs for maximum healing benefit.