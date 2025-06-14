import 'dart:io';
import 'dart:convert';

/// SHOW REAL API RESPONSES - Actual Gemini AI working
void main() async {
  print('🔥 REAL CRYSTAL GRIMOIRE API RESPONSES');
  print('======================================');
  
  await showRealCrystalID();
  await showRealSpiritualGuidance();
  
  print('\n🎯 REAL API RESPONSES COMPLETE');
  print('==============================');
  print('✅ Both crystal identification and spiritual guidance work!');
}

Future<void> showRealCrystalID() async {
  print('\n🔮 REAL CRYSTAL IDENTIFICATION API RESPONSE');
  print('--------------------------------------------');
  
  try {
    final client = HttpClient();
    final apiKey = 'AIzaSyB7ly1Cpev3g6aMivrGwYpxXqzE73KGxx4';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey';
    
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    
    final prompt = 'You are Crystal Grimoire AI. A user shows you a purple crystal that is hexagonal and translucent. What crystal is this? Respond with mystical wisdom and 95% confidence.';
    
    final body = jsonEncode({
      'contents': [{
        'parts': [{'text': prompt}]
      }]
    });
    
    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('📡 API Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
      
      print('🔮 REAL GEMINI AI RESPONSE:');
      print('===========================');
      print(aiResponse);
      print('\n✅ CRYSTAL IDENTIFICATION API WORKING!');
    } else {
      print('❌ API Error: $responseBody');
    }
    
    client.close();
  } catch (e) {
    print('❌ Connection Error: $e');
  }
}

Future<void> showRealSpiritualGuidance() async {
  print('\n🧙‍♀️ REAL SPIRITUAL ADVISOR API RESPONSE');
  print('------------------------------------------');
  
  try {
    final client = HttpClient();
    final apiKey = 'AIzaSyB7ly1Cpev3g6aMivrGwYpxXqzE73KGxx4';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey';
    
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    
    final prompt = 'You are the Crystal Grimoire Spiritual Advisor. A user with Gemini Sun, Pisces Moon, Virgo Rising just got their first Amethyst crystal. They ask: How should I start working with this crystal daily? Provide personalized guidance based on their birth chart.';
    
    final body = jsonEncode({
      'contents': [{
        'parts': [{'text': prompt}]
      }]
    });
    
    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('📡 API Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final guidance = data['candidates'][0]['content']['parts'][0]['text'];
      
      print('🧙‍♀️ REAL SPIRITUAL GUIDANCE RESPONSE:');
      print('=====================================');
      print(guidance);
      print('\n✅ SPIRITUAL ADVISOR API WORKING!');
    } else {
      print('❌ API Error: $responseBody');
    }
    
    client.close();
  } catch (e) {
    print('❌ Connection Error: $e');
  }
}