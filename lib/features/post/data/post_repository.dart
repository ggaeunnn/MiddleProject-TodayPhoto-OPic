import 'package:opicproject/core/manager/supabase_manager.dart';

class PostRepository {
  static final PostRepository shared = PostRepository._internal();
  PostRepository._internal();

  final supabase = SupabaseManager.shared.supabase;

  /// 좋아요 토글
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

  /// 댓글 작성
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

  /// 댓글 목록 조회
  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    final supabase = SupabaseManager.shared.supabase;

    final result = await supabase
        .from('comments')
        .select('*, user:user_id(id, nickname)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(result);
  }

  /// 좋아요 개수 조회
  Future<int> getLikeCount(int postId) async {
    final result = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId);

    return result.length;
  }

  /// 게시물 하나 조회
  Future<Map<String, dynamic>> getPostById(int id) async {
    final result = await supabase
        .from('posts')
        .select('*, user:user_id(id, nickname)')
        .eq('id', id)
        .maybeSingle();

    return result ?? {};
  }

  /// 게시물 이미지 수정
  Future<void> updatePostImage(int id, String newUrl) async {
    await supabase.from('posts').update({'image_url': newUrl}).eq('id', id);
  }

  /// 전체 게시물 조회
  Future<List<Map<String, dynamic>>> getAllPosts() async {
    final result = await supabase
        .from('posts')
        .select()
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  /// 게시물 생성
  Future<int?> insertPost({
    required int userId,
    required String imageUrl,
  }) async {
    final result = await supabase
        .from('posts')
        .insert({
          'user_id': userId,
          'image_url': imageUrl,
          'topic_id': 3, // 필요하면 나중에 파라미터로 변경
        })
        .select('id')
        .maybeSingle();

    return result?['id'];
  }

  /// 게시물 + 댓글 + 좋아요 삭제
  Future<void> deletePostWithRelations(int postId) async {
    await supabase.from('likes').delete().eq('post_id', postId);
    await supabase.from('comments').delete().eq('post_id', postId);
    await supabase.from('posts').delete().eq('id', postId);
  }
}
