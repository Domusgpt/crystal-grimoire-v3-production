import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Production-ready Settings Service with Firebase sync and full functionality
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Settings state
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _soundEnabled = true;
  bool _hapticFeedback = true;
  bool _moonPhaseAlertsEnabled = true;
  String _selectedTheme = 'Cosmic Purple';
  String _selectedLanguage = 'English';
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _eveningReminderTime = const TimeOfDay(hour: 18, minute: 0);
  
  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get hapticFeedback => _hapticFeedback;
  bool get moonPhaseAlertsEnabled => _moonPhaseAlertsEnabled;
  String get selectedTheme => _selectedTheme;
  String get selectedLanguage => _selectedLanguage;
  TimeOfDay get morningReminderTime => _morningReminderTime;
  TimeOfDay get eveningReminderTime => _eveningReminderTime;

  /// Initialize settings service
  Future<void> initialize() async {
    try {
      // Initialize notifications
      await _initializeNotifications();
      
      // Load settings from local storage
      await _loadLocalSettings();
      
      // Sync with Firebase if user is logged in
      if (_auth.currentUser != null) {
        await _syncWithFirebase();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Settings initialization error: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    
    // Request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
    _moonPhaseAlertsEnabled = prefs.getBool('moon_phase_alerts') ?? true;
    _selectedTheme = prefs.getString('selected_theme') ?? 'Cosmic Purple';
    _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    
    // Load reminder times
    final morningHour = prefs.getInt('morning_reminder_hour') ?? 9;
    final morningMinute = prefs.getInt('morning_reminder_minute') ?? 0;
    _morningReminderTime = TimeOfDay(hour: morningHour, minute: morningMinute);
    
    final eveningHour = prefs.getInt('evening_reminder_hour') ?? 18;
    final eveningMinute = prefs.getInt('evening_reminder_minute') ?? 0;
    _eveningReminderTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);
  }

  /// Sync settings with Firebase
  Future<void> _syncWithFirebase() async {
    if (_auth.currentUser == null) return;
    
    try {
      final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
      final settingsDoc = await userDoc.collection('settings').doc('preferences').get();
      
      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        
        _notificationsEnabled = data['notifications_enabled'] ?? _notificationsEnabled;
        _darkModeEnabled = data['dark_mode_enabled'] ?? _darkModeEnabled;
        _soundEnabled = data['sound_enabled'] ?? _soundEnabled;
        _hapticFeedback = data['haptic_feedback'] ?? _hapticFeedback;
        _moonPhaseAlertsEnabled = data['moon_phase_alerts'] ?? _moonPhaseAlertsEnabled;
        _selectedTheme = data['selected_theme'] ?? _selectedTheme;
        _selectedLanguage = data['selected_language'] ?? _selectedLanguage;
        
        // Load reminder times from Firebase
        if (data['morning_reminder_time'] != null) {
          final morningTime = data['morning_reminder_time'] as Map<String, dynamic>;
          _morningReminderTime = TimeOfDay(
            hour: morningTime['hour'] ?? 9,
            minute: morningTime['minute'] ?? 0,
          );
        }
        
        if (data['evening_reminder_time'] != null) {
          final eveningTime = data['evening_reminder_time'] as Map<String, dynamic>;
          _eveningReminderTime = TimeOfDay(
            hour: eveningTime['hour'] ?? 18,
            minute: eveningTime['minute'] ?? 0,
          );
        }
        
        // Apply loaded settings
        await _saveLocalSettings();
        await _updateNotificationSchedule();
      }
    } catch (e) {
      debugPrint('Firebase sync error: $e');
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('haptic_feedback', _hapticFeedback);
    await prefs.setBool('moon_phase_alerts', _moonPhaseAlertsEnabled);
    await prefs.setString('selected_theme', _selectedTheme);
    await prefs.setString('selected_language', _selectedLanguage);
    
    // Save reminder times
    await prefs.setInt('morning_reminder_hour', _morningReminderTime.hour);
    await prefs.setInt('morning_reminder_minute', _morningReminderTime.minute);
    await prefs.setInt('evening_reminder_hour', _eveningReminderTime.hour);
    await prefs.setInt('evening_reminder_minute', _eveningReminderTime.minute);
  }

  /// Save settings to Firebase
  Future<void> _saveToFirebase() async {
    if (_auth.currentUser == null) return;
    
    try {
      final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
      
      await userDoc.collection('settings').doc('preferences').set({
        'notifications_enabled': _notificationsEnabled,
        'dark_mode_enabled': _darkModeEnabled,
        'sound_enabled': _soundEnabled,
        'haptic_feedback': _hapticFeedback,
        'moon_phase_alerts': _moonPhaseAlertsEnabled,
        'selected_theme': _selectedTheme,
        'selected_language': _selectedLanguage,
        'morning_reminder_time': {
          'hour': _morningReminderTime.hour,
          'minute': _morningReminderTime.minute,
        },
        'evening_reminder_time': {
          'hour': _eveningReminderTime.hour,
          'minute': _eveningReminderTime.minute,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firebase save error: $e');
    }
  }

  /// Toggle daily reminders
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveLocalSettings();
    await _saveToFirebase();
    await _updateNotificationSchedule();
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode(bool enabled) async {
    _darkModeEnabled = enabled;
    await _saveLocalSettings();
    await _saveToFirebase();
    notifyListeners();
  }

  /// Toggle sound effects
  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    await _saveLocalSettings();
    await _saveToFirebase();
    notifyListeners();
  }

  /// Toggle haptic feedback
  Future<void> toggleHapticFeedback(bool enabled) async {
    _hapticFeedback = enabled;
    await _saveLocalSettings();
    await _saveToFirebase();
    notifyListeners();
  }

  /// Toggle moon phase alerts
  Future<void> toggleMoonPhaseAlerts(bool enabled) async {
    _moonPhaseAlertsEnabled = enabled;
    await _saveLocalSettings();
    await _saveToFirebase();
    await _updateMoonPhaseNotifications();
    notifyListeners();
  }

  /// Update theme selection
  Future<void> updateTheme(String theme) async {
    _selectedTheme = theme;
    await _saveLocalSettings();
    await _saveToFirebase();
    notifyListeners();
  }

  /// Update language selection
  Future<void> updateLanguage(String language) async {
    _selectedLanguage = language;
    await _saveLocalSettings();
    await _saveToFirebase();
    notifyListeners();
  }

  /// Update reminder times
  Future<void> updateReminderTimes({
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
  }) async {
    if (morningTime != null) _morningReminderTime = morningTime;
    if (eveningTime != null) _eveningReminderTime = eveningTime;
    
    await _saveLocalSettings();
    await _saveToFirebase();
    await _updateNotificationSchedule();
    notifyListeners();
  }

  /// Update notification schedule
  Future<void> _updateNotificationSchedule() async {
    // Cancel existing notifications
    await _notifications.cancelAll();
    
    if (!_notificationsEnabled) return;
    
    // Schedule daily reminders
    await _scheduleDailyReminder(
      id: 1,
      title: 'Crystal Meditation Time 🔮',
      body: 'Take a moment to connect with your crystals and set your intentions.',
      time: _morningReminderTime,
    );
    
    await _scheduleDailyReminder(
      id: 2,
      title: 'Evening Reflection ✨',
      body: 'Reflect on your day and express gratitude with your crystal companions.',
      time: _eveningReminderTime,
    );
  }

  /// Schedule a daily reminder
  Future<void> _scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily spiritual practice reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Update moon phase notifications
  Future<void> _updateMoonPhaseNotifications() async {
    // Cancel existing moon phase notifications
    for (int i = 10; i < 20; i++) {
      await _notifications.cancel(i);
    }
    
    if (!_moonPhaseAlertsEnabled) return;
    
    // Calculate next moon phases and schedule notifications
    await _scheduleMoonPhaseNotifications();
  }

  /// Schedule moon phase notifications
  Future<void> _scheduleMoonPhaseNotifications() async {
    // Simplified moon phase calculation
    final now = DateTime.now();
    final daysInCycle = 29.5;
    final nextNewMoon = _calculateNextMoonPhase(now, 'new');
    final nextFullMoon = _calculateNextMoonPhase(now, 'full');
    
    // Schedule new moon notification
    if (nextNewMoon.isAfter(now)) {
      await _scheduleNotification(
        id: 10,
        title: 'New Moon Tonight 🌑',
        body: 'Perfect time for new beginnings and setting intentions with your crystals.',
        scheduledDate: nextNewMoon.subtract(const Duration(hours: 2)),
      );
    }
    
    // Schedule full moon notification
    if (nextFullMoon.isAfter(now)) {
      await _scheduleNotification(
        id: 11,
        title: 'Full Moon Tonight 🌕',
        body: 'Harness the powerful energy for manifestation and crystal charging.',
        scheduledDate: nextFullMoon.subtract(const Duration(hours: 2)),
      );
    }
  }

  /// Calculate next moon phase (simplified)
  DateTime _calculateNextMoonPhase(DateTime date, String phase) {
    // Simplified calculation - in production would use proper lunar ephemeris
    final daysSinceEpoch = date.difference(DateTime(2000, 1, 6)).inDays;
    final cyclePosition = daysSinceEpoch % 29.5;
    
    double targetPhase;
    switch (phase) {
      case 'new':
        targetPhase = 0;
        break;
      case 'full':
        targetPhase = 14.75;
        break;
      default:
        targetPhase = 0;
    }
    
    double daysToPhase = targetPhase - cyclePosition;
    if (daysToPhase <= 0) daysToPhase += 29.5;
    
    return date.add(Duration(days: daysToPhase.round()));
  }

  /// Schedule a specific notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'moon_phases',
          'Moon Phase Alerts',
          channelDescription: 'Notifications for moon phase changes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Get theme colors based on selection
  Map<String, Color> getThemeColors() {
    switch (_selectedTheme) {
      case 'Cosmic Purple':
        return {
          'primary': const Color(0xFF6A4C93),
          'accent': const Color(0xFF9A7BB0),
          'background': const Color(0xFF0F0F23),
        };
      case 'Mystic Blue':
        return {
          'primary': const Color(0xFF4A90E2),
          'accent': const Color(0xFF7BB3F0),
          'background': const Color(0xFF0A1628),
        };
      case 'Forest Green':
        return {
          'primary': const Color(0xFF2E7D32),
          'accent': const Color(0xFF66BB6A),
          'background': const Color(0xFF0D1B0F),
        };
      case 'Ruby Red':
        return {
          'primary': const Color(0xFFD32F2F),
          'accent': const Color(0xFFEF5350),
          'background': const Color(0xFF1C0A0A),
        };
      default:
        return {
          'primary': const Color(0xFF6A4C93),
          'accent': const Color(0xFF9A7BB0),
          'background': const Color(0xFF0F0F23),
        };
    }
  }

  /// Get available themes
  List<String> get availableThemes => [
    'Cosmic Purple',
    'Mystic Blue', 
    'Forest Green',
    'Ruby Red',
  ];

  /// Get available languages
  List<String> get availableLanguages => [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
  ];

  /// Export user settings as JSON
  Map<String, dynamic> exportSettings() {
    return {
      'notifications_enabled': _notificationsEnabled,
      'dark_mode_enabled': _darkModeEnabled,
      'sound_enabled': _soundEnabled,
      'haptic_feedback': _hapticFeedback,
      'moon_phase_alerts': _moonPhaseAlertsEnabled,
      'selected_theme': _selectedTheme,
      'selected_language': _selectedLanguage,
      'morning_reminder': {
        'hour': _morningReminderTime.hour,
        'minute': _morningReminderTime.minute,
      },
      'evening_reminder': {
        'hour': _eveningReminderTime.hour,
        'minute': _eveningReminderTime.minute,
      },
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    _notificationsEnabled = settings['notifications_enabled'] ?? _notificationsEnabled;
    _darkModeEnabled = settings['dark_mode_enabled'] ?? _darkModeEnabled;
    _soundEnabled = settings['sound_enabled'] ?? _soundEnabled;
    _hapticFeedback = settings['haptic_feedback'] ?? _hapticFeedback;
    _moonPhaseAlertsEnabled = settings['moon_phase_alerts'] ?? _moonPhaseAlertsEnabled;
    _selectedTheme = settings['selected_theme'] ?? _selectedTheme;
    _selectedLanguage = settings['selected_language'] ?? _selectedLanguage;
    
    if (settings['morning_reminder'] != null) {
      final morning = settings['morning_reminder'];
      _morningReminderTime = TimeOfDay(
        hour: morning['hour'] ?? 9,
        minute: morning['minute'] ?? 0,
      );
    }
    
    if (settings['evening_reminder'] != null) {
      final evening = settings['evening_reminder'];
      _eveningReminderTime = TimeOfDay(
        hour: evening['hour'] ?? 18,
        minute: evening['minute'] ?? 0,
      );
    }
    
    await _saveLocalSettings();
    await _saveToFirebase();
    await _updateNotificationSchedule();
    await _updateMoonPhaseNotifications();
    notifyListeners();
  }
}