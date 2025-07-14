import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? profileImage;
  final Timestamp? requestTimestamp;
  final Timestamp? lastActive;
  final Timestamp? createdAt;
  final bool isProfilePrivate;

  UserModel({
    required this.uid,
    required this.email,
    this.username = "",
    this.profileImage,
    this.requestTimestamp,
    this.lastActive,
    this.createdAt,
    this.isProfilePrivate = false,
  });

  /// Create UserModel from JSON, with safe null/empty handling
  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON map is null');
    }

    final uid = json['uid']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';
    final username = json['username']?.toString() ?? '';
    final profileImage = json['profileImage']?.toString();
    final requestTimestamp = json['requestTimestamp'] is Timestamp
        ? json['requestTimestamp'] as Timestamp
        : null;
    final lastActive = json['lastActive'] is Timestamp
        ? json['lastActive'] as Timestamp
        : null;
    final createdAt = json['createdAt'] is Timestamp
        ? json['createdAt'] as Timestamp
        : null;
    final isProfilePrivate = json['isProfilePrivate'] is bool
        ? json['isProfilePrivate'] as bool
        : false;

    if (uid.isEmpty || email.isEmpty) {
      throw ArgumentError('Missing required user fields');
    }

    return UserModel(
      uid: uid,
      email: email,
      username: username,
      profileImage: profileImage,
      requestTimestamp: requestTimestamp,
      lastActive: lastActive,
      createdAt: createdAt,
      isProfilePrivate: isProfilePrivate,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profileImage': profileImage,
      'requestTimestamp': requestTimestamp,
      'lastActive': lastActive,
      'createdAt': createdAt,
      'isProfilePrivate': isProfilePrivate,
    };
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserModel {
//   final String uid;
//   final String email;

//   final String username;
//   final Timestamp? requestTimestamp;

//   UserModel({
//     required this.uid,
//     required this.email,
//     this.requestTimestamp,

//     this.username = "",
//   });

//   /// Create UserModel from JSON, with safe null/empty handling
//   factory UserModel.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       throw ArgumentError('JSON map is null');
//     }

//     final uid = json['uid']?.toString() ?? '';
//     final email = json['email']?.toString() ?? '';
//     final username = json['username']?.toString() ?? '';
//     final Timestamp? requestTimestamp =
//         json['requestTimestamp'] is Timestamp
//             ? json['requestTimestamp'] as Timestamp
//             : null;
//     if (uid.isEmpty || email.isEmpty) {
//       throw ArgumentError('Missing required user fields');
//     }

//     return UserModel(
//       uid: uid,
//       email: email,
//       username: username,
//       requestTimestamp: requestTimestamp,
//     );
//   }

//   /// Convert UserModel to JSON
//   Map<String, dynamic> toJson() {
//     return {'uid': uid, 'email': email, "username": username, "requestTimestamp": requestTimestamp};
//   }
// }
