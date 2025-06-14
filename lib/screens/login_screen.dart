import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import '../services/firebase_service.dart';
import '../widgets/animations/mystical_animations.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUp;
  
  const LoginScreen({Key? key, required this.isSignUp}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            // Background particles
            const Positioned.fill(
              child: FloatingParticles(
                particleCount: 30,
                color: Colors.deepPurple,
              ),
            ),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF20B2AA), Color(0xFFFF4500)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.diamond,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      Center(
                        child: Text(
                          _isSignUp ? 'Join Crystal Grimoire' : 'Welcome Back',
                          style: GoogleFonts.cinzel(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Center(
                        child: Text(
                          _isSignUp 
                            ? 'Start your mystical journey today'
                            : 'Continue your crystal adventure',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Name field (only for sign up)
                      if (_isSignUp) ...[
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Email field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (_isSignUp && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isSignUp ? 'Create Account' : 'Sign In',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Forgot password (only show for sign in)
                      if (!_isSignUp) ...[
                        Center(
                          child: TextButton(
                            onPressed: _handleForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.lato(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Toggle between sign up and sign in
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                              ? 'Already have an account? Sign In'
                              : 'Don\'t have an account? Sign Up',
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Social login options
                      _buildSocialLoginSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.purple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: GoogleFonts.lato(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              label: 'Google',
              onPressed: _handleGoogleSignIn,
            ),
            _buildSocialButton(
              icon: Icons.apple,
              label: 'Apple',
              onPressed: _handleAppleSignIn,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white70),
          label: Text(
            label,
            style: GoogleFonts.lato(color: Colors.white70),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      if (_isSignUp) {
        await firebaseService.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
      } else {
        await firebaseService.signInUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      
      // Force page reload after successful login to trigger auth state
      debugPrint('✅ Login successful, reloading page to show authenticated state');
      if (mounted) {
        // Wait a moment for auth state to propagate, then reload
        await Future.delayed(const Duration(milliseconds: 500));
        // Force page reload to trigger AuthWrapper with new auth state
        html.window.location.reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.signInWithGoogle();
      // Force page reload after Google sign-in
      debugPrint('✅ Google sign-in successful, reloading page');
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        html.window.location.reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.signInWithApple();
      // Don't navigate here - let the AuthWrapper handle it
      debugPrint('✅ Apple sign-in initiated, AuthWrapper will handle navigation');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.sendPasswordResetEmail(email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}