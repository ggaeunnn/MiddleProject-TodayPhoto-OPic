import 'package:dio/dio.dart';
import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/block_model.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/core/models/friend_request_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendRepository {
  final Dio _dio = DioManager.shared.dio;
  final SupabaseClient _supabase = SupabaseManager.shared.supabase;

  // 특정 유저 정보 가져오기
  Future<UserInfo?> fetchAUser(int userId) async {
    final Map<String, dynamic>? data = await _supabase
        .from("user")
        .select('*')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return UserInfo.fromJson(data);
  }

  // 특정 유저 정보 가져오기 (닉네임으로)
  Future<UserInfo?> fetchAUserByName(String nickname) async {
    final Map<String, dynamic>? data = await _supabase
        .from("user")
        .select('*')
        .eq('nickname', nickname)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return UserInfo.fromJson(data);
  }

  // 친구 목록 가져오기
  Future<List<Friend>> fetchFriends({
    int currentPage = 1,
    int perPage = 5,
    required int loginId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      '/friends?select=*,user1:user!friends_user1_id_fkey(exit_at),user2:user!friends_user2_id_fkey(exit_at)&or=(user1_id.eq.$loginId,user2_id.eq.$loginId)&user1.exit_at=is.null&user2.exit_at=is.null',
      options: Options(headers: {'Range': range}),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<Friend> results = data.map((json) {
        return Friend.fromJson(json);
      }).toList();

      return results;
    } else {
      return List.empty();
    }
  }

  // 친구 요청 목록 가져오기
  Future<List<FriendRequest>> fetchFriendRequests({
    int currentPage = 1,
    int perPage = 5,
    required int loginId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      '/friend_request?select=*,requester:user!friend_request_request_id_fkey(exit_at)&target_id=eq.$loginId&answered_at=is.null&requester.exit_at=is.null',
      options: Options(headers: {'Range': range}),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<FriendRequest> results = data.map((json) {
        return FriendRequest.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // 친구 삭제하기
  Future<void> deleteFriend(int friendId) async {
    await _supabase.from('friends').delete().eq('id', friendId);
  }

  // 친구 관계 확인하기
  Future<bool> checkIfFriend(int loginUserId, int friendUserId) async {
    final Map<String, dynamic>? data = await _supabase
        .from("friends")
        .select('*')
        .or(
          'and(user1_id.eq.$loginUserId,user2_id.eq.$friendUserId), and(user1_id.eq.$friendUserId,user2_id.eq.$loginUserId)',
        )
        .maybeSingle();
    if (data == null) {
      return false;
    }
    return true;
  }

  // 해당 닉네임을 사용하는 사용자가 있는지 확인하기
  Future<bool> checkIfExist(String userNickname, {int? excludeUserId}) async {
    if (excludeUserId != null) {
      final List<dynamic> data = await _supabase
          .from("user")
          .select('id')
          .eq('nickname', userNickname);

      final filtered = data
          .where((user) => user['id'] != excludeUserId)
          .toList();
      return filtered.isNotEmpty;
    } else {
      final Map<String, dynamic>? data = await _supabase
          .from("user")
          .select('*')
          .eq('nickname', userNickname)
          .maybeSingle();
      if (data == null) {
        return false;
      }
      return true;
    }
  }

  // 친구 요청하기
  Future<void> makeARequest(int loginUserId, int targetUserId) async {
    await _supabase.from('friend_request').insert({
      "created_at": "${DateTime.now()}",
      "request_id": loginUserId,
      "target_id": targetUserId,
    });
  }

  // 친구 요청 응답하기
  Future<void> answerARequest(int requestId) async {
    await _supabase
        .from('friend_request')
        .update({'answered_at': "${DateTime.now()}"})
        .eq('id', requestId);
  }

  // 친구 요청 수락 - 친구 추가하기
  Future<void> acceptARequest(
    int requestId,
    int loginUserId,
    int requesterId,
  ) async {
    await _supabase.from('friends').insert({
      'created_at': "${DateTime.now()}",
      'user1_id': loginUserId,
      'user2_id': requesterId,
    });
  }

  // 차단 사용자 목록 불러오기 (pager)
  Future<List<BlockUser>> fetchBlockedUserWithPager({
    int currentPage = 1,
    int perPage = 10,
    required int loginId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      '/block?select=*,blocked:user!block_blocked_user_fkey(exit_at)&user_id=eq.$loginId&blocked.exit_at=is.null',
      options: Options(headers: {'Range': range}),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<BlockUser> results = data.map((json) {
        return BlockUser.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // 차단 해제하기
  Future<void> unblockUser(int loginId, int targetId) async {
    await _supabase
        .from("block")
        .delete()
        .eq('user_id', loginId)
        .eq('blocked_user', targetId);
  }
}
