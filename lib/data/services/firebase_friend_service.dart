import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhikr_share/core/constants/firestore_collections.dart';
import 'package:dhikr_share/core/interfaces/friend_service.dart';
import 'package:dhikr_share/domain/models/friend_request_model.dart';
import 'package:dhikr_share/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFriendService implements FriendRequestService {
  static final FirebaseFriendService _instance =
      FirebaseFriendService._internal();
  factory FirebaseFriendService() => _instance;
  FirebaseFriendService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> sendFriendRequest(FriendRequestModel request) async {
    final docId = '${request.from}_to_${request.to}';
    final docRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.friendRequests)
        .doc(docId);

    final existing = await docRef.get();
    if (existing.exists) {
      throw Exception("Friend request already sent.");
    }

    await docRef.set(request.toJson());
  }

@override
Future<void> sendFriendRequestByEmail(
  String fromUid,
  String receiverEmail,
) async {
  final querySnapshot = await _firestore
      .collection(FirestoreCollections.users)
      .where('email', isEqualTo: receiverEmail)
      .limit(1)
      .get();

  if (querySnapshot.docs.isEmpty) {
    throw Exception("User with email not found.");
  }

  final toUid = querySnapshot.docs.first.id;

  if (fromUid == toUid) {
    throw Exception("You cannot send request to yourself.");
  }

  final request = FriendRequestModel(
    from: fromUid,
    to: toUid,
    status: 'pending',
    timestamp: Timestamp.now(),
  );

  await sendFriendRequest(request);
}

@override
Future<List<UserModel>> getFriendRequests() async {
  final List<UserModel> requestSenders = [];

  // Step 1: Get all friend_requests where 'to' == currentUserId
  final friendRequestSnapshot = await _firestore
      .collection(FirestoreCollections.friendRequests)
      .where('to', isEqualTo: _auth.currentUser?.uid)
      .where('status', isEqualTo: 'pending')
      .get();


  if (friendRequestSnapshot.docs.isEmpty) return [];

  // Step 2: Extract sender IDs (from)
  final senderIds = friendRequestSnapshot.docs.map((doc) => doc['from']).toList();

  // Step 3: Fetch all users where uid in senderIds
  final usersSnapshot = await _firestore
      .collection(FirestoreCollections.users)
      .where(FieldPath.documentId, whereIn: senderIds)
      .get();

  for (var doc in usersSnapshot.docs) {
    final user = UserModel.fromJson(doc.data());
    log("user time ${user.requestTimestamp}");
    requestSenders.add(user);
  }

  return requestSenders;
}


}
