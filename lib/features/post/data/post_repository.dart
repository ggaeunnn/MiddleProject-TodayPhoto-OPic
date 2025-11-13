import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/post_model.dart';

class PostRepository {
  static final PostRepository shared = PostRepository._internal();
  PostRepository._internal();

  final supabase = SupabaseManager.shared.supabase;

  Future<void> toggleLike(int userId, int postId) async {
    final supabase = SupabaseManager.shared.supabase;

    final result = await supabase
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('post_id', postId);
    //좋아요 함, 취소함
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

  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    final supabase = SupabaseManager.shared.supabase;
    final result = await supabase
        .from('comments')
        .select('*, user:user_id(id, nickname)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return result;
  }

  Future<int> getLikeCount(int postId) async {
    final result = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId);
    return result.length;
  }

  Future<Map<String, dynamic>> getPostById(int id) async {
    final result = await supabase
        .from('posts')
        .select('*, user:user_id(id, nickname)')
        .eq('id', id)
        .maybeSingle();

    return result ?? {};
  }

  Future<void> updatePostImage(int id, String newUrl) async {
    await supabase.from('posts').update({'image_url': newUrl}).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    final result = await supabase
        .from('posts')
        .select()
        .order('id', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<int> insertPost({
    required int userId,
    required String imageUrl,
  }) async {
    final result = await supabase
        .from('posts')
        .insert({'user_id': userId, 'image_url': imageUrl, 'topic_id': 3})
        .select('id')
        .maybeSingle();

    return result?['id'];
  }

 post_delete
  Future<void> deletePostWithRelations(int postId) async {
    await supabase.from('likes').delete().eq('post_id', postId);
    await supabase.from('comments').delete().eq('post_id', postId);
    await supabase.from('posts').delete().eq('id', postId);

  Future<Post?> fetchPostWriterId(int postId) async {
    return await SupabaseManager.shared.fetchPostWriterId(postId);

  }
}
