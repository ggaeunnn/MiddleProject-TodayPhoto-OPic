import 'package:opicproject/core/manager/supabase_manager.dart';

class PostRepository {
  static final PostRepository shared = PostRepository._internal();
  PostRepository._internal();

  final supabase = SupabaseManager.shared.supabase;

  // 홈
  Future<List<Map<String, dynamic>>> getAllPosts() async {
    return await supabase.from('posts').select();
  }

  // 상세
  Future<Map<String, dynamic>> getPostById(int id) async {
    return await supabase.from('posts').select().eq('id', id).single();
  }

  Future<void> updatePostImage(int id, String newUrl) async {
    await supabase.from('posts').update({'image_url': newUrl}).eq('id', id);
  }

  // 좋아요
  Future<void> toggleLike(String userId, int postId) async {
    final res = await supabase
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('post_id', postId);

    if (res.isEmpty) {
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

  Future<void> fetchLike(String userId, int postId) async {
    final supabase = SupabaseManager.shared.supabase;

    final res = await supabase
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('post_id', postId);

    if (res.isEmpty) {
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

  // 좋아요 개수
  Future<int> getLikeCount(int postId) async {
    final res = await supabase.from('likes').select('id').eq('post_id', postId);
    return res.length;
  }
}
