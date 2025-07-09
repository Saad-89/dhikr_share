import 'package:dhikr_share/core/interfaces/auth_service.dart';
import 'package:dhikr_share/data/services/firestore_user_service.dart';
import 'package:dhikr_share/domain/models/user_model.dart';
import 'package:dhikr_share/presentation/bottomNavBar/bottomNavBar.dart';
import 'package:dhikr_share/presentation/login_screen/login_screen.dart';
import 'package:dhikr_share/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  Future<void> signUp(context, userName, email, password) async {
    _setLoading(true);
    try {
      _user = await authService.signUp(email, password);
      if (_user != null) {
        final user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          username: userName,
        );
        await _firestoreUserService.saveUser(user);
      }

      _setLoading(false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: AppRoutes.bottomNav),
          builder: (_) => const BottomNavScreen(),
        ),
        (route) => false,
      );
      Fluttertoast.showToast(msg: "Account Created SuccessFully!");
    } catch (e) {
      _setLoading(false);
      print(e.toString());
    }
  }

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
      Fluttertoast.showToast(msg: "Sign In Successfully Created SuccessFully!");
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
}

