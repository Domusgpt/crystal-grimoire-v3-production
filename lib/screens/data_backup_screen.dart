import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/settings_service.dart';
import '../models/user_profile.dart';

class DataBackupScreen extends StatefulWidget {
  const DataBackupScreen({Key? key}) : super(key: key);

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  DateTime? _lastBackupDate;
  int _crystalCount = 0;
  int _journalEntries = 0;
  double _backupSize = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }

  Future<void> _loadBackupInfo() async {
    // Load actual backup information
    setState(() {
      // Mock data - replace with actual backup info
      _lastBackupDate = DateTime.now().subtract(const Duration(days: 3));
      _crystalCount = 12;
      _journalEntries = 8;
      _backupSize = 2.3;
    });
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
          'Sync & Backup',
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
            _buildBackupStatus(),
            const SizedBox(height: 24),
            _buildDataSummary(),
            const SizedBox(height: 24),
            _buildBackupActions(),
            const SizedBox(height: 24),
            _buildAutoBackupSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupStatus() {
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
          Row(
            children: [
              Icon(
                _lastBackupDate != null ? Icons.cloud_done : Icons.cloud_off,
                color: _lastBackupDate != null ? Colors.green : Colors.orange,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup Status',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _lastBackupDate != null 
                          ? 'Last backup: ${_formatDate(_lastBackupDate!)}'
                          : 'No backup found',
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
          Row(
            children: [
              Icon(Icons.storage, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Backup size: ${_backupSize.toStringAsFixed(1)} MB',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummary() {
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
            'Your Data',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDataItem(
            icon: Icons.diamond,
            label: 'Crystal Collection',
            value: '$_crystalCount crystals',
          ),
          const SizedBox(height: 12),
          _buildDataItem(
            icon: Icons.book,
            label: 'Journal Entries',
            value: '$_journalEntries entries',
          ),
          const SizedBox(height: 12),
          _buildDataItem(
            icon: Icons.person,
            label: 'Profile & Settings',
            value: 'Birth chart, preferences',
          ),
          const SizedBox(height: 12),
          _buildDataItem(
            icon: Icons.insights,
            label: 'Usage Analytics',
            value: 'Session history, patterns',
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackupActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Backup Actions',
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Create Backup Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isBackingUp ? null : _createBackup,
            icon: _isBackingUp 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup),
            label: Text(
              _isBackingUp ? 'Creating Backup...' : 'Create Backup Now',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Restore Backup Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isRestoring ? null : _showRestoreDialog,
            icon: _isRestoring 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.restore),
            label: Text(
              _isRestoring ? 'Restoring...' : 'Restore from Backup',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF6A4C93)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Export Data Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            label: Text(
              'Export Data (JSON)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoBackupSettings() {
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
            'Auto-Backup Settings',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: Text(
              'Daily Auto-Backup',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'Automatically backup your data every day',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            value: true,
            onChanged: (value) {
              // Implement auto-backup toggle
            },
            activeColor: const Color(0xFF66BB6A),
            contentPadding: EdgeInsets.zero,
          ),
          
          SwitchListTile(
            title: Text(
              'Cloud Sync',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'Sync data across all your devices',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            value: true,
            onChanged: (value) {
              // Implement cloud sync toggle
            },
            activeColor: const Color(0xFF66BB6A),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);

    try {
      // Simulate backup creation
      await Future.delayed(const Duration(seconds: 2));
      
      // In real implementation, this would:
      // 1. Collect all user data
      // 2. Create encrypted backup
      // 3. Upload to Firebase Storage
      // 4. Update backup metadata
      
      setState(() {
        _lastBackupDate = DateTime.now();
        _backupSize = 2.5; // Update size
      });
      
      _showSuccessSnackbar('Backup created successfully!');
      
    } catch (e) {
      _showErrorSnackbar('Backup failed: $e');
    } finally {
      setState(() => _isBackingUp = false);
    }
  }

  Future<void> _showRestoreDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Restore from Backup',
          style: GoogleFonts.cinzel(color: Colors.white),
        ),
        content: Text(
          'This will replace all current data with your backup. This action cannot be undone.\n\nAre you sure you want to continue?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreBackup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4C93),
            ),
            child: Text(
              'Restore',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup() async {
    setState(() => _isRestoring = true);

    try {
      // Simulate restore process
      await Future.delayed(const Duration(seconds: 3));
      
      // In real implementation, this would:
      // 1. Download backup from Firebase Storage
      // 2. Decrypt and validate backup
      // 3. Replace current data
      // 4. Restart app/reload data
      
      _showSuccessSnackbar('Data restored successfully!');
      
    } catch (e) {
      _showErrorSnackbar('Restore failed: $e');
    } finally {
      setState(() => _isRestoring = false);
    }
  }

  Future<void> _exportData() async {
    try {
      // Create exportable data structure
      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'version': '1.0',
        'user_profile': {
          'name': 'User Name',
          'email': 'user@example.com',
          'birth_chart': {
            'date': '1990-03-21',
            'time': '15:30',
            'location': 'Los Angeles, CA',
          },
        },
        'crystal_collection': [
          {
            'name': 'Amethyst',
            'type': 'Quartz',
            'color': 'Purple',
            'acquisition_date': '2024-01-15',
            'notes': 'For meditation',
          },
          // Add more crystals...
        ],
        'journal_entries': [
          {
            'date': '2024-06-10',
            'content': 'Great meditation session with amethyst today.',
            'mood': 'peaceful',
          },
          // Add more entries...
        ],
        'settings': {
          'notifications_enabled': true,
          'dark_mode': true,
          'theme': 'Cosmic Purple',
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // In real implementation, this would save to file or share
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          title: Text(
            'Data Export Ready',
            style: GoogleFonts.cinzel(color: Colors.white),
          ),
          content: Text(
            'Your data has been exported successfully!\n\nIn a production app, this would save the file to your device or share it via email/cloud storage.',
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
      _showErrorSnackbar('Export failed: $e');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}