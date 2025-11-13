// feed_viewmodel.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/models/user_model.dart';

import 'feed_repository.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedRepository _repository = FeedRepository();

  int currentPage = 1;
  ScrollController scrollController = ScrollController();

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  bool shouldShowScrollUpButton = false;

  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserInfo? _feedUser;
  UserInfo? get feedUser => _feedUser;

  bool _isBlocked = false;
  bool get isBlocked => _isBlocked;

  bool _isBlockedMe = false;
  bool get isBlockedMe => _isBlockedMe;

  bool _isRequested = false;
  bool get isRequested => _isRequested;

  int? _currentFeedUserId;

  bool _isStatusChecked = false;
  bool get isStatusChecked => _isStatusChecked;

  FeedViewModel() {
    _initializeScrollListener();
  }

  void _initializeScrollListener() {
    Timer? debounce;

    scrollController.addListener(() {
      if (debounce?.isActive ?? false) debounce!.cancel();

      debounce = Timer(const Duration(milliseconds: 300), () {
        final double offset = scrollController.offset;

        if (offset < 60) {
          if (shouldShowScrollUpButton) {
            shouldShowScrollUpButton = false;
            notifyListeners();
          }
        } else {
          if (!shouldShowScrollUpButton) {
            shouldShowScrollUpButton = true;
            notifyListeners();
          }
        }
      });

      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        debugPrint('Scroll End');
        if (_currentFeedUserId != null) {
          fetchMorePosts(_currentFeedUserId!);
        }
      }
    });
  }

  Future<void> initializeFeed(int feedUserId, int loginUserId) async {
    if (_currentFeedUserId == feedUserId && _isInitialized) {
      debugPrint("FeedViewModel already initialized for user $feedUserId");
      return;
    }

    _currentFeedUserId = feedUserId;
    _loginUserId = loginUserId;
    _isInitialized = false;
    _posts = [];
    _feedUser = null;
    _isStatusChecked = false;

    _isLoading = true;
    notifyListeners();

    await fetchAUser(feedUserId);
    await fetchPosts(1, feedUserId);

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkUserStatus(int loginUserId, int feedUserId) async {
    if (_isStatusChecked) {
      return;
    }

    await Future.wait([
      checkIfBlocked(loginUserId, feedUserId),
      checkIfRequested(loginUserId, feedUserId),
      checkIfBlockedMe(loginUserId, feedUserId),
    ]);

    _isStatusChecked = true;
    notifyListeners();
  }

  void moveScrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  // 피드 게시물들 가져오기
  Future<void> fetchPosts(int startIndex, int userId) async {
    _posts = await _repository.fetchPosts(startIndex, userId);
    debugPrint("FeedViewModel fetchPosts 호출됨: ${_posts.length}개");
  }

  Future<void> refresh(int userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    currentPage = 1;
    _posts = await _repository.fetchPosts(currentPage, userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMorePosts(int userId) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    currentPage += 1;
    final fetchedPosts = await _repository.fetchPosts(currentPage, userId);

    if (fetchedPosts.isNotEmpty) {
      _posts.addAll(fetchedPosts);
    } else {
      currentPage -= 1;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 아이디로 유저 정보 조회
  Future<void> fetchAUser(int userId) async {
    _feedUser = await _repository.fetchAUser(userId);
    notifyListeners();
  }

  // 내가 상대를 차단했는지 확인
  Future<void> checkIfBlocked(int loginUserId, int userId) async {
    _isBlocked = await _repository.checkIfBlocked(loginUserId, userId);
  }

  // 상대가 나를 차단했는지 확인
  Future<void> checkIfBlockedMe(int loginUserId, int userId) async {
    _isBlockedMe = await _repository.checkIfBlockedMe(loginUserId, userId);
  }

  // 차단하기
  Future<void> blockUser(int loginUserId, int userId) async {
    await _repository.blockUser(loginUserId, userId);
    _isBlocked = true;
    notifyListeners();
  }

  // 차단해제하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    _isBlocked = false;
    notifyListeners();
  }

  // 친구 요청중인지 확인
  Future<void> checkIfRequested(int loginUserId, int userId) async {
    _isRequested = await _repository.checkIfRequested(loginUserId, userId);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
