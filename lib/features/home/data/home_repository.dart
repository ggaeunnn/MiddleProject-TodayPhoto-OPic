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

  //게시물 주제 연결
  Future<List<Map<String, dynamic>>> getPostsByTopicId(int topicId) async {
    final result = await _supabase
        .from('posts')
        .select()
        .eq('topic_id', topicId)
        .order('id', ascending: false);
    return List<Map<String, dynamic>>.from(result);
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
