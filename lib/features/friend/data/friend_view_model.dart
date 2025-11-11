import 'dart:async';

import 'package:flutter/cupertino.dart';
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

  FriendViewModel(BuildContext context, int loginUserId) {
    fetchFriends(1, loginUserId);

    Timer? _debounce;

    // 바닥 감지
    scrollController.addListener(() async {
      // scroll 일어나면 기존 타이머 취소
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 300), () {
        final double offset = scrollController.offset;

        debugPrint('scrollController.offset: ${offset}');

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
        fetchMoreFriends(loginUserId);
      }
    });
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
    _friends = await _repository.fetchFriends(1, loginUserId);

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
    _friends = await this._repository.fetchFriends(currentPage, loginUserId);
    notifyListeners();
  }

  Future<void> fetchMoreFriends(int loginUser) async {
    currentPage += 1;
    dynamic fetchedFriends = await this._repository.fetchFriends(
      currentPage,
      loginUser,
    );
    _friends.addAll(fetchedFriends);
    notifyListeners();
    debugPrint("FriendViewmodel fetchedFriends 호출됨");
  }

  Future<void> deleteFriend(int friendId) async {
    await this._repository.deleteFriend(friendId);

    final removedCount = _friends.length;
    _friends.removeWhere((friend) => friend.id == friendId);

    notifyListeners();
    debugPrint("FriendViewmodel deleteFriend 호출");
  }

  int getOtherUserId(Friend friend, int myUserId) {
    return friend.user1Id == myUserId ? friend.user2Id : friend.user1Id;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
