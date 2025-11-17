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
  bool shouldShowScrollUpButton = false;

  // 피드 게시물 목록
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  // 로그인 유저 아이디
  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  // 초기설정 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 로딩중
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 피드 주인 유저 정보
  UserInfo? _feedUser;
  UserInfo? get feedUser => _feedUser;

  // 차단 여부(내가 상대를)
  bool _isBlocked = false;
  bool get isBlocked => _isBlocked;

  // 차단 여부(상대가 나를)
  bool _isBlockedMe = false;
  bool get isBlockedMe => _isBlockedMe;

  // 친구 요청 중인지 여부
  bool _isRequested = false;
  bool get isRequested => _isRequested;

  // 현재 피드 주인 유저
  int? _currentFeedUserId;

  // 관계 상태 확인 여부
  bool _isStatusChecked = false;
  bool get isStatusChecked => _isStatusChecked;

  FeedViewModel() {
    _initializeScrollListener();
  }

  // 스크롤 관련
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

  void moveScrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  // 피드 정보 초기설정 (다른 유저 피드로 이동할 때 이전 유저 정보 남지 않게)
  Future<void> initializeFeed(int feedUserId, int loginUserId) async {
    if (_currentFeedUserId == feedUserId && _isInitialized) {
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

    await Future.wait([fetchAUser(feedUserId), fetchPosts(1, feedUserId)]);

    _isInitialized = true;
    _isLoading = false;

    notifyListeners();
  }

  // 유저와 피드 유저의 관계 확인
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

  // 새로고침
  Future<void> refresh(int userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    currentPage = 1;
    _posts = await _repository.fetchPosts(
      currentPage: currentPage,
      userId: userId,
    );

    _isLoading = false;
    notifyListeners();
  }

  // 피드 게시물 가져오기
  Future<void> fetchPosts(int startIndex, int userId) async {
    _posts = await _repository.fetchPosts(
      currentPage: startIndex,
      userId: userId,
    );
  }

  // 피드 게시물 가져오기 (다음 페이지)
  Future<void> fetchMorePosts(int userId) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    currentPage += 1;
    final fetchedPosts = await _repository.fetchPosts(
      currentPage: currentPage,
      userId: userId,
    );

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
  }

  // 차단 여부 확인 (내가 상대를)
  Future<void> checkIfBlocked(int loginUserId, int userId) async {
    _isBlocked = await _repository.checkIfBlocked(loginUserId, userId);
  }

  // 차단 여부 확인 (상대가 나를)
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

  // 친구 요청 중인지 확인
  Future<void> checkIfRequested(int loginUserId, int userId) async {
    _isRequested = await _repository.checkIfRequested(loginUserId, userId);
  }

  // 친구 요청 취소하기
  Future<void> deleteARequest(int loginUserId, int targetUserId) async {
    await _repository.deleteARequest(loginUserId, targetUserId);
    _isRequested = false;
    notifyListeners();
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
