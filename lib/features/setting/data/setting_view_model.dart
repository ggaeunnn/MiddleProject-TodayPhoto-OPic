import 'package:flutter/foundation.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/user_model.dart';

import 'setting_repository.dart';

class SettingViewModel extends ChangeNotifier {
  final SettingRepository _repository = SettingRepository();

  UserInfo? _loginUser;
  UserInfo? get loginUser => _loginUser;

  AlarmSetting? _alarmSetting;
  AlarmSetting? get alarmSetting => _alarmSetting;

  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  bool _isExist = false;
  bool get isExist => _isExist;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  late bool _isLoading = false;
  bool get isLoading => _isLoading;

  // AuthManager 상태 구독
  SettingViewModel() {
    AuthManager.shared.addListener(_onAuthChanged);
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
      notifyListeners();
    } else if (userId != null && _isInitialized) {
      print("초기화 완료");
    }

    debugPrint("userId: $userId");
  }

  Future<void> initialize(int loginUserId) async {
    _loginUserId = loginUserId;
  }

  Future<void> fetchUserInfo(int userId) async {
    _loginUser = await _repository.fetchAUser(userId);
    notifyListeners();
  }

  Future<void> checkIfExist(String nickname) async {
    _isExist = await _repository.checkIfExist(nickname);
    notifyListeners();
  }

  Future<void> editNickname(int loginUserId, String newNickname) async {
    await _repository.editNickname(loginUserId, newNickname);
    await fetchUserInfo(loginUserId);
  }

  Future<void> fetchAlarmSetting(int loginId) async {
    _alarmSetting = await _repository.fetchAlarmSetting(loginId);
    notifyListeners();
  }

  // 알람 설정 업데이트 추가
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

  @override
  void dispose() {
    AuthManager.shared.removeListener(_onAuthChanged);
    super.dispose();
  }
}
