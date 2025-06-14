import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

class ReminderTimesScreen extends StatefulWidget {
  const ReminderTimesScreen({Key? key}) : super(key: key);

  @override
  State<ReminderTimesScreen> createState() => _ReminderTimesScreenState();
}

class _ReminderTimesScreenState extends State<ReminderTimesScreen> {
  late TimeOfDay _morningTime;
  late TimeOfDay _eveningTime;

  @override
  void initState() {
    super.initState();
    final settings = SettingsService();
    _morningTime = settings.morningReminderTime;
    _eveningTime = settings.eveningReminderTime;
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
          'Reminder Times',
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
              'Set your daily spiritual practice reminders',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            
            // Morning Reminder
            _buildTimeSelector(
              title: 'Morning Meditation',
              subtitle: 'Start your day with crystal energy',
              icon: Icons.wb_sunny,
              time: _morningTime,
              onTap: () => _selectTime(context, true),
            ),
            
            const SizedBox(height: 24),
            
            // Evening Reminder  
            _buildTimeSelector(
              title: 'Evening Reflection',
              subtitle: 'End your day with gratitude',
              icon: Icons.nights_stay,
              time: _eveningTime,
              onTap: () => _selectTime(context, false),
            ),
            
            const SizedBox(height: 48),
            
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
                  'Save Reminder Times',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Text
            Text(
              'Reminders will be sent daily at the selected times. Make sure notifications are enabled in your device settings.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required TimeOfDay time,
    required VoidCallback onTap,
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
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6A4C93).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF9A7BB0),
            size: 24,
          ),
        ),
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time.format(context),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9A7BB0),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white60,
              size: 16,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isMorning) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: isMorning ? _morningTime : _eveningTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6A4C93),
              onPrimary: Colors.white,
              surface: Color(0xFF1a1a2e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        if (isMorning) {
          _morningTime = selectedTime;
        } else {
          _eveningTime = selectedTime;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    final settings = SettingsService();
    
    await settings.updateReminderTimes(
      morningTime: _morningTime,
      eveningTime: _eveningTime,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reminder times saved successfully!',
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