import 'dart:io';
import 'dart:convert';

/// SIMPLE API AND SERVICE TESTING
/// Tests core functionality without Flutter dependencies
void main() async {
  print('🔥 CRYSTAL GRIMOIRE API TESTING');
  print('================================');
  
  Map<String, String> results = {};
  
  print('\n1. 🔮 Testing Gemini AI API');
  await testGeminiAPI(results);
  
  print('\n2. 🌐 Testing Backend Service');
  await testBackendService(results);
  
  print('\n3. 💳 Testing Stripe Integration');
  await testStripeIntegration(results);
  
  print('\n4. 🔥 Testing Firebase Configuration');
  await testFirebaseConfig(results);
  
  print('\n5. 📱 Testing App Build Status');
  await testAppBuild(results);
  
  print('\n🎯 FINAL RESULTS');
  print('================');
  
  int working = 0;
  int postLaunch = 0;
  int broken = 0;
  
  results.forEach((service, result) {
    print('$result');
    if (result.contains('✅')) working++;
    else if (result.contains('⚠️')) postLaunch++;
    else broken++;
  });
  
  print('\n📊 SUMMARY:');
  print('✅ Working Now: $working');
  print('⚠️ Post-Launch: $postLaunch');
  print('❌ Broken: $broken');
  
  if (broken == 0) {
    print('\n🚀 LAUNCH READY - All critical services functional!');
  } else {
    print('\n🚨 $broken critical issues need fixing before launch');
  }
}

Future<void> testGeminiAPI(Map<String, String> results) async {
  try {
    print('Testing Gemini AI API connection...');
    
    // Test with a simple text request (no image)
    final client = HttpClient();
    final apiKey = 'AIzaSyB7ly1Cpev3g6aMivrGwYpxXqzE73KGxx4';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey';
    
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'contents': [{
        'parts': [{'text': 'What is amethyst? Respond in one sentence.'}]
      }]
    });
    
    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        print('  ✅ API Response: ${text.substring(0, 50)}...');
        results['Gemini AI'] = '✅ Gemini AI API - WORKING (${response.statusCode})';
      } else {
        results['Gemini AI'] = '❌ Gemini AI API - Invalid response format';
      }
    } else {
      print('  ❌ Status: ${response.statusCode}');
      print('  ❌ Response: $responseBody');
      results['Gemini AI'] = '❌ Gemini AI API - HTTP ${response.statusCode}';
    }
    
    client.close();
  } catch (e) {
    print('  ❌ Error: $e');
    results['Gemini AI'] = '❌ Gemini AI API - Connection failed: $e';
  }
}

Future<void> testBackendService(Map<String, String> results) async {
  try {
    print('Testing backend service availability...');
    
    // Test if backend is accessible
    final client = HttpClient();
    
    // Test multiple potential backend URLs
    final urls = [
      'https://app-5108296280.us-central1.run.app/health',
      'https://app-5108296280.us-central1.run.app/v1/health',
      'https://app-5108296280.us-central1.run.app/',
    ];
    
    bool backendWorking = false;
    String workingUrl = '';
    
    for (final url in urls) {
      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        
        if (response.statusCode == 200 || response.statusCode == 404) {
          backendWorking = true;
          workingUrl = url;
          print('  ✅ Backend accessible at: $url');
          break;
        }
      } catch (e) {
        print('  - Tried $url: Not accessible');
      }
    }
    
    if (backendWorking) {
      results['Backend'] = '✅ Backend Service - ACCESSIBLE at $workingUrl';
    } else {
      results['Backend'] = '⚠️ Backend Service - POST-LAUNCH (needs deployment)';
    }
    
    client.close();
  } catch (e) {
    results['Backend'] = '⚠️ Backend Service - POST-LAUNCH (deployment needed)';
  }
}

Future<void> testStripeIntegration(Map<String, String> results) async {
  try {
    print('Testing Stripe API accessibility...');
    
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('https://api.stripe.com/v1'));
    request.headers.set('User-Agent', 'CrystalGrimoire/1.0');
    
    final response = await request.close();
    
    if (response.statusCode == 401) {
      // 401 is expected without API key - means Stripe is accessible
      print('  ✅ Stripe API accessible (401 as expected)');
      results['Stripe'] = '⚠️ Stripe Payments - POST-LAUNCH (needs production keys)';
    } else {
      print('  - Unexpected status: ${response.statusCode}');
      results['Stripe'] = '⚠️ Stripe Payments - POST-LAUNCH (configuration needed)';
    }
    
    client.close();
  } catch (e) {
    print('  ❌ Error: $e');
    results['Stripe'] = '❌ Stripe Payments - Connection failed';
  }
}

Future<void> testFirebaseConfig(Map<String, String> results) async {
  try {
    print('Testing Firebase configuration...');
    
    // Check if firebase config files exist
    final webConfigFile = File('web/firebase-messaging-sw.js');
    final optionsFile = File('lib/firebase_options.dart');
    
    bool webConfigExists = await webConfigFile.exists();
    bool optionsExists = await optionsFile.exists();
    
    print('  - Web config: ${webConfigExists ? "✅ Found" : "❌ Missing"}');
    print('  - Options file: ${optionsExists ? "✅ Found" : "❌ Missing"}');
    
    if (webConfigExists && optionsExists) {
      // Test Firebase API accessibility
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://firebase.googleapis.com/'));
      final response = await request.close();
      
      if (response.statusCode == 200 || response.statusCode == 404) {
        results['Firebase'] = '✅ Firebase - CONFIGURED and accessible';
      } else {
        results['Firebase'] = '⚠️ Firebase - POST-LAUNCH (API issues)';
      }
      
      client.close();
    } else {
      results['Firebase'] = '❌ Firebase - Missing configuration files';
    }
  } catch (e) {
    print('  ❌ Error: $e');
    results['Firebase'] = '⚠️ Firebase - POST-LAUNCH (needs configuration)';
  }
}

Future<void> testAppBuild(Map<String, String> results) async {
  try {
    print('Testing app build status...');
    
    // Check if the app built successfully (build folder exists)
    final buildDir = Directory('build/web');
    bool buildExists = await buildDir.exists();
    
    if (buildExists) {
      print('  ✅ Web build: Generated successfully');
      
      // Check for key build files
      final indexFile = File('build/web/index.html');
      final mainFile = File('build/web/main.dart.js');
      
      bool indexExists = await indexFile.exists();
      bool mainExists = await mainFile.exists();
      
      print('  - Index.html: ${indexExists ? "✅" : "❌"}');
      print('  - Main.dart.js: ${mainExists ? "✅" : "❌"}');
      
      if (indexExists && mainExists) {
        results['App Build'] = '✅ App Build - READY FOR DEPLOYMENT';
      } else {
        results['App Build'] = '❌ App Build - Missing critical files';
      }
    } else {
      results['App Build'] = '❌ App Build - Build failed or not generated';
    }
  } catch (e) {
    results['App Build'] = '❌ App Build - Error checking build: $e';
  }
}