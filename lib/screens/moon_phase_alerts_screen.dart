import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

class MoonPhaseAlertsScreen extends StatefulWidget {
  const MoonPhaseAlertsScreen({Key? key}) : super(key: key);

  @override
  State<MoonPhaseAlertsScreen> createState() => _MoonPhaseAlertsScreenState();
}

class _MoonPhaseAlertsScreenState extends State<MoonPhaseAlertsScreen> {
  bool _moonPhaseAlertsEnabled = true;
  bool _newMoonAlerts = true;
  bool _fullMoonAlerts = true;
  bool _firstQuarterAlerts = false;
  bool _lastQuarterAlerts = false;
  String _alertTiming = '2 hours before';

  @override
  void initState() {
    super.initState();
    final settings = SettingsService();
    _moonPhaseAlertsEnabled = settings.moonPhaseAlertsEnabled;
  }

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
          'Moon Phase Alerts',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              'Get notified about moon phases to optimize your crystal practices',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            
            // Master Toggle
            _buildToggleOption(
              title: 'Moon Phase Alerts',
              subtitle: 'Enable all moon phase notifications',
              value: _moonPhaseAlertsEnabled,
              onChanged: (value) {
                setState(() {
                  _moonPhaseAlertsEnabled = value;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Individual Phase Toggles
            if (_moonPhaseAlertsEnabled) ...[
              Text(
                'Which phases to track:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPhaseOption(
                title: 'New Moon 🌑',
                subtitle: 'Perfect for new intentions and beginnings',
                value: _newMoonAlerts,
                onChanged: (value) {
                  setState(() {
                    _newMoonAlerts = value;
                  });
                },
              ),
              
              _buildPhaseOption(
                title: 'Full Moon 🌕',
                subtitle: 'Ideal for manifestation and crystal charging',
                value: _fullMoonAlerts,
                onChanged: (value) {
                  setState(() {
                    _fullMoonAlerts = value;
                  });
                },
              ),
              
              _buildPhaseOption(
                title: 'First Quarter 🌓',
                subtitle: 'Time for action and overcoming challenges',
                value: _firstQuarterAlerts,
                onChanged: (value) {
                  setState(() {
                    _firstQuarterAlerts = value;
                  });
                },
              ),
              
              _buildPhaseOption(
                title: 'Last Quarter 🌗',
                subtitle: 'Release what no longer serves you',
                value: _lastQuarterAlerts,
                onChanged: (value) {
                  setState(() {
                    _lastQuarterAlerts = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Alert Timing
              Text(
                'Alert timing:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTimingSelector(),
            ],
            
            const Spacer(),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4C93),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Moon Phase Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6A4C93).withOpacity(0.3),
            const Color(0xFF9A7BB0).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6A4C93).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6A4C93),
          activeTrackColor: const Color(0xFF9A7BB0).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildPhaseOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6A4C93).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6A4C93),
            activeTrackColor: const Color(0xFF9A7BB0).withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTimingSelector() {
    final timingOptions = [
      '30 minutes before',
      '1 hour before',
      '2 hours before',
      '4 hours before',
      'Day of',
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6A4C93).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _alertTiming,
          isExpanded: true,
          dropdownColor: const Color(0xFF1a1a2e),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
          items: timingOptions.map((String timing) {
            return DropdownMenuItem<String>(
              value: timing,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(timing),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _alertTiming = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final settings = SettingsService();
    
    await settings.toggleMoonPhaseAlerts(_moonPhaseAlertsEnabled);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Moon phase alert settings saved!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6A4C93),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      Navigator.pop(context);
    }
  }
}