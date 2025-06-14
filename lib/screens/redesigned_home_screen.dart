import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/teal_red_gem_logo.dart';
import '../widgets/daily_crystal_card.dart';
import '../widgets/ads/banner_ad_widget.dart';
import '../widgets/loading/video_loading_screen.dart';
import 'camera_screen.dart';
import 'collection_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'metaphysical_guidance_screen.dart';
import 'account_screen.dart';
import 'marketplace_screen.dart';
import 'pro_features_screen.dart';
import 'dart:math' as math;

class RedesignedHomeScreen extends StatefulWidget {
  const RedesignedHomeScreen({Key? key}) : super(key: key);

  @override
  State<RedesignedHomeScreen> createState() => _RedesignedHomeScreenState();
}

class _RedesignedHomeScreenState extends State<RedesignedHomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Single animation controller for better performance
    _mainController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.33, curve: Curves.elasticOut)
      )
    );
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.33, 1.0, curve: Curves.easeInOut)
      )
    );
    
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final firebaseService = context.watch<FirebaseService>();
    final userProfile = firebaseService.currentUserProfile;
    final isProUser = userProfile?.subscriptionTier.name == 'pro' || 
                      userProfile?.subscriptionTier.name == 'founders';
    final isPremiumUser = userProfile?.subscriptionTier.name == 'premium' || isProUser;

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
            // Background particles (reduced for performance)
            const Positioned.fill(
              child: RepaintBoundary(
                child: FloatingParticles(
                  particleCount: 12,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with logo and title
                    _buildHeader(userProfile),
                    
                    // Prominent Crystal ID section
                    _buildProminentCrystalID(isPremiumUser),
                    
                    // Ads for free users
                    if (!isPremiumUser) _buildAdSection(),
                    
                    // Crystal of the Day (moved below Crystal ID)
                    _buildCrystalOfTheDay(),
                    
                    // Main features grid
                    _buildFeaturesGrid(isProUser, isPremiumUser),
                    
                    // PRO Features section (replaces individual features)
                    if (!isProUser) _buildProFeaturesTeaser(),
                    
                    // Bottom ad for free users
                    if (!isPremiumUser) _buildBottomAd(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isProUser),
    );
  }

  Widget _buildHeader(dynamic userProfile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // App logo and title - more prominent
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation.value,
                child: Column(
                  children: [
                    // Logo placeholder - will be replaced with your assets
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF20B2AA), Color(0xFFFF4500)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.6),
                                  blurRadius: 25,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.diamond,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Crystal Grimoire title - more apparent
                    Text(
                      'Crystal Grimoire',
                      style: GoogleFonts.cinzel(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            offset: Offset(0, 3),
                            blurRadius: 12,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                    
                    // User greeting
                    if (userProfile != null)
                      Text(
                        'Welcome back, ${userProfile.name}',
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
        ],
      ),
    );
  }

  Widget _buildProminentCrystalID(bool isPremiumUser) {
    final remainingIds = isPremiumUser ? -1 : 5; // -1 = unlimited
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          final shimmerValue = _mainController.value;
          return Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.8),
                  Colors.deepPurple.withOpacity(0.6),
                  Colors.indigo.withOpacity(0.8),
                ],
                stops: [
                  math.max(0.0, shimmerValue - 0.3),
                  shimmerValue,
                  math.min(1.0, shimmerValue + 0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _handleCrystalID(context, isPremiumUser),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Crystal Identification',
                            style: GoogleFonts.cinzel(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPremiumUser 
                          ? 'Unlimited AI-powered identifications'
                          : 'AI-powered crystal identification ($remainingIds left today)',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!isPremiumUser) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Watch ad for +1 ID',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: BannerAdWidget(),
    );
  }

  Widget _buildCrystalOfTheDay() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: DailyCrystalCard(),
    );
  }

  Widget _buildFeaturesGrid(bool isProUser, bool isPremiumUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildFeatureCard(
            icon: Icons.collections,
            title: 'Collection',
            subtitle: 'Your crystals',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionScreen())),
            available: true,
          ),
          _buildFeatureCard(
            icon: Icons.store,
            title: 'Marketplace',
            subtitle: isPremiumUser ? 'Buy & Sell' : 'Browse only',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
            available: true,
          ),
          _buildFeatureCard(
            icon: Icons.account_circle,
            title: 'Account',
            subtitle: 'Profile & Settings',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen())),
            available: true,
          ),
          _buildFeatureCard(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            available: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProFeaturesTeaser() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.amber.withOpacity(0.3),
              Colors.orange.withOpacity(0.3),
            ],
          ),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProFeaturesScreen())),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock PRO Features',
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Journal • Spiritual Guidance • Advanced Features',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAd() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: BannerAdWidget(),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool available,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: available 
            ? [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)]
            : [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)],
        ),
        border: Border.all(
          color: available ? Colors.purple.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: available ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: available ? Colors.white : Colors.white54,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: available ? Colors.white : Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: available ? Colors.white70 : Colors.white38,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isProUser) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.9),
            Colors.purple.withOpacity(0.9),
          ],
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Identify'),
          const BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Collection'),
          BottomNavigationBarItem(
            icon: Icon(isProUser ? Icons.psychology : Icons.lock),
            label: isProUser ? 'Guidance' : 'PRO',
          ),
        ],
        onTap: (index) => _handleBottomNavTap(index, isProUser),
      ),
    );
  }

  void _handleBottomNavTap(int index, bool isProUser) {
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // Identify
        _handleCrystalID(context, isProUser);
        break;
      case 2: // Collection
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionScreen()));
        break;
      case 3: // PRO/Guidance
        if (isProUser) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MetaphysicalGuidanceScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProFeaturesScreen()));
        }
        break;
    }
  }

  void _handleCrystalID(BuildContext context, bool isPremiumUser) {
    if (!isPremiumUser) {
      // Show ad reward dialog for free users
      _showAdRewardDialog(context);
    } else {
      // Direct access for premium users
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
    }
  }

  void _showAdRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Watch Ad for Crystal ID',
          style: GoogleFonts.cinzel(color: Colors.white),
        ),
        content: Text(
          'Watch a short video to get +1 crystal identification, or upgrade to Premium for unlimited IDs.',
          style: GoogleFonts.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRewardedAd(context);
            },
            child: const Text('Watch Ad'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProFeaturesScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd(BuildContext context) {
    // Show video loading screen while "ad" plays
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoLoadingScreen(
          onComplete: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
          },
          message: 'Enjoying your reward...',
        ),
      ),
    );
  }
}