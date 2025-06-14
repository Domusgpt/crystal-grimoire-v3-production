import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// AUTHENTICATION ISSUE DIAGNOSIS
/// Tests the specific Firebase Auth error from user's console log
void main() async {
  print('🔐 CRYSTAL GRIMOIRE AUTHENTICATION DIAGNOSIS');
  print('Investigating the 400 error from Firebase Auth...\n');
  
  await testFirebaseAuthEndpoint();
  await testGoogleSignInConfig();
  await testFirebaseConfig();
  await diagnoseAuthError();
  
  print('\n🎯 DIAGNOSIS COMPLETE');
}

/// Test Firebase Auth Endpoint
Future<void> testFirebaseAuthEndpoint() async {
  print('🔍 Testing Firebase Auth Endpoint...');
  
  try {
    // Test the exact endpoint that's failing in the console
    final response = await http.post(
      Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'test@example.com',
        'password': 'testpassword',
        'returnSecureToken': true,
      }),
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      final errorMessage = error['error']['message'];
      
      print('\n❌ AUTH ERROR IDENTIFIED:');
      print('Error: $errorMessage');
      
      // Diagnose common issues
      if (errorMessage.contains('API_KEY_INVALID')) {
        print('🔧 SOLUTION: API key is invalid or restricted');
      } else if (errorMessage.contains('PROJECT_NOT_FOUND')) {
        print('🔧 SOLUTION: Firebase project not found');
      } else if (errorMessage.contains('OPERATION_NOT_ALLOWED')) {
        print('🔧 SOLUTION: Email/password authentication not enabled');
      } else if (errorMessage.contains('EMAIL_EXISTS')) {
        print('🔧 INFO: This is normal - email already registered');
      } else {
        print('🔧 UNKNOWN ERROR: Check Firebase console');
      }
    } else if (response.statusCode == 200) {
      print('✅ Auth endpoint working correctly');
    }
    
  } catch (e) {
    print('❌ Auth Endpoint Test Failed: $e');
  }
}

/// Test Google Sign-In Configuration
Future<void> testGoogleSignInConfig() async {
  print('\n🔍 Testing Google Sign-In Configuration...');
  
  try {
    final response = await http.get(
      Uri.parse('https://crystalgrimoire-production.web.app'),
    );
    
    if (response.body.contains('gis-dart')) {
      print('✅ Google Identity Services: LOADED');
    } else {
      print('❌ Google Identity Services: NOT FOUND');
    }
    
    if (response.body.contains('client_id')) {
      print('✅ Google Client ID: CONFIGURED');
    } else {
      print('❌ Google Client ID: MISSING');
    }
    
  } catch (e) {
    print('❌ Google Sign-In Test Failed: $e');
  }
}

/// Test Firebase Configuration
Future<void> testFirebaseConfig() async {
  print('\n🔍 Testing Firebase Configuration...');
  
  try {
    final response = await http.get(
      Uri.parse('https://crystalgrimoire-production.web.app/main.dart.js'),
    );
    
    final jsContent = response.body;
    
    if (jsContent.contains('crystalgrimoire-production')) {
      print('✅ Project ID: crystalgrimoire-production');
    }
    
    if (jsContent.contains('AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c')) {
      print('✅ API Key: Configured');
    }
    
    if (jsContent.contains('firebaseapp.com')) {
      print('✅ Auth Domain: Configured');
    }
    
  } catch (e) {
    print('❌ Firebase Config Test Failed: $e');
  }
}

/// Diagnose the specific authentication error
Future<void> diagnoseAuthError() async {
  print('\n🩺 DIAGNOSING AUTHENTICATION ERROR...');
  
  print('Based on the console log error:');
  print('POST https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=... 400 (Bad Request)');
  print('');
  
  // Test Firebase project settings
  await testProjectSettings();
  
  // Test authentication methods
  await testAuthMethods();
}

/// Test Firebase Project Settings
Future<void> testProjectSettings() async {
  print('🔧 Testing Project Settings...');
  
  try {
    // Test if project exists and is accessible
    final response = await http.get(
      Uri.parse('https://firebase.googleapis.com/v1beta1/projects/crystalgrimoire-production'),
    );
    
    if (response.statusCode == 200) {
      print('✅ Firebase Project: EXISTS');
    } else if (response.statusCode == 403) {
      print('✅ Firebase Project: EXISTS (Access Restricted)');
    } else if (response.statusCode == 404) {
      print('❌ Firebase Project: NOT FOUND');
    } else {
      print('⚠️ Firebase Project: Status ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Project Settings Test Failed: $e');
  }
}

/// Test Authentication Methods
Future<void> testAuthMethods() async {
  print('\n🔧 Testing Authentication Methods...');
  
  // Common authentication issues and solutions
  print('COMMON AUTHENTICATION ISSUES:');
  print('');
  
  print('1. ❌ Email/Password Sign-In Not Enabled');
  print('   🔧 SOLUTION: Enable in Firebase Console > Authentication > Sign-in method');
  print('');
  
  print('2. ❌ API Key Restrictions');
  print('   🔧 SOLUTION: Check Google Cloud Console > Credentials > API restrictions');
  print('');
  
  print('3. ❌ Authorized Domains');
  print('   🔧 SOLUTION: Add "crystalgrimoire-production.web.app" to authorized domains');
  print('');
  
  print('4. ❌ Project Billing');
  print('   🔧 SOLUTION: Ensure Firebase project has billing enabled for Blaze plan');
  print('');
  
  print('VERIFICATION STEPS:');
  print('1. Go to: https://console.firebase.google.com/project/crystalgrimoire-production');
  print('2. Authentication > Sign-in method > Email/Password: ENABLE');
  print('3. Authentication > Settings > Authorized domains: ADD crystalgrimoire-production.web.app');
  print('4. Project Settings > General > Check project is active');
}