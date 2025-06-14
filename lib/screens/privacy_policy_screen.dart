import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
          'Privacy Policy',
          style: GoogleFonts.cinzel(
            fontSize: 24,
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
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              'Data Collection',
              'We collect only the spiritual data you provide to enhance your crystal journey:\n\n'
              '• Birth chart information (date, time, location)\n'
              '• Crystal collection and notes\n'
              '• Journal entries and meditation logs\n'
              '• App usage patterns for personalization\n'
              '• Account information (name, email)',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'How We Use Your Data',
              'Your spiritual data is sacred to us. We use it to:\n\n'
              '• Provide personalized crystal recommendations\n'
              '• Generate accurate birth chart readings\n'
              '• Suggest relevant spiritual guidance\n'
              '• Improve app features and accuracy\n'
              '• Sync your data across devices',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Data Protection',
              'Your spiritual information is protected with:\n\n'
              '• End-to-end encryption for sensitive data\n'
              '• Secure Firebase cloud storage\n'
              '• Local device encryption\n'
              '• Regular security audits\n'
              '• No third-party data sharing',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Your Rights',
              'You have complete control over your spiritual data:\n\n'
              '• Export all your data at any time\n'
              '• Delete your account and all data\n'
              '• Modify privacy settings\n'
              '• Opt out of analytics\n'
              '• Request data corrections',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Third-Party Services',
              'We use trusted services to enhance your experience:\n\n'
              '• Firebase (Google) for secure data storage\n'
              '• Gemini AI for crystal identification\n'
              '• Stripe for secure payment processing\n'
              '• Analytics for app improvement\n\n'
              'All partners are bound by strict privacy agreements.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Spiritual Data Ethics',
              'We respect the sacred nature of spiritual information:\n\n'
              '• Your birth chart remains private and encrypted\n'
              '• Journal entries are never shared or analyzed\n'
              '• Crystal collection data stays confidential\n'
              '• AI insights are generated locally when possible\n'
              '• Cultural and spiritual traditions are honored',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Children\'s Privacy',
              'Crystal Grimoire is designed for users 13+ years old. We do not knowingly collect data from children under 13. If you believe a child has provided us with personal information, please contact us immediately.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Updates to Privacy Policy',
              'This privacy policy may be updated to reflect new features or legal requirements. We will notify you of any significant changes through the app or email.',
            ),
            const SizedBox(height: 32),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              const Icon(Icons.security, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Your Spiritual Privacy Matters',
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: June 13, 2025\n\n'
            'Crystal Grimoire respects the sacred nature of your spiritual journey. This privacy policy explains how we protect your birth chart, crystal collection, and personal spiritual data.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6A4C93).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90E2).withOpacity(0.3),
            const Color(0xFF7BB3F0).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7BB3F0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.email,
            'Email',
            'phillips.paul.email@gmail.com',
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.business,
            'Developer',
            'Paul Phillips (domusgpt)',
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.location_on,
            'Location',
            'United States',
          ),
          const SizedBox(height: 16),
          Text(
            'If you have any questions about this privacy policy or how we handle your spiritual data, please don\'t hesitate to reach out. Your privacy and spiritual journey are important to us.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}