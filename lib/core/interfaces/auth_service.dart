import 'package:dhikr_share/domain/models/user_model.dart';

abstract class AuthService {
  Future<UserModel> signUp(String email , String password);
  Future<UserModel> signIn(String email , String password);
}