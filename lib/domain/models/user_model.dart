class UserModel {
  final String uid;
  final String email;

   final String username;

  UserModel({
    required this.uid,
    required this.email,

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

    if (uid.isEmpty || email.isEmpty) {
      throw ArgumentError('Missing required user fields');
    }

    return UserModel(
      uid: uid,
      email: email,
      username: username,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      "username": username,
    };
  }
}
