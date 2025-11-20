import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepository {
  /*static final PostRepository shared = PostRepository._internal();
  PostRepository._internal();*/
  PostRepository() {}
  final SupabaseClient _supabase = SupabaseManager.shared.supabase;
  final supabase = SupabaseManager.shared.supabase;

  //좋아요 버튼
  Future<void> toggleLike(int userId, int postId) async {
    final supabase = SupabaseManager.shared.supabase;

    final result = await supabase
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('post_id', postId);

    if (result.isEmpty) {
      await supabase.from('likes').insert({
        'user_id': userId,
        'post_id': postId,
      });
    } else {
      await supabase
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);
    }
  }

  // 로그인 유저가 특정 포스트를 좋아요 했는지 여부 확인
  Future<bool> checkIfLikedPost(int loginUserId, int postId) async {
    final List<dynamic> data = await _supabase
        .from("likes")
        .select('id')
        .eq('user_id', loginUserId)
        .eq('post_id', postId);

    return data.isNotEmpty;
  }

  // 댓글달기
  Future<void> commentSend(int userId, int postId, String text) async {
    final supabase = SupabaseManager.shared.supabase;

    await supabase.from('comments').insert({
      'user_id': userId,
      'post_id': postId,
      'text': text,
      'is_deleted': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  //댓글 가져오기
  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    final supabase = SupabaseManager.shared.supabase;

    final result = await supabase
        .from('comments')
        .select('*, user:user_id(id, nickname)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(result);
  }

  // 특정 포스트의 좋아요 갯수 가져오기
  Future<int> getLikeCount(int postId) async {
    final List<dynamic> data = await supabase
        .from("likes")
        .select('id') // id만 가져오기
        .eq('post_id', postId);

    return data.length;
  }

  //상세게시물 불러오기
  Future<Map<String, dynamic>> getPostById(int id) async {
    final result = await supabase
        .from('posts')
        .select(
          '*, user:user_id(id, nickname), topic:topic_id(id, content, uploaded_at)',
        )
        .eq('id', id)
        .maybeSingle();

    return result ?? {};
  }

  //이미지 수정
  Future<void> updatePostImage(int id, String newUrl) async {
    await supabase.from('posts').update({'image_url': newUrl}).eq('id', id);
  }

  //게시물 추가
  Future<int?> insertPost({
    required int userId,
    required String imageUrl,
    required int topicId,
  }) async {
    final result = await supabase
        .from('posts')
        .insert({'user_id': userId, 'image_url': imageUrl, 'topic_id': topicId})
        .select('id')
        .maybeSingle();

    return result?['id'];
  }

  //게시물 삭제
  Future<void> deletePostWithRelations(int postId) async {
    await supabase.from('likes').delete().eq('post_id', postId);
    await supabase.from('comments').delete().eq('post_id', postId);
    await supabase.from('posts').delete().eq('id', postId);
  }
}
