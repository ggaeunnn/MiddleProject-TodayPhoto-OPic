import 'package:opicproject/core/manager/supabase_manager.dart';

class PostRepository {
  static final PostRepository shared = PostRepository._internal();
  PostRepository._internal();
  final supabase = SupabaseManager.shared.supabase;

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    return await SupabaseManager.shared.supabase.from('posts').select();
  }

  Future<Map<String, dynamic>> getPostById(int id) async {
    return await SupabaseManager.shared.supabase
        .from('posts')
        .select()
        .eq('id', id)
        .single();
  }

  Future<void> updatePostImage(int id, String newUrl) async {
    await SupabaseManager.shared.supabase
        .from('posts')
        .update({'image_url': newUrl})
        .eq('id', id);
  }
}
