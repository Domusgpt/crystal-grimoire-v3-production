import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('Stripe')
external StripeJS Stripe(String publishableKey);

@JS()
@anonymous
class StripeJS {
  external Promise<PaymentResult> redirectToCheckout(CheckoutOptions options);
}

@JS()
@anonymous
class CheckoutOptions {
  external factory CheckoutOptions({
    required String sessionId,
  });
}

@JS()
@anonymous
class PaymentResult {
  external String? get error;
}

@JS()
@anonymous
class Promise<T> {
  external Promise then(Function onFulfilled, [Function? onRejected]);
}

class StripeWebService {
  static const String _publishableKey = 'pk_test_51OZxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // TODO: Replace with real publishable key
  static const String _baseUrl = 'https://crystalgrimoire-backend.herokuapp.com'; // TODO: Replace with real backend URL
  
  static late StripeJS _stripe;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    if (kIsWeb) {
      // Load Stripe.js script
      await _loadStripeScript();
      _stripe = Stripe(_publishableKey);
      _initialized = true;
    }
  }

  static Future<void> _loadStripeScript() async {
    final completer = Completer<void>();
    
    final script = html.ScriptElement()
      ..src = 'https://js.stripe.com/v3/'
      ..type = 'text/javascript';
    
    script.onLoad.listen((_) {
      completer.complete();
    });
    
    script.onError.listen((_) {
      completer.completeError('Failed to load Stripe script');
    });
    
    html.document.head!.append(script);
    
    return completer.future;
  }

  static Future<StripeCheckoutResult> createCheckoutSession({
    required String priceId,
    required String tier,
  }) async {
    try {
      if (!kIsWeb) {
        return StripeCheckoutResult(
          success: false,
          error: 'Stripe web checkout only available on web platform',
        );
      }

      if (!_initialized) {
        await initialize();
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return StripeCheckoutResult(
          success: false,
          error: 'User must be logged in to purchase',
        );
      }

      // Create checkout session on backend
      final response = await http.post(
        Uri.parse('$_baseUrl/create-checkout-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: jsonEncode({
          'price_id': priceId,
          'tier': tier,
          'customer_email': user.email,
          'customer_id': user.uid,
          'success_url': '${html.window.location.origin}/payment-success',
          'cancel_url': '${html.window.location.origin}/payment-cancel',
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        return StripeCheckoutResult(
          success: false,
          error: errorData['error'] ?? 'Failed to create checkout session',
        );
      }

      final data = jsonDecode(response.body);
      final sessionId = data['session_id'] as String;

      // Redirect to Stripe Checkout
      final result = await _redirectToCheckout(sessionId);
      
      if (result.error != null) {
        return StripeCheckoutResult(
          success: false,
          error: result.error!,
        );
      }

      return StripeCheckoutResult(
        success: true,
        sessionId: sessionId,
      );
    } catch (e) {
      return StripeCheckoutResult(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  static Future<PaymentResult> _redirectToCheckout(String sessionId) async {
    final completer = Completer<PaymentResult>();
    
    final promise = _stripe.redirectToCheckout(
      CheckoutOptions(sessionId: sessionId),
    );
    
    promise.then(allowInterop((result) {
      completer.complete(result);
    }), allowInterop((error) {
      completer.completeError(error);
    }));
    
    return completer.future;
  }

  // Price IDs for different subscription tiers
  static String getPriceId(String tier, String interval) {
    // TODO: Replace with real Stripe price IDs
    final priceIds = {
      'premium_monthly': 'price_1234567890abcdef1234567890abcdef',
      'premium_annual': 'price_1234567890abcdef1234567890abcdef',
      'pro_monthly': 'price_1234567890abcdef1234567890abcdef',
      'pro_annual': 'price_1234567890abcdef1234567890abcdef',
      'founders_lifetime': 'price_1234567890abcdef1234567890abcdef',
    };
    
    return priceIds['${tier}_$interval'] ?? priceIds['premium_monthly']!;
  }

  // Get subscription products for display
  static List<StripeProduct> getProducts() {
    return [
      StripeProduct(
        tier: 'premium',
        name: 'Crystal Premium',
        description: '5 IDs/day + Collection + Ad-free',
        monthlyPrice: 8.99,
        annualPrice: 89.99,
        features: [
          '5 crystal identifications per day',
          'Unlimited collection storage',
          'Ad-free experience',
          'Basic spiritual guidance',
          'Moon phase notifications',
        ],
      ),
      StripeProduct(
        tier: 'pro',
        name: 'Crystal Pro',
        description: '20 IDs/day + AI Guidance + Premium features',
        monthlyPrice: 19.99,
        annualPrice: 199.99,
        features: [
          '20 crystal identifications per day',
          'AI-powered spiritual guidance',
          'Personalized birth chart analysis',
          'Dream journal with insights',
          'Crystal healing protocols',
          'Sound bath meditations',
          'All premium features',
        ],
      ),
      StripeProduct(
        tier: 'founders',
        name: 'Founders Lifetime',
        description: 'Unlimited everything + Beta access',
        monthlyPrice: null,
        annualPrice: null,
        lifetimePrice: 499.00,
        features: [
          'Unlimited crystal identifications',
          'All Pro features forever',
          'Beta access to new features',
          'Direct founder communication',
          'Exclusive crystal marketplace access',
          'Lifetime updates and support',
        ],
      ),
    ];
  }
}

class StripeCheckoutResult {
  final bool success;
  final String? error;
  final String? sessionId;

  StripeCheckoutResult({
    required this.success,
    this.error,
    this.sessionId,
  });
}

class StripeProduct {
  final String tier;
  final String name;
  final String description;
  final double? monthlyPrice;
  final double? annualPrice;
  final double? lifetimePrice;
  final List<String> features;

  StripeProduct({
    required this.tier,
    required this.name,
    required this.description,
    this.monthlyPrice,
    this.annualPrice,
    this.lifetimePrice,
    required this.features,
  });

  double? getPrice(String interval) {
    switch (interval) {
      case 'monthly':
        return monthlyPrice;
      case 'annual':
        return annualPrice;
      case 'lifetime':
        return lifetimePrice;
      default:
        return monthlyPrice;
    }
  }

  String getPriceString(String interval) {
    final price = getPrice(interval);
    if (price == null) return 'Free';
    
    switch (interval) {
      case 'monthly':
        return '\$${price.toStringAsFixed(2)}/month';
      case 'annual':
        return '\$${price.toStringAsFixed(2)}/year';
      case 'lifetime':
        return '\$${price.toStringAsFixed(2)} one-time';
      default:
        return '\$${price.toStringAsFixed(2)}';
    }
  }
}