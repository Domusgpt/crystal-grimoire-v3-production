import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../services/collection_service_v2.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final List<String> _entries = [];
  final TextEditingController _journalController = TextEditingController();
  bool _isWriting = false;

  @override
  void initState() {
    super.initState();
    
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
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_journalController.text.trim().isNotEmpty) {
      setState(() {
        _entries.insert(0, _journalController.text.trim());
        _isWriting = false;
        _journalController.clear();
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                          icon: Icon(_isWriting ? Icons.view_list : Icons.edit),
                          onPressed: () {
                            setState(() => _isWriting = !_isWriting);
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _isWriting ? _buildWritingView() : _buildJournalView(),
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: MysticalCard(
              child: TextField(
                controller: _journalController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts about your crystal journey...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),
          MysticalButton(
            text: 'Save Entry',
            onPressed: _saveEntry,
          ),
        ],
      ),
    );
  }

  Widget _buildJournalView() {
    final theme = Theme.of(context);

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
              'Tap the edit icon to start journaling',
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MysticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entry ${_entries.length - index}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _entries[index],
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Just now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}