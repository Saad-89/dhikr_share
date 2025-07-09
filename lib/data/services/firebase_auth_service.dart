import 'package:dhikr_share/core/interfaces/auth_service.dart';
import 'package:dhikr_share/domain/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService implements AuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserModel> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    return UserModel(uid: user.uid, email: user.email ?? "");
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    return UserModel(uid: user.uid, email: user.email ?? "");
  }
  
  @override
    Future<void> signOut() async{
     await _auth.signOut();
  }
}
