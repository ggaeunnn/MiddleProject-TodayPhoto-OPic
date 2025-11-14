import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opicproject/core/models/alarm_model.dart';

import 'alarm_repository.dart';

class AlarmViewModel extends ChangeNotifier {
  final AlarmRepository _repository = AlarmRepository();

  int currentPage = 1;
  ScrollController scrollController = ScrollController();

  List<Alarm> _alarms = [];
  List<Alarm> get alarms => _alarms;

  bool shouldShowScrollUpButton = false;

  Alarm? _certainAlarm;
  Alarm? get certainAlarm => _certainAlarm;

  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AlarmViewModel() {
    _initializeScrollListener();
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
        if (_loginUserId != null) {
          fetchMoreAlarms(_loginUserId!);
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

  // 리포지토리에서 데이터 가져오는데 이제 시작하자마자 가져오기
  Future<void> fetchAlarms(int startIndex, int loginUserId) async {
    _isLoading = true;
    _loginUserId = loginUserId;
    currentPage = startIndex;
    notifyListeners();

    _alarms = await _repository.fetchAlarms(startIndex, loginUserId);
    _isLoading = false;

    //구독자(?)에게 알림보내기
    notifyListeners();
    debugPrint("FriendViewModel _initFriends 호출됨");
  }

  Future<void> refresh(int loginUserId) async {
    // isLoading을 true로 설정 (리스트는 비우지 않음)
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    currentPage = 1;
    _alarms = await _repository.fetchAlarms(currentPage, loginUserId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreAlarms(int loginUser) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedAlarms = await _repository.fetchAlarms(currentPage, loginUser);

    if (fetchedAlarms.isNotEmpty) {
      _alarms.addAll(fetchedAlarms);
    } else {
      currentPage -= 1;
    }
    _isLoading = false;
    notifyListeners();
    debugPrint("AlarmViewmodel fetchedAlarms 호출됨");
  }

  Future<void> fetchAnAlarm(int alarmId) async {
    _certainAlarm = await _repository.fetchAnAlarm(alarmId);
  }

  Future<void> checkAlarm(int loginUserId, int alarmId) async {
    await _repository.checkAlarm(alarmId);
    await refresh(loginUserId);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
