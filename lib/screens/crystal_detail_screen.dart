import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../services/collection_service_v2.dart';
import '../models/crystal_collection.dart'; // Imports UnifiedCrystalData via CollectionEntry
import '../models/unified_crystal_data.dart'; // Explicit import for UnifiedCrystalData
// import '../models/crystal.dart'; // Old model, remove

class CrystalDetailScreen extends StatefulWidget {
  final CollectionEntry? collectionEntry; // Contains UnifiedCrystalData
  final UnifiedCrystalData? unifiedCrystalData; // For direct passing if not in collection

  const CrystalDetailScreen({
    Key? key,
    this.collectionEntry,
    this.unifiedCrystalData,
  }) :  assert(collectionEntry != null || unifiedCrystalData != null,
              'Either collectionEntry or unifiedCrystalData must be provided'),
        super(key: key);

  @override
  State<CrystalDetailScreen> createState() => _CrystalDetailScreenState();
}

class _CrystalDetailScreenState extends State<CrystalDetailScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // UnifiedCrystalData get crystal => widget.collectionEntry?.crystalData ?? widget.unifiedCrystalData!;
  // Making it nullable to handle the case where it might still be null if assert fails or logic changes
  UnifiedCrystalData? get ucd {
    if (widget.collectionEntry != null) {
      return widget.collectionEntry!.crystalData;
    }
    return widget.unifiedCrystalData;
  }
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
        widget.collectionEntry!.id, // This ID is CollectionEntry's ID
        purpose: purpose,
        intention: 'Viewed crystal details',
      );

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usage logged for ${ucd!.crystalCore.identification.stoneType}'),
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

    if (ucd == null) { // Check against the new ucd getter
      return Scaffold(
        body: Center(
          child: Text(
            'Crystal data not available.', // Updated message
            style: theme.textTheme.headlineMedium,
          ),
        ),
      );
    }

    final crystalCore = ucd!.crystalCore;
    final enrichment = ucd!.automaticEnrichment;
    // final userProps = ucd!.userIntegration; // If needed

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
                              text: crystalCore.identification.stoneType, // Use new path
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isInCollection)
                            Consumer<CollectionServiceV2>( // Example for toggling favorite
                              builder: (context, service, child) {
                                return IconButton(
                                  icon: Icon(
                                    widget.collectionEntry!.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: widget.collectionEntry!.isFavorite
                                        ? Colors.red
                                        : null,
                                  ),
                                  onPressed: () {
                                    // TODO: This favorite is on CollectionEntry, not UnifiedCrystalData.
                                    // If favorite needs to be on UCD, it must be added to UserIntegration.
                                    // For now, assuming CollectionEntry.isFavorite is the source of truth.
                                    // service.toggleFavorite(widget.collectionEntry!.id); // This method was in old service
                                    debugPrint("Toggle favorite for CollectionEntry ID: ${widget.collectionEntry!.id}");
                                    HapticFeedback.lightImpact();
                                    // This would require a method in CollectionServiceV2 to update CollectionEntry's fav status
                                    // and then persist it via UnifiedDataService potentially if that part of CE is synced.
                                  },
                                );
                              }
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
                                              text: crystalCore.identification.stoneType, // Use new path
                                              style: theme.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              // Use crystalFamily or variety as scientific/subtitle
                                              crystalCore.identification.crystalFamily.isNotEmpty
                                                  ? crystalCore.identification.crystalFamily
                                                  : (crystalCore.identification.variety ?? 'N/A'),
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
                                            // Usage count is on CollectionEntry, not UCD
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
                                  // Use a combination of properties for description
                                  Text(
                                    enrichment?.healingProperties.join('. ') ??
                                    'This crystal holds many secrets yet to be unveiled.', // Fallback
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Collection details (if in collection) - This part remains largely the same
                            // as it uses widget.collectionEntry properties directly.
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
                                    // If personal notes are on UserIntegration:
                                    // if (ucd?.userIntegration?.personalNotes?.isNotEmpty == true)
                                    //   _buildDetailItem('Personal Notes', ucd!.userIntegration!.personalNotes!, theme),
                                    // For now, using CollectionEntry notes:
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

                            // Metaphysical properties from AutomaticEnrichment
                            if (enrichment?.healingProperties.isNotEmpty ?? false)
                              MysticalCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Healing Properties', // Changed title
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...(enrichment!.healingProperties).map(
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

                            // Care Instructions from AutomaticEnrichment
                            if (enrichment?.careInstructions.isNotEmpty ?? false)
                              MysticalCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Care Instructions',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    ...(enrichment!.careInstructions).map((instr) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(Icons.eco, size: 16, color: theme.colorScheme.secondary),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(instr, style: theme.textTheme.bodyMedium)),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Chakras from EnergyMapping
                            Builder(builder: (context) {
                              final List<String> allChakras = [];
                              if (crystalCore.energyMapping.primaryChakra.isNotEmpty) {
                                allChakras.add(crystalCore.energyMapping.primaryChakra);
                              }
                              allChakras.addAll(crystalCore.energyMapping.secondaryChakras);
                              if (allChakras.isEmpty) return const SizedBox.shrink();

                              return MysticalCard(
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
                                      children: allChakras.map((chakra) {
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
                                            // chakra.toString().split('.').last, // If it was an enum
                                            chakra, // Assuming it's already a string
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
                              );
                            }),

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