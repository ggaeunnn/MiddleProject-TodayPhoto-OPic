import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/models/friend_model.dart';

class FriendRepository {
  // 친구 목록 가져오기
  Future<List<Friend>> fetchFriends(int currentPage, int loginUserId) async {
    return await DioManager.shared.fetchFriends(
      currentPage: currentPage,
      loginId: loginUserId,
    );
  }

  // 친구 수 세기
}
