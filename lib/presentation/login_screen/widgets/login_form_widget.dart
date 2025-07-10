import 'package:dhikr_share/presentation/bottomNavBar/bottomNavBar.dart';
import 'package:dhikr_share/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // _loadSavedCredentials();
    // _testAuthConnection();
  }

  // Future<void> _testAuthConnection() async {
  //   final isConnected = await _authService.testAuthConnection();
  //   if (!isConnected) {
  //     setState(() {
  //       _errorMessage =
  //           'Unable to connect to authentication service. Please check your internet connection.';
  //     });
  //   }
  // }

  // Future<void> _loadSavedCredentials() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedEmail = prefs.getString('saved_email');
  //     final savedPassword = prefs.getString('saved_password');

  //     if (savedEmail != null && savedPassword != null) {
  //       setState(() {
  //         _emailController.text = savedEmail;
  //         _passwordController.text = savedPassword;
  //         _rememberMe = true;
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading saved credentials: $e');
  //   }
  // }

  Future<void> _signIn() async {
    // if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // try {
    //   // First verify if user exists
    //   final userExists = await _authService.verifyUserExists(
    //     _emailController.text.trim(),
    //   );

    //   if (userExists == null) {
    //     setState(() {
    //       _errorMessage = 'No account found with this email address.\n\n'
    //           'Please sign up first or check your email address.';
    //       _isLoading = false;
    //     });
    //     return;
    //   }

    //   if (!userExists['email_confirmed']) {
    //     setState(() {
    //       _errorMessage =
    //           'Please check your email and click the confirmation link before signing in.';
    //       _isLoading = false;
    //     });
    //     return;
    //   }

    //   final response = await _authService.signInWithEmail(
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text,
    //     rememberMe: _rememberMe,
    //   );

    //   if (response.user != null) {
    //     if (mounted) {
    //       Navigator.pushReplacementNamed(context, AppRoutes.mainDhikrCounter);
    //     }
    //   }
    // } catch (e) {
    // setState(() {
    //   if (e is Exception) {
    //     _errorMessage = e.toString();
    //   } else {
    //     _errorMessage = 'Login failed: ${e.toString()}';
    //   }
    //   _isLoading = false;
    // });
    // }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.bottomNav),
        builder: (_) => const BottomNavScreen(),
      ),
      (route) => false,
    );
    setState(() {
      _isLoading = false;
    });
  }

  // Future<void> _createTestUser() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     await _authService.signUpWithEmail(
  //       email: 'user@dhikrshare.com',
  //       password: 'Bismillah123',
  //       fullName: 'Test User',
  //       username: 'testuser',
  //     );

  //     setState(() {
  //       _emailController.text = 'user@dhikrshare.com';
  //       _passwordController.text = 'Bismillah123';
  //       _errorMessage = 'Test user created successfully! You can now sign in.';
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Failed to create test user: ${e.toString()}';
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Remember me checkbox
          TextButton(
            onPressed: () {
              // TODO: Implement forgot password
              Navigator.pushNamed(context, '/reset-password');
            },
            child: const Text('Forgot Password?'),
          ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     // Checkbox(
          //     //   value: _rememberMe,
          //     //   onChanged: (value) {
          //     //     setState(() {
          //     //       _rememberMe = value ?? false;
          //     //     });
          //     //   },
          //     // ),
          //     // const Text('Remember me'),
          //     // const Spacer(),
          //     TextButton(
          //       onPressed: () {
          //         // TODO: Implement forgot password
          //       },
          //       child: const Text('Forgot Password?'),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),

          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Consumer<AuthViewmodel>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: () {
                    provider.signIn(
                      context,
                      _emailController.text,
                      _passwordController.text,
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                );
              },
            ),
          ),

          // const SizedBox(height: 16),

          // // Create test user button (for debugging)
          // if (kDebugMode)
          //   TextButton(
          //     // onPressed: _isLoading ? null : _createTestUser,
          //     onPressed: null,
          //     child: const Text(
          //       'Create Test User (Debug)',
          //       style: TextStyle(fontSize: 12),
          //     ),
          //   ),
          const SizedBox(height: 16),

          // Sign up option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signUpScreen);

                  // TODO: Navigate to sign up screen
                  // Navigator.pushNamed(context, '/islamic-onboarding');
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
