import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String from;
  final String to;
  final String status;
  final Timestamp timestamp;

  FriendRequestModel({
    required this.from,
    required this.to,
    required this.status,
    required this.timestamp,
  });

  /// From Firestore JSON
  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      status: json['status'] ?? 'pending',
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  /// To Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
