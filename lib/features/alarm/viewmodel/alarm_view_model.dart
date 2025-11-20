import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:opicproject/core/models/alarm_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/alarm_repository.dart';

class AlarmViewModel extends ChangeNotifier {
  final AlarmRepository _repository = GetIt.instance<AlarmRepository>();

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

  // 마지막 페이지 여부
  bool _isLastPage = false;
  bool get isLastPage => _isLastPage;

  // 안 읽은 알람 수
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  bool get hasUnreadAlarm => _unreadCount > 0;

  // Realtime 구독
  RealtimeChannel? _alarmChannel;

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

      if (_isScrollNearBottom() && !_isLoading && !_isLastPage) {
        debugPrint('📜 Scroll Near Bottom - Loading more alarms...');
        if (_loginUserId != null) {
          fetchMoreAlarms(_loginUserId!);
        }
      }
    });
  }

  bool _isScrollNearBottom() {
    if (!scrollController.hasClients) return false;

    final position = scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // 하단 네비게이션바 높이(약 80px) + 여유 공간(200px) = 280px
    const bottomThreshold = 280.0;

    return currentScroll >= (maxScroll - bottomThreshold);
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

  // Realtime 구독 시작
  void _startRealtimeSubscription(int loginUserId) {
    // 기존 구독이 있으면 해제
    if (_alarmChannel != null) {
      _repository.unsubscribeFromAlarms(_alarmChannel!);
    }

    _alarmChannel = _repository.subscribeToAlarms(
      loginUserId: loginUserId,
      onInsert: _handleAlarmInsert,
      onUpdate: _handleAlarmUpdate,
      onDelete: _handleAlarmDelete,
    );
  }

  // 새 알람 추가 처리
  void _handleAlarmInsert(Alarm newAlarm) {
    // is_checked가 false인 경우만 리스트에 추가
    if (!newAlarm.isChecked) {
      // 중복 체크
      final exists = _alarms.any((alarm) => alarm.id == newAlarm.id);
      if (!exists) {
        _alarms = [newAlarm, ..._alarms];
        _updateUnreadCount();
        notifyListeners();
      }
    }
  }

  // 알람 업데이트 처리
  void _handleAlarmUpdate(Alarm updatedAlarm) {
    final index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);

    if (updatedAlarm.isChecked) {
      // 읽음 처리된 경우 리스트에서 제거
      if (index != -1) {
        _alarms = _alarms
            .where((alarm) => alarm.id != updatedAlarm.id)
            .toList();
        _updateUnreadCount();
        notifyListeners();
      }
    } else {
      // 아직 안 읽은 경우 업데이트
      if (index != -1) {
        _alarms = [
          ..._alarms.sublist(0, index),
          updatedAlarm,
          ..._alarms.sublist(index + 1),
        ];
        _updateUnreadCount();
        notifyListeners();
      }
    }
  }

  // 알람 삭제 처리
  void _handleAlarmDelete(int alarmId) {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index != -1) {
      _alarms = _alarms.where((alarm) => alarm.id != alarmId).toList();
      _updateUnreadCount();
      notifyListeners();
    }
  }

  // 새로고침
  Future<void> refresh(int loginUserId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    currentPage = 1;
    _isLastPage = false;

    final fetchedAlarms = await _repository.fetchAlarms(
      currentPage: currentPage,
      loginId: loginUserId,
    );

    _alarms = List.from(fetchedAlarms);
    if (fetchedAlarms.length < 10) {
      _isLastPage = true;
    }

    _updateUnreadCount();

    _isLoading = false;
    notifyListeners();
  }

  // 알람리스트 가져오기
  Future<void> fetchAlarms(int startIndex, int loginUserId) async {
    _isLoading = true;
    _loginUserId = loginUserId;
    currentPage = startIndex;
    _isLastPage = false;
    notifyListeners();

    final fetchedAlarms = await _repository.fetchAlarms(
      currentPage: startIndex,
      loginId: loginUserId,
    );

    _alarms = List.from(fetchedAlarms);

    if (fetchedAlarms.length < 20) {
      _isLastPage = true;
    }

    _updateUnreadCount();

    _startRealtimeSubscription(loginUserId);

    _isLoading = false;
    notifyListeners();
  }

  // 알람 불러오기(다음페이지)
  Future<void> fetchMoreAlarms(int loginUser) async {
    if (_isLoading || _isLastPage) return;

    _isLoading = true;
    currentPage += 1;

    try {
      final fetchedAlarms = await _repository.fetchAlarms(
        currentPage: currentPage,
        loginId: loginUser,
      );

      if (fetchedAlarms.isNotEmpty) {
        _alarms = [..._alarms, ...fetchedAlarms];

        if (fetchedAlarms.length < 20) {
          _isLastPage = true;
        }

        _updateUnreadCount();
      } else {
        currentPage -= 1;
        _isLastPage = true;
      }
    } catch (e) {
      currentPage -= 1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 알림의 정보 가져오기
  Future<void> fetchAnAlarm(int alarmId) async {
    _certainAlarm = await _repository.fetchAnAlarm(alarmId);

    notifyListeners();
  }

  // 알림 확인 처리하기
  Future<void> checkAlarm(int loginUserId, int alarmId) async {
    await _repository.checkAlarm(alarmId);

    _alarms = _alarms.where((alarm) => alarm.id != alarmId).toList();

    _updateUnreadCount();
    notifyListeners();
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    scrollController.dispose();
    if (_alarmChannel != null) {
      _repository.unsubscribeFromAlarms(_alarmChannel!);
    }
    super.dispose();
  }
}
