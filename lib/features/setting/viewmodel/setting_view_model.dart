// setting_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/user_model.dart';

import '../data/setting_repository.dart';

class SettingViewModel extends ChangeNotifier {
  final SettingRepository _repository = SettingRepository();

  // 로그인 유저 정보
  UserInfo? _loginUser;
  UserInfo? get loginUser => _loginUser;

  // 유저의 알림 세팅
  AlarmSetting? _alarmSetting;
  AlarmSetting? get alarmSetting => _alarmSetting;

  // 로그인 유저 아이디
  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  // 닉네임 존재 여부
  bool _isExist = false;
  bool get isExist => _isExist;

  // 초기 설정 여부
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 로딩중
  late bool _isLoading = false;
  bool get isLoading => _isLoading;

  SettingViewModel() {
    AuthManager.shared.addListener(_onAuthChanged);
  }

  // 로그인 관련
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
      notifyListeners();
    } else if (userId != null && _isInitialized) {
      print("초기화 완료");
    }
  }

  // 초기 설정
  Future<void> initialize(int loginUserId) async {
    _loginUserId = loginUserId;
  }

  // 로그인 유저 정보 불러오기
  Future<void> fetchUserInfo(int userId) async {
    _loginUser = await _repository.fetchAUser(userId);
    notifyListeners();
  }

  // 해당 닉네임이 존재하는지(중복방지)
  Future<bool> checkIfExist(String nickname, int currentUserId) async {
    if (_loginUser?.nickname == nickname) {
      _isExist = false;
      notifyListeners();
      return false;
    }

    _isExist = await _repository.checkIfExist(
      nickname,
      excludeUserId: currentUserId,
    );
    notifyListeners();
    return _isExist;
  }

  // 닉네임 변경하기
  Future<bool> editNickname(int loginUserId, String nickname) async {
    _isLoading = true;
    notifyListeners();

    final updatedUser = await _repository.editNickname(loginUserId, nickname);

    if (updatedUser != null) {
      _loginUser = updatedUser;
      AuthManager.shared.updateUserInfo(updatedUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 푸시 알람 설정 불러오기
  Future<void> fetchAlarmSetting(int loginId) async {
    _alarmSetting = await _repository.fetchAlarmSetting(loginId: loginId);
    notifyListeners();
  }

  // 푸시 알람 설정 업데이트
  Future<void> updateAlarmSetting({
    required int userId,
    required AlarmSetting newSetting,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateAlarmSetting(userId, newSetting);
      _alarmSetting = newSetting;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // API 중복 호출 방지
  @override
  void dispose() {
    AuthManager.shared.removeListener(_onAuthChanged);
    super.dispose();
  }
}
