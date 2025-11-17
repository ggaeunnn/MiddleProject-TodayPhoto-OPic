import 'package:flutter/foundation.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/models/topic_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager shared = SupabaseManager._internal();

  factory SupabaseManager() => shared;

  SupabaseManager._internal() {
    debugPrint("SupabaseManager init");
  }

  SupabaseClient get supabase => Supabase.instance.client;

  // 오늘의 주제 가져오기
  Future<Topic?> fetchATopic(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfNextDay = DateTime(date.year, date.month, date.day + 1);

    final Map<String, dynamic>? data = await supabase
        .from("topic")
        .select('content')
        .gte('uploaded_at', startOfDay.toIso8601String())
        .lt('uploaded_at', startOfNextDay.toIso8601String())
        .maybeSingle();

    if (data == null) {
      return null;
    }
    return Topic.fromJson(data);
  }

  Future<Post?> fetchPostWriterId(int postId) async {
    final Map<String, dynamic>? data = await supabase
        .from("posts")
        .select('*')
        .eq('id', postId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return Post.fromJson(data);
  }

  // 특정 포스트의 좋아요 갯수 가져오기
  Future<int> getLikeCount(int postId) async {
    final List<dynamic> data = await supabase
        .from("likes")
        .select('id') // id만 가져오기
        .eq('post_id', postId);

    return data.length;
  }

  // 특정 포스트의 댓글 갯수 가져오기
  Future<int> getCommentCount(int postId) async {
    final List<dynamic> data = await supabase
        .from("comments")
        .select('id') // id만 가져오기
        .eq('post_id', postId);

    return data.length;
  }

  // 로그인 유저가 특정 포스트를 좋아요 했는지 여부 확인
  Future<bool> checkIfLikedPost(int loginUserId, int postId) async {
    final List<dynamic> data = await supabase
        .from("likes")
        .select('id')
        .eq('user_id', loginUserId)
        .eq('post_id', postId);

    return data.isNotEmpty;
  }
}
