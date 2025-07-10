import 'package:dhikr_share/domain/models/user_model.dart';

abstract class UserDataService {
  Future<void> saveUser(UserModel user);
}