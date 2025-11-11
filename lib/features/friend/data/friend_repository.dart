import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/core/models/friend_request_model.dart';

class FriendRepository {
  // 친구 목록 가져오기
  Future<List<Friend>> fetchFriends(int currentPage, int loginUserId) async {
    return await DioManager.shared.fetchFriends(
      currentPage: currentPage,
      loginId: loginUserId,
    );
  }

  // 친구 삭제하기
  Future<void> deleteFriend(int friendId) async {
    await SupabaseManager.shared.supabase
        .from('friends')
        .delete()
        .eq('id', friendId);
  }

  // 친구 요청 목록 가져오기
  Future<List<FriendRequest>> fetchFriendRequests(
    int currentPage,
    int loginUserId,
  ) async {
    return await DioManager.shared.fetchFriendRequests(
      currentPage: currentPage,
      loginId: loginUserId,
    );
  }
}
