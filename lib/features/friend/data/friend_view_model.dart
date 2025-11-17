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
  bool shouldShowScrollUpButton = false;

  // 친구 목록
  List<Friend> _friends = [];
  List<Friend> get friends => _friends;

  // 친구 요청 목록
  List<FriendRequest> _friendRequests = [];
  List<FriendRequest> get friendRequests => _friendRequests;

  // 차단 유저 목록
  List<BlockUser> _blockUsers = [];
  List<BlockUser> get blockUsers => _blockUsers;

  // 사용자 정보 (캐시)
  Map<int, UserInfo> _userInfoCache = {};
  Map<int, UserInfo> get userInfoCache => _userInfoCache;

  // 특정 사용자 정보
  UserInfo? _certainUser;
  UserInfo? get certainUser => _certainUser;

  // 로그인 유저 아이디
  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  // 해당 닉네임 사용자 존재 여부
  bool _isExist = false;
  bool get isExist => _isExist;

  // 친구 여부
  bool _isFriend = false;
  bool get isFriend => _isFriend;

  // 친구 <-> 친구요청 <-> 차단 화면 변경 탭 번호
  int _tabNumber = 0;
  int get tabNumber => _tabNumber;

  // 초기설정 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 로딩중
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FriendViewModel() {
    AuthManager.shared.addListener(_onAuthChanged);
    _checkCurrentAuth();
    _initializeScrollListener();
  }

  // 로그인 정보 변경 확인
  void _onAuthChanged() {
    _checkCurrentAuth();
  }

  // 로그인 확인
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
  }

  //스크롤 관련
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

  void moveScrollUp() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  // 친구 <-> 친구 요청 <-> 차단 탭 변경
  void changeTab(int tab) {
    _tabNumber = tab;
    notifyListeners();
  }

  // 초기 설정
  Future<void> initialize(int loginUserId) async {
    _loginUserId = loginUserId;
    currentPage = 1;

    await Future.wait([
      _fetchFriends(currentPage, loginUserId),
      _fetchFriendRequests(currentPage, loginUserId),
      _fetchBlockUsers(currentPage, loginUserId),
    ]);

    await _loadAllUserInfos();

    notifyListeners();
  }

  // 친구 목록 불러오기
  Future<void> _fetchFriends(int page, int loginUserId) async {
    _friends = await _repository.fetchFriends(
      currentPage: page,
      loginId: loginUserId,
    );
  }

  // 친구 요청 목록 불러오기
  Future<void> _fetchFriendRequests(int page, int loginUserId) async {
    _friendRequests = await _repository.fetchFriendRequests(
      currentPage: page,
      loginId: loginUserId,
    );
  }

  // 차단 목록 불러오기
  Future<void> _fetchBlockUsers(int page, int loginUserId) async {
    _blockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage: page,
      loginId: loginUserId,
    );
  }

  // 친구, 친구요청, 차단 정보 한번에 불러오기
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

    final futures = allUserIds
        .where((userId) => !_userInfoCache.containsKey(userId))
        .map((userId) async {
          final userInfo = await _repository.fetchAUser(userId);
          if (userInfo != null) {
            _userInfoCache[userId] = userInfo;
          }
        });

    await Future.wait(futures);
  }

  // 아이디로 유저 정보 얻기
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

  // 새로고침
  Future<void> refresh(int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    currentPage = 1;

    await Future.wait([
      _fetchFriends(currentPage, loginUserId),
      _fetchFriendRequests(currentPage, loginUserId),
      _fetchBlockUsers(currentPage, loginUserId),
    ]);

    await _loadAllUserInfos();

    _isLoading = false;
    notifyListeners();
  }

  // 친구 목록 불러오기
  Future<void> fetchFriends(int startIndex, int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    await _fetchFriends(startIndex, loginUserId);
    await _loadAllUserInfos();

    _isLoading = false;
    notifyListeners();
  }

  // 친구목록 불러오기(다음 페이지)
  Future<void> fetchMoreFriends(int loginUser) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedFriends = await _repository.fetchFriends(
      currentPage: currentPage,
      loginId: loginUser,
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

  // 친구 삭제하기
  Future<void> deleteFriend(int friendId, int loginUserId) async {
    await _repository.deleteFriend(friendId);
    _friends.removeWhere((friend) => friend.id == friendId);
    notifyListeners();
  }

  // 친구 요청 불러오기
  Future<void> fetchFriendRequests(int startIndex, int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    await _fetchFriendRequests(startIndex, loginUserId);
    await _loadAllUserInfos();

    _isLoading = false;
    notifyListeners();
  }

  // 친구 요청 불러오기 (다음 페이지)
  Future<void> fetchMoreFriendRequests(int loginUserId) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedFriendRequests = await _repository.fetchFriendRequests(
      currentPage: currentPage,
      loginId: loginUserId,
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

  // 유저 아이디로 유저 정보 불러오기
  Future<void> fetchAUser(int userId) async {
    _certainUser = await _repository.fetchAUser(userId);
    notifyListeners();
  }

  // 닉네임으로 유저 정보 불러오기
  Future<void> fetchAUserByName(String nickname) async {
    _certainUser = await _repository.fetchAUserByName(nickname);
    notifyListeners();
  }

  // 해당 닉네임을 사용하는 유저가 있는지 여부 확인
  Future<void> checkIfExist(String nickname) async {
    _isExist = await _repository.checkIfExist(nickname);
    notifyListeners();
  }

  // 친구 관계 확인하기
  Future<bool> checkIfFriend(int loginUserId, int friendUserId) async {
    _isFriend = await _repository.checkIfFriend(loginUserId, friendUserId);
    notifyListeners();
    return _isFriend;
  }

  // 친구 요청 보내기
  Future<void> makeARequest(int loginUserId, int targetUserId) async {
    await _repository.makeARequest(loginUserId, targetUserId);
    notifyListeners();
  }

  // 친구 요청 응답하기(거절)
  Future<void> answerARequest(int requestId, int loginUserId) async {
    await _repository.answerARequest(requestId);

    _friendRequests.removeWhere((request) => request.id == requestId);
    notifyListeners();
  }

  // 친구 요청 응답하기(수락)
  Future<void> acceptARequest(
    int requestId,
    int loginUserId,
    int requesterId,
  ) async {
    await _repository.acceptARequest(requestId, loginUserId, requesterId);

    await Future.wait([
      _fetchFriends(currentPage, loginUserId),
      _fetchFriendRequests(currentPage, loginUserId),
    ]);

    notifyListeners();
  }

  // 차단 유저 목록 불러오기
  Future<void> fetchBlockUsersWithPager(
    int currentPage,
    int loginUserId,
  ) async {
    _blockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage: currentPage,
      loginId: loginUserId,
    );

    await _loadAllUserInfos();

    notifyListeners();
  }

  // 차단 유저 목록 불러오기(다음페이지)
  Future<void> fetchMoreBlockUsersWithPager(int loginUserId) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedBlockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage: currentPage,
      loginId: loginUserId,
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

  // 차단 해제하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    _blockUsers.removeWhere((block) => block.blockedUserId == userId);
    notifyListeners();
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    AuthManager.shared.removeListener(_onAuthChanged);
    scrollController.dispose();
    super.dispose();
  }
}
