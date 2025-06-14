import 'dart:convert';
import 'package:http/http.dart' as http;

// Quick test of Gemini API
void main() async {
  print('🔮 Testing Gemini API Connection');
  print('=' * 50);
  
  const apiKey = 'AIzaSyB7ly1Cpev3g6aMivrGwYpxXqzE73KGxx4';
  const model = 'gemini-2.0-flash-exp';
  
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{
            'text': 'Hello! Can you identify crystals? Please respond with just "YES" if you can help with crystal identification.'
          }]
        }],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 100,
        }
      }),
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No response';
      print('✅ Gemini Response: $text');
      print('✅ Gemini API is working!');
    } else {
      print('❌ API Error: ${response.statusCode}');
      print('❌ Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Network Error: $e');
  }
}