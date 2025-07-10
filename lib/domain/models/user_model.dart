import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;

  final String username;
  final Timestamp? requestTimestamp;

  UserModel({
    required this.uid,
    required this.email,
    this.requestTimestamp,

    this.username = "",
  });

  /// Create UserModel from JSON, with safe null/empty handling
  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON map is null');
    }

    final uid = json['uid']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';
    final username = json['username']?.toString() ?? '';
    final Timestamp? requestTimestamp =
        json['requestTimestamp'] is Timestamp
            ? json['requestTimestamp'] as Timestamp
            : null;
    if (uid.isEmpty || email.isEmpty) {
      throw ArgumentError('Missing required user fields');
    }

    return UserModel(
      uid: uid,
      email: email,
      username: username,
      requestTimestamp: requestTimestamp,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, "username": username, "requestTimestamp": requestTimestamp};
  }
}
