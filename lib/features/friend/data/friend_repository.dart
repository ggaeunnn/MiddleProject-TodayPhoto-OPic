import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendRepository {
  final _supabase = Supabase.instance.client;

  // 친구 목록 가져오기
  Future<List<Friend>> fetchFriends(int currentPage, int loginUserId) async {
    return await DioManager.shared.fetchFriends(
      currentPage: currentPage,
      loginId: loginUserId,
    );
  }

  // 친구 삭제
  Future<void> deleteFriend(int friendId) async {
    await _supabase.from('friends').delete().eq('id', friendId);
  }
}
