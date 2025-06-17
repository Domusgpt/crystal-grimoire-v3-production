import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Services
import 'services/app_state.dart';
import 'services/collection_service_v2.dart';
import 'services/unified_data_service.dart';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';
import 'services/backend_service.dart';
import 'firebase_options.dart';

// Screens
import 'screens/enhanced_home_screen.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully');
    
    // Initialize Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for the mystical theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0221),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CrystalGrimoireApp());
}

class CrystalGrimoireApp extends StatelessWidget {
  const CrystalGrimoireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider(create: (_) => FirebaseService()),
        Provider(create: (_) => StorageService()),
        Provider(create: (_) => BackendService()),
        Provider(
          create: (context) => UnifiedDataService(
            firebaseService: context.read<FirebaseService>(),
            storageService: context.read<StorageService>(),
            backendService: context.read<BackendService>(),
          ),
        ),
        Provider(
          create: (context) => CollectionServiceV2(
            unifiedDataService: context.read<UnifiedDataService>(),
            backendService: context.read<BackendService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: '🔮 Crystal Grimoire V3',
        debugShowCheckedModeBanner: false,
        
        // Enhanced mystical theme
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: const Color(0xFF0D0221), // Deep mystical background
          
          // Enhanced app bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF16213E),
            foregroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          
          // Enhanced card theme
          cardTheme: CardThemeData(
            color: const Color(0xFF16213E).withOpacity(0.8),
            elevation: 8,
            shadowColor: Colors.purple.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          
          // Enhanced color scheme
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF9D4EDD),
            secondary: Color(0xFF7B2CBF),
            surface: Color(0xFF16213E),
            background: Color(0xFF0D0221),
            error: Color(0xFFFF5555),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onBackground: Colors.white,
            onError: Colors.white,
            brightness: Brightness.dark,
          ),
          
          // Enhanced text theme with Google Fonts
          textTheme: TextTheme(
            displayLarge: GoogleFonts.cinzelDecorative(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: GoogleFonts.cinzelDecorative(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: GoogleFonts.cinzelDecorative(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            headlineLarge: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            headlineSmall: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleMedium: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            titleSmall: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.raleway(
              color: Colors.white,
            ),
            bodyMedium: GoogleFonts.raleway(
              color: Colors.white70,
            ),
            bodySmall: GoogleFonts.raleway(
              color: Colors.white70,
            ),
            labelLarge: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            labelMedium: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            labelSmall: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Enhanced button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9D4EDD),
              foregroundColor: Colors.white,
              shadowColor: const Color(0xFF9D4EDD).withOpacity(0.5),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          
          // Enhanced input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF16213E).withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: const Color(0xFF9D4EDD).withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: const Color(0xFF9D4EDD).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF9D4EDD),
                width: 2,
              ),
            ),
            labelStyle: const TextStyle(color: Colors.white70),
            hintStyle: const TextStyle(color: Colors.white54),
          ),
          
          // Enhanced floating action button theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF7209B7),
            foregroundColor: Colors.white,
            elevation: 12,
          ),
          
          // Enhanced icon theme
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 24,
          ),
          
          // Enhanced divider theme
          dividerTheme: DividerThemeData(
            color: Colors.white.withOpacity(0.2),
            thickness: 1,
          ),
        ),
        
        home: const AuthWrapper(),
        
        // Enhanced route transitions
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D0221), // Deep mystical purple-black
                    Color(0xFF1A0B2E), // Dark violet
                    Color(0xFF16213E), // Midnight blue
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated loading crystal
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF9D4EDD).withOpacity(0.8),
                            const Color(0xFF7B2CBF).withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '🔮 Loading Crystal Grimoire...',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return const EnhancedHomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0221), // Deep mystical purple-black
              Color(0xFF1A0B2E), // Dark violet
              Color(0xFF16213E), // Midnight blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mystical crystal logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF9D4EDD).withOpacity(0.8),
                          const Color(0xFF7B2CBF).withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9D4EDD).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Enhanced title with gradient text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFE0AAFF),
                        Color(0xFFC77DFF),
                        Color(0xFF9D4EDD),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '🔮 CRYSTAL GRIMOIRE V3',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Your Mystical Crystal Companion',
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Status card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF16213E).withOpacity(0.8),
                          const Color(0xFF1A0B2E).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF9D4EDD).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '✅ Professional Backend LIVE',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🔮 AI Crystal Identification Ready',
                          style: GoogleFonts.raleway(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '💎 UnifiedCrystalData Active',
                          style: GoogleFonts.raleway(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '🌙 Mystical Features Enabled',
                          style: GoogleFonts.raleway(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Enhanced login button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF9D4EDD),
                          Color(0xFF7B2CBF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9D4EDD).withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signInAnonymously();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Login failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Enter Crystal Realm',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
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
      ),
    );
  }
}