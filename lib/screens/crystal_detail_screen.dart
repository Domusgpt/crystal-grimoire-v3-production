import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../services/collection_service_v2.dart';
import '../models/crystal_collection.dart';
import '../models/crystal.dart';

class CrystalDetailScreen extends StatefulWidget {
  final CollectionEntry? collectionEntry;
  final Crystal? crystal;

  const CrystalDetailScreen({
    Key? key,
    this.collectionEntry,
    this.crystal,
  }) : super(key: key);

  @override
  State<CrystalDetailScreen> createState() => _CrystalDetailScreenState();
}

class _CrystalDetailScreenState extends State<CrystalDetailScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Crystal? get crystal => widget.collectionEntry?.crystal ?? widget.crystal;
  bool get isInCollection => widget.collectionEntry != null;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _logUsage(String purpose) async {
    if (!isInCollection) return;

    try {
      final collectionService = context.read<CollectionServiceV2>();
      await collectionService.logUsage(
        widget.collectionEntry!.id,
        purpose: purpose,
        intention: 'Viewed crystal details',
      );

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usage logged for ${crystal!.name}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log usage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (crystal == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Crystal not found',
            style: theme.textTheme.headlineMedium,
          ),
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
            particleCount: 25,
            color: Colors.purpleAccent,
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
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
                              text: crystal!.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isInCollection)
                            IconButton(
                              icon: Icon(
                                widget.collectionEntry!.isFavorite 
                                    ? Icons.favorite 
                                    : Icons.favorite_border,
                                color: widget.collectionEntry!.isFavorite 
                                    ? Colors.red 
                                    : null,
                              ),
                              onPressed: () {
                                // TODO: Toggle favorite status
                                HapticFeedback.lightImpact();
                              },
                            ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Crystal basic info
                            MysticalCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ShimmeringText(
                                              text: crystal!.name,
                                              style: theme.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              crystal!.scientificName,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isInCollection)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${widget.collectionEntry!.usageCount} uses',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    crystal!.description,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Collection details (if in collection)
                            if (isInCollection)
                              MysticalCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Collection Details',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDetailItem(
                                            'Added',
                                            _formatDate(widget.collectionEntry!.dateAdded),
                                            theme,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildDetailItem(
                                            'Size',
                                            widget.collectionEntry!.size.toUpperCase(),
                                            theme,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildDetailItem(
                                            'Quality',
                                            widget.collectionEntry!.quality.toUpperCase(),
                                            theme,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget.collectionEntry!.source.isNotEmpty)
                                      _buildDetailItem(
                                        'Source',
                                        widget.collectionEntry!.source,
                                        theme,
                                      ),
                                    if (widget.collectionEntry!.notes?.isNotEmpty == true)
                                      _buildDetailItem(
                                        'Notes',
                                        widget.collectionEntry!.notes!,
                                        theme,
                                      ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Metaphysical properties
                            if (crystal!.metaphysicalProperties.isNotEmpty)
                              MysticalCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Metaphysical Properties',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...crystal!.metaphysicalProperties.map(
                                      (prop) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                prop,
                                                style: theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Chakras
                            if (crystal!.chakras.isNotEmpty)
                              MysticalCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Associated Chakras',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: crystal!.chakras.map((chakra) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: theme.colorScheme.primary.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            chakra.toString().split('.').last,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Actions
                            if (isInCollection)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MysticalButton(
                                          text: 'Log Meditation',
                                          onPressed: () => _logUsage('meditation'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: MysticalButton(
                                          text: 'Log Healing',
                                          onPressed: () => _logUsage('healing'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  MysticalButton(
                                    text: 'View Usage History',
                                    onPressed: () {
                                      // TODO: Show usage history
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
}