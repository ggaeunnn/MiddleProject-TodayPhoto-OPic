import 'dart:io';

import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  static final HomeRepository shared = HomeRepository._internal();
  HomeRepository._internal();
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
    final loggedInUserUuid = Supabase.instance.client.auth.currentUser?.id;

    if (loggedInUserUuid == null) {
      throw Exception("로그인된 사용자가 없습니다.");
    }

    final myUserData = await SupabaseManager.shared.supabase
        .from('user')
        .select('id')
        .eq('uuid', loggedInUserUuid)
        .single();

    final myUserId = myUserData['id'] as int;

    final blockedList = await SupabaseManager.shared.supabase
        .from('block')
        .select('blocked_user')
        .eq('user_id', myUserId);

    final blockedUserIds = blockedList
        .map((row) => row['blocked_user'] as int)
        .toSet();

    final posts = await SupabaseManager.shared.supabase
        .from('posts')
        .select('*, user:user_id(id, nickname)')
        .eq('topic_id', topicId)
        .order('id', ascending: false);

    if (posts.isEmpty) {
      return [];
    }

    if (blockedUserIds.isEmpty) {
      return posts;
    }

    final filtered = posts.where((post) {
      final writerId = post['user']?['id'] as int?;
      final nickname = post['user']?['nickname'];

      if (nickname == '알수없음') {
        return false;
      }

      if (writerId != null && blockedUserIds.contains(writerId)) {
        return false;
      }

      return true;
    }).toList();

    return filtered;
  }

  //좋아요 가져오기
  Future<int> getLikeCounts(int postId) async {
    final List<dynamic> data = await _supabase
        .from("likes")
        .select('id') // id만 가져오기
        .eq('post_id', postId);

    return data.length;
  }

  // 특정 포스트의 댓글 갯수 가져오기
  Future<int> getCommentCounts(int postId) async {
    final List<dynamic> data = await _supabase
        .from("comments")
        .select('id') // id만 가져오기
        .eq('post_id', postId);

    return data.length;
  }

  //이미지 수파베이스에
  Future<String?> uploadImageToSupabase(File file) async {
    final supabase = SupabaseManager.shared.supabase;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('post_images').upload(fileName, file);

    return supabase.storage.from('post_images').getPublicUrl(fileName);
  }
}
