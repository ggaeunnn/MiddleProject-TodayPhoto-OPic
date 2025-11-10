import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/models/friend_model.dart';

class FriendRepository {
  Future<List<Friend>> fetchFriends(int currentPage, int loginUser) async {
    return await DioManager.shared.fetchFriends(
      currentPage: currentPage,
      loginId: loginUser,
    );
  }
}
