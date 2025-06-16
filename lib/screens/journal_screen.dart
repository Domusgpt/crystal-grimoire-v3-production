import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../services/collection_service_v2.dart';
import '../models/user_profile.dart';
import '../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final List<JournalEntry> _entries = [];
  final TextEditingController _journalController = TextEditingController();
  bool _isWriting = false;
  bool _isLoading = true;
  String? _editingEntryId;

  // New state variables for additional entry data
  String? _currentMoonPhase;
  List<String> _selectedMoods = [];
  List<String> _selectedCrystalIds = []; // Stores crystalId from CollectionEntry
  List<CollectionEntry> _ownedCrystals = []; // From collection_models.dart

  late CollectionServiceV2 _collectionService;
  late AstrologyService _astrologyService; // Added

  // Predefined moods for ChoiceChips
  final List<String> _predefinedMoods = [
    "Happy", "Reflective", "Inspired", "Calm", "Grateful", "Energized", "Peaceful", "Anxious"
  ];

  @override
  void initState() {
    super.initState();
    _collectionService = Provider.of<CollectionServiceV2>(context, listen: false);
    _astrologyService = AstrologyService();
    _loadEntries();
    // Call _loadDataForWritingView only if starting in writing mode (e.g. for a new entry directly)
    // or when toggling to writing mode. For now, primarily called when _isWriting becomes true.
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // _fadeController.forward(); // Will be controlled by _isLoading or when data for writing view is ready
  }

  Future<void> _loadEntries() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final loadedEntries = await _collectionService.loadJournalEntries();
      if (!mounted) return;
      setState(() {
        _entries.clear();
        _entries.addAll(loadedEntries);
        _isLoading = false;
        // Ensure fade controller animates in, even if list was empty and remains empty.
        if (!_fadeController.isAnimating) {
          _fadeController.forward(from: 0.0);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading entries: ${e.toString()}'))
      );
    }
  }

  Future<void> _loadDataForWritingView() async {
    if (!mounted) return;
    // Show a loading indicator for this specific data if needed, separate from _isLoading for entries list
    // For simplicity, just fetching and updating state.
    try {
      // Fetch in parallel
      final results = await Future.wait([
        _astrologyService.getCurrentMoonPhase(),
        _collectionService.loadUserOwnedCrystals(),
      ]);
      if (!mounted) return;
      setState(() {
        _currentMoonPhase = results[0] as String;
        _ownedCrystals = results[1] as List<CollectionEntry>;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading support data for writing: ${e.toString()}'))
      );
      // Set default/error states if necessary
      setState(() {
        _currentMoonPhase = _currentMoonPhase ?? "Moon phase unavailable";
      });
    }
  }

  void _clearWritingSelections() {
    setState(() {
      _selectedMoods.clear();
      _selectedCrystalIds.clear();
      // _currentMoonPhase is not cleared here as it might be useful to keep the last fetched value
      // until the next explicit fetch by _loadDataForWritingView.
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final String fullText = _journalController.text.trim();
    if (fullText.isEmpty) return;

    String title = fullText.split('\n').first;
    if (title.length > 50) {
      title = title.substring(0, 50) + "...";
    } else if (title.isEmpty && fullText.isNotEmpty) {
      title = fullText.length > 50 ? fullText.substring(0, 50) + "..." : fullText;
    }
    if (title.isEmpty) {
      title = "Journal Entry";
    }

    try {
      if (_editingEntryId == null) {
        // Create new entry
        final newEntry = JournalEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Backend should ideally assign ID
          title: title,
          content: fullText,
          date: DateTime.now(),
          moodTags: List.from(_selectedMoods),
          crystalIdsUsed: List.from(_selectedCrystalIds),
          moonPhase: _currentMoonPhase,
        );
        await _collectionService.saveJournalEntry(newEntry);
      } else {
        // Update existing entry
        final existingEntry = _entries.firstWhere((e) => e.id == _editingEntryId);
        final updatedEntry = existingEntry.copyWith(
          title: title,
          content: fullText,
          date: existingEntry.date, // Keep original creation date for updates unless explicitly changing
          moodTags: List.from(_selectedMoods),
          crystalIdsUsed: List.from(_selectedCrystalIds),
          moonPhase: _currentMoonPhase, // Update moon phase to current on edit
        );
        await _collectionService.updateJournalEntry(updatedEntry);
      }

      if (!mounted) return;
      setState(() {
        _isWriting = false;
        _editingEntryId = null;
        _journalController.clear();
        _clearWritingSelections();
      });
      HapticFeedback.lightImpact();
      _loadEntries();
    } catch (e) {
      if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving entry: ${e.toString()}'))
        );
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this journal entry?'),
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

    if (confirmed == true) {
      try {
        await _collectionService.deleteJournalEntry(entryId);
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        _loadEntries(); // Refresh list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: ${e.toString()}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = Provider.of<UserProfile>(context);

    if (!userProfile.hasAccessTo('journal')) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: ShimmeringText(
            text: 'Journal',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.background,
                    theme.colorScheme.primary.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            const FloatingParticles(
              particleCount: 15,
              color: Colors.purpleAccent,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: MysticalCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Journaling is a Pro feature',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please upgrade your subscription to document your spiritual journey and unlock deeper insights.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        MysticalButton(
                          text: 'Upgrade to Pro',
                          onPressed: () {
                            // TODO: Navigate to subscription page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Navigate to subscription page (Not Implemented)')),
                            );
                          },
                          icon: Icons.star,
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          ),
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
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.background,
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Floating particles
          const FloatingParticles(
            particleCount: 15,
            color: Colors.purpleAccent,
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ShimmeringText(
                            text: 'Journal',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isWriting ? Icons.view_list : Icons.add_circle_outline),
                          tooltip: _isWriting ? "View Entries" : "New Entry",
                          onPressed: () {
                            setState(() {
                              if (_isWriting) {
                                // Was writing (either new or editing), now switching to list view
                                _isWriting = false;
                                _editingEntryId = null; // Clear editing state regardless
                                _journalController.clear();
                                _clearWritingSelections();
                              } else {
                                // Was in list view, now switching to writing view for a NEW entry
                                _isWriting = true;
                                _editingEntryId = null;
                                _journalController.clear();
                                _clearWritingSelections();
                                _loadDataForWritingView(); // Load fresh data for new entry
                              }
                            });
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _isWriting
                          ? _buildWritingView(key: const ValueKey('writingView')) // Added keys for AnimatedSwitcher
                          : _buildJournalView(key: const ValueKey('journalView')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingView() {
    final theme = Theme.of(context);

    // This is the state of _buildWritingView and _showCrystalSelectionDialog from commit 01HYC3V8PNHDSG8PCH1Z02H49W
    // I will re-paste the complete intended code for these two methods here.
    // The AnimatedSwitcher part will be handled in the main build method's diff.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Moon Phase Display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nightlight_round, color: theme.colorScheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Moon Phase: ${_currentMoonPhase ?? "Loading..."}',
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.secondary), // Adjusted style
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mood Tags Input
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("I'm Feeling:", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 6.0,
                    children: _predefinedMoods.map((mood) {
                      final isSelected = _selectedMoods.contains(mood);
                      return ChoiceChip(
                        label: Text(mood),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedMoods.add(mood);
                            } else {
                              _selectedMoods.remove(mood);
                            }
                          });
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        elevation: isSelected ? 3 : 1,
                        pressElevation: 5,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Crystals Used Input
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("Crystals Used:", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                   const SizedBox(height: 4),
                  TextButton.icon(
                    icon: Icon(Icons.diamond_outlined, color: theme.colorScheme.secondary),
                    label: Text("Select Crystals", style: TextStyle(color: theme.colorScheme.secondary)),
                    onPressed: _showCrystalSelectionDialog,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Padding( // Changed from `if` to always show, displaying "None selected"
                    padding: const EdgeInsets.only(top: 0, left: 4.0),
                    child: Text(
                      _selectedCrystalIds.isEmpty
                          ? "None selected"
                          : "Using: ${_selectedCrystalIds.map((id) => _ownedCrystals.firstWhere((c) => c.crystalId == id, orElse: () => CollectionEntry(id: '', crystalId: id, name: 'Unknown', addedDate: DateTime.now(), properties: {})).name).join(', ')}",
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Text Field
            SizedBox(
              height: 250,
              child: MysticalCard(
                elevation: 2,
                child: TextField(
                  controller: _journalController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts about your crystal journey...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 24),
            MysticalButton(
              text: _editingEntryId != null ? 'Update Entry' : 'Save Entry',
              onPressed: _saveEntry,
              icon: _editingEntryId != null ? Icons.check_circle_outline : Icons.save_alt,
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCrystalSelectionDialog() {
    if (_ownedCrystals.isEmpty && mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading your crystals... Try again in a moment.'))
      );
      if (!_isLoading) {
        _loadDataForWritingView();
      }
      return;
    }

    List<String> dialogSelectedCrystalIds = List.from(_selectedCrystalIds);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dialogTheme = Theme.of(context);
        return AlertDialog(
          backgroundColor: dialogTheme.colorScheme.surface,
          title: Text("Select Crystals Used", style: dialogTheme.textTheme.titleLarge?.copyWith(color: dialogTheme.colorScheme.onSurface)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SizedBox(
                width: double.maxFinite,
                child: _ownedCrystals.isEmpty
                  ? Center(child: Text("You don't have any crystals in your collection yet.", style: dialogTheme.textTheme.bodyMedium))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _ownedCrystals.length,
                      itemBuilder: (BuildContext context, int index) {
                        final crystal = _ownedCrystals[index];
                        final isSelected = dialogSelectedCrystalIds.contains(crystal.crystalId);
                        return CheckboxListTile(
                          title: Text(crystal.name, style: dialogTheme.textTheme.bodyLarge?.copyWith(color: dialogTheme.colorScheme.onSurfaceVariant)),
                          value: isSelected,
                          activeColor: dialogTheme.colorScheme.primary,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              if (value == true) {
                                if (!dialogSelectedCrystalIds.contains(crystal.crystalId)) {
                                  dialogSelectedCrystalIds.add(crystal.crystalId);
                                }
                              } else {
                                dialogSelectedCrystalIds.remove(crystal.crystalId);
                              }
                            });
                          },
                        );
                      },
                    ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: dialogTheme.colorScheme.secondary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Done", style: TextStyle(color: dialogTheme.colorScheme.primary, fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  _selectedCrystalIds = List.from(dialogSelectedCrystalIds);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildJournalView() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No journal entries yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the "+" icon to start journaling', // Updated prompt
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MysticalCard(
            child: Padding( // Added padding inside card
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1, // Ensure title is one line with ellipsis
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_note, color: theme.colorScheme.secondary),
                            tooltip: "Edit Entry",
                            onPressed: () {
                              setState(() {
                                _editingEntryId = entry.id;
                                _journalController.text = entry.content;
                                _selectedMoods = List.from(entry.moodTags);
                                _selectedCrystalIds = List.from(entry.crystalIdsUsed);
                                _loadDataForWritingView(); // Fetch current moon phase & owned crystals
                                // Moon phase for the entry itself is entry.moonPhase, _currentMoonPhase is for new/updated entries
                                _isWriting = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                            tooltip: "Delete Entry",
                            onPressed: () => _deleteEntry(entry.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.content,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${entry.date.year.toString()}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}