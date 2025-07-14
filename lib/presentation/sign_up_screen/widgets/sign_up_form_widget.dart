import 'dart:io';

import 'package:dhikr_share/presentation/bottomNavBar/bottomNavBar.dart';
import 'package:dhikr_share/viewmodels/auth_viewmodel.dart';
import 'package:dhikr_share/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({super.key});

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  final bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Image Picker UI
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     Container(
          //       padding: EdgeInsets.all(3),
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         border: Border.all(
          //           color:
          //               _selectedImage != null
          //                   ? Theme.of(context).primaryColor
          //                   : Colors.grey.shade300,
          //           width: 2,
          //         ),
          //       ),
          //       child: GestureDetector(
          //         onTap: () async {
          //           setState(() => _isUploadingImage = true);
          //           await _pickImage();
          //           setState(() => _isUploadingImage = false);
          //         },
          //         child: CircleAvatar(
          //           radius: 45,
          //           backgroundColor: Colors.grey.shade200,
          //           backgroundImage:
          //               _selectedImage != null
          //                   ? FileImage(File(_selectedImage!.path))
          //                   : null,
          //           child:
          //               _selectedImage == null
          //                   ? const Icon(
          //                     Icons.add_a_photo,
          //                     size: 30,
          //                     color: Colors.grey,
          //                   )
          //                   : null,
          //         ),
          //       ),
          //     ),

          //     if (_isUploadingImage)
          //       Container(
          //         width: 96,
          //         height: 96,
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: Colors.black.withOpacity(0.4),
          //         ),
          //         child: const Center(
          //           child: SizedBox(
          //             width: 24,
          //             height: 24,
          //             child: CircularProgressIndicator(
          //               strokeWidth: 2.5,
          //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //             ),
          //           ),
          //         ),
          //       ),
          //   ],
          // ),
          // const SizedBox(height: 16),

          // username field
          TextFormField(
            controller: _userController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

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

          const SizedBox(height: 20),

          // Remember me checkbox

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
                    if (_formKey.currentState!.validate()) {
                      // provider.signUp(
                      //   context,
                      //   _userController.text,
                      //   _emailController.text,
                      //   _passwordController.text,
                      // );
                      provider.signUp(
                        context,
                        _userController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text,
                        _selectedImage,
                      );
                    }
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.loginScreen);
                },
                child: const Text('Sign In'),
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

// import 'package:dhikr_share/presentation/bottomNavBar/bottomNavBar.dart';
// import 'package:dhikr_share/viewmodels/auth_viewmodel.dart';
// import 'package:dhikr_share/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SignUpFormWidget extends StatefulWidget {
//   const SignUpFormWidget({super.key});

//   @override
//   State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
// }

// class _SignUpFormWidgetState extends State<SignUpFormWidget> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _userController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   bool _isLoading = false;
//   final bool _rememberMe = false;
//   bool _obscurePassword = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           // Email field
//           TextFormField(
//             controller: _userController,
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               labelText: 'Username',
//               prefixIcon: const Icon(Icons.person),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your username';
//               }
//               return null;
//             },
//           ),

//           const SizedBox(height: 16),

//           TextFormField(
//             controller: _emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: InputDecoration(
//               labelText: 'Email',
//               prefixIcon: const Icon(Icons.email_outlined),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               }
//               if (!RegExp(
//                 r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//               ).hasMatch(value)) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//           ),

//           const SizedBox(height: 16),

//           // Password field
//           TextFormField(
//             controller: _passwordController,
//             obscureText: _obscurePassword,
//             decoration: InputDecoration(
//               labelText: 'Password',
//               prefixIcon: const Icon(Icons.lock_outline),
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _obscurePassword = !_obscurePassword;
//                   });
//                 },
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your password';
//               }
//               if (value.length < 6) {
//                 return 'Password must be at least 6 characters';
//               }
//               return null;
//             },
//           ),

//           const SizedBox(height: 20),

//           // Remember me checkbox

//           // Error message
//           if (_errorMessage != null)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red.shade200),
//               ),
//               child: Text(
//                 _errorMessage!,
//                 style: TextStyle(color: Colors.red.shade700, fontSize: 14),
//               ),
//             ),

//           // Login button
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: Consumer<AuthViewmodel>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 return ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       provider.signUp(
//                         context,
//                         _userController.text,
//                         _emailController.text,
//                         _passwordController.text,
//                       );
//                     }
//                   },

//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child:
//                       _isLoading
//                           ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                           : const Text(
//                             'Sign Up',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 16),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text("Already have an account?"),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, AppRoutes.loginScreen);
//                 },
//                 child: const Text('Sign In'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
