import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service that uses Firebase Multimodal GenAI Extension for crystal identification
class GeminiVisionService {
  static const String _collectionPath = 'crystal_identifications';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // /// Identify crystal using Multimodal GenAI Extension - DEPRECATED: Use BackendService
  // /// This leverages our installed googlecloud/firestore-multimodal-genai extension
  // Future<Map<String, dynamic>> identifyCrystal({
  //   required String imageUrl,
  //   required String userId,
  //   Map<String, dynamic>? userContext,
  // }) async {
  //   try {
  //     // Create document for the extension to process
  //     final docRef = _firestore.collection(_collectionPath).doc();
      
  //     // Document structure that the extension will process
  //     final requestData = {
  //       'userId': userId,
  //       'imageUrl': imageUrl, // Cloud Storage URL or base64
  //       'timestamp': FieldValue.serverTimestamp(),
  //       'status': 'PROCESSING',
  //       'userContext': userContext ?? {},
        
  //       // Extension will substitute these into the prompt
  //       'image': imageUrl,
  //       'user_collection_size': userContext?['collection_size'] ?? 0,
  //       'user_expertise_level': userContext?['expertise_level'] ?? 'beginner',
  //       'user_birth_sign': userContext?['birth_sign'] ?? 'unknown',
  //       'user_spiritual_goals': userContext?['spiritual_goals'] ?? 'general wellness',
  //     };
      
  //     // Save document - this triggers the extension
  //     await docRef.set(requestData);
      
  //     debugPrint('🔮 Crystal identification request submitted: ${docRef.id}');
      
  //     // Listen for the extension's response
  //     return await _waitForResponse(docRef);
      
  //   } catch (e) {
  //     debugPrint('❌ Crystal identification failed: $e');
  //     throw Exception('Failed to identify crystal: $e');
  //   }
  // }

  // /// Wait for the extension to process and return results - Helper for deprecated method
  // Future<Map<String, dynamic>> _waitForResponse(DocumentReference docRef) async {
  //   const maxWaitTime = Duration(minutes: 2);
  //   const checkInterval = Duration(seconds: 2);
    
  //   final startTime = DateTime.now();
    
  //   while (DateTime.now().difference(startTime) < maxWaitTime) {
  //     final doc = await docRef.get();
  //     final data = doc.data() as Map<String, dynamic>?;
      
  //     if (data != null) {
  //       final status = data['status'] as String?;
        
  //       if (status == 'COMPLETED') {
  //         // Extension finished processing
  //         final response = data['response'] as String?;
  //         debugPrint('✅ Crystal identification complete');
          
  //         return {
  //           'success': true,
  //           'identification': _parseResponse(response ?? ''),
  //           'raw_response': response,
  //           'metadata': {
  //             'processing_time': DateTime.now().difference(startTime).inSeconds,
  //             'document_id': docRef.id,
  //           }
  //         };
  //       } else if (status == 'ERROR') {
  //         throw Exception('Extension processing failed: ${data['error']}');
  //       }
  //     }
      
  //     // Wait before checking again
  //     await Future.delayed(checkInterval);
  //   }
    
  //   throw Exception('Crystal identification timed out after ${maxWaitTime.inMinutes} minutes');
  // }

  // /// Parse the Gemini response into structured data - Helper for deprecated method
  // Map<String, dynamic> _parseResponse(String response) {
  //   try {
  //     // The extension should return JSON-structured data based on our prompt
  //     // For now, return the raw response with basic parsing
  //     return {
  //       'name': _extractField(response, 'name'),
  //       'confidence': _extractConfidence(response),
  //       'metaphysical_properties': _extractMetaphysical(response),
  //       'physical_properties': _extractPhysical(response),
  //       'personalized_guidance': _extractGuidance(response),
  //       'raw_text': response,
  //     };
  //   } catch (e) {
  //     debugPrint('⚠️ Failed to parse response, returning raw data');
  //     return {
  //       'name': 'Unknown Crystal',
  //       'confidence': 50,
  //       'raw_text': response,
  //       'parse_error': e.toString(),
  //     };
  //   }
  // }

  // String _extractField(String response, String field) {
  //   // Simple extraction - could be improved with regex
  //   final lines = response.split('\n');
  //   for (final line in lines) {
  //     if (line.toLowerCase().contains(field.toLowerCase())) {
  //       return line.split(':').last.trim();
  //     }
  //   }
  //   return 'Unknown';
  // }

  // int _extractConfidence(String response) {
  //   final confidenceMatch = RegExp(r'confidence[:\s]*(\d+)%?', caseSensitive: false)
  //       .firstMatch(response);
  //   return int.tryParse(confidenceMatch?.group(1) ?? '75') ?? 75;
  // }

  // List<String> _extractMetaphysical(String response) {
  //   // Extract metaphysical properties from the response
  //   final properties = <String>[];
  //   final lines = response.split('\n');
    
  //   bool inMetaphysicalSection = false;
  //   for (final line in lines) {
  //     if (line.toLowerCase().contains('metaphysical') ||
  //         line.toLowerCase().contains('spiritual') ||
  //         line.toLowerCase().contains('healing')) {
  //       inMetaphysicalSection = true;
  //       continue;
  //     }
      
  //     if (inMetaphysicalSection) {
  //       if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
  //         properties.add(line.trim().substring(1).trim());
  //       } else if (line.trim().isEmpty) {
  //         break;
  //       }
  //     }
  //   }
    
  //   return properties.isNotEmpty ? properties : ['Promotes general wellness'];
  // }

  // Map<String, String> _extractPhysical(String response) {
  //   return {
  //     'hardness': _extractField(response, 'hardness'),
  //     'crystal_system': _extractField(response, 'crystal system'),
  //     'color': _extractField(response, 'color'),
  //     'transparency': _extractField(response, 'transparency'),
  //   };
  // }

  // String _extractGuidance(String response) {
  //   final lines = response.split('\n');
  //   for (int i = 0; i < lines.length; i++) {
  //     if (lines[i].toLowerCase().contains('guidance') ||
  //         lines[i].toLowerCase().contains('recommendation') ||
  //         lines[i].toLowerCase().contains('advice')) {
  //       // Return the next few lines as guidance
  //       final guidanceLines = lines.skip(i + 1).take(3);
  //       return guidanceLines.where((line) => line.trim().isNotEmpty).join(' ');
  //     }
  //   }
  //   return 'This crystal resonates with your spiritual journey.';
  // }

  /// Get crystal identification history for a user
  Stream<List<Map<String, dynamic>>> getCrystalIdentificationHistory(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'COMPLETED')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'timestamp': data['timestamp'],
          'identification': _parseResponse(data['response'] ?? ''),
          'imageUrl': data['imageUrl'],
        };
      }).toList();
    });
  }

  /// Re-identify a crystal (useful for retry functionality)
  Future<void> retryIdentification(String documentId) async {
    final docRef = _firestore.collection(_collectionPath).doc(documentId);
    
    // Reset status to trigger the extension again
    await docRef.update({
      'status': 'PENDING',
      'retry_timestamp': FieldValue.serverTimestamp(),
    });
  }
}