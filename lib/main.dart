import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully');
    
    // Initialize Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for the mystical theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0221),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CrystalGrimoireApp());
}

class CrystalGrimoireApp extends StatelessWidget {
  const CrystalGrimoireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🔮 Crystal Grimoire V3',
      debugShowCheckedModeBanner: false,
      
      // Enhanced mystical theme
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF0D0221), // Deep mystical background
        
        // Enhanced app bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213E),
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        
        // Enhanced card theme
        cardTheme: CardThemeData(
          color: const Color(0xFF16213E).withOpacity(0.8),
          elevation: 8,
          shadowColor: Colors.purple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        
        // Enhanced color scheme
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9D4EDD),
          secondary: Color(0xFF7B2CBF),
          surface: Color(0xFF16213E),
          background: Color(0xFF0D0221),
          error: Color(0xFFFF5555),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
      ),
      
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        
        if (snapshot.hasData) {
          return const BeautifulHomeScreen();
        } else {
          return const BeautifulLoginScreen();
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0221), // Deep mystical purple-black
              Color(0xFF1A0B2E), // Dark violet
              Color(0xFF16213E), // Midnight blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loading crystal
              const AnimatedCrystalLogo(size: 120),
              const SizedBox(height: 24),
              Text(
                '🔮 Loading Crystal Grimoire...',
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BeautifulLoginScreen extends StatelessWidget {
  const BeautifulLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0221), // Deep mystical purple-black
              Color(0xFF1A0B2E), // Dark violet
              Color(0xFF16213E), // Midnight blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles
            const FloatingParticles(),
            
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Beautiful animated crystal logo
                      const AnimatedCrystalLogo(size: 150),
                      
                      const SizedBox(height: 32),
                      
                      // Enhanced title with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFE0AAFF),
                            Color(0xFFC77DFF),
                            Color(0xFF9D4EDD),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'CRYSTAL GRIMOIRE',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Your Mystical Crystal Companion',
                        style: GoogleFonts.raleway(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Feature cards
                      Row(
                        children: [
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.camera_alt,
                              title: 'AI Crystal Identification',
                              description: 'Identify crystals instantly with advanced AI',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.collections_bookmark,
                              title: 'Personal Collection',
                              description: 'Build and manage your crystal library',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.auto_fix_high,
                              title: 'Spiritual Guidance',
                              description: 'Get personalized metaphysical advice',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.store,
                              title: 'Crystal Marketplace',
                              description: 'Buy and sell with the community',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Enhanced login button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF9D4EDD),
                              Color(0xFF7B2CBF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9D4EDD).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signInAnonymously();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Login failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Start Your Crystal Journey',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BeautifulHomeScreen extends StatefulWidget {
  const BeautifulHomeScreen({Key? key}) : super(key: key);

  @override
  State<BeautifulHomeScreen> createState() => _BeautifulHomeScreenState();
}

class _BeautifulHomeScreenState extends State<BeautifulHomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ImagePicker _picker = ImagePicker();
  bool _isIdentifying = false;
  Map<String, dynamic>? _lastIdentification;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Enhanced mystical background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0221), // Deep mystical purple-black
                  Color(0xFF1A0B2E), // Dark violet
                  Color(0xFF16213E), // Midnight blue
                ],
              ),
            ),
          ),
          
          // Animated crystal particles
          const FloatingParticles(),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App header with animated logo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Beautiful animated crystal logo
                          const AnimatedCrystalLogo(size: 120),
                          
                          const SizedBox(height: 20),
                          
                          // Shimmering title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFE0AAFF),
                                Color(0xFFC77DFF),
                                Color(0xFF9D4EDD),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                            child: Text(
                              'Crystal Grimoire',
                              style: GoogleFonts.cinzelDecorative(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Your Mystical Crystal Companion',
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Enhanced Crystal Identification Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: CrystalIdentificationCard(
                        isIdentifying: _isIdentifying,
                        onIdentify: _pickAndIdentifyImage,
                        lastIdentification: _lastIdentification,
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  
                  // Feature cards grid
                  SliverPadding(
                    padding: const EdgeInsets.all(20.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildListDelegate([
                        MainFeatureCard(
                          icon: Icons.collections_bookmark,
                          title: 'Collection',
                          description: 'Your crystal inventory',
                          iconColor: Colors.amber,
                          onTap: () => _showComingSoon(context, 'Collection'),
                        ),
                        MainFeatureCard(
                          icon: Icons.book,
                          title: 'Journal',
                          description: 'Spiritual journal & insights',
                          iconColor: Colors.blue,
                          onTap: () => _showComingSoon(context, 'Journal'),
                        ),
                        MainFeatureCard(
                          icon: Icons.auto_fix_high,
                          title: 'Guidance',
                          description: 'AI spiritual wisdom',
                          iconColor: Colors.purple,
                          onTap: () => _showComingSoon(context, 'Guidance'),
                        ),
                        MainFeatureCard(
                          icon: Icons.store,
                          title: 'Marketplace',
                          description: 'Buy & sell crystals',
                          iconColor: Colors.green,
                          onTap: () => _showComingSoon(context, 'Marketplace'),
                        ),
                      ]),
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating action button
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7209B7), Color(0xFF560BAD)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7209B7).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.logout, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔮 $feature feature coming soon!'),
        backgroundColor: const Color(0xFF9D4EDD),
      ),
    );
  }

  Future<void> _pickAndIdentifyImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isIdentifying = true;
      });

      // Convert image to base64
      final Uint8List imageBytes = await image.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Call our professional backend
      final response = await http.post(
        Uri.parse('https://us-central1-crystalgrimoire-v3-production.cloudfunctions.net/api/crystal/identify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image_data': 'data:image/jpeg;base64,$base64Image',
          'user_context': {
            'user_id': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
            'subscription_tier': 'free',
          }
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        setState(() {
          _lastIdentification = result;
          _isIdentifying = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔮 Crystal identified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }

    } catch (e) {
      setState(() {
        _isIdentifying = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error identifying crystal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Custom Widgets

class AnimatedCrystalLogo extends StatefulWidget {
  final double size;

  const AnimatedCrystalLogo({Key? key, required this.size}) : super(key: key);

  @override
  State<AnimatedCrystalLogo> createState() => _AnimatedCrystalLogoState();
}

class _AnimatedCrystalLogoState extends State<AnimatedCrystalLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF20B2AA).withOpacity(0.8), // Teal
                      const Color(0xFFFF4500).withOpacity(0.7), // Red-orange
                      const Color(0xFFFFD700).withOpacity(0.6), // Gold
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF20B2AA).withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingParticles extends StatefulWidget {
  const FloatingParticles({Key? key}) : super(key: key);

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    particles = List.generate(15, (index) => Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(particles, _controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double speed;
  late double size;
  late Color color;

  Particle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    speed = 0.1 + random.nextDouble() * 0.3;
    size = 2 + random.nextDouble() * 4;
    color = [
      const Color(0xFF9D4EDD),
      const Color(0xFF7B2CBF),
      const Color(0xFFE0AAFF),
    ][random.nextInt(3)];
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = (particle.x + animationValue * particle.speed) % 1.0 * size.width;
      final y = particle.y * size.height;
      
      paint.color = particle.color.withOpacity(0.6);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF16213E).withOpacity(0.8),
            const Color(0xFF1A0B2E).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF9D4EDD), size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MainFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final VoidCallback onTap;

  const MainFeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF16213E).withOpacity(0.8),
              const Color(0xFF1A0B2E).withOpacity(0.6),
            ],
          ),
          border: Border.all(
            color: iconColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.3),
                      iconColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.raleway(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CrystalIdentificationCard extends StatelessWidget {
  final bool isIdentifying;
  final VoidCallback onIdentify;
  final Map<String, dynamic>? lastIdentification;

  const CrystalIdentificationCard({
    Key? key,
    required this.isIdentifying,
    required this.onIdentify,
    this.lastIdentification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF20B2AA), // Teal
            Color(0xFFFF4500), // Red-orange
            Color(0xFFFFD700), // Gold
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20B2AA).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isIdentifying ? Icons.hourglass_empty : Icons.camera_alt,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            isIdentifying ? 'Analyzing Crystal...' : '🔮 AI Crystal Identification',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isIdentifying 
              ? 'Our AI is analyzing your crystal with professional accuracy'
              : 'Upload a photo of your crystal for professional AI identification',
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (isIdentifying)
            const CircularProgressIndicator(color: Colors.white)
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: onIdentify,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Identify Crystal'),
            ),
          
          if (lastIdentification != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Last Identification:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getIdentificationSummary(lastIdentification!),
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getIdentificationSummary(Map<String, dynamic> result) {
    try {
      final core = result['crystal_core'] as Map<String, dynamic>?;
      final identification = core?['identification'] as Map<String, dynamic>?;
      final stoneName = identification?['stone_type'] ?? 'Unknown Crystal';
      final confidence = ((identification?['confidence'] ?? 0.0) * 100).toInt();
      return '$stoneName (${confidence}% confidence)';
    } catch (e) {
      return 'Crystal identification completed successfully';
    }
  }
}