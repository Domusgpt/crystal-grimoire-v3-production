import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:html' as html;
import '../models/user_profile.dart';
import '../models/crystal_collection.dart';
import '../models/journal_entry.dart';

/// FIXED Firebase Service using proper Firebase SDK
class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  UserProfile? _userProfile;
  
  // Getters
  bool get isAuthenticated => _currentUser != null;
  String? get currentUserId => _currentUser?.uid;
  UserProfile? get currentUser => _userProfile;
  UserProfile? get currentUserProfile => _userProfile;
  bool get isConfigured => true; // Firebase is always configured
  
  /// Initialize the service
  Future<void> initialize() async {
    try {
      // Set auth persistence to LOCAL (persists across browser sessions)
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
        debugPrint('🔒 Auth persistence set to LOCAL');
      }
      
      // Handle Google Sign-In redirect result FIRST (web only)
      if (kIsWeb) {
        await handleGoogleSignInRedirect();
      }
      
      // Load current user if already signed in AFTER redirect processing
      _currentUser = _auth.currentUser;
      if (_currentUser != null) {
        debugPrint('🔑 Found existing user: ${_currentUser?.email ?? 'unknown'}');
        await _loadUserProfile(_currentUser!.uid);
      }
      
      // Listen to auth state changes with enhanced logging and delayed processing
      _auth.authStateChanges().listen((User? user) async {
        debugPrint('🔄 Auth state changed: ${user?.uid ?? 'null'}');
        if (user != null) {
          debugPrint('✅ User authenticated: ${user.email} (${user.uid})');
          _currentUser = user;
          await _loadUserProfile(user.uid);
          debugPrint('📝 User profile loaded successfully');
        } else {
          debugPrint('🔒 User not authenticated');
          // Wait a moment in case auth state is still settling after redirect
          await Future.delayed(const Duration(milliseconds: 1000));
          final delayedUser = _auth.currentUser;
          if (delayedUser != null) {
            debugPrint('🔄 Found user after delay: ${delayedUser.email}');
            _currentUser = delayedUser;
            await _loadUserProfile(delayedUser.uid);
          } else {
            _currentUser = null;
            _userProfile = null;
          }
        }
        notifyListeners();
        debugPrint('📡 Auth state listeners notified');
      });
    } catch (e) {
      debugPrint('❌ Firebase service initialization error: $e');
    }
  }
  
  /// Register new user with email and password
  Future<UserProfile> registerUser({
    required String email,
    required String password,
    required String name,
    DateTime? birthDate,
    String? birthTime,
    String? birthLocation,
  }) async {
    try {
      // Create authentication account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Failed to create user account');
      }
      
      // Update display name
      await credential.user!.updateDisplayName(name);
      
      // Create user profile
      final userProfile = UserProfile(
        id: credential.user!.uid,
        name: name,
        email: email,
        subscriptionTier: SubscriptionTier.free,
        createdAt: DateTime.now(),
        birthDate: birthDate,
        birthTime: birthTime,
        birthLocation: birthLocation,
      );
      
      // Save user profile to Firestore
      await _saveUserProfile(userProfile);
      _userProfile = userProfile;
      _currentUser = credential.user;
      
      notifyListeners();
      return userProfile;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  /// Sign in existing user
  Future<UserProfile> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Sign in failed - no user returned');
      }
      
      _currentUser = credential.user;
      await _loadUserProfile(credential.user!.uid);
      
      notifyListeners();
      return _userProfile!;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _userProfile = null;
    notifyListeners();
  }
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
  
  /// Save user profile to Firestore
  Future<void> _saveUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.id)
        .set(profile.toJson());
  }
  
  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        _userProfile = UserProfile.fromJson(doc.data()!);
        debugPrint('📋 Loaded existing user profile: ${_userProfile?.email}');
      } else {
        // Create default profile for any authenticated user
        _userProfile = UserProfile(
          id: userId,
          name: _currentUser?.displayName ?? 'User',
          email: _currentUser?.email ?? '',
          subscriptionTier: SubscriptionTier.free,
          createdAt: DateTime.now(),
        );
        await _saveUserProfile(_userProfile!);
        debugPrint('🆕 Created new user profile: ${_userProfile?.email}');
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
      // Create minimal fallback profile
      _userProfile = UserProfile(
        id: userId,
        name: _currentUser?.displayName ?? 'User',
        email: _currentUser?.email ?? '',
        subscriptionTier: SubscriptionTier.free,
        createdAt: DateTime.now(),
      );
      debugPrint('🔄 Created fallback profile for user');
    }
  }
  
  /// Save crystal collection to Firestore
  Future<void> saveCrystalCollection(List<CollectionEntry> collection) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    try {
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(currentUserId!);
      
      // Save collection as subcollection
      for (final entry in collection) {
        final entryRef = userRef.collection('crystals').doc(entry.id);
        batch.set(entryRef, entry.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save crystal collection: $e');
    }
  }
  
  /// Load crystal collection from Firestore
  Future<List<CollectionEntry>> loadCrystalCollection() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId!)
          .collection('crystals')
          .get();
      
      return snapshot.docs
          .map((doc) => CollectionEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Failed to load crystal collection: $e');
      return [];
    }
  }
  
  /// Save journal entry to Firestore
  Future<void> saveJournalEntry(JournalEntry entry) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId!)
          .collection('journal')
          .doc(entry.id)
          .set(entry.toJson());
    } catch (e) {
      throw Exception('Failed to save journal entry: $e');
    }
  }
  
  /// Load journal entries from Firestore
  Future<List<JournalEntry>> loadJournalEntries({int limit = 50}) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId!)
          .collection('journal')
          .orderBy('dateTime', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => JournalEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Failed to load journal entries: $e');
      return [];
    }
  }
  
  /// Update user subscription tier
  Future<void> updateSubscriptionTier(SubscriptionTier tier) async {
    if (!isAuthenticated || _userProfile == null) {
      throw Exception('User not authenticated');
    }
    
    _userProfile = _userProfile!.copyWith(subscriptionTier: tier);
    await _saveUserProfile(_userProfile!);
    notifyListeners();
  }
  
  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    await _saveUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }
  
  /// Get service status
  Map<String, dynamic> getServiceStatus() {
    return {
      'configured': isConfigured,
      'authenticated': isAuthenticated,
      'current_user': _userProfile?.name ?? 'None',
      'user_id': currentUserId,
    };
  }
  
  /// Sign in with Google using Firebase redirect method (no popups, no Google SDK)
  Future<UserProfile> signInWithGoogle() async {
    try {
      // Create Google Auth Provider with proper configuration
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });
      
      if (kIsWeb) {
        // Use Firebase redirect for web - no popup, no Google SDK needed
        await _auth.signInWithRedirect(googleProvider);
        // This method doesn't return - it redirects the page
        // The result is handled in handleGoogleSignInRedirect()
        return UserProfile(
          id: 'redirecting',
          name: 'Redirecting...',
          email: '',
          subscriptionTier: SubscriptionTier.free,
          createdAt: DateTime.now(),
        );
      } else {
        // Mobile - use Firebase popup
        final userCredential = await _auth.signInWithPopup(googleProvider);
        
        if (userCredential.user == null) {
          throw Exception('Failed to authenticate with Google');
        }
        
        final user = userCredential.user!;
        _userProfile = UserProfile(
          id: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email ?? '',
          subscriptionTier: SubscriptionTier.free,
          createdAt: DateTime.now(),
          profileImageUrl: user.photoURL,
        );
        
        await _saveUserProfile(_userProfile!);
        _currentUser = user;
        
        notifyListeners();
        return _userProfile!;
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      throw Exception('Google sign-in failed: $e');
    }
  }
  
  /// Handle redirect result after Google Sign-In (web only)
  Future<void> handleGoogleSignInRedirect() async {
    if (!kIsWeb) return;
    
    try {
      debugPrint('🔍 Checking for Google Sign-In redirect result...');
      
      // Check for redirect result with retry logic
      UserCredential? userCredential;
      for (int i = 0; i < 3; i++) {
        userCredential = await _auth.getRedirectResult();
        debugPrint('🔍 Redirect result check attempt ${i + 1}: ${userCredential.user?.email ?? 'null'}');
        
        if (userCredential.user != null) {
          break;
        }
        
        // Wait before retry
        if (i < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
        }
      }
      
      if (userCredential?.user != null) {
        debugPrint('✅ Google Sign-In redirect successful!');
        final user = userCredential!.user!;
        
        // Create user profile
        _userProfile = UserProfile(
          id: user.uid,
          name: user.displayName ?? 'Google User',
          email: user.email ?? '',
          subscriptionTier: SubscriptionTier.free,
          createdAt: DateTime.now(),
          profileImageUrl: user.photoURL,
        );
        
        // Save to Firestore
        await _saveUserProfile(_userProfile!);
        _currentUser = user;
        
        debugPrint('🔮 User profile created and saved: ${user.email}');
        debugPrint('🔑 Auth state: ${_auth.currentUser?.uid}');
        
        // Force notify listeners and reload page to show authenticated state
        notifyListeners();
        
        // Force page reload to ensure UI updates
        if (kIsWeb) {
          debugPrint('🔄 Forcing page reload after successful Google auth');
          await Future.delayed(const Duration(milliseconds: 500));
          html.window.location.reload();
        }
        
      } else {
        debugPrint('ℹ️ No redirect result found');
        // Check if user is already authenticated (may take time after redirect)
        if (_auth.currentUser != null) {
          debugPrint('✅ User already authenticated: ${_auth.currentUser?.email ?? 'unknown'}');
          _currentUser = _auth.currentUser;
          if (_currentUser != null) {
            await _loadUserProfile(_currentUser!.uid);
          }
          notifyListeners();
        } else {
          // Try waiting a bit longer for auth state to update after redirect
          debugPrint('⏳ Waiting for potential auth state change after redirect...');
          await Future.delayed(const Duration(seconds: 3));
          if (_auth.currentUser != null) {
            debugPrint('✅ Auth state updated after delay: ${_auth.currentUser?.email ?? 'unknown'}');
            _currentUser = _auth.currentUser;
            if (_currentUser != null) {
              await _loadUserProfile(_currentUser!.uid);
            }
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Google redirect result error: $e');
      // Still check for existing auth
      if (_auth.currentUser != null) {
        debugPrint('🔄 Fallback: User still authenticated');
        _currentUser = _auth.currentUser;
        if (_currentUser != null) {
          await _loadUserProfile(_currentUser!.uid);
        }
        notifyListeners();
      }
    }
  }
  
  /// Sign in with Apple
  Future<UserProfile> signInWithApple() async {
    try {
      // Import at top of file if needed
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.crystalgrimoire.v3.service',
          redirectUri: Uri.parse('https://crystalgrimoire-production.firebaseapp.com/__/auth/handler'),
        ),
      );
      
      // Create Firebase credential
      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      // Sign in to Firebase with Apple credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('Failed to authenticate with Apple');
      }
      
      // Create or update user profile
      final user = userCredential.user!;
      final displayName = appleCredential.givenName != null && appleCredential.familyName != null
          ? '${appleCredential.givenName} ${appleCredential.familyName}'
          : user.displayName ?? 'Apple User';
      
      _userProfile = UserProfile(
        id: user.uid,
        name: displayName,
        email: appleCredential.email ?? user.email ?? '',
        subscriptionTier: SubscriptionTier.free,
        createdAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _saveUserProfile(_userProfile!);
      _currentUser = user;
      
      notifyListeners();
      return _userProfile!;
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }
  
  /// Real-time user profile stream
  Stream<UserProfile?> getUserProfileStream() {
    if (!isAuthenticated) {
      return Stream.value(null);
    }
    
    return _firestore
        .collection('users')
        .doc(currentUserId!)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfile.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
  
  /// Real-time crystal collection stream
  Stream<List<CollectionEntry>> getCrystalCollectionStream() {
    if (!isAuthenticated) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('users')
        .doc(currentUserId!)
        .collection('crystals')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CollectionEntry.fromJson(doc.data()))
          .toList();
    });
  }
  
  /// Track user activity for analytics
  Future<void> trackUserActivity(String activity, Map<String, dynamic> metadata) async {
    if (!isAuthenticated) return;
    
    try {
      await _firestore
          .collection('analytics')
          .doc()
          .set({
        'user_id': currentUserId,
        'activity': activity,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
        'subscription_tier': _userProfile?.subscriptionTier.name ?? 'free',
      });
    } catch (e) {
      debugPrint('Activity tracking failed: $e');
    }
  }
}