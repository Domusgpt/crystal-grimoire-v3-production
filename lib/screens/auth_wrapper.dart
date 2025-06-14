import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import 'auth_gate_screen.dart';
import 'redesigned_home_screen.dart';

/// Robust authentication wrapper that handles all auth states properly
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;
  String _initStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      setState(() => _initStatus = 'Connecting to Firebase...');
      
      // Get Firebase service from provider
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      setState(() => _initStatus = 'Checking authentication...');
      
      // Wait for auth state to settle (reduced time)
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _initStatus = 'Loading user profile...');
      
      // Let Firebase service complete initialization (reduced time)
      await Future.delayed(const Duration(milliseconds: 200));
      
      debugPrint('🔮 Auth wrapper initialization complete');
      
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      debugPrint('❌ Auth wrapper initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initStatus = 'Ready';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still loading auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // User is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('🏠 AuthWrapper: User authenticated (${snapshot.data?.email ?? 'no email'}), showing home screen');
          return const RedesignedHomeScreen();
        }

        // User not authenticated
        debugPrint('🔒 AuthWrapper: User not authenticated, showing auth gate');
        return const AuthGateScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF20B2AA), Color(0xFFFF4500)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App title
              Text(
                'Crystal Grimoire',
                style: GoogleFonts.cinzel(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Loading indicator
              const CircularProgressIndicator(
                color: Colors.purple,
                strokeWidth: 3,
              ),
              
              const SizedBox(height: 16),
              
              // Status text
              Text(
                _initStatus,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}