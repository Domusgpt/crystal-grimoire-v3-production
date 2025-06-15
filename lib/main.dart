import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:universal_platform/universal_platform.dart';

// Services
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'services/ads_service.dart';
import 'services/storage_service.dart';
import 'services/collection_service_v2.dart';
import 'services/firebase_service.dart';
import 'services/stripe_service.dart';
import 'services/ai_service.dart';
import 'services/unified_data_service.dart';
import 'services/backend_service.dart';
import 'services/firebase_ai_service.dart';
import 'services/unified_ai_service.dart';
import 'services/feature_integration_service.dart';
import 'firebase_options.dart';

// Screens
import 'screens/auth_wrapper.dart';
import 'config/enhanced_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for all platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    
    // Firebase App Check disabled for now to prevent ReCAPTCHA errors
    // await FirebaseAppCheck.instance.activate(
    //   webProvider: ReCaptchaV3Provider('6Lemm7EqAAAAAH8lIGXl4smnJFk_NUNGEtJ-SWTV'),
    //   androidProvider: AndroidProvider.debug,
    //   appleProvider: AppleProvider.debug,
    // );
    
    // Initialize Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
    // Initialize Firebase Performance Monitoring
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    
    // Initialize Firebase Messaging for web push notifications
    if (UniversalPlatform.isWeb) {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    
    // Initialize Firebase AI Logic
    await FirebaseAIService.initialize();
    
    // Pre-initialize Firebase Auth to handle redirect results
    print('🔑 Pre-initializing Firebase Auth...');
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    print('✅ Firebase Auth initialized successfully');
    
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  // Initialize services
  await _initializeServices();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F23),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CrystalGrimoireApp());
}

Future<void> _initializeServices() async {
  try {
    print('🚀 Initializing Crystal Grimoire services...');
    
    // Initialize payment service (mobile only)
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await PaymentService.initialize();
      print('✅ Payment service initialized');
    }
    
    // Initialize ads service (mobile only)
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await AdsService.initialize();
      print('✅ Ads service initialized');
    }
    
    print('🔥 Firebase Blaze features ready for premium users');
    print('🔮 Unified data service with real-time sync enabled');
    
  } catch (e) {
    print('❌ Service initialization failed: $e');
  }
}

class CrystalGrimoireApp extends StatelessWidget {
  const CrystalGrimoireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => StorageService()),
        ChangeNotifierProvider(
          create: (_) => FirebaseService(),
        ),
        Provider(create: (_) => BackendService()),
        
        // Core unified data service with Firebase Blaze features
        ChangeNotifierProxyProvider3<FirebaseService, StorageService, BackendService, UnifiedDataService>(
          create: (context) => UnifiedDataService(
            firebaseService: context.read<FirebaseService>(),
            storageService: context.read<StorageService>(),
            backendService: context.read<BackendService>(),
          ),
          update: (context, firebase, storage, backend, previous) => 
            previous ?? UnifiedDataService(
              firebaseService: firebase,
              storageService: storage,
              backendService: backend,
            ),
        ),
        
        // Stripe service for premium features
        ProxyProvider<FirebaseService, StripeService>(
          create: (context) => StripeService(
            firebaseService: context.read<FirebaseService>(),
          ),
          update: (context, firebase, previous) => 
            previous ?? StripeService(firebaseService: firebase),
        ),
        
        // Collection service with Firebase integration
        ChangeNotifierProxyProvider2<FirebaseService, UnifiedDataService, CollectionServiceV2>(
          create: (context) => CollectionServiceV2(
            firebaseService: context.read<FirebaseService>(),
            unifiedDataService: context.read<UnifiedDataService>(),
          )..initialize(),
          update: (context, firebase, unified, previous) => 
            previous ?? CollectionServiceV2(firebaseService: firebase, unifiedDataService: unified)..initialize(),
        ),
        
        // App state connected to collection service
        ChangeNotifierProxyProvider<CollectionServiceV2, AppState>(
          create: (context) {
            final appState = AppState();
            final collectionService = context.read<CollectionServiceV2>();
            appState.setCollectionService(collectionService);
            appState.initialize();
            return appState;
          },
          update: (context, collection, previous) {
            if (previous != null) {
              previous.setCollectionService(collection);
              return previous;
            }
            final appState = AppState();
            appState.setCollectionService(collection);
            appState.initialize();
            return appState;
          },
        ),
        
        // Enhanced AI service with unified data context
        ChangeNotifierProxyProvider3<StorageService, CollectionServiceV2, UnifiedDataService, UnifiedAIService>(
          create: (context) => UnifiedAIService(
            storageService: context.read<StorageService>(),
            collectionService: context.read<CollectionServiceV2>(),
          ),
          update: (context, storage, collection, unifiedData, previous) => 
            previous ?? UnifiedAIService(
              storageService: storage,
              collectionService: collection,
            ),
        ),
        
        // Feature integration service for cross-feature linking
        ChangeNotifierProxyProvider2<CollectionServiceV2, FirebaseService, FeatureIntegrationService>(
          create: (context) => FeatureIntegrationService(
            collectionService: context.read<CollectionServiceV2>(),
            firebaseService: context.read<FirebaseService>(),
          ),
          update: (context, collection, firebase, previous) => 
            previous ?? FeatureIntegrationService(
              collectionService: collection,
              firebaseService: firebase,
            ),
        ),
      ],
      child: MaterialApp(
        title: 'Crystal Grimoire',
        debugShowCheckedModeBanner: false,
        theme: CrystalGrimoireTheme.theme,
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const AuthWrapper(),
        },
      ),
    );
  }
}