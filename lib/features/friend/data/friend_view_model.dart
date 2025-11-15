import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/block_model.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/core/models/friend_request_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/friend/data/friend_repository.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendRepository _repository = FriendRepository();

  int currentPage = 1;
  ScrollController scrollController = ScrollController();

  List<Friend> _friends = [];
  List<Friend> get friends => _friends;

  List<FriendRequest> _friendRequests = [];
  List<FriendRequest> get friendRequests => _friendRequests;

  List<BlockUser> _blockUsers = [];
  List<BlockUser> get blockUsers => _blockUsers;

  Map<int, UserInfo> _userInfoCache = {};
  Map<int, UserInfo> get userInfoCache => _userInfoCache;

  bool shouldShowScrollUpButton = false;

  UserInfo? _certainUser;
  UserInfo? get certainUser => _certainUser;

  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  bool _isExist = false;
  bool get isExist => _isExist;

  bool _isFriend = false;
  bool get isFriend => _isFriend;

  int _tabNumber = 0;
  int get tabNumber => _tabNumber;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // AuthManager 상태 구독
  FriendViewModel() {
    AuthManager.shared.addListener(_onAuthChanged);
    _checkCurrentAuth();
    _initializeScrollListener();
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
      _userInfoCache = {}; // 캐시 초기화
      notifyListeners();
    } else if (userId != null && _isInitialized) {
      debugPrint("초기화 완료");
    }

    debugPrint("userId: $userId");
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
        fetchMoreFriends(_loginUserId!);
      }
    });
  }

  void changeTab(int tab) {
    _tabNumber = tab;
    notifyListeners();
  }

  Future<void> initialize(int loginUserId) async {
    _loginUserId = loginUserId;
    currentPage = 1;

    await fetchFriends(currentPage, loginUserId);
    await fetchFriendRequests(currentPage, loginUserId);
    await fetchBlockUsersWithPager(currentPage, loginUserId);

    await _loadAllUserInfos();
  }

  void moveScrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> _loadAllUserInfos() async {
    final allUserIds = <int>{};

    for (var friend in _friends) {
      allUserIds.add(friend.user1Id);
      allUserIds.add(friend.user2Id);
    }

    for (var request in _friendRequests) {
      allUserIds.add(request.requestId);
      allUserIds.add(request.targetId);
    }

    for (var block in _blockUsers) {
      allUserIds.add(block.blockedUserId);
    }

    for (var userId in allUserIds) {
      if (!_userInfoCache.containsKey(userId)) {
        try {
          final userInfo = await _repository.fetchAUser(userId);
          if (userInfo != null) {
            _userInfoCache[userId] = userInfo;
          }
        } catch (e) {
          debugPrint("유저 정보 로드 실패 (userId: $userId): $e");
        }
      }
    }

    notifyListeners();
  }

  Future<UserInfo?> getUserInfo(int userId) async {
    if (_userInfoCache.containsKey(userId)) {
      return _userInfoCache[userId];
    }

    try {
      final userInfo = await _repository.fetchAUser(userId);
      if (userInfo != null) {
        _userInfoCache[userId] = userInfo;
        notifyListeners();
      }
      return userInfo;
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchFriends(int startIndex, int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    _friends = await _repository.fetchFriends(startIndex, loginUserId);

    await _loadAllUserInfos();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh(int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    currentPage = 1;

    _friends = await _repository.fetchFriends(currentPage, loginUserId);
    _friendRequests = await _repository.fetchFriendRequests(
      currentPage,
      loginUserId,
    );
    _blockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage,
      loginUserId,
    );

    await _loadAllUserInfos();

    _isLoading = false;
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
      await _loadAllUserInfos();
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteFriend(int friendId, int loginUserId) async {
    await _repository.deleteFriend(friendId);
    await fetchFriends(currentPage, loginUserId);
    notifyListeners();
  }

  Future<void> fetchFriendRequests(int startIndex, int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    _friendRequests = await _repository.fetchFriendRequests(
      startIndex,
      loginUserId,
    );

    await _loadAllUserInfos();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreFriendRequests(int loginUserId) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedFriendRequests = await _repository.fetchFriendRequests(
      currentPage,
      loginUserId,
    );

    if (fetchedFriendRequests.isNotEmpty) {
      _friendRequests.addAll(fetchedFriendRequests);
      await _loadAllUserInfos();
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAUser(int userId) async {
    _certainUser = await _repository.fetchAUser(userId);
    notifyListeners();
  }

  Future<void> checkIfExist(String nickname) async {
    _isExist = await _repository.checkIfExist(nickname);
    notifyListeners();
  }

  Future<void> fetchAUserByName(String nickname) async {
    _certainUser = await _repository.fetchAUserByName(nickname);
    notifyListeners();
  }

  Future<bool> checkIfFriend(int loginUserId, int friendUserId) async {
    _isFriend = await _repository.checkIfFriend(loginUserId, friendUserId);
    notifyListeners();
    return _isFriend;
  }

  Future<void> makeARequest(int loginUserId, int targetUserId) async {
    await _repository.makeARequest(loginUserId, targetUserId);
    notifyListeners();
  }

  Future<void> deleteARequest(int loginUserId, int targetUserId) async {
    await _repository.deleteARequest(loginUserId, targetUserId);
    notifyListeners();
  }

  Future<void> answerARequest(int requestId, int loginUserId) async {
    await _repository.answerARequest(requestId);
    await fetchFriendRequests(currentPage, loginUserId);
  }

  Future<void> acceptARequest(
    int requestId,
    int loginUserId,
    int requesterId,
  ) async {
    await _repository.acceptARequest(requestId, loginUserId, requesterId);
    await fetchFriends(currentPage, loginUserId);
    await fetchFriendRequests(currentPage, loginUserId);
  }

  Future<void> editNickname(int loginUserId, String nickname) async {
    await _repository.editNickname(loginUserId, nickname);
    await fetchAUser(loginUserId);
  }

  Future<void> fetchBlockUsersWithPager(
    int currentPage,
    int loginUserId,
  ) async {
    _blockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage,
      loginUserId,
    );

    await _loadAllUserInfos();

    notifyListeners();
  }

  Future<void> fetchMoreBlockUsersWithPager(int loginUserId) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedBlockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage,
      loginUserId,
    );

    if (fetchedBlockUsers.isNotEmpty) {
      _blockUsers.addAll(fetchedBlockUsers);
      await _loadAllUserInfos();
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    notifyListeners();
  }

  @override
  void dispose() {
    AuthManager.shared.removeListener(_onAuthChanged);
    scrollController.dispose();
    super.dispose();
  }
}
