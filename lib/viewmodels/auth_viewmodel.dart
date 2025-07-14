import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhikr_share/core/interfaces/auth_service.dart';
import 'package:dhikr_share/data/services/firestore_user_service.dart';
import 'package:dhikr_share/domain/models/user_model.dart';
import 'package:dhikr_share/presentation/bottomNavBar/bottomNavBar.dart';
import 'package:dhikr_share/routes/app_routes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AuthViewmodel extends ChangeNotifier {
  final AuthService authService;
  final FirestoreUserService _firestoreUserService;
  AuthViewmodel(this.authService, this._firestoreUserService);

  UserModel? _user;
  String? _error;
  bool _loading = false;

  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }


// new signup method including profile image

Future signUp(BuildContext context, String userName, String email, String password, XFile? imageFile) async {
  _setLoading(true);
  try {
    _user = await authService.signUp(email, password);
    if (_user != null) {
      // String? profileImageUrl;

      // Upload profile image if selected
      // if (imageFile != null) {
      //   final ref = FirebaseStorage.instance
      //       .ref()
      //       .child("profile_images")
      //       .child("${_user!.uid}.jpg");

      //   await ref.putData(await imageFile.readAsBytes());
      //   profileImageUrl = await ref.getDownloadURL();
      // }

      final now = Timestamp.now();

      final user = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        username: userName,
        profileImage: "https://onlinelearninginsights.wordpress.com/wp-content/uploads/2012/06/facebook-avatar.png",
        createdAt: now,
        lastActive: now,
        isProfilePrivate: false,
      );

      await _firestoreUserService.saveUser(user);

      _setLoading(false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: AppRoutes.bottomNav),
          builder: (_) => const BottomNavScreen(),
        ),
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Account Created Successfully!");
    }
  } catch (e) {
    _setLoading(false);
    print(e.toString());
    Fluttertoast.showToast(msg: "Sign up failed: ${e.toString()}");
  }
}


  // Future<void> signUp(context, userName, email, password) async {
  //   _setLoading(true);
  //   try {
  //     _user = await authService.signUp(email, password);
  //     if (_user != null) {
  //       final user = UserModel(
  //         uid: _user!.uid,
  //         email: _user!.email,
  //         username: userName,
  //       );
  //       await _firestoreUserService.saveUser(user);
  //     }

  //     _setLoading(false);
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //         settings: RouteSettings(name: AppRoutes.bottomNav),
  //         builder: (_) => const BottomNavScreen(),
  //       ),
  //       (route) => false,
  //     );
  //     Fluttertoast.showToast(msg: "Account Created SuccessFully!");
  //   } catch (e) {
  //     _setLoading(false);
  //     print(e.toString());
  //   }
  // }

  Future<void> signIn(context, email, password) async {
    _setLoading(true);
    try {
      _user = await authService.signIn(email, password);
      _setLoading(false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: AppRoutes.bottomNav),
          builder: (_) => const BottomNavScreen(),
        ),
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Sign In Successfully!");
    } catch (e) {
      _setLoading(false);
      print(e.toString());
    }
  }

  void signOut(context) async {
    _setLoading(true);
    try {
      await authService.signOut();
      _setLoading(false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Sign Out SuccessFully!");
    } catch (e) {
      _setLoading(false);
      print(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(
    BuildContext context,
    String email,
  ) async {
    _setLoading(true);
    try {
      await authService.sendPasswordResetEmail(email);
      _setLoading(false);
      Fluttertoast.showToast(msg: "Password reset email sent successfully!");
      Navigator.pop(context);
    } catch (e) {
      _setLoading(false);
      Fluttertoast.showToast(
        msg: "Failed to send reset email: ${e.toString()}",
      );
    }
  }
}
