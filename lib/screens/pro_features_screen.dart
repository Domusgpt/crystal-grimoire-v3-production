import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../services/stripe_service.dart';
import '../models/user_profile.dart';
import '../widgets/animations/mystical_animations.dart';
import 'journal_screen.dart';
import 'metaphysical_guidance_screen.dart';
import 'moon_ritual_screen.dart';
import 'crystal_healing_screen.dart';
import 'sound_bath_screen.dart';

class ProFeaturesScreen extends StatefulWidget {
  const ProFeaturesScreen({Key? key}) : super(key: key);

  @override
  State<ProFeaturesScreen> createState() => _ProFeaturesScreenState();
}

class _ProFeaturesScreenState extends State<ProFeaturesScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut)
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.watch<FirebaseService>();
    final userProfile = firebaseService.currentUserProfile;
    final isProUser = userProfile?.subscriptionTier.name == 'pro' || 
                      userProfile?.subscriptionTier.name == 'founders';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: Text(
          isProUser ? 'PRO Features' : 'Upgrade to PRO',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                particleCount: 30,
                color: Colors.deepPurple,
              ),
            ),
            
            // Main content
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Header
                          _buildHeader(isProUser),
                          
                          const SizedBox(height: 32),
                          
                          // PRO Features grid
                          _buildProFeaturesGrid(isProUser),
                          
                          const SizedBox(height: 32),
                          
                          // Subscription plans (if not PRO)
                          if (!isProUser) _buildSubscriptionPlans(),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isProUser) {
    return Column(
      children: [
        // PRO badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'CRYSTAL GRIMOIRE PRO',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          isProUser 
            ? 'Welcome to the full Crystal Grimoire experience!'
            : 'Unlock the complete mystical journey',
          style: GoogleFonts.lato(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProFeaturesGrid(bool isProUser) {
    final features = [
      {
        'icon': Icons.book,
        'title': 'Spiritual Journal',
        'description': 'Track your mystical journey with guided prompts',
        'screen': const JournalScreen(),
      },
      {
        'icon': Icons.psychology,
        'title': 'AI Guidance',
        'description': 'Personalized spiritual advice from advanced AI',
        'screen': const MetaphysicalGuidanceScreen(),
      },
      {
        'icon': Icons.nightlight,
        'title': 'Moon Rituals',
        'description': 'Sacred ceremonies aligned with lunar cycles',
        'screen': const MoonRitualScreen(),
      },
      {
        'icon': Icons.healing,
        'title': 'Crystal Healing',
        'description': 'Therapeutic sessions with your crystals',
        'screen': const CrystalHealingScreen(),
      },
      {
        'icon': Icons.graphic_eq,
        'title': 'Sound Bath',
        'description': 'Immersive meditation with crystal bowls',
        'screen': const SoundBathScreen(),
      },
      {
        'icon': Icons.insights,
        'title': 'Advanced Analytics',
        'description': 'Deep insights into your spiritual progress',
        'screen': null, // TODO: Create analytics screen
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
          onTap: isProUser && feature['screen'] != null
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => feature['screen'] as Widget),
              )
            : null,
          available: isProUser,
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
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
          color: available 
            ? Colors.purple.withOpacity(0.5) 
            : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
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
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: available ? Colors.white : Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: available ? Colors.white70 : Colors.white38,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!available) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PRO',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return Column(
      children: [
        Text(
          'Choose Your Plan',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Premium Plan
        _buildPlanCard(
          title: 'Premium',
          price: '\$9.99/month',
          features: [
            'Unlimited Crystal IDs',
            'Personal Collection',
            'Marketplace Access',
            'Basic AI Guidance',
          ],
          color: Colors.purple,
          onTap: () => _handleSubscription('premium'),
        ),
        
        const SizedBox(height: 16),
        
        // PRO Plan (Recommended)
        _buildPlanCard(
          title: 'PRO',
          price: '\$19.99/month',
          features: [
            'Everything in Premium',
            'Spiritual Journal',
            'Advanced AI Guidance',
            'Moon Rituals & Healing',
            'Sound Bath Meditation',
            'Priority Support',
          ],
          color: Colors.amber,
          isRecommended: true,
          onTap: () => _handleSubscription('pro'),
        ),
        
        const SizedBox(height: 16),
        
        // Founders Plan
        _buildPlanCard(
          title: 'Founders Edition',
          price: '\$199 Lifetime',
          features: [
            'Everything in PRO',
            'Lifetime Access',
            'Exclusive Features',
            'Beta Access',
            'Direct Support',
            'Founder Badge',
          ],
          color: Colors.deepPurple,
          onTap: () => _handleSubscription('founders'),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    bool isRecommended = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
        ),
        border: Border.all(
          color: isRecommended ? color : color.withOpacity(0.5),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (isRecommended) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RECOMMENDED',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  price,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubscription(String tier) async {
    try {
      final firebaseService = context.read<FirebaseService>();
      final stripeService = context.read<StripeService>();
      
      if (!firebaseService.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to upgrade your subscription'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create payment intent
      final result = await stripeService.createSubscriptionPaymentIntent(
        tier: SubscriptionTier.values.firstWhere((t) => t.name == tier),
        customerEmail: firebaseService.currentUser!.email!,
      );

      Navigator.pop(context); // Close loading dialog

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subscription to $tier plan initiated!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subscription failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}