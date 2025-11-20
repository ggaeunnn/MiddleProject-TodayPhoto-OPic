import 'package:opicproject/core/models/friend_model.dart';

extension FriendExtension on Friend {
  int getOtherUserId(int loginId) {
    return loginId == user1Id ? user2Id : user1Id;
  }
}
