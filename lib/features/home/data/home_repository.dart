import 'dart:io';

import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  /*static final HomeRepository shared = HomeRepository._internal();
  HomeRepository._internal();*/
  final SupabaseClient _supabase = SupabaseManager.shared.supabase;

  // 오늘의 주제 가져오기
  Future<Map<String, dynamic>?> fetchTodayTopic() async {
    final today = DateTime.now().toUtc().toString().substring(0, 10);

    final result = await _supabase
        .from('topic')
        .select()
        .gte('uploaded_at', '$today 00:00:00')
        .lte('uploaded_at', '$today 23:59:59')
        .maybeSingle();

    return result;
  }

  //게시물 주제연결
  Future<List<Map<String, dynamic>>> getPostsByTopicId(int topicId) async {
    try {
      final loggedInUserUuid = _supabase.auth.currentUser?.id;

      Set<int> blockedUserIds = {};
      Set<int> reportedPostIds = {};

      // 신고된 게시물
      final reportedList = await _supabase
          .from('post_report')
          .select('reported_post_id')
          .eq('is_checked', true);

      reportedPostIds = reportedList
          .map((row) => row['reported_post_id'] as int)
          .toSet();

      // 로그인한 경우 차단 목록 가져오기
      if (loggedInUserUuid != null) {
        final myUserData = await _supabase
            .from('user')
            .select('id')
            .eq('uuid', loggedInUserUuid)
            .maybeSingle();

        if (myUserData != null) {
          final myUserId = myUserData['id'] as int;

          final blockedList = await _supabase
              .from('block')
              .select('blocked_user')
              .eq('user_id', myUserId);

          blockedUserIds = blockedList
              .map((row) => row['blocked_user'] as int)
              .toSet();
        }
      }

      // 게시글 가져오기
      final posts = await _supabase
          .from('posts')
          .select('*, user:user_id(id, nickname)')
          .eq('topic_id', topicId)
          .order('id', ascending: false);

      if (posts.isEmpty) return [];

      // 필터링
      final filtered = posts.where((post) {
        final postId = post['id'] as int?;
        final writerId = post['user']?['id'] as int?;
        final nickname = post['user']?['nickname'];

        if (postId != null && reportedPostIds.contains(postId)) return false;
        if (nickname == '알수없음') return false;
        if (writerId != null && blockedUserIds.contains(writerId)) return false;

        return true;
      }).toList();

      return filtered;
    } catch (_) {
      return [];
    }
  }

  //좋아요 가져오기
  Future<int> getLikeCounts(int postId) async {
    final data = await _supabase
        .from("likes")
        .select('id')
        .eq('post_id', postId);

    return data.length;
  }

  // 특정 포스트의 댓글 갯수 가져오기
  Future<int> getCommentCounts(int postId) async {
    final data = await _supabase
        .from("comments")
        .select('id')
        .eq('post_id', postId);

    return data.length;
  }

  //이미지 수파베이스에
  Future<String?> uploadImageToSupabase(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage.from('post_images').upload(fileName, file);

    return _supabase.storage.from('post_images').getPublicUrl(fileName);
  }
}
