import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/features/friend/data/friend_repository.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendRepository _repository = FriendRepository();

  int currentPage = 1;
  ScrollController scrollController = ScrollController();

  List<Friend> _friends = [];
  List<Friend> get friends => _friends;

  bool shouldShowScrollUpButton = false;

  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  bool _showFriendRequests = false;
  bool get showFriendRequests => _showFriendRequests;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // AuthManager 상태 구독
  FriendViewModel() {
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
      _friends = [];
      notifyListeners();
    } else if (userId != null && _isInitialized) {
      print("초기화 완료");
    }

    debugPrint("userId: $userId");
  }

  void _initializeScrollListener() {
    Timer? _debounce;

    // 바닥 감지
    scrollController.addListener(() {
      // scroll 일어나면 기존 타이머 취소
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 300), () {
        final double offset = scrollController.offset;

        if (offset < 30) {
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
        fetchMoreFriends(_loginUserId!);
      }
    });
  }

  void changeTab(bool showRequests) {
    _showFriendRequests = showRequests;
    notifyListeners();
  }

  Future<void> initialize(int loginUserId) async {
    _loginUserId = loginUserId;
    currentPage = 1;
    await fetchFriends(currentPage, loginUserId);
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
  Future<void> fetchFriends(int startIndex, int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    _friends = await _repository.fetchFriends(startIndex, loginUserId);
    _isLoading = false;

    //구독자(?)에게 알림보내기
    notifyListeners();
    debugPrint("FriendViewModel _initFriends 호출됨");
  }

  Future<void> refresh(int loginUserId) async {
    _friends = [];
    notifyListeners();
    // 1.7초 딜레이
    await Future.delayed(const Duration(milliseconds: 1000));
    currentPage = 1;
    _friends = await _repository.fetchFriends(currentPage, loginUserId);
    notifyListeners();
  }

  Future<void> fetchMoreFriends(int loginUser) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedFriends = await _repository.fetchFriends(
      currentPage,
      loginUser,
    );

    if (fetchedFriends.isNotEmpty) {
      _friends.addAll(fetchedFriends);
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
    debugPrint("FriendViewmodel fetchedFriends 호출됨");
  }

  // 친구 삭제하기
  Future<void> deleteFriend(int friendId) async {
    await _repository.deleteFriend(friendId);
    _friends.removeWhere((friend) => friend.id == friendId);
    notifyListeners();
  }
}
