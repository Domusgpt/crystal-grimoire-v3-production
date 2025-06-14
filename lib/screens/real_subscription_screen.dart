import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RealSubscriptionScreen extends StatefulWidget {
  const RealSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<RealSubscriptionScreen> createState() => _RealSubscriptionScreenState();
}

class _RealSubscriptionScreenState extends State<RealSubscriptionScreen> {
  String _selectedPlan = 'monthly';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crystal Grimoire Premium',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentPlanStatus(),
            const SizedBox(height: 24),
            _buildPremiumFeatures(),
            const SizedBox(height: 24),
            _buildPricingPlans(),
            const SizedBox(height: 24),
            _buildUpgradeButton(),
            const SizedBox(height: 16),
            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6A4C93).withOpacity(0.3),
            const Color(0xFF9A7BB0).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6A4C93).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, color: Colors.amber, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan: Free',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Upgrade to unlock premium spiritual tools',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This month: 3/5 crystal identifications used',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6A4C93)),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    final features = [
      {
        'icon': Icons.diamond,
        'title': 'Unlimited Crystal ID',
        'description': '30+ identifications per day',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Advanced AI Guidance',
        'description': 'Personalized spiritual advice',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Cloud Sync',
        'description': 'Access data on all devices',
      },
      {
        'icon': Icons.psychology,
        'title': 'Birth Chart Analysis',
        'description': 'Detailed astrology insights',
      },
      {
        'icon': Icons.healing,
        'title': 'Crystal Healing Plans',
        'description': 'Customized healing protocols',
      },
      {
        'icon': Icons.support,
        'title': 'Priority Support',
        'description': '24/7 customer assistance',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6A4C93).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildFeatureItem(
            feature['icon'] as IconData,
            feature['title'] as String,
            feature['description'] as String,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A4C93).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Monthly Plan
        GestureDetector(
          onTap: () => setState(() => _selectedPlan = 'monthly'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _selectedPlan == 'monthly'
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF6A4C93).withOpacity(0.3),
                        const Color(0xFF9A7BB0).withOpacity(0.1),
                      ],
                    )
                  : null,
              color: _selectedPlan != 'monthly' 
                  ? const Color(0xFF1a1a2e).withOpacity(0.5)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPlan == 'monthly'
                    ? const Color(0xFF6A4C93)
                    : Colors.white24,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: 'monthly',
                  groupValue: _selectedPlan,
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                  activeColor: const Color(0xFF6A4C93),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Premium',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$9.99/month • Cancel anytime',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$9.99',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Annual Plan
        GestureDetector(
          onTap: () => setState(() => _selectedPlan = 'annual'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _selectedPlan == 'annual'
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF6A4C93).withOpacity(0.3),
                        const Color(0xFF9A7BB0).withOpacity(0.1),
                      ],
                    )
                  : null,
              color: _selectedPlan != 'annual' 
                  ? const Color(0xFF1a1a2e).withOpacity(0.5)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPlan == 'annual'
                    ? const Color(0xFF6A4C93)
                    : Colors.white24,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: 'annual',
                  groupValue: _selectedPlan,
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                  activeColor: const Color(0xFF6A4C93),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Annual Premium',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '17% OFF',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$99.99/year • Best value',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$99.99',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '\$8.33/mo',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleUpgrade,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A4C93),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Upgrade to Premium',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Secure Payment',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment is secured by Stripe. Cancel anytime in settings. No hidden fees.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpgrade() async {
    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // In real implementation, this would:
      // 1. Call Stripe payment processing
      // 2. Update user subscription in Firebase
      // 3. Enable premium features
      // 4. Send confirmation email
      
      if (mounted) {
        _showSuccessDialog();
      }
      
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Payment failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 16),
            Text(
              'Welcome to Premium!',
              style: GoogleFonts.cinzel(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Your ${_selectedPlan} subscription is now active. Enjoy unlimited crystal identifications and premium features!',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to account screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4C93),
            ),
            child: Text(
              'Start Exploring',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Payment Error',
          style: GoogleFonts.cinzel(color: Colors.red),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(color: const Color(0xFF6A4C93)),
            ),
          ),
        ],
      ),
    );
  }
}