import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../services/ai_service.dart';
import '../services/backend_service.dart';
import '../config/backend_config.dart';
import '../services/platform_file.dart';
import '../models/crystal.dart';
import '../config/api_config.dart';
import 'results_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final List<PlatformFile> _images = [];
  final int _maxImages = 5;
  
  late AnimationController _pulseController;
  late AnimationController _instructionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _instructionFade;
  
  bool _isProcessing = false;
  int _currentInstructionIndex = 0;
  
  final List<String> _photoInstructions = [
    'Capture the crystal from the front',
    'Show the crystal\'s side profile',
    'Include size reference (coin, ruler)',
    'Capture any unique features',
    'Show the crystal in natural light',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _instructionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _instructionFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _instructionController,
      curve: Curves.easeIn,
    ));
    
    _instructionController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        final platformFile = await PlatformFile.fromXFile(image);
        setState(() {
          _images.add(platformFile);
          _currentInstructionIndex = _images.length;
        });
        
        HapticFeedback.mediumImpact();
        
        // Animate instruction change
        await _instructionController.reverse();
        await _instructionController.forward();
      }
    } catch (e) {
      _showError('Failed to capture image');
    }
  }
  
  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        final platformFiles = <PlatformFile>[];
        for (var image in images) {
          if (_images.length + platformFiles.length < _maxImages) {
            platformFiles.add(await PlatformFile.fromXFile(image));
          }
        }
        setState(() {
          _images.addAll(platformFiles);
          _currentInstructionIndex = _images.length;
        });
        
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showError('Failed to pick images');
    }
  }
  
  void _removeImage(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _images.removeAt(index);
      _currentInstructionIndex = _images.length;
    });
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _proceedToIdentify() async {
    if (_images.isEmpty) {
      _showError('Please capture at least one image');
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiConfig.getRandomLoadingMessage()),
            duration: const Duration(seconds: 10),
          ),
        );
      }
      
      // Call backend service if available, otherwise use AI service
      CrystalIdentification identification;
      if (BackendConfig.useBackend && await BackendConfig.isBackendAvailable()) {
        print('🔮 Using backend service for identification');
        identification = await BackendService.identifyCrystal(
          images: _images,
          userContext: 'Please identify this crystal with your mystical wisdom.',
        );
      } else {
        print('🔮 Using direct AI service for identification');
        identification = await AIService.identifyCrystal(
          images: _images,
          userContext: 'Please identify this crystal with your mystical wisdom.',
        );
      }
      
      if (mounted) {
        setState(() => _isProcessing = false);
        
        // Navigate to results screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              crystal: identification.crystal ?? Crystal(
                id: 'unknown',
                name: 'Unknown Crystal',
                scientificName: 'Unknown',
                group: 'Unknown',
                description: 'Crystal could not be identified',
                metaphysicalProperties: [],
                healingProperties: [],
                chakras: [],
                elements: [],
                properties: {},
                colorDescription: 'Unknown',
                hardness: 'Unknown',
                formation: 'Unknown',
                careInstructions: 'Unknown',
                imageUrls: [],
                type: 'Unknown',
                color: 'Unknown',
                imageUrl: '',
                planetaryRulers: [],
                zodiacSigns: [],
                crystalSystem: 'Unknown',
                formations: [],
                chargingMethods: [],
              ),
              imageUrl: _images.isNotEmpty ? _images.first.path : null,
              analysisData: {
                'confidence': identification.confidence,
                'session_id': identification.sessionId,
                'mystical_message': identification.mysticalMessage,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        
        String errorMessage = e.toString();
        
        // Provide helpful error messages
        if (errorMessage.contains('API key')) {
          errorMessage = 'Please set your API key!\n\n'
              '1. Get a FREE Gemini key at:\n'
              'https://makersuite.google.com/app/apikey\n\n'
              '2. Add it to lib/config/api_config.dart';
        } else if (errorMessage.contains('Network')) {
          errorMessage = 'Please check your internet connection';
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Crystal Identification'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const ShimmeringText(
          text: 'Crystal Capture',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background particles
          const FloatingParticles(
            particleCount: 10,
            color: Colors.purpleAccent,
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Instructions card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FadeTransition(
                    opacity: _instructionFade,
                    child: MysticalCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.purple,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentInstructionIndex < _photoInstructions.length
                                ? _photoInstructions[_currentInstructionIndex]
                                : 'Ready to identify your crystal!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_images.length}/$_maxImages photos captured',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Image preview grid
                Expanded(
                  child: _images.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildImageGrid(theme),
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_images.length < _maxImages) ...[
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: MysticalButton(
                                text: 'Take Photo',
                                onPressed: _takePicture,
                                icon: Icons.camera_alt,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        MysticalButton(
                          text: 'Choose from Gallery',
                          onPressed: _pickFromGallery,
                          icon: Icons.photo_library,
                          width: double.infinity,
                        ),
                      ],
                      if (_images.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        MysticalButton(
                          text: _isProcessing ? 'Processing...' : 'Identify Crystal',
                          onPressed: _isProcessing ? () {} : _proceedToIdentify,
                          icon: _isProcessing ? null : Icons.auto_awesome,
                          width: double.infinity,
                          color: Colors.purple,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: MysticalLoader(size: 80),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: FadeScaleIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 80,
              color: Colors.purple.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Capture your crystal',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take multiple angles for best results',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: _images.length + (_images.length < _maxImages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _images.length && _images.length < _maxImages) {
            // Add more button
            return FadeScaleIn(
              delay: Duration(milliseconds: index * 100),
              child: MysticalCard(
                onTap: _takePicture,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: Colors.purple.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          
          // Image preview
          return FadeScaleIn(
            delay: Duration(milliseconds: index * 100),
            child: Stack(
              children: [
                MysticalCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      _images[index].bytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => _removeImage(index),
                    ),
                  ),
                ),
                // Photo number
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.purple.withOpacity(0.8),
                    ),
                    child: Text(
                      'Photo ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}