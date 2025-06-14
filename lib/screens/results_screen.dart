import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../models/crystal.dart';
import '../models/crystal_collection.dart';
import '../services/collection_service_v2.dart';
import '../services/app_state.dart';

class ResultsScreen extends StatefulWidget {
  final Crystal crystal;
  final String? imageUrl;
  final Map<String, dynamic>? analysisData;

  const ResultsScreen({
    Key? key,
    required this.crystal,
    this.imageUrl,
    this.analysisData,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAddingToCollection = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final collectionService = context.watch<CollectionServiceV2>();
    
    // Check if crystal is already in collection
    final isInCollection = collectionService.collection.any(
      (entry) => entry.crystal.name.toLowerCase() == widget.crystal.name.toLowerCase()
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            const Positioned.fill(
              child: FloatingParticles(
                particleCount: 30,
                color: Colors.deepPurple,
              ),
            ),
            
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        
                        const SizedBox(height: 24),
                        
                        // Crystal image and basic info
                        _buildCrystalCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Properties sections
                        _buildPropertiesSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Action buttons
                        _buildActionButtons(isInCollection, collectionService),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        Expanded(
          child: Text(
            'Crystal Identified',
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 48), // Balance the back button
      ],
    );
  }

  Widget _buildCrystalCard() {
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crystal name
          Text(
            widget.crystal.name,
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Confidence and mystical message
          if (widget.analysisData != null) ...[
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple[300], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Confidence: ${(widget.analysisData!['confidence'] ?? 0).toStringAsFixed(1)}%',
                  style: GoogleFonts.lato(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (widget.analysisData!['mystical_message'] != null)
              Text(
                widget.analysisData!['mystical_message'],
                style: GoogleFonts.lato(
                  color: Colors.purple[200],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
          
          const SizedBox(height: 16),
          
          // Basic properties
          _buildPropertyRow('Color', widget.crystal.color),
          _buildPropertyRow('Hardness', widget.crystal.hardness),
          _buildPropertyRow('Formation', widget.crystal.formation),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.lato(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chakras
        if (widget.crystal.chakras.isNotEmpty) ...[
          _buildPropertySection(
            'Chakras',
            widget.crystal.chakras,
            Icons.circle,
            Colors.purple,
          ),
          const SizedBox(height: 16),
        ],
        
        // Healing properties
        if (widget.crystal.healingProperties.isNotEmpty) ...[
          _buildPropertySection(
            'Healing Properties',
            widget.crystal.healingProperties,
            Icons.healing,
            Colors.green,
          ),
          const SizedBox(height: 16),
        ],
        
        // Elements
        if (widget.crystal.elements.isNotEmpty) ...[
          _buildPropertySection(
            'Elements',
            widget.crystal.elements,
            Icons.nature,
            Colors.blue,
          ),
        ],
      ],
    );
  }

  Widget _buildPropertySection(String title, List<String> items, IconData icon, Color color) {
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                item,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isInCollection, CollectionServiceV2 collectionService) {
    return Column(
      children: [
        // Add to Collection button
        if (!isInCollection)
          SizedBox(
            width: double.infinity,
            child: _isAddingToCollection 
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        'Adding to Collection...',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : MysticalButton(
                  text: 'Add to My Collection',
                  onPressed: () => _addToCollection(collectionService),
                  icon: Icons.add_circle_outline,
                ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Already in Your Collection',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Other action buttons
        Row(
          children: [
            Expanded(
              child: MysticalButton(
                text: 'View Details',
                onPressed: () => _viewCrystalDetails(),
                icon: Icons.info_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MysticalButton(
                text: 'Share',
                onPressed: () => _shareCrystal(),
                icon: Icons.share,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addToCollection(CollectionServiceV2 collectionService) async {
    setState(() => _isAddingToCollection = true);
    
    try {
      // Add crystal to collection
      await collectionService.addCrystal(
        widget.crystal,
        notes: 'Identified using Crystal Grimoire AI',
        source: 'Crystal Identification',
        location: 'Unknown',
        size: 'medium',
        quality: 'tumbled',
        primaryUses: ['meditation', 'healing'],
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.crystal.name} added to your collection!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Collection',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
                // Navigate to collection screen
              },
            ),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add crystal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCollection = false);
      }
    }
  }

  void _viewCrystalDetails() {
    // Navigate to detailed crystal info screen
    // This could show more detailed information about the crystal
  }

  void _shareCrystal() {
    // Share crystal identification results
    final text = 'I just identified ${widget.crystal.name} using Crystal Grimoire! '
        'It\'s associated with the ${widget.crystal.chakras.join(", ")} chakras '
        'and has amazing healing properties.';
    
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Crystal info copied to clipboard!'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}