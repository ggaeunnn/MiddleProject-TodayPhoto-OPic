import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/core/models/friend_request_model.dart';
import 'package:opicproject/core/models/user_model.dart';

class FriendRepository {
  // 특정 유저 정보 가져오기
  Future<UserInfo?> fetchAUser(int userId) async {
    return await SupabaseManager.shared.fetchAUser(userId);
  }

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

  // 친구 관계 확인하기
  Future<bool> checkIfFriend(int loginUserId, int friendUserId) async {
    return await SupabaseManager.shared.checkIfFriend(
      loginUserId,
      friendUserId,
    );
  }

  // 해당 친구가 있는지 확인하기
  Future<bool> checkIfExist(String userNickname) async {
    return await SupabaseManager.shared.checkIfExist(userNickname);
  }

  // 닉네임으로 친구 정보 가져오기
  Future<UserInfo?> fetchAUserByName(String nickname) async {
    return await SupabaseManager.shared.fetchAUserByName(nickname);
  }

  // 친구 요청하기
  Future<void> makeARequest(int loginUserId, int targetUserId) async {
    return await SupabaseManager.shared.makeARequest(loginUserId, targetUserId);
  }

  // 친구 요청 응답하기
  Future<void> answerARequest(int requestId) async {
    return await SupabaseManager.shared.answerARequest(requestId);
  }

  // 친구 요청 수락 - 친구 추가하기
  Future<void> acceptARequest(
    int requestId,
    int loginUserId,
    int requesterId,
  ) async {
    return await SupabaseManager.shared.acceptARequest(
      requestId,
      loginUserId,
      requesterId,
    );
  }

  // 닉네임 변경하기
  Future<void> editNickname(int loginUserId, String nickname) async {
    await SupabaseManager.shared.editNickname(loginUserId, nickname);
  }
}
