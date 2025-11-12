import 'package:opicproject/core/manager/supabase_manager.dart';

class PostRepository {
  static final PostRepository shared = PostRepository._internal();
  PostRepository._internal();

  final supabase = SupabaseManager.shared.supabase;

  Future<void> toggleLike(int userId, int postId) async {
    final supabase = SupabaseManager.shared.supabase;

    final res = await supabase
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('post_id', postId);
    //좋아요 함, 취소함
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

  Future<int> getLikeCount(int postId) async {
    final res = await supabase.from('likes').select('id').eq('post_id', postId);
    return res.length;
  }

  Future<Map<String, dynamic>> getPostById(int id) async {
    final res = await supabase
        .from('posts')
        .select()
        .eq('id', id)
        .maybeSingle();
    return res ?? {};
  }

  Future<void> updatePostImage(int id, String newUrl) async {
    await supabase.from('posts').update({'image_url': newUrl}).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    final res = await supabase.from('posts').select();
    return List<Map<String, dynamic>>.from(res);
  }
}
