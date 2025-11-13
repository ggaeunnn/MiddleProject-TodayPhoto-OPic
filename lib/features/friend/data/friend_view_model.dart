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
    // isLoading을 true로 설정 (리스트는 비우지 않음)
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    currentPage = 1;
    _friends = await _repository.fetchFriends(currentPage, loginUserId);
    _friendRequests = await _repository.fetchFriendRequests(
      currentPage,
      loginUserId,
    );
    _blockUsers = (await _repository.fetchBlockedUserWithPager(
      currentPage,
      loginUserId,
    ));

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
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
    debugPrint("FriendViewmodel fetchedFriends 호출됨");
  }

  // 친구 삭제하기
  Future<void> deleteFriend(int friendId, int loginUserId) async {
    await _repository.deleteFriend(friendId);
    await fetchFriends(currentPage, loginUserId);
    notifyListeners();
  }

  // 친구 요청 불러오기
  Future<void> fetchFriendRequests(int startIndex, int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    _friendRequests = await _repository.fetchFriendRequests(
      startIndex,
      loginUserId,
    );
    _isLoading = false;

    //구독자(?)에게 알림보내기
    notifyListeners();
    debugPrint("FriendViewModel _initFriends 호출됨");
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
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
    debugPrint("FriendViewmodel fetchedFriends 호출됨");
  }

  // 특정 유저 정보 가져오기
  Future<void> fetchAUser(int userId) async {
    _certainUser = await _repository.fetchAUser(userId);
    notifyListeners();
    debugPrint("certainUser : $_certainUser");
  }

  // 특정 유저 유무 확인하기
  Future<void> checkIfExist(String nickname) async {
    _isExist = await _repository.checkIfExist(nickname);
    notifyListeners();
  }

  // 특정 유저 정보 가져오기(닉네임으로)
  Future<void> fetchAUserByName(String nickname) async {
    _certainUser = await _repository.fetchAUserByName(nickname);
    notifyListeners();
  }

  // 친구 관계 확인하기
  Future<bool> checkIfFriend(int loginUserId, int friendUserId) async {
    _isFriend = await _repository.checkIfFriend(loginUserId, friendUserId);
    notifyListeners();
    return _isFriend;
  }

  // 친구 요청 하기
  Future<void> makeARequest(int loginUserId, int targetUserId) async {
    await _repository.makeARequest(loginUserId, targetUserId);
    notifyListeners();
  }

  // 요청 취소하기
  Future<void> deleteARequest(int loginUserId, int targetUserId) async {
    await _repository.deleteARequest(loginUserId, targetUserId);
    notifyListeners();
  }

  // 친구 요청 응답하기
  Future<void> answerARequest(int requestId, int loginUserId) async {
    await _repository.answerARequest(requestId);
    await fetchFriendRequests(currentPage, loginUserId);
  }

  // 친구 요청 수락 - 친구 추가 하기
  Future<void> acceptARequest(
    int requestId,
    int loginUserId,
    int requesterId,
  ) async {
    await _repository.acceptARequest(requestId, loginUserId, requesterId);
    await fetchFriends(currentPage, loginUserId);
    await fetchFriendRequests(currentPage, loginUserId);
  }

  // 닉네임 수정하기
  Future<void> editNickname(int loginUserId, String nickname) async {
    await _repository.editNickname(loginUserId, nickname);
    await fetchAUser(loginUserId);
  }

  // 차단 사용자 불러오기
  Future<void> fetchBlockUsersWithPager(
    int currentPage,
    int loginUserId,
  ) async {
    _blockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage,
      loginUserId,
    );
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
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
    debugPrint("FriendViewmodel fetchedFriends 호출됨");
  }

  // 차단 해제하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    notifyListeners();
  }
}
