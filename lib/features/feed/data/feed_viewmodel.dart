import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
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

  // AuthManager 상태 구독
  FeedViewModel() {
    AuthManager.shared.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    _checkCurrentAuth();
  }

  void _checkCurrentAuth() {
    final userId = AuthManager.shared.userInfo?.id;

    if (userId != null && !_isInitialized) {
      _loginUserId = userId;
      _isInitialized = true;
      notifyListeners();
      initialize(userId);
    } else if (userId == null && _isInitialized) {
      _loginUserId = null;
      _isInitialized = false;
      _posts = [];
      notifyListeners();
    } else if (userId != null && _isInitialized) {
      print("초기화 완료");
    }

    debugPrint("userId: $userId");
  }

  void _initializeScrollListener() {
    Timer? debounce;

    // 바닥 감지
    scrollController.addListener(() {
      // scroll 일어나면 기존 타이머 취소
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
        //여기에 바닥감지시 실행할 코드를 작성한다.
        fetchMorePosts(_loginUserId!);
      }
    });
  }

  Future<void> initialize(int loginUserId) async {
    _loginUserId = loginUserId;
    currentPage = 1;
    await fetchPosts(currentPage, loginUserId);
  }

  void moveScrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
    // scrollController.position.minScrollExtent
  }

  // 리포지토리에서 데이터 가져오는데 이제 시작하자마자 가져오기
  Future<void> fetchPosts(int startIndex, int userId) async {
    _isLoading = true;
    notifyListeners();

    _posts = await _repository.fetchPosts(startIndex, userId);
    _isLoading = false;

    //구독자(?)에게 알림보내기
    notifyListeners();
    debugPrint("FeedViewModel _initPosts 호출됨");
  }

  Future<void> refresh(int userId) async {
    // isLoading을 true로 설정 (리스트는 비우지 않음)
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
    currentPage += 1;
    final fetchedPosts = await _repository.fetchPosts(currentPage, userId);

    if (fetchedPosts.isNotEmpty) {
      _posts.addAll(fetchedPosts);
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
    debugPrint("FriendViewmodel fetchedFriends 호출됨");
  }

  // 유저 정보 가져오기
  Future<void> fetchAUser(int userId) async {
    _feedUser = await _repository.fetchAUser(userId);
    notifyListeners();
    debugPrint("certainUser : $_feedUser");
  }

  // 차단 여부 확인하기
  Future<void> checkIfBlocked(int loginUserId, int userId) async {
    _isBlocked = await _repository.checkIfBlocked(loginUserId, userId);
    notifyListeners();
  }

  // 차단하기
  Future<void> blockUser(int loginUserId, int userId) async {
    await _repository.blockUser(loginUserId, userId);
    notifyListeners();
  }

  // 차단 해제 하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    notifyListeners();
  }

  void dispose() {
    AuthManager.shared.removeListener(_onAuthChanged);
    scrollController.dispose();
    super.dispose();
  }
}
