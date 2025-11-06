import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/features/feed/data/feed_repository.dart';

class FeedService {
  final FeedRepository _dataRepository;

  FeedService(this._dataRepository);

  //온보딩 콘텐츠 데이터 가져오기
  Future<Map<String, dynamic>> fetchFeed(userId) async {
    return await _dataRepository.fetchFeed(userId);
  }

  Future<void> blockUser(userId) async {
    return await _dataRepository.blockUser(userId);
  }
}
