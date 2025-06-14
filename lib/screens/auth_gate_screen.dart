import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/app_state.dart';
import '../widgets/animations/mystical_animations.dart';
import 'redesigned_home_screen.dart';
import 'login_screen.dart';

/// Authentication gate - users must sign up to access any features
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({Key? key}) : super(key: key);

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut)
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F23),
            body: Center(
              child: CircularProgressIndicator(color: Colors.purple),
            ),
          );
        }
        
        // If user is authenticated, show main app
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('🔑 AuthGate: User authenticated, showing home screen for ${snapshot.data!.email}');
          return const RedesignedHomeScreen();
        }
        
        // Otherwise show auth gate
        debugPrint('🔒 AuthGate: User not authenticated, showing login screen');
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0F23),
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background particles
                const Positioned.fill(
                  child: FloatingParticles(
                    particleCount: 50,
                    color: Colors.deepPurple,
                  ),
                ),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(),
                      
                      // Logo and title
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Column(
                              children: [
                                // Main logo placeholder - will be replaced with your assets
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF20B2AA), Color(0xFFFF4500)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(0.5),
                                              blurRadius: 30,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.diamond,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // App title
                                Text(
                                  'Crystal Grimoire',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      const Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 8,
                                        color: Colors.purple,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                Text(
                                  'Your Mystical Crystal Companion',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Features preview
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              Icons.camera_alt,
                              'AI Crystal Identification',
                              'Identify crystals instantly with advanced AI',
                            ),
                            _buildFeatureItem(
                              Icons.collections,
                              'Personal Collection',
                              'Build and manage your crystal library',
                            ),
                            _buildFeatureItem(
                              Icons.psychology,
                              'Spiritual Guidance',
                              'Get personalized metaphysical advice',
                            ),
                            _buildFeatureItem(
                              Icons.store,
                              'Crystal Marketplace',
                              'Buy and sell with the community',
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Call to action
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => _showAuthDialog(context, isSignUp: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  'Start Your Crystal Journey',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextButton(
                              onPressed: () => _showAuthDialog(context, isSignUp: false),
                              child: Text(
                                'Already have an account? Sign In',
                                style: GoogleFonts.lato(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthDialog(BuildContext context, {required bool isSignUp}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(isSignUp: isSignUp),
      ),
    );
  }
}