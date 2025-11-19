import 'package:dio/dio.dart';
import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/data/user_relation_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedRepository {
  final Dio _dio = DioManager.shared.dio;
  final SupabaseClient _supabase = Supabase.instance.client;

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

  // 유저 관계 상태 한번에 가져오기
  Future<UserRelationState> fetchUserRelation(
    int loginUserId,
    int targetUserId,
  ) async {
    final results = await Future.wait([
      isUserBlocked(loginUserId, targetUserId),
      isUserBlockedMe(loginUserId, targetUserId),
      isFriendRequested(loginUserId, targetUserId),
      isFriendNow(loginUserId, targetUserId),
    ]);

    return UserRelationState(
      isBlocked: results[0],
      isBlockedMe: results[1],
      isRequested: results[2],
      isFriend: results[3],
    );
  }

  // 친구 목록 가져오기
  Future<List<Friend>> fetchFriends({
    int currentPage = 1,
    int perPage = 5,
    required int loginId,
  }) async {
    final range = _calculateRange(page: currentPage, perPage: perPage);

    final response = await _dio.get(
      '/friends',
      queryParameters: {
        'select': '*',
        'or': '(user1_id.eq.$loginId,user2_id.eq.$loginId)',
      },
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

  // 공통 관계 확인 하기
  Future<bool> _checkRelationExists({
    required String table,
    required Map<String, Object> conditions,
  }) async {
    final data = await _supabase
        .from(table)
        .select('id')
        .match(conditions)
        .maybeSingle();

    return data != null;
  }

  // 차단 여부 확인하기 (내가 상대를)
  Future<bool> isUserBlocked(int loginUserId, int userId) async {
    return await _checkRelationExists(
      table: 'block',
      conditions: {'user_id': loginUserId, 'blocked_user': userId},
    );
  }

  // 차단 여부 확인하기 (상대가 나를)
  Future<bool> isUserBlockedMe(int loginUserId, int userId) async {
    return await _checkRelationExists(
      table: 'block',
      conditions: {'user_id': userId, 'blocked_user': loginUserId},
    );
  }

  // 차단하기
  Future<void> blockUser(int loginUserId, int userId) async {
    await _supabase.from("block").insert({
      'user_id': loginUserId,
      'blocked_user': userId,
      'blocked_at': DateTime.now().toIso8601String(),
    });
  }

  // 차단 해제 하기
  Future<void> unblockUser(int loginId, int targetId) async {
    await _supabase
        .from("block")
        .delete()
        .eq('user_id', loginId)
        .eq('blocked_user', targetId);
  }

  // 친구 관계 확인하기
  Future<bool> isFriendNow(int loginUserId, int userId) async {
    final data = await _supabase
        .from("friends")
        .select('id')
        .or(
          'and(user1_id.eq.$loginUserId,user2_id.eq.$userId),and(user1_id.eq.$userId,user2_id.eq.$loginUserId)',
        )
        .maybeSingle();

    return data != null;
  }

  // 친구 신청 중인지 확인하기
  Future<bool> isFriendRequested(int loginUserId, int userId) async {
    final data = await _supabase
        .from("friend_request")
        .select('id')
        .isFilter('answered_at', null)
        .or(
          'and(request_id.eq.$loginUserId,target_id.eq.$userId),and(request_id.eq.$userId,target_id.eq.$loginUserId)',
        )
        .maybeSingle();

    return data != null;
  }

  // 친구 요청 취소하기
  Future<void> deleteARequest(int loginUserId, int targetUserId) async {
    await _supabase
        .from("friend_request")
        .delete()
        .eq('request_id', loginUserId)
        .eq('target_id', targetUserId);
  }

  // 유저의 피드 게시물 가져오기
  Future<List<Post>> fetchPosts({
    int currentPage = 1,
    int perPage = 15,
    required int userId,
  }) async {
    final range = _calculateRange(page: currentPage, perPage: perPage);

    final response = await _dio.get(
      '/posts',
      queryParameters: {
        'select': '*',
        'user_id': 'eq.$userId',
        'is_deleted': 'eq.false',
        'order': 'created_at.desc',
      },
      options: Options(headers: {'Range': range}),
    );
    if (response.data != null) {
      final List data = response.data;
      final List<Post> results = data.map((json) {
        return Post.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // range header
  String _calculateRange({required int page, required int perPage}) {
    final int startIndex = perPage * (page - 1);
    final int endIndex = startIndex + perPage - 1;
    return "$startIndex-$endIndex";
  }
}
