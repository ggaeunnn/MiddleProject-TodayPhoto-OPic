import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/block_model.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/core/models/friend_request_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/friend/data/friend_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendRepository _repository = GetIt.instance<FriendRepository>();

  // 탭별 페이지 관리
  int _friendsPage = 1;
  int _requestsPage = 1;
  int _blocksPage = 1;

  // 전체 개수 관리
  int _friendsCount = 0;
  int _requestsCount = 0;
  int _blocksCount = 0;
  int get friendsCount => _friendsCount;
  int get requestsCount => _requestsCount;
  int get blocksCount => _blocksCount;

  // 탭별 스크롤 컨트롤러
  final ScrollController friendsScrollController = ScrollController();
  final ScrollController requestsScrollController = ScrollController();
  final ScrollController blocksScrollController = ScrollController();

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

  // Supabase 실시간 구독
  RealtimeChannel? _friendsChannel;
  RealtimeChannel? _requestsChannel;
  RealtimeChannel? _blocksChannel;

  FriendViewModel() {
    _initializeScrollListeners();
    AuthManager.shared.addListener(_onAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _checkCurrentAuth();
      }
    });
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
      _userInfoCache = {};
      _friendsCount = 0;
      _requestsCount = 0;
      _blocksCount = 0;
      _disposeRealtimeChannels();
      notifyListeners();
    } else if (userId != null && _isInitialized) {
      debugPrint("초기화 완료");
    }
  }

  // 실시간 구독 설정
  void _setupRealtimeSubscriptions(int loginUserId) {
    final supabase = Supabase.instance.client;

    // 친구 목록 실시간 업데이트 (필터 없이 콜백에서 처리)
    _friendsChannel = supabase
        .channel('friends_changes_$loginUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'friends',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty &&
                (newRecord['user1_id'] == loginUserId ||
                    newRecord['user2_id'] == loginUserId)) {
              _handleFriendsChange(loginUserId);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'friends',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty &&
                (newRecord['user1_id'] == loginUserId ||
                    newRecord['user2_id'] == loginUserId)) {
              _handleFriendsChange(loginUserId);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'friends',
          callback: (payload) {
            _handleFriendsChange(loginUserId);
          },
        )
        .subscribe();

    // 친구 요청 실시간 업데이트
    _requestsChannel = supabase
        .channel('friend_request_changes_$loginUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'friend_request',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'target_id',
            value: loginUserId,
          ),
          callback: (payload) {
            _handleFriendRequestsChange(loginUserId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'friend_request',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'target_id',
            value: loginUserId,
          ),
          callback: (payload) {
            _handleFriendRequestsChange(loginUserId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'friend_request',
          callback: (payload) {
            _handleFriendRequestsChange(loginUserId);
          },
        )
        .subscribe();

    // 차단 목록 실시간 업데이트
    _blocksChannel = supabase
        .channel('block_$loginUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'block',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: loginUserId,
          ),
          callback: (payload) {
            _handleBlocksChange(loginUserId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'block',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: loginUserId,
          ),
          callback: (payload) {
            _handleBlocksChange(loginUserId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'block',
          callback: (payload) {
            _handleBlocksChange(loginUserId);
          },
        )
        .subscribe();
  }

  // 친구 목록 변경 처리
  Future<void> _handleFriendsChange(int loginUserId) async {
    await Future.wait([
      _fetchFriends(_friendsPage, loginUserId),
      _fetchFriendsCount(loginUserId),
    ]);
    await _loadAllUserInfos();
    notifyListeners();
  }

  // 친구 요청 변경 처리
  Future<void> _handleFriendRequestsChange(int loginUserId) async {
    await Future.wait([
      _fetchFriendRequests(_requestsPage, loginUserId),
      _fetchRequestsCount(loginUserId),
    ]);
    await _loadAllUserInfos();
    notifyListeners();
  }

  // 차단 목록 변경 처리
  Future<void> _handleBlocksChange(int loginUserId) async {
    await Future.wait([
      _fetchBlockUsers(_blocksPage, loginUserId),
      _fetchBlocksCount(loginUserId),
    ]);
    await _loadAllUserInfos();
    notifyListeners();
  }

  // 실시간 구독 해제
  void _disposeRealtimeChannels() {
    _friendsChannel?.unsubscribe();
    _requestsChannel?.unsubscribe();
    _blocksChannel?.unsubscribe();
    _friendsChannel = null;
    _requestsChannel = null;
    _blocksChannel = null;
  }

  //탭별 스크롤 리스너 설정
  void _initializeScrollListeners() {
    Timer? debounce;

    // 친구 목록
    friendsScrollController.addListener(() {
      _handleScrollEvent(
        friendsScrollController,
        () => fetchMoreFriends(_loginUserId!),
        debounce,
      );
    });

    // 친구 요청 목록
    requestsScrollController.addListener(() {
      _handleScrollEvent(
        requestsScrollController,
        () => fetchMoreFriendRequests(_loginUserId!),
        debounce,
      );
    });

    // 차단 목록
    blocksScrollController.addListener(() {
      _handleScrollEvent(
        blocksScrollController,
        () => fetchMoreBlockUsersWithPager(_loginUserId!),
        debounce,
      );
    });
  }

  // 공통 스크롤 이벤트 처리
  void _handleScrollEvent(
    ScrollController controller,
    VoidCallback onLoadMore,
    Timer? debounce,
  ) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 300), () {
      final double offset = controller.offset;

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

    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 100) {
      onLoadMore();
    }
  }

  // 탭별 ScrollController 반환
  ScrollController get currentScrollController {
    return switch (_tabNumber) {
      0 => friendsScrollController,
      1 => requestsScrollController,
      2 => blocksScrollController,
      _ => friendsScrollController,
    };
  }

  void moveScrollUp() {
    currentScrollController.animateTo(
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
    _friendsPage = 1;
    _requestsPage = 1;
    _blocksPage = 1;

    await Future.wait([
      _fetchFriends(_friendsPage, loginUserId),
      _fetchFriendRequests(_requestsPage, loginUserId),
      _fetchBlockUsers(_blocksPage, loginUserId),
      _fetchFriendsCount(loginUserId),
      _fetchRequestsCount(loginUserId),
      _fetchBlocksCount(loginUserId),
    ]);

    await _loadAllUserInfos();
    _setupRealtimeSubscriptions(loginUserId);
    notifyListeners();
  }

  // 친구 목록 불러오기
  Future<void> _fetchFriends(int page, int loginUserId) async {
    _friends = await _repository.fetchFriendsWithPager(
      currentPage: page,
      loginId: loginUserId,
    );
  }

  // 친구 목록 전체 개수 불러오기
  Future<void> _fetchFriendsCount(int loginUserId) async {
    _friendsCount = await _repository.getFriendsCount(loginId: loginUserId);
    debugPrint("FriendsCount: $_friendsCount");
  }

  // 친구 요청 목록 불러오기
  Future<void> _fetchFriendRequests(int page, int loginUserId) async {
    _friendRequests = await _repository.fetchFriendRequestsWithPager(
      currentPage: page,
      loginId: loginUserId,
    );
  }

  // 친구 요청 목록 전체 개수 불러오기
  Future<void> _fetchRequestsCount(int loginUserId) async {
    _requestsCount = await _repository.getRequestsCount(loginId: loginUserId);
    debugPrint("RequestsCount: $_requestsCount");
  }

  // 차단 목록 불러오기
  Future<void> _fetchBlockUsers(int page, int loginUserId) async {
    _blockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage: page,
      loginId: loginUserId,
    );
  }

  // 차단 목록 전체 개수 불러오기
  Future<void> _fetchBlocksCount(int loginUserId) async {
    _blocksCount = await _repository.getBlocksCount(loginId: loginUserId);
    debugPrint("BlocksCount: $_blocksCount");
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
    _friendsPage = 1;
    _requestsPage = 1;
    _blocksPage = 1;

    await Future.wait([
      _fetchFriends(_friendsPage, loginUserId),
      _fetchFriendRequests(_requestsPage, loginUserId),
      _fetchBlockUsers(_blocksPage, loginUserId),
      _fetchFriendsCount(loginUserId),
      _fetchRequestsCount(loginUserId),
      _fetchBlocksCount(loginUserId),
    ]);

    await _loadAllUserInfos();

    _isLoading = false;
    notifyListeners();
  }

  // 친구목록 불러오기(다음 페이지)
  Future<void> fetchMoreFriends(int loginUser) async {
    if (_isLoading) return;

    _isLoading = true;
    _friendsPage += 1;
    final fetchedFriends = await _repository.fetchFriendsWithPager(
      currentPage: _friendsPage,
      loginId: loginUser,
    );

    if (fetchedFriends.isNotEmpty) {
      _friends.addAll(fetchedFriends);
      await _loadAllUserInfos();
    } else {
      _friendsPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
  }

  // 친구 삭제하기
  Future<void> deleteFriend(int friendId, int loginUserId) async {
    await _repository.deleteFriend(friendId);
    await _fetchFriendsCount(loginUserId);
    notifyListeners();
  }

  // 친구 요청 불러오기 (다음 페이지)
  Future<void> fetchMoreFriendRequests(int loginUserId) async {
    if (_isLoading) return;

    _isLoading = true;
    _requestsPage += 1;
    final fetchedFriendRequests = await _repository
        .fetchFriendRequestsWithPager(
          currentPage: _requestsPage,
          loginId: loginUserId,
        );

    if (fetchedFriendRequests.isNotEmpty) {
      _friendRequests.addAll(fetchedFriendRequests);
      await _loadAllUserInfos();
    } else {
      _requestsPage -= 1;
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
    await _fetchRequestsCount(loginUserId);
    notifyListeners();
  }

  // 친구 요청 응답하기(수락)
  Future<void> acceptARequest(
    int requestId,
    int loginUserId,
    int requesterId,
  ) async {
    await _repository.acceptARequest(requestId, loginUserId, requesterId);
    await _repository.answerARequest(requestId);
    await Future.wait([
      _fetchFriendsCount(loginUserId),
      _fetchRequestsCount(loginUserId),
    ]);
    notifyListeners();
  }

  // 차단 유저 목록 불러오기(다음페이지)
  Future<void> fetchMoreBlockUsersWithPager(int loginUserId) async {
    if (_isLoading) return;

    _isLoading = true;
    _blocksPage += 1;
    final fetchedBlockUsers = await _repository.fetchBlockedUserWithPager(
      currentPage: _blocksPage,
      loginId: loginUserId,
    );

    if (fetchedBlockUsers.isNotEmpty) {
      _blockUsers.addAll(fetchedBlockUsers);
      await _loadAllUserInfos();
    } else {
      _blocksPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
  }

  // 차단하기
  Future<void> blockUser(int loginUserId, int targetUserId) async {
    await _repository.blockUser(loginUserId, targetUserId);
    await _fetchBlocksCount(loginUserId);
    notifyListeners();
  }

  // 차단 해제하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    await _fetchBlocksCount(loginUserId);
    notifyListeners();
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    AuthManager.shared.removeListener(_onAuthChanged);
    friendsScrollController.dispose();
    requestsScrollController.dispose();
    blocksScrollController.dispose();
    _disposeRealtimeChannels();
    super.dispose();
  }
}
