import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhikr_share/core/constants/firestore_collections.dart';
import 'package:dhikr_share/core/interfaces/user_data_service.dart';
import 'package:dhikr_share/domain/models/user_model.dart';
class FirestoreUserService implements UserDataService {

  static final FirestoreUserService _instance = FirestoreUserService._internal();
  factory FirestoreUserService() => _instance;
  FirestoreUserService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<void> saveUser(UserModel user) async{
    await _firestore.collection(FirestoreCollections.users).doc(user.uid).set(user.toJson());
  }
  
}