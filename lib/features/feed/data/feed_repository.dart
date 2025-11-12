import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/models/user_model.dart';

class FeedRepository {
  // 친구 목록 가져오기
  Future<List<Post>> fetchPosts(int currentPage, int userId) async {
    return await DioManager.shared.fetchPosts(
      currentPage: currentPage,
      userId: userId,
    );
  }

  // 유저 정보 가져오기
  Future<UserInfo?> fetchAUser(int userId) async {
    return await SupabaseManager.shared.fetchAUser(userId);
  }

  Future<void> blockUser(int userId) async {
    //TODO:데이터베이스 처리
    return;
  }
}
