import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../services/app_state.dart';
import '../services/collection_service_v2.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/scheduled_ritual.dart'; // Added
import '../services/storage_service.dart'; // Added
import 'package:intl/intl.dart'; // Added
import '../widgets/common/mystical_card.dart'; // Assuming this exists for styling scheduled rituals

class MoonRitualScreen extends StatefulWidget {
  const MoonRitualScreen({Key? key}) : super(key: key);

  @override
  State<MoonRitualScreen> createState() => _MoonRitualScreenState();
}

class _MoonRitualScreenState extends State<MoonRitualScreen> {
  String selectedPhase = 'Waxing Crescent';
  List<String> recommendedCrystals = [];
  List<ScheduledRitual> _scheduledRituals = []; // Added
  bool _isLoadingRituals = true; // Added
  
  final Map<String, Map<String, dynamic>> moonPhaseData = {
    'New Moon': {
      'meaning': 'New beginnings, setting intentions',
      'crystals': ['Black Moonstone', 'Labradorite', 'Clear Quartz'],
      'ritual': 'Write down your intentions for the lunar cycle',
      'affirmation': 'I plant seeds of intention that will bloom with the moon',
    },
    'Waxing Crescent': {
      'meaning': 'Growth, manifestation, taking action',
      'crystals': ['Citrine', 'Green Aventurine', 'Pyrite'],
      'ritual': 'Charge your crystals under moonlight',
      'affirmation': 'I nurture my dreams into reality',
    },
    'First Quarter': {
      'meaning': 'Challenges, decisions, commitment',
      'crystals': ['Carnelian', 'Red Jasper', 'Tiger Eye'],
      'ritual': 'Meditate on obstacles and solutions',
      'affirmation': 'I face challenges with courage and wisdom',
    },
    'Waxing Gibbous': {
      'meaning': 'Refinement, adjustment, patience',
      'crystals': ['Rose Quartz', 'Rhodonite', 'Pink Tourmaline'],
      'ritual': 'Practice gratitude for progress made',
      'affirmation': 'I trust in divine timing',
    },
    'Full Moon': {
      'meaning': 'Culmination, release, gratitude',
      'crystals': ['Selenite', 'Moonstone', 'Clear Quartz'],
      'ritual': 'Release what no longer serves you',
      'affirmation': 'I release and receive with grace',
    },
    'Waning Gibbous': {
      'meaning': 'Gratitude, sharing, generosity',
      'crystals': ['Amethyst', 'Lepidolite', 'Blue Lace Agate'],
      'ritual': 'Share your wisdom and abundance',
      'affirmation': 'I am grateful for all I have learned',
    },
    'Last Quarter': {
      'meaning': 'Release, forgiveness, letting go',
      'crystals': ['Smoky Quartz', 'Black Tourmaline', 'Obsidian'],
      'ritual': 'Cleanse your space and crystals',
      'affirmation': 'I release the past with love',
    },
    'Waning Crescent': {
      'meaning': 'Rest, reflection, preparation',
      'crystals': ['Selenite', 'Celestite', 'Blue Calcite'],
      'ritual': 'Rest and prepare for the new cycle',
      'affirmation': 'I honor the cycles of rest and action',
    },
  };

  @override
  void initState() {
    super.initState();
    _updateRecommendedCrystals();
    _loadScheduledRitualsFromStorage(); // Added
  }

  Future<void> _loadScheduledRitualsFromStorage() async {
    if (!mounted) return;
    setState(() {
      _isLoadingRituals = true;
    });
    _scheduledRituals = await StorageService.loadScheduledRituals();
    if (!mounted) return;
    setState(() {
      _isLoadingRituals = false;
    });
  }

  void _updateRecommendedCrystals() {
    final collectionService = context.read<CollectionServiceV2>();
    final phaseCrystals = moonPhaseData[selectedPhase]!['crystals'] as List<String>;
    
    // Filter to show only crystals the user owns
    recommendedCrystals = collectionService.collection
        .where((entry) => phaseCrystals.contains(entry.crystal.name))
        .map((entry) => entry.crystal.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile>(context);
    final theme = Theme.of(context); // Get theme for paywall consistency

    if (!userProfile.hasAccessTo('moon_rituals')) {
      // Using a paywall structure similar to JournalScreen
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Moon Rituals',
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
        ),
        body: Stack( // Using Stack to allow potential background effects like FloatingParticles
          children: [
            Container( // Background gradient consistent with the screen's theme
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0015), // Dark top
                    Color(0xFF1A0B2E), // Mid
                    Color(0xFF2D1B69), // Lighter bottom (matching screen's active theme)
                  ],
                ),
              ),
            ),
            // Optional: Add FloatingParticles if desired, like in JournalScreen
            // const FloatingParticles(particleCount: 15, color: Colors.purpleAccent),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: MysticalCard( // Using MysticalCard for consistent themed container
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.nightlight_round, // Icon related to Moon Rituals
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Unlock Moon Rituals',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This is a Pro feature. Please upgrade your subscription to unlock this mystical journey and align with lunar energies.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon( // Using ElevatedButton for now, can be MysticalButton
                          icon: const Icon(Icons.star_border_purple500_sharp),
                          label: const Text('Upgrade to Pro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: theme.textTheme.titleMedium,
                          ),
                          onPressed: () {
                            // TODO: Navigate to subscription page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigate to subscription page (Not Implemented)')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Moon Rituals',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Mystical background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0015),
                  Color(0xFF1A0B2E),
                  Color(0xFF2D1B69),
                ],
              ),
            ),
          ),
          
          // Stars effect
          ...List.generate(50, (index) {
            return Positioned(
              top: (index * 37.0) % MediaQuery.of(context).size.height,
              left: (index * 47.0) % MediaQuery.of(context).size.width,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Moon phase selector
                  _buildMoonPhaseSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Current phase info
                  _buildPhaseInfoCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Recommended crystals
                  _buildRecommendedCrystals(),
                  
                  const SizedBox(height: 24),
                  
                  // Ritual guidance
                  _buildRitualGuidance(),
                  
                  const SizedBox(height: 24),
                  
                  // Schedule ritual button
                  _buildScheduleButton(),

                  const SizedBox(height: 32), // Spacing before the list

                  // Display Scheduled Rituals
                  _buildScheduledRitualsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonPhaseSelector() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: moonPhaseData.keys.length,
        itemBuilder: (context, index) {
          final phase = moonPhaseData.keys.elementAt(index);
          final isSelected = phase == selectedPhase;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPhase = phase;
                _updateRecommendedCrystals();
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      )
                    : null,
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white30,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getMoonIcon(index),
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phase.split(' ').first,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getMoonIcon(int index) {
    final icons = [
      Icons.brightness_3, // New Moon
      Icons.brightness_2, // Waxing Crescent
      Icons.brightness_medium, // First Quarter
      Icons.brightness_4, // Waxing Gibbous
      Icons.brightness_1, // Full Moon
      Icons.brightness_5, // Waning Gibbous
      Icons.brightness_6, // Last Quarter
      Icons.brightness_7, // Waning Crescent
    ];
    return icons[index % icons.length];
  }

  Widget _buildPhaseInfoCard() {
    final phaseInfo = moonPhaseData[selectedPhase]!;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedPhase,
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                phaseInfo['meaning'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.format_quote,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        phaseInfo['affirmation'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCrystals() {
    final phaseCrystals = moonPhaseData[selectedPhase]!['crystals'] as List<String>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Crystals',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: phaseCrystals.length,
            itemBuilder: (context, index) {
              final crystal = phaseCrystals[index];
              final isOwned = recommendedCrystals.contains(crystal);
              
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: isOwned 
                              ? const Color(0xFF10B981).withOpacity(0.5)
                              : Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.diamond,
                            color: isOwned 
                                ? const Color(0xFF10B981) 
                                : Colors.white60,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            crystal,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isOwned) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Owned',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRitualGuidance() {
    final ritual = moonPhaseData[selectedPhase]!['ritual'];
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ritual Suggestion',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                ritual,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)), // Allow scheduling for up to a year
              builder: (context, child) { // Optional: Theming the date picker
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: const Color(0xFF6366F1), // Header background
                      onPrimary: Colors.white, // Header text
                      onSurface: Colors.white70, // Body text
                    ),
                    dialogBackgroundColor: const Color(0xFF1A0B2E),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              final ritualName = moonPhaseData[selectedPhase]?['ritual'] as String? ?? 'Moon Ritual';
              final newRitual = ScheduledRitual(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                moonPhase: selectedPhase,
                ritualName: ritualName,
                scheduledDate: pickedDate,
              );

              _scheduledRituals.add(newRitual);
              await StorageService.saveScheduledRituals(_scheduledRituals);

              if(mounted) {
                setState(() {}); // Refresh UI to show the new ritual in the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${newRitual.ritualName} scheduled for ${DateFormat('yyyy-MM-dd').format(pickedDate)}!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  'Schedule Ritual',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledRitualsList() {
    if (_isLoadingRituals) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final theme = Theme.of(context); // For text styles

    if (_scheduledRituals.isEmpty) {
      return Center(
        child: Column( // Added Column for Icon + Text
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No rituals scheduled yet.',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Scheduled Rituals',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _scheduledRituals.length,
          itemBuilder: (context, index) {
            final ritual = _scheduledRituals[index];
            TextStyle titleStyle = GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: ritual.isCompleted ? Colors.white.withOpacity(0.5) : Colors.white,
              decoration: ritual.isCompleted ? TextDecoration.lineThrough : null,
            );
            TextStyle subtitleStyle = GoogleFonts.poppins(
              color: ritual.isCompleted ? Colors.white.withOpacity(0.4) : Colors.white70,
              decoration: ritual.isCompleted ? TextDecoration.lineThrough : null,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: MysticalCard(
                child: CheckboxListTile(
                  title: Text(ritual.ritualName, style: titleStyle),
                  subtitle: Text(
                    '${ritual.moonPhase} - ${DateFormat('EEE, MMM d, yyyy').format(ritual.scheduledDate)}',
                    style: subtitleStyle,
                  ),
                  value: ritual.isCompleted,
                  onChanged: (bool? newValue) async {
                    if (newValue == null) return;
                    setState(() {
                      ritual.isCompleted = newValue;
                    });
                    await StorageService.saveScheduledRituals(_scheduledRituals);
                    // Optionally, show a snackbar or confirmation
                  },
                  activeColor: theme.colorScheme.primary.withOpacity(0.7),
                  checkColor: Colors.white,
                  secondary: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.7)),
                    tooltip: "Delete Ritual",
                    onPressed: () async {
                      final bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text('Are you sure you want to delete the ritual "${ritual.ritualName}"?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        _scheduledRituals.removeWhere((r) => r.id == ritual.id);
                        await StorageService.saveScheduledRituals(_scheduledRituals);
                        if(mounted) setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${ritual.ritualName} removed.', style: GoogleFonts.poppins()),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                  controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                  tileColor: ritual.isCompleted ? Colors.white.withOpacity(0.05) : Colors.transparent,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}