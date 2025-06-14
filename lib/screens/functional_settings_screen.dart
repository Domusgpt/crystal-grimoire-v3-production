import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';
import '../services/app_state.dart';
import 'reminder_times_screen.dart';
import 'moon_phase_alerts_screen.dart';

class FunctionalSettingsScreen extends StatefulWidget {
  const FunctionalSettingsScreen({Key? key}) : super(key: key);

  @override
  State<FunctionalSettingsScreen> createState() => _FunctionalSettingsScreenState();
}

class _FunctionalSettingsScreenState extends State<FunctionalSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    
    // Initialize settings service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SettingsService().initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsService>.value(
      value: SettingsService(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F23),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'SETTINGS',
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<SettingsService>(
            builder: (context, settings, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationsSection(settings),
                    const SizedBox(height: 24),
                    _buildAppearanceSection(settings),
                    const SizedBox(height: 24),
                    _buildDataSection(settings),
                    const SizedBox(height: 24),
                    _buildAboutSection(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(SettingsService settings) {
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
          Text(
            'NOTIFICATIONS',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Daily Reminders Toggle
          _buildToggleTile(
            icon: Icons.notifications_active,
            title: 'Daily Reminders',
            subtitle: 'Get gentle reminders for your spiritual practice',
            value: settings.notificationsEnabled,
            onChanged: (value) async {
              await settings.toggleNotifications(value);
              _showSuccessSnackbar('Daily reminders ${value ? 'enabled' : 'disabled'}');
            },
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Reminder Times
          _buildNavigationTile(
            icon: Icons.schedule,
            title: 'Reminder Times',
            subtitle: '${settings.morningReminderTime.format(context)}, ${settings.eveningReminderTime.format(context)}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReminderTimesScreen()),
            ),
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Moon Phase Alerts
          _buildNavigationTile(
            icon: Icons.brightness_3,
            title: 'Moon Phase Alerts',
            subtitle: settings.moonPhaseAlertsEnabled 
              ? 'Notifications for new moon phases'
              : 'Moon phase alerts disabled',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MoonPhaseAlertsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(SettingsService settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E7D32).withOpacity(0.3),
            const Color(0xFF66BB6A).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF66BB6A).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPEARANCE',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Theme Selector
          _buildDropdownTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: settings.selectedTheme,
            value: settings.selectedTheme,
            items: settings.availableThemes,
            onChanged: (value) async {
              if (value != null) {
                await settings.updateTheme(value);
                _showSuccessSnackbar('Theme changed to $value');
              }
            },
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Dark Mode Toggle
          _buildToggleTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Easy on the eyes for nighttime meditation',
            value: settings.darkModeEnabled,
            onChanged: (value) async {
              await settings.toggleDarkMode(value);
              _showSuccessSnackbar('Dark mode ${value ? 'enabled' : 'disabled'}');
            },
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Sound Effects Toggle
          _buildToggleTile(
            icon: Icons.volume_up,
            title: 'Sound Effects',
            subtitle: 'Audio feedback for interactions',
            value: settings.soundEnabled,
            onChanged: (value) async {
              await settings.toggleSound(value);
              _showSuccessSnackbar('Sound effects ${value ? 'enabled' : 'disabled'}');
            },
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Haptic Feedback Toggle
          _buildToggleTile(
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: 'Vibration feedback for touch interactions',
            value: settings.hapticFeedback,
            onChanged: (value) async {
              await settings.toggleHapticFeedback(value);
              _showSuccessSnackbar('Haptic feedback ${value ? 'enabled' : 'disabled'}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(SettingsService settings) {
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
            'DATA & PRIVACY',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Export Settings
          _buildActionTile(
            icon: Icons.download,
            title: 'Export Settings',
            subtitle: 'Download your settings as JSON file',
            onTap: () => _exportSettings(settings),
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Import Settings
          _buildActionTile(
            icon: Icons.upload,
            title: 'Import Settings',
            subtitle: 'Restore settings from backup file',
            onTap: () => _importSettings(settings),
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          // Sync with Firebase
          _buildActionTile(
            icon: Icons.sync,
            title: 'Sync Data',
            subtitle: 'Sync settings with your account',
            onTap: () => _syncData(settings),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD32F2F).withOpacity(0.3),
            const Color(0xFFEF5350).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEF5350).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: '2.0.0 (Build 42)',
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          _buildInfoTile(
            icon: Icons.policy,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
          ),
          
          const Divider(color: Colors.white24, height: 32),
          
          _buildInfoTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help with CrystalGrimoire',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6A4C93),
        activeTrackColor: const Color(0xFF9A7BB0).withOpacity(0.5),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white60,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF1a1a2e),
        style: GoogleFonts.poppins(color: Colors.white),
        underline: Container(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white60,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A4C93),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _exportSettings(SettingsService settings) async {
    try {
      final settingsData = settings.exportSettings();
      // In a real app, you'd save this to file or share it
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          title: Text(
            'Settings Exported',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Text(
            'Settings exported successfully!\n\nIn a production app, this would save to your device or cloud storage.',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(color: const Color(0xFF6A4C93)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSuccessSnackbar('Export failed: $e');
    }
  }

  Future<void> _importSettings(SettingsService settings) async {
    // In a real app, you'd pick a file and import it
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Import Settings',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'In a production app, this would let you select a backup file to restore your settings.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFF6A4C93)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncData(SettingsService settings) async {
    try {
      // Force sync with Firebase
      await settings.initialize();
      _showSuccessSnackbar('Settings synced successfully!');
    } catch (e) {
      _showSuccessSnackbar('Sync failed: $e');
    }
  }
}