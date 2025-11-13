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

  // 차단 여부 확인하기
  Future<bool> checkIfBlocked(int loginUserId, int userId) async {
    return await SupabaseManager.shared.checkIfBlocked(loginUserId, userId);
  }

  // 차단하기
  Future<void> blockUser(int loginUserId, int userId) async {
    return await SupabaseManager.shared.blockUser(loginUserId, userId);
  }

  // 차단 해제 하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    return await SupabaseManager.shared.unblockUser(loginUserId, userId);
  }
}
