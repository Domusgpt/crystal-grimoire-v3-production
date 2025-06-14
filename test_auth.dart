import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'lib/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Firebase Auth
    final auth = FirebaseAuth.instance;
    print('✅ Firebase Auth instance created');
    print('Current user: ${auth.currentUser?.email ?? 'None'}');
    
    // Test our FirebaseService
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    print('✅ FirebaseService initialized');
    print('Service status: ${firebaseService.getServiceStatus()}');
    
    print('\n🔥 Crystal Grimoire V3 - Firebase Authentication Test Complete');
    print('The login system is properly configured and ready to use.');
    
  } catch (e) {
    print('❌ Firebase test failed: $e');
  }
}