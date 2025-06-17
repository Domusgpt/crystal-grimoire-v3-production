import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../widgets/common/mystical_card.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundBathScreen extends StatefulWidget {
  const SoundBathScreen({Key? key}) : super(key: key);

  @override
  State<SoundBathScreen> createState() => _SoundBathScreenState();
}

class _SoundBathScreenState extends State<SoundBathScreen> 
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late Animation<double> _waveAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;
  
  // Audio Player State
  late AudioPlayer _audioPlayer;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  bool isPlaying = false; // Retained for UI elements, but driven by _playerState
  String selectedSound = 'Crystal Bowl';
  int selectedDuration = 10; // minutes
  
  // Placeholder asset path
  static const String _defaultAudioPath = 'audio/sound_bath/default_sound.mp3';

  final Map<String, Map<String, dynamic>> soundData = {
    'Crystal Bowl': {
      'frequency': '432 Hz',
      'description': 'Pure crystal vibrations for deep healing',
      'color': const Color(0xFF9333EA),
      'icon': Icons.album,
      'assetPath': _defaultAudioPath,
    },
    'Tibetan Bowl': {
      'frequency': '528 Hz',
      'description': 'Ancient healing frequencies',
      'color': const Color(0xFFD97706),
      'icon': Icons.circle,
      'assetPath': _defaultAudioPath,
    },
    'Ocean Waves': {
      'frequency': 'Natural',
      'description': 'Calming rhythm of the sea',
      'color': const Color(0xFF0EA5E9),
      'icon': Icons.waves,
      'assetPath': _defaultAudioPath,
    },
    'Rain Forest': {
      'frequency': 'Natural',
      'description': 'Immersive nature sounds',
      'color': const Color(0xFF10B981),
      'icon': Icons.forest,
      'assetPath': _defaultAudioPath,
    },
    'Chakra Tones': {
      'frequency': '396-963 Hz',
      'description': 'Full chakra alignment sequence',
      'color': const Color(0xFFEC4899),
      'icon': Icons.blur_circular,
      'assetPath': _defaultAudioPath,
    },
  };

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if(mounted) {
        setState(() {
          _playerState = s;
          isPlaying = (s == PlayerState.playing);
        });
      }
    });
    _audioPlayer.onDurationChanged.listen((Duration d) {
      if(mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((Duration p) {
      if(mounted) setState(() => _position = p);
    });
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _breathingController.dispose();
    _glowController.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile>(context);
    final theme = Theme.of(context); // Get theme for consistency

    if (!userProfile.hasAccessTo('sound_bath')) {
      // Paywall structure similar to JournalScreen, MoonRitualScreen
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Sound Bath',
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
        ),
        body: Stack(
          children: [
            Container( // Background gradient consistent with the screen's theme
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0015), // Dark top from screen's theme
                    Color(0xFF1A0B2E), // Mid
                    Color(0xFF2D1B69), // Lighter bottom
                  ],
                ),
              ),
            ),
            // Optional: const FloatingParticles(particleCount: 15, color: Colors.lightBlueAccent),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: MysticalCard( // Assuming MysticalCard is available and styled
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.waves, // Icon related to Sound/Waves
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Unlock Sound Bath',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This is a Pro feature. Please upgrade your subscription to immerse yourself in healing frequencies and soundscapes.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.star_border_purple500_sharp),
                          label: const Text('Upgrade to Pro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: theme.textTheme.titleMedium,
                          ),
                          onPressed: () {
                            // TODO: Navigate to subscription page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigate to subscription page (Not Implemented)')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sound Bath',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Mystical background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0015),
                  Color(0xFF1A0B2E),
                  Color(0xFF2D1B69),
                ],
              ),
            ),
          ),
          
          // Animated waves
          if (_playerState == PlayerState.playing) // Conditional rendering based on player state
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: WavePainter(
                    animationValue: _waveAnimation.value,
                    color: soundData[selectedSound]!['color'] as Color,
                  ),
                );
              },
            ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Central visualization
                  _buildCentralVisualization(),
                  
                  const SizedBox(height: 40),
                  
                  // Sound selector
                  _buildSoundSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Duration selector
                  _buildDurationSelector(),

                  const SizedBox(height: 16), // Adjusted spacing

                  // Slider and Duration Text
                  if (_duration != null) _buildPlaybackSlider(),
                  
                  const SizedBox(height: 24),
                  
                  // Breathing guide
                  if (_playerState == PlayerState.playing) _buildBreathingGuide(), // Conditional rendering
                  
                  const SizedBox(height: 32),
                  
                  // Play controls
                  _buildPlayControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralVisualization() {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (soundData[selectedSound]!['color'] as Color)
                    .withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 50,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: isPlaying ? _breathingAnimation.value : 1.0,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        (soundData[selectedSound]!['color'] as Color)
                            .withOpacity(0.1),
                        (soundData[selectedSound]!['color'] as Color)
                            .withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Middle ring
              Transform.scale(
                scale: isPlaying ? _breathingAnimation.value * 0.8 : 0.8,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        (soundData[selectedSound]!['color'] as Color)
                            .withOpacity(0.2),
                        (soundData[selectedSound]!['color'] as Color)
                            .withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Center
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: soundData[selectedSound]!['color'] as Color,
                  boxShadow: [
                    BoxShadow(
                      color: (soundData[selectedSound]!['color'] as Color)
                          .withOpacity(0.8),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  soundData[selectedSound]!['icon'] as IconData,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Sound',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: soundData.length,
            itemBuilder: (context, index) {
              final sound = soundData.keys.elementAt(index);
              final data = soundData[sound]!;
              final isSelected = sound == selectedSound;
              
              return GestureDetector(
                onTap: () async {
                  if (selectedSound != sound) {
                    if (_playerState == PlayerState.playing) {
                      await _audioPlayer.stop();
                    }
                    setState(() {
                      selectedSound = sound;
                      _position = Duration.zero; // Reset position for new sound
                      // _duration = null; // Optionally reset duration until new sound loads
                    });
                  }
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? [
                                    (data['color'] as Color).withOpacity(0.3),
                                    (data['color'] as Color).withOpacity(0.1),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                          ),
                          border: Border.all(
                            color: isSelected
                                ? (data['color'] as Color).withOpacity(0.5)
                                : Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              data['icon'] as IconData,
                              color: isSelected
                                  ? data['color'] as Color
                                  : Colors.white70,
                              size: 32,
                            ),
                            Text(
                              sound,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              data['frequency'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          soundData[selectedSound]!['description'] as String,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duration',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [5, 10, 15, 20, 30].map((duration) {
                  final isSelected = duration == selectedDuration;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDuration = duration;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (soundData[selectedSound]!['color'] as Color)
                                .withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? soundData[selectedSound]!['color'] as Color
                              : Colors.white30,
                        ),
                      ),
                      child: Text(
                        '$duration min',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingGuide() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _breathingAnimation.value > 1.0 ? 'Breathe In' : 'Breathe Out',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white70),
            onPressed: () {
              // Previous sound logic
            },
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Play/Pause button
        GestureDetector(
          onTap: () async {
            final currentAssetPath = soundData[selectedSound]!['assetPath'] as String;
            if (_playerState == PlayerState.playing) {
              await _audioPlayer.pause();
            } else {
              await _audioPlayer.play(AssetSource(currentAssetPath));
            }
            // isPlaying state is updated by the onPlayerStateChanged listener
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  soundData[selectedSound]!['color'] as Color,
                  (soundData[selectedSound]!['color'] as Color).withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (soundData[selectedSound]!['color'] as Color)
                      .withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Next button - Placeholder, actual logic might involve a playlist or sequence
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white70),
            onPressed: () {
              // Next sound logic
            },
          ),
        ),
      ],
    );
  }

  // Widget for Playback Slider and Duration Text
  Widget _buildPlaybackSlider() {
    final color = soundData[selectedSound]!['color'] as Color;
    return Column(
      children: [
        Slider(
          value: (_position?.inMilliseconds ?? 0).toDouble().clamp(0.0, (_duration?.inMilliseconds ?? 1.0).toDouble()),
          min: 0.0,
          max: (_duration?.inMilliseconds ?? 1.0).toDouble() > 0 ? (_duration!.inMilliseconds.toDouble()) : 1.0, // Ensure max is not 0
          onChanged: (value) {
            final position = Duration(milliseconds: value.round());
            _audioPlayer.seek(position);
          },
          activeColor: color,
          inactiveColor: color.withOpacity(0.3),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position ?? Duration.zero),
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              Text(
                _formatDuration(_duration ?? Duration.zero),
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 5; i++) {
      final progress = (animationValue + i * 0.2) % 1.0;
      final radius = size.width * 0.3 * progress;
      final opacity = 1.0 - progress;
      
      paint.color = color.withOpacity(opacity * 0.3);
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

