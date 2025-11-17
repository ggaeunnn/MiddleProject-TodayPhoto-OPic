import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opicproject/core/models/alarm_model.dart';

import 'alarm_repository.dart';

class AlarmViewModel extends ChangeNotifier {
  final AlarmRepository _repository = AlarmRepository();

  AlarmViewModel() {
    _initializeScrollListener();
  }

  int currentPage = 1;
  ScrollController scrollController = ScrollController();
  bool shouldShowScrollUpButton = false;

  // 알람 리스트
  List<Alarm> _alarms = [];
  List<Alarm> get alarms => _alarms;

  // 특정 알람
  Alarm? _certainAlarm;
  Alarm? get certainAlarm => _certainAlarm;

  // 로그인한 유저 정보
  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  // 불러오는 중 여부
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 안 읽은 알람 수
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  bool get hasUnreadAlarm => _unreadCount > 0;

  // 스크롤 관련
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

  // 안읽은 알람 갯수 확인
  void _updateUnreadCount() {
    _unreadCount = _alarms.where((alarm) => !alarm.isChecked).length;
  }

  // 새로고참
  Future<void> refresh(int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    currentPage = 1;
    _alarms = await _repository.fetchAlarms(
      currentPage: currentPage,
      loginId: loginUserId,
    );
    _updateUnreadCount();

    _isLoading = false;
    notifyListeners();
  }

  // 알람리스트 가져오기
  Future<void> fetchAlarms(int startIndex, int loginUserId) async {
    _isLoading = true;
    _loginUserId = loginUserId;
    currentPage = startIndex;
    notifyListeners();

    _alarms = await _repository.fetchAlarms(
      currentPage: startIndex,
      loginId: loginUserId,
    );
    _updateUnreadCount();

    _isLoading = false;
    notifyListeners();
  }

  // 알람 불러오기(다음페이지)
  Future<void> fetchMoreAlarms(int loginUser) async {
    if (_isLoading) return;

    _isLoading = true;
    currentPage += 1;
    final fetchedAlarms = await _repository.fetchAlarms(
      currentPage: currentPage,
      loginId: loginUser,
    );

    if (fetchedAlarms.isNotEmpty) {
      _alarms.addAll(fetchedAlarms);
      _updateUnreadCount();
    } else {
      currentPage -= 1;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 특정 알림의 정보 가져오기
  Future<void> fetchAnAlarm(int alarmId) async {
    _certainAlarm = await _repository.fetchAnAlarm(alarmId);

    notifyListeners();
  }

  // 알림 확인 처리하기
  Future<void> checkAlarm(int loginUserId, int alarmId) async {
    await _repository.checkAlarm(alarmId);

    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index != -1) {
      final oldAlarm = _alarms[index];

      _alarms[index] = Alarm(
        id: oldAlarm.id,
        createdAt: oldAlarm.createdAt,
        userId: oldAlarm.userId,
        alarmType: oldAlarm.alarmType,
        content: oldAlarm.content,
        isChecked: true,
        data: oldAlarm.data,
      );

      _updateUnreadCount();
      notifyListeners();
    }
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
