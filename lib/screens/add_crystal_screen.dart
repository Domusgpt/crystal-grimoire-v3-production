import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../services/collection_service_v2.dart';
import '../models/crystal.dart';

class AddCrystalScreen extends StatefulWidget {
  final Crystal? crystal;

  const AddCrystalScreen({
    Key? key,
    this.crystal,
  }) : super(key: key);

  @override
  State<AddCrystalScreen> createState() => _AddCrystalScreenState();
}

class _AddCrystalScreenState extends State<AddCrystalScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _notesController = TextEditingController();
  final _sourceController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedSize = 'medium';
  String _selectedQuality = 'tumbled';
  bool _isFavorite = false;
  bool _isLoading = false;

  final List<String> _sizes = ['small', 'medium', 'large', 'extra_large'];
  final List<String> _qualities = ['raw', 'tumbled', 'polished', 'carved'];

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
    _notesController.dispose();
    _sourceController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _addCrystal() async {
    if (widget.crystal == null) return;

    setState(() => _isLoading = true);

    try {
      final collectionService = context.read<CollectionServiceV2>();
      
      await collectionService.addCrystal(
        widget.crystal!,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        source: _sourceController.text.trim().isNotEmpty 
            ? _sourceController.text.trim() 
            : null,
        purchasePrice: _priceController.text.trim().isNotEmpty 
            ? double.tryParse(_priceController.text.trim()) 
            : null,
        location: _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() 
            : null,
        size: _selectedSize,
        quality: _selectedQuality,
      );

      HapticFeedback.lightImpact();
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.crystal!.name} added to your collection!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add crystal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
                            text: 'Add Crystal',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                          // Crystal info
                          if (widget.crystal != null)
                            MysticalCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmeringText(
                                    text: widget.crystal!.name,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.crystal!.scientificName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Notes
                          MysticalCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Notes',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _notesController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: 'Add your personal notes about this crystal...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Source and price
                          Row(
                            children: [
                              Expanded(
                                child: MysticalCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Source',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _sourceController,
                                        decoration: const InputDecoration(
                                          hintText: 'Where did you get it?',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MysticalCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price (\$)',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: '0.00',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Size and quality
                          MysticalCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Physical Properties',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Size',
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            value: _selectedSize,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            items: _sizes.map((size) {
                                              return DropdownMenuItem(
                                                value: size,
                                                child: Text(size.replaceAll('_', ' ').toUpperCase()),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() => _selectedSize = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quality',
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            value: _selectedQuality,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            items: _qualities.map((quality) {
                                              return DropdownMenuItem(
                                                value: quality,
                                                child: Text(quality.toUpperCase()),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() => _selectedQuality = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Add button
                          MysticalButton(
                            text: _isLoading ? 'Adding...' : 'Add to Collection',
                            onPressed: _isLoading ? () {} : _addCrystal,
                          ),
                        ],
                      ),
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
}