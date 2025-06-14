import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Test script to verify Firebase Multimodal GenAI Extension works
void main() async {
  print('🔮 Testing Firebase Multimodal GenAI Extension...');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('✅ Firebase initialized');
  
  // Test the extension
  await testMultimodalExtension();
}

Future<void> testMultimodalExtension() async {
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Create a test document in the crystal_identifications collection
    final docRef = firestore.collection('crystal_identifications').doc();
    
    print('📝 Creating test document: ${docRef.id}');
    
    // Test data that matches our extension configuration
    final testData = {
      'imageUrl': 'https://example.com/test-crystal.jpg', // Test URL
      'userBirthSign': 'Leo',
      'userCollectionSize': 5,
      'userSpiritualGoals': 'Healing and wellness',
      'userContext': 'Test user seeking crystal identification for spiritual growth',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'PROCESSING',
      'userId': 'test_user_123',
    };
    
    // Save the document - this should trigger the multimodal extension
    await docRef.set(testData);
    print('✅ Test document created and submitted to extension');
    
    // Wait for the extension to process
    print('⏳ Waiting for extension to process (max 60 seconds)...');
    
    const maxWaitTime = Duration(seconds: 60);
    const checkInterval = Duration(seconds: 5);
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < maxWaitTime) {
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>?;
      
      if (data != null) {
        final status = data['status'] as String?;
        print('📊 Current status: $status');
        
        if (status == 'COMPLETED' || data.containsKey('output')) {
          final response = data['output'] as String? ?? data['response'] as String?;
          print('🎉 Extension processing completed!');
          print('📝 Response: ${response?.substring(0, 200)}...');
          
          // Check if response contains JSON as expected
          if (response?.contains('identification') == true) {
            print('✅ Response appears to contain structured JSON data');
          } else {
            print('⚠️ Response format may need adjustment');
          }
          
          // Cleanup test document
          await docRef.delete();
          print('🗑️ Test document cleaned up');
          return;
          
        } else if (status == 'ERROR') {
          print('❌ Extension processing failed: ${data['error']}');
          await docRef.delete();
          return;
        }
      }
      
      // Wait before checking again
      await Future.delayed(checkInterval);
    }
    
    print('⏰ Extension test timed out - this may indicate configuration issues');
    
    // Check the document one more time
    final finalDoc = await docRef.get();
    final finalData = finalDoc.data() as Map<String, dynamic>?;
    print('📊 Final document state: ${finalData?.keys.toList()}');
    
    // Cleanup
    await docRef.delete();
    
  } catch (e) {
    print('❌ Extension test failed: $e');
  }
}