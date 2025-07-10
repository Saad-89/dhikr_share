// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import './supabase_service.dart';

// class AuthService {
//   static final AuthService _instance = AuthService._internal();
//   factory AuthService() => _instance;
//   AuthService._internal();

//   final SupabaseService _supabaseService = SupabaseService();

//   // Google Sign In configuration
//   static const String _googleClientId = String.fromEnvironment(
//     'GOOGLE_CLIENT_ID',
//     defaultValue: '',
//   );

//   static const String _googleServerClientId = String.fromEnvironment(
//     'GOOGLE_SERVER_CLIENT_ID',
//     defaultValue: '',
//   );

//   late final GoogleSignIn _googleSignIn;

//   bool _isInitialized = false;

//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     // Initialize Google Sign In
//     _googleSignIn = GoogleSignIn(
//       clientId: Platform.isIOS ? _googleClientId : null,
//       serverClientId:
//           _googleServerClientId.isNotEmpty ? _googleServerClientId : null,
//       scopes: ['email', 'profile'],
//     );

//     _isInitialized = true;
//   }

//   // Get current user
//   User? get currentUser {
//     if (!_supabaseService.isInitialized) return null;
//     return _supabaseService.syncClient.auth.currentUser;
//   }

//   // Get current session
//   Session? get currentSession {
//     if (!_supabaseService.isInitialized) return null;
//     return _supabaseService.syncClient.auth.currentSession;
//   }

//   // Check if user is logged in
//   bool get isLoggedIn => currentUser != null;

//   // Email/Password Sign Up
//   Future<AuthResponse> signUpWithEmail({
//     required String email,
//     required String password,
//     String? fullName,
//     String? username,
//   }) async {
//     try {
//       final client = await _supabaseService.client;

//       // Check if user already exists
//       final existingUser = await verifyUserExists(email);
//       if (existingUser != null) {
//         throw AuthException(
//           'An account with this email already exists. Please try signing in instead.',
//         );
//       }

//       final response = await client.auth.signUp(
//         email: email,
//         password: password,
//         data: {
//           if (fullName != null) 'full_name': fullName,
//           if (username != null) 'username': username,
//         },
//       );

//       if (response.user != null) {
//         await _saveLoginState(true);
//         debugPrint('Sign up successful for user: ${response.user!.email}');
//       }

//       return response;
//     } catch (e) {
//       debugPrint('Sign up error: $e');

//       if (e is AuthException) {
//         if (e.message.contains('User already registered')) {
//           throw AuthException(
//             'An account with this email already exists. Please try signing in instead.',
//           );
//         }
//         if (e.message.contains('Password should be at least')) {
//           throw AuthException('Password must be at least 6 characters long.');
//         }
//         if (e.message.contains('Invalid email')) {
//           throw AuthException('Please enter a valid email address.');
//         }
//       }

//       rethrow;
//     }
//   }

//   // Email/Password Sign In
//   Future<AuthResponse> signInWithEmail({
//     required String email,
//     required String password,
//     bool rememberMe = true,
//   }) async {
//     try {
//       final client = await _supabaseService.client;

//       debugPrint('Attempting sign in for email: $email');

//       final response = await client.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );

//       if (response.user != null && rememberMe) {
//         await _saveLoginState(true);
//         await _saveUserCredentials(email, password);
//         debugPrint('Sign in successful for user: ${response.user!.email}');
//       }

//       return response;
//     } catch (e) {
//       debugPrint('Sign in error: $e');

//       // Enhanced error handling for specific auth errors
//       if (e is AuthException) {
//         if (e.message.contains('Invalid login credentials') ||
//             e.message.contains('invalid_credentials')) {
//           throw AuthException(
//             'Invalid email or password. Please check your credentials and try again.\n\n'
//             'If you are a new user, please sign up first.\n'
//             'If you forgot your password, use the "Forgot Password" option.',
//           );
//         }
//         if (e.message.contains('Email not confirmed')) {
//           throw AuthException(
//             'Please check your email and click the confirmation link before signing in.',
//           );
//         }
//         if (e.message.contains('Too many requests')) {
//           throw AuthException(
//             'Too many login attempts. Please wait a few minutes before trying again.',
//           );
//         }
//       }

//       rethrow;
//     }
//   }

//   // Google Sign In
//   Future<AuthResponse?> signInWithGoogle() async {
//     try {
//       if (!_isInitialized) await initialize();

//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final client = await _supabaseService.client;

//       final response = await client.auth.signInWithIdToken(
//         provider: OAuthProvider.google,
//         idToken: googleAuth.idToken!,
//         accessToken: googleAuth.accessToken,
//       );

//       if (response.user != null) {
//         await _saveLoginState(true);
//       }

//       return response;
//     } catch (e) {
//       debugPrint('Google sign in error: $e');
//       rethrow;
//     }
//   }

//   // Apple Sign In
//   Future<AuthResponse?> signInWithApple() async {
//     try {
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );

//       final client = await _supabaseService.client;

//       final response = await client.auth.signInWithIdToken(
//         provider: OAuthProvider.apple,
//         idToken: appleCredential.identityToken!,
//       );

//       if (response.user != null) {
//         await _saveLoginState(true);
//       }

//       return response;
//     } catch (e) {
//       debugPrint('Apple sign in error: $e');
//       rethrow;
//     }
//   }

//   // Sign Out
//   Future<void> signOut() async {
//     try {
//       final client = await _supabaseService.client;
//       await client.auth.signOut();

//       // Clear saved login state
//       await _saveLoginState(false);
//       await _clearUserCredentials();

//       // Sign out from Google if signed in
//       if (_isInitialized) {
//         await _googleSignIn.signOut();
//       }
//     } catch (e) {
//       debugPrint('Sign out error: $e');
//       rethrow;
//     }
//   }

//   // Auto sign in with saved credentials
//   Future<bool> autoSignIn() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

//       if (!isLoggedIn) return false;

//       final client = await _supabaseService.client;
//       final session = client.auth.currentSession;

//       if (session != null && !session.isExpired) {
//         return true;
//       }

//       // Try to refresh session
//       final response = await client.auth.refreshSession();
//       return response.session != null;
//     } catch (e) {
//       debugPrint('Auto sign in error: $e');
//       await _saveLoginState(false);
//       return false;
//     }
//   }

//   // Get user profile
//   Future<Map<String, dynamic>?> getUserProfile() async {
//     try {
//       if (!isLoggedIn) return null;

//       final client = await _supabaseService.client;
//       final response = await client
//           .from('user_profiles')
//           .select()
//           .eq('id', currentUser!.id)
//           .single();

//       return response;
//     } catch (e) {
//       debugPrint('Get user profile error: $e');
//       return null;
//     }
//   }

//   // Update user profile
//   Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
//     try {
//       if (!isLoggedIn) return false;

//       final client = await _supabaseService.client;
//       await client.from('user_profiles').update({
//         ...updates,
//         'updated_at': DateTime.now().toIso8601String()
//       }).eq('id', currentUser!.id);

//       return true;
//     } catch (e) {
//       debugPrint('Update user profile error: $e');
//       return false;
//     }
//   }

//   // Listen to auth state changes
//   Stream<AuthState> get authStateChanges {
//     return _supabaseService.syncClient.auth.onAuthStateChange;
//   }

//   // Reset password
//   Future<void> resetPassword(String email) async {
//     try {
//       final client = await _supabaseService.client;
//       await client.auth.resetPasswordForEmail(email);
//     } catch (e) {
//       debugPrint('Reset password error: $e');
//       rethrow;
//     }
//   }

//   // Private helper methods
//   Future<void> _saveLoginState(bool isLoggedIn) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('is_logged_in', isLoggedIn);
//   }

//   Future<void> _saveUserCredentials(String email, String password) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('saved_email', email);
//     // Note: In production, consider more secure storage for passwords
//     await prefs.setString('saved_password', password);
//   }

//   Future<void> _clearUserCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('saved_email');
//     await prefs.remove('saved_password');
//   }

//   // Check if platform supports specific social login
//   bool get supportsGoogleSignIn => true;
//   bool get supportsAppleSignIn => Platform.isIOS || Platform.isMacOS;

//   // Debug function to verify user exists
//   Future<Map<String, dynamic>?> verifyUserExists(String email) async {
//     try {
//       final client = await _supabaseService.client;

//       final response = await client.rpc(
//         'verify_user_exists',
//         params: {'user_email': email},
//       );

//       if (response != null && response.isNotEmpty) {
//         return response.first as Map<String, dynamic>;
//       }

//       return null;
//     } catch (e) {
//       debugPrint('Error verifying user exists: $e');
//       return null;
//     }
//   }

//   // Test connection and auth setup
//   Future<bool> testAuthConnection() async {
//     try {
//       final client = await _supabaseService.client;

//       // Test basic connectivity
//       final response = await client
//           .from('user_profiles')
//           .select('count')
//           .count(CountOption.exact);

//       debugPrint(
//         'Auth connection test successful. User profiles count: ${response.count}',
//       );
//       return true;
//     } catch (e) {
//       debugPrint('Auth connection test failed: $e');
//       return false;
//     }
//   }
// }
