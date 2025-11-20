// feed_viewmodel.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/data/feed_repository.dart';
import 'package:opicproject/features/feed/data/feed_state.dart';
import 'package:opicproject/features/feed/data/user_relation_state.dart';
import 'package:opicproject/features/feed/manager/pagination_manager.dart';
import 'package:opicproject/features/feed/manager/scroll_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedRepository _repository = GetIt.instance<FeedRepository>();
  late final ScrollManager _scrollManager;
  final PaginationManager _paginationManager = PaginationManager();

  // 스크롤 컨트롤러
  ScrollController scrollController = ScrollController();

  // 상태
  FeedState _state = const FeedState();
  FeedState get state => _state;

  // 관계 상태
  UserRelationState _relationState = const UserRelationState();
  UserRelationState get relationState => _relationState;

  // 피드 게시물 목록
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  // 피드 주인 유저 정보
  UserInfo? _feedUser;
  UserInfo? get feedUser => _feedUser;

  // 현재 피드 주인 유저, 로그인 유저 ID
  int? _currentFeedUserId;
  int? _loginUserId;

  // 마지막 페이지 여부
  bool _isLastPage = false;
  bool get isLastPage => _isLastPage;

  // Supabase Realtime 구독
  RealtimeChannel? _postsChannel;
  RealtimeChannel? _userChannel;

  // Getter
  int get currentPage => _paginationManager.currentPage;
  bool get shouldShowScrollUpButton => _state.shouldShowScrollUpButton;
  bool get isInitialized => _state.isInitialized;
  bool get isLoading => _state.isLoading;
  bool get isStatusChecked => _state.isStatusChecked;
  bool get isBlocked => _relationState.isBlocked;
  bool get isBlockedMe => _relationState.isBlockedMe;
  bool get isRequested => _relationState.isRequested;
  bool get isFriend => _relationState.isFriend;

  FeedViewModel() {
    _initializeScrollManager();
  }

  // 스크롤 관련
  void _initializeScrollManager() {
    _scrollManager = ScrollManager(
      controller: scrollController,
      onScrollToBottom: _handleScrollToBottom,
      onScrollButtonVisibilityChanged: _updateScrollButtonVisibility,
    );
    _scrollManager.initialize();
  }

  void _handleScrollToBottom() {
    if (_currentFeedUserId != null) {
      fetchMorePosts(_currentFeedUserId!);
    }
  }

  void _updateScrollButtonVisibility(bool shouldShow) {
    if (_state.shouldShowScrollUpButton != shouldShow) {
      _updateState(shouldShowScrollUpButton: shouldShow);
    }
  }

  void moveScrollUp() {
    _scrollManager.scrollToTop();
  }

  // 상태 업데이트
  void _updateState({
    bool? isInitialized,
    bool? isLoading,
    bool? isStatusChecked,
    bool? shouldShowScrollUpButton,
  }) {
    _state = FeedState(
      isInitialized: isInitialized ?? _state.isInitialized,
      isLoading: isLoading ?? _state.isLoading,
      isStatusChecked: _state.isStatusChecked,
      shouldShowScrollUpButton:
          shouldShowScrollUpButton ?? _state.shouldShowScrollUpButton,
    );
    notifyListeners();
  }

  void _updateRelationState({
    bool? isBlocked,
    bool? isBlockedMe,
    bool? isRequested,
    bool? isFriend,
  }) {
    _relationState = UserRelationState(
      isBlocked: isBlocked ?? _relationState.isBlocked,
      isBlockedMe: isBlockedMe ?? _relationState.isBlockedMe,
      isRequested: isRequested ?? _relationState.isRequested,
      isFriend: isFriend ?? _relationState.isFriend,
    );
    notifyListeners();
  }

  // Realtime 구독 설정
  void _setupRealtimeSubscription(int feedUserId) {
    final supabase = Supabase.instance.client;

    _postsChannel = supabase
        .channel('posts_changes_$feedUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            _handlePostChanged(feedUserId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: feedUserId,
          ),
          callback: (payload) {
            _handlePostChanged(feedUserId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: feedUserId,
          ),
          callback: (payload) {
            _handlePostChanged(feedUserId);
          },
        )
        .subscribe();

    _userChannel = supabase
        .channel('user_changes_$feedUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'user',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: feedUserId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              _handleUserInfoChanged(newRecord);
            }
          },
        )
        .subscribe();
  }

  // 게시물 삭제 처리
  Future<void> _handlePostChanged(int feedUserId) async {
    await refresh(feedUserId);
    notifyListeners();
  }

  // 유저 정보 처리
  void _handleUserInfoChanged(Map<String, dynamic> newUserData) {
    try {
      final updatedUser = UserInfo.fromJson(newUserData);
      _feedUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating user info: $e');
    }
  }

  // Realtime 구독 해제
  void _disposeRealtimeChannel() {
    _postsChannel?.unsubscribe();
    _userChannel?.unsubscribe();
    _postsChannel = null;
    _userChannel = null;
  }

  // 피드 정보 초기설정 (다른 유저 피드로 이동할 때 이전 유저 정보 남지 않게)
  Future<void> initializeFeed(int feedUserId, int loginUserId) async {
    if (_state.isLoading) return;

    if (_currentFeedUserId == feedUserId && _state.isInitialized) {
      return;
    }

    _resetFeedData(feedUserId, loginUserId);
    _updateState(isLoading: true);

    await _loadInitialData(loginUserId, feedUserId);

    _setupRealtimeSubscription(feedUserId);
    _updateState(isInitialized: true, isLoading: false);
  }

  void _resetFeedData(int feedUserId, int loginUserId) {
    _currentFeedUserId = feedUserId;
    _loginUserId = loginUserId;
    _posts = [];
    _feedUser = null;
    _paginationManager.reset();
    _state = const FeedState();
    _relationState = const UserRelationState();
    _scrollManager.resetLoadingState();
    _isLastPage = false;
    _disposeRealtimeChannel();
  }

  Future<void> _loadInitialData(int loginUserId, int feedUserId) async {
    await Future.wait([
      _fetchAUser(feedUserId),
      _fetchPosts(page: 1, userId: feedUserId),
      _fetchUserRelation(loginUserId, feedUserId),
    ]);
  }

  // 유저 관계 상태 가져오기
  Future<void> _fetchUserRelation(int loginUserId, int feedUserId) async {
    _relationState = await _repository.fetchUserRelation(
      loginUserId,
      feedUserId,
    );
    notifyListeners();
  }

  // 유저 관계 상태 새로고침
  Future<void> refreshUserRelation() async {
    if (_loginUserId == null || _currentFeedUserId == null) return;

    await _fetchUserRelation(_loginUserId!, _currentFeedUserId!);
  }

  Future<void> refresh(int userId) async {
    _updateState(isLoading: true);

    await Future.delayed(Duration(milliseconds: 1000));

    _paginationManager.reset();
    _scrollManager.resetLoadingState();
    _isLastPage = false;

    await Future.wait([
      _fetchPosts(page: 1, userId: userId).then((_) {}),
      if (_loginUserId != null) _fetchUserRelation(_loginUserId!, userId),
    ]);

    _updateState(isLoading: false);
  }

  // 유저와 피드 유저의 관계 확인
  Future<void> checkUserStatus(int loginUserId, int feedUserId) async {
    if (_state.isStatusChecked) return;

    _relationState = await _repository.fetchUserRelation(
      loginUserId,
      feedUserId,
    );

    _updateState(isStatusChecked: true);
  }

  // 피드 게시물 가져오기
  Future<void> _fetchPosts({required int page, required int userId}) async {
    final fetchedPosts = await _repository.fetchPosts(
      currentPage: page,
      userId: userId,
    );

    _posts = fetchedPosts;

    if (fetchedPosts.length < 15) {
      _isLastPage = true;
    }
  }

  // 피드 게시물 가져오기 (다음 페이지)
  Future<void> fetchMorePosts(int userId) async {
    if (_state.isLoading || _isLastPage) return;

    _updateState(isLoading: true);

    _paginationManager.nextPage();
    final fetchedPosts = await _repository.fetchPosts(
      currentPage: currentPage,
      userId: userId,
    );

    if (fetchedPosts.isNotEmpty) {
      _posts.addAll(fetchedPosts);

      if (fetchedPosts.length < 15) {
        _isLastPage = true;
      }
    } else {
      _paginationManager.pastPage();
      _isLastPage = true;
      _onLastPageReached();
    }

    _updateState(isLoading: false);
    _scrollManager.resetLoadingState();
  }

  // 마지막 페이지 도달 콜백 (토스트 표시용)
  VoidCallback? _onLastPageReachedCallback;

  void setOnLastPageReachedCallback(VoidCallback? callback) {
    _onLastPageReachedCallback = callback;
  }

  void _onLastPageReached() {
    _onLastPageReachedCallback?.call();
  }

  // 게시물 삭제 후 UI 업데이트
  Future<void> onPostDeleted(int deletedPostId) async {
    _posts.removeWhere((post) => post.id == deletedPostId);
    notifyListeners();

    if (_currentFeedUserId != null) {
      await refresh(_currentFeedUserId!);
    }
  }

  // 게시물 단순 제거 (API 호출 없이)
  void removePost(int postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  // 아이디로 유저 정보 조회
  Future<void> _fetchAUser(int userId) async {
    _feedUser = await _repository.fetchAUser(userId);
  }

  // 차단하기
  Future<void> blockUser(int loginUserId, int userId) async {
    await _repository.blockUser(loginUserId, userId);
    await refreshUserRelation();
  }

  // 차단해제하기
  Future<void> unblockUser(int loginUserId, int userId) async {
    await _repository.unblockUser(loginUserId, userId);
    await refreshUserRelation();
  }

  // 친구 요청 취소하기
  Future<void> deleteARequest(int loginUserId, int targetUserId) async {
    await _repository.deleteARequest(loginUserId, targetUserId);
    await refreshUserRelation();
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    scrollController.dispose();
    _scrollManager.dispose();
    _disposeRealtimeChannel();
    super.dispose();
  }
}
