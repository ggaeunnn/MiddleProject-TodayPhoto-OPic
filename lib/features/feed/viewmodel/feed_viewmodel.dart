import 'package:flutter/material.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/features/feed/data/feed_repository.dart';
import 'package:opicproject/features/feed/data/feed_service.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedService _service;
  //해당 피드의 주인 유저 아이디
  final int userId = 1;
  String nickname = '';
  final bool isMyFeed = false;

  List<Post> _posts = [];
  int likeCount = 0;
  int postCount = 0;
  // ===== Public Getters =====
  List<Post> get feed => _posts;

  FeedViewModel(this._service) {
    _initialize();
  }

  //뷰모델 초기화
  void _initialize() async {
    fetchFeed(userId);
  }

  //로그인 된 유저와 해당 뷰모델이 가진 유저아이디 비교
  void checkMyFeed() {}
  Future<void> fetchFeed(int userId) async {
    Map<String, dynamic> data = await _service.fetchFeed(userId);

    _posts = data['posts'] ?? [];
    nickname = data['nickname'] ?? '';
    likeCount = data['like_count'] ?? 0;
    postCount = data['post_count'] ?? 0;

    notifyListeners();
  }

  Future<void> blockUser(userId) async {
    await _service.blockUser(userId);
  }
}
