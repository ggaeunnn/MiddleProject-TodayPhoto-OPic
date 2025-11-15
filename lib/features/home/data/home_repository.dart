import 'package:opicproject/core/manager/supabase_manager.dart';

class HomeRepository {
  static final HomeRepository shared = HomeRepository._internal();
  HomeRepository._internal();

  final supabase = SupabaseManager.shared.supabase;

  Future<Map<String, dynamic>?> fetchTodayTopic() async {
    final today = DateTime.now().toUtc().toString().substring(0, 10);

    final result = await supabase
        .from('topic')
        .select()
        .gte('uploaded_at', '$today 00:00:00')
        .lte('uploaded_at', '$today 23:59:59')
        .maybeSingle();

    return result;
  }

  Future<int> getLikeCounts(int postId) async {
    return await SupabaseManager.shared.getLikeCount(postId);
  }

  Future<int> getCommentCounts(int postId) async {
    return await SupabaseManager.shared.getCommentCount(postId);
  }
}
