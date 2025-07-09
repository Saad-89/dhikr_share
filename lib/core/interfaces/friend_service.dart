import 'package:dhikr_share/domain/models/friend_request_model.dart';



abstract class FriendRequestService {
  Future<void> sendFriendRequest(FriendRequestModel request);
  Future<void> sendFriendRequestByEmail(String fromUid,
  String receiverEmail,);
  Future<void> getFriendRequests();
}