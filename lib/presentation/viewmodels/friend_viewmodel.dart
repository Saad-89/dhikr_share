import 'package:dhikr_share/data/services/firebase_friend_service.dart';
import 'package:dhikr_share/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FriendViewmodel extends ChangeNotifier {
  final FirebaseFriendService _firebaseFriendService;

  FriendViewmodel(this._firebaseFriendService);
  bool _loading = false;

  bool get isLoading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  List<UserModel> _requestSenders = [];

  List<UserModel> get requestSenders => _requestSenders;

  Future<void> sendFriendRequestByEmail(
    BuildContext context,
    String receiverEmail,
  ) async {
    try {
      _setLoading(true);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _setLoading(false);
        Fluttertoast.showToast(msg: "User not authenticated.");
        return;
      }

      await _firebaseFriendService.sendFriendRequestByEmail(
        currentUser.uid,
        receiverEmail,
      );

      _setLoading(false);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Friend request sent successfully!");
    } catch (e) {
      _setLoading(false);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> loadFriendRequests() async {
    try {
      _setLoading(true);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _setLoading(false);
        return;
      }

      final result = await _firebaseFriendService.getFriendRequests();

      _requestSenders = result;
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      print("Error loading friend requests: $e");
    }
  }
}
